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
        contentView.addSubview(dateTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(coinLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(searchOnChainLabel)

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
        dateTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(19)
            make.top.equalTo(contentView).offset(16)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dateTitleLabel).offset(1)
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(3)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(16)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(amountTitleLabel).offset(1)
            make.top.equalTo(amountTitleLabel.snp.bottom).offset(3)
        }
        typeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-19)
            make.top.equalTo(contentView).offset(16)
        }
        coinLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-19)
            make.top.equalTo(typeLabel.snp.bottom).offset(3)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(19)
            make.right.equalTo(searchOnChainLabel.snp.left).offset(-5)
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
        searchOnChainLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-19)
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
        //防止用户名字挤压
        //宽度不够时，可以被压缩
        addressLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容
        addressLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        //不可以被压缩，尽量显示完整
        searchOnChainLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    //MARK: - 懒加载对象
    lazy var dateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "808080")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_transactions_date_title")
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "808080")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_transactions_amount_title")
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var typeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var coinLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "808080")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.lineBreakMode = .byTruncatingMiddle
        label.text = "---"
        return label
    }()
    lazy var searchOnChainLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "7A7AEE")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_transactions_check_detail_on_chain")
        return label
    }()
    //MARK: - 设置数据
    var tokenName: String?
    var btcModel: BTCTransaction? {
        didSet {
            guard let model = btcModel else {
                return
            }
            coinLabel.text = "BTC"
            dateLabel.text = timestampToDateString(timestamp: model.block_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.transaction_value ?? 0)),
                                                      scale: 8,
                                                      unit: 100000000)
            addressLabel.text = model.inputs?.first?.prev_addresses?.first
            if model.transaction_type == 0 {
                // 转账
                typeLabel.textColor = UIColor.init(hex: "E54040")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
            } else {
                // 收款
                typeLabel.textColor = UIColor.init(hex: "13B788")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
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
            addressLabel.text = model.receiver
            coinLabel.text = model.module_name
            if model.type == 1 {
                // 平台币铸币
                typeLabel.textColor = UIColor.init(hex: "FB8F0B")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_publish_title")
            } else if model.type == 2 {
                // vtoken交易
                if model.transaction_type == 0 {
                    // 转账
                    typeLabel.textColor = UIColor.init(hex: "E54040")
                    typeLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
                } else {
                    // 收款
                    typeLabel.textColor = UIColor.init(hex: "13B788")
                    typeLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
                }
            }  else if model.type == 7 {
                // 稳定币铸币
                typeLabel.textColor = UIColor.init(hex: "FB8F0B")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_make_coin_title")
            } else if model.type == 9 {
                // publish
                typeLabel.textColor = UIColor.init(hex: "FB8F0B")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_publish_title")
            } else if model.type == 12 {
                // 稳定币交易
                if model.transaction_type == 0 {
                    // 转账
                    typeLabel.textColor = UIColor.init(hex: "E54040")
                    typeLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
                } else {
                    // 收款
                    typeLabel.textColor = UIColor.init(hex: "13B788")
                    typeLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
                }
            } else if model.type == 13 {
                // 交易所交易
                #warning("交易状态待整理")
                if model.transaction_type == 0 {
                    // 转账
                    typeLabel.textColor = UIColor.init(hex: "E54040")
                    typeLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
                } else {
                    // 收款
                    typeLabel.textColor = UIColor.init(hex: "13B788")
                    typeLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
                }
            } else {
                typeLabel.textColor = UIColor.init(hex: "FB8F0B")
                typeLabel.text = "---"
            }
        }
    }
    var libraModel: LibraDataModel? {
        didSet {
            guard let model = libraModel else {
                return
            }
            coinLabel.text = "Libra"
            dateLabel.text = model.date
            amountLabel.text = model.amount
            if model.event == "sent" {
                // 转账
                typeLabel.textColor = UIColor.init(hex: "E54040")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
                addressLabel.text = model.toAddress
            } else {
                // 收款
                typeLabel.textColor = UIColor.init(hex: "13B788")
                typeLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
                addressLabel.text = model.fromAddress
            }
        }
    }
    
}
