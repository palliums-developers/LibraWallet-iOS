//
//  WalletTransactionsTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletTransactionsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(transactionTypeImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(cellSpaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletDetailTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        transactionTypeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(29)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionTypeImageView.snp.right).offset(15)
            make.right.equalTo(amountLabel.snp.left).offset(-5)
            make.centerY.equalTo(contentView).offset(-10)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionTypeImageView.snp.right).offset(15)
            make.centerY.equalTo(contentView).offset(10)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-27)
            make.centerY.equalTo(addressLabel)
        }
        stateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-27)
            make.centerY.equalTo(dateLabel)
        }
        cellSpaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(29)
            make.right.equalTo(contentView.snp.right).offset(-29)
            make.height.equalTo(1)
        }
        //防止用户名字挤压
        //宽度不够时，可以被压缩
        addressLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容
        addressLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        //不可以被压缩，尽量显示完整
    }
    //MARK: - 懒加载对象
    private lazy var transactionTypeImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        return view
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BCBCBC")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = ""
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.lineBreakMode = .byTruncatingMiddle
        label.text = "---"
        return label
    }()
    lazy var cellSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    //MARK: - 设置数据
    var tokenName: String?
    var btcModel: TrezorBTCTransactionDataModel? {
        didSet {
            guard let model = btcModel else {
                return
            }
            dateLabel.text = timestampToDateString(timestamp: model.blockTime ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.transaction_value ?? 0)),
                                                      scale: 8,
                                                      unit: 100000000)
            addressLabel.text = model.vin?.first?.addresses?.first
            if model.transaction_type == 0 {
                // 转账
                stateLabel.textColor = UIColor.init(hex: "E54040")
                stateLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
            } else {
                // 收款
                stateLabel.textColor = UIColor.init(hex: "13B788")
                stateLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
            }
        }
    }
    var violasModel: ViolasDataModel? {
        didSet {
            guard let model = violasModel else {
                return
            }
            dateLabel.text = timestampToDateString(timestamp: model.expiration_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.amount ?? 0)),
                                                      scale: 4,
                                                      unit: 1000000)
            if model.type == 1 {
                // 平台币铸币
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            } else if model.type == 2 {
                // vtoken交易
                if model.transaction_type == 0 {
                    // 转账
                    amountLabel.textColor = UIColor.init(hex: "13B788")
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    addressLabel.text = model.receiver
                } else {
                    // 收款
                    amountLabel.textColor = UIColor.init(hex: "E54040")
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    addressLabel.text = model.sender
                }
            }  else if model.type == 7 {
                // 稳定币铸币
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            } else if model.type == 9 {
                // publish
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "publish_sign")
                addressLabel.text = model.sender
            } else if model.type == 12 {
                // 稳定币交易
                if model.transaction_type == 0 {
                    // 转账
                    amountLabel.textColor = UIColor.init(hex: "13B788")
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    addressLabel.text = model.receiver
                } else {
                    // 收款
                    amountLabel.textColor = UIColor.init(hex: "E54040")
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    addressLabel.text = model.sender
                }
            } else if model.type == 13 {
                // 交易所交易
                #warning("交易状态待整理")
                if model.transaction_type == 0 {
                    // 转账
                    amountLabel.textColor = UIColor.init(hex: "13B788")
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    addressLabel.text = model.receiver
                } else {
                    // 收款
                    amountLabel.textColor = UIColor.init(hex: "E54040")
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    addressLabel.text = model.sender
                }
            } else {
            }
        }
    }
    var libraModel: LibraDataModel? {
        didSet {
            guard let model = libraModel else {
                return
            }
            dateLabel.text = timestampToDateString(timestamp: model.expiration_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.amount ?? 0)),
                                          scale: 4,
                                          unit: 1000000)
            if model.transaction_type == 0 {
                // 转账
                stateLabel.textColor = UIColor.init(hex: "E54040")
                stateLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
                addressLabel.text = model.receiver
            } else {
                // 收款
                stateLabel.textColor = UIColor.init(hex: "13B788")
                stateLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
                addressLabel.text = model.sender
            }
        }
    }
    
}
