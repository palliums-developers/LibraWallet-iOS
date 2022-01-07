//
//  AssetsPoolTableViewCell.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class AssetsPoolTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        contentView.addSubview(transactionTypeImageView)
        contentView.addSubview(stateLabel)
        contentView.addSubview(tokenLabel)
        contentView.addSubview(inputAmountLabel)
        contentView.addSubview(exchangeIndicatorLabel)
        contentView.addSubview(outputAmountLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(spaceLabel)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolTableViewCell销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        transactionTypeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(15)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        stateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(-20)
            make.left.equalTo(transactionTypeImageView.snp.right).offset(8)
        }
        tokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(20)
            make.left.equalTo(transactionTypeImageView.snp.right).offset(8)
        }
        inputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionTypeImageView.snp.right).offset(8)
            make.centerY.equalTo(contentView)
        }
        exchangeIndicatorLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(inputAmountLabel)
            make.left.equalTo(inputAmountLabel.snp.right).offset(13)
            make.size.equalTo(CGSize.init(width: 10, height: 9))
        }
        outputAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(exchangeIndicatorLabel.snp.right).offset(13)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.centerY.equalTo(tokenLabel)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.height.equalTo(0.5)
        }
    }
    // MARK: - 懒加载对象
    private lazy var transactionTypeImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        return view
    }()
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var tokenLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        return label
    }()
    private lazy var exchangeIndicatorLabel : UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "&"
        return label
    }()
    lazy var outputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "000000")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    //MARK: - 设置数据
    var model: AssetsPoolTransactionsDataModel? {
        didSet {
            tokenLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_token_title") +
                getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.token ?? 0),
                                       scale: 6,
                                       unit: 1000000)
            inputAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.amounta ?? 0),
                                                           scale: 6,
                                                           unit: 1000000) + (model?.coina ?? "")
            outputAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.amountb ?? 0),
                                                            scale: 6,
                                                            unit: 1000000) + (model?.coinb ?? "")
            dateLabel.text = timestampToDateString(timestamp: model?.date ?? 0,
                                                   dateFormat: "MM.dd HH:mm")
            if model?.status == "Executed" {
                stateLabel.textColor = UIColor.init(hex: "13B788")
                if model?.transaction_type == "ADD_LIQUIDITY" {
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_in_success_title")
                } else if model?.transaction_type == "REMOVE_LIQUIDITY" {
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_out_success_title")
                } else {
                    stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_invalid_title")
                }
            } else {
                stateLabel.textColor = UIColor.init(hex: "E54040")
                if model?.transaction_type == "ADD_LIQUIDITY" {
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_in_failed_title")
                } else if model?.transaction_type == "REMOVE_LIQUIDITY" {
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_out_failed_title")
                } else {
                    stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_invalid_title")
                }
            }
        }
    }
    var indexPath: IndexPath?
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                spaceLabel.alpha = 0
            }
        }
    }
    /// 语言切换
    @objc func setText() {
        if model?.status == "Executed" {
            stateLabel.textColor = UIColor.init(hex: "13B788")
            if model?.transaction_type == "ADD_LIQUIDITY" {
                stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_in_success_title")
            } else if model?.transaction_type == "REMOVE_LIQUIDITY" {
                stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_out_success_title")
            } else {
                stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_invalid_title")
            }
        } else {
            stateLabel.textColor = UIColor.init(hex: "E54040")
            if model?.transaction_type == "ADD_LIQUIDITY" {
                stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_in_failed_title")
            } else if model?.transaction_type == "REMOVE_LIQUIDITY" {
                stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_out_failed_title")
            } else {
                stateLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_invalid_title")
            }
        }
        tokenLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_token_title") +
            getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.token ?? 0),
                                   scale: 6,
                                   unit: 1000000)
    }
}
