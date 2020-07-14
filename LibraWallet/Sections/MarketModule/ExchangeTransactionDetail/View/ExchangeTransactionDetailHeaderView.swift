//
//  ExchangeTransactionDetailHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ExchangeTransactionDetailHeaderView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(submitIndicatorImageView)
        contentView.addSubview(submitTitleLabel)
        contentView.addSubview(submitSpaceLabel)
        contentView.addSubview(exchangeIndicatorImageView)
        contentView.addSubview(exchangeTitleLabel)
        contentView.addSubview(exchangeSpaceLabel)
        contentView.addSubview(finalIndicatorImageView)
        contentView.addSubview(finalTitleLabel)
        contentView.addSubview(retryButton)
        contentView.addSubview(inputAmountTitleLabel)
        contentView.addSubview(inputAmountLabel)
//        contentView.addSubview(inputAmountUnitLabel)
        contentView.addSubview(exchangeAmountIndicatorImageView)
        contentView.addSubview(outputAmountTitleLabel)
        contentView.addSubview(outputAmountLabel)
        contentView.addSubview(outputAmountUnitLabel)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ExchangeTransactionDetailHeaderView销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        submitIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.right.equalTo(submitTitleLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        submitTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.right.equalTo(submitSpaceLabel.snp.left).offset(-4)
        }
        submitSpaceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.right.equalTo(exchangeIndicatorImageView.snp.left).offset(-7)
            make.size.equalTo(CGSize.init(width: 38, height: 2))
        }
        exchangeIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.right.equalTo(exchangeTitleLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        exchangeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(25)
            make.centerX.equalTo(contentView)
        }
        exchangeSpaceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.left.equalTo(exchangeTitleLabel.snp.right).offset(5)
            make.size.equalTo(CGSize.init(width: 38, height: 2))
        }
        finalIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.left.equalTo(exchangeSpaceLabel.snp.right).offset(7)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        finalTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeTitleLabel)
            make.left.equalTo(finalIndicatorImageView.snp.right).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-10)
        }
        inputAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(exchangeAmountIndicatorImageView.snp.left).offset(-10)
            make.bottom.equalTo(exchangeAmountIndicatorImageView.snp.top).offset(-18)
        }
        inputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(exchangeAmountIndicatorImageView.snp.left).offset(-10)
            make.bottom.equalTo(exchangeAmountIndicatorImageView.snp.bottom)
        }
//        inputAmountUnitLabel.snp.makeConstraints { (make) in
//            make.bottom.equalTo(inputAmountLabel.snp.bottom).offset(-3)
//            make.left.equalTo(inputAmountLabel.snp.right).offset(5)
//        }
        exchangeAmountIndicatorImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(116)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        outputAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(exchangeAmountIndicatorImageView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.bottom.equalTo(exchangeAmountIndicatorImageView.snp.top).offset(-18)
        }
        outputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(exchangeAmountIndicatorImageView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.bottom.equalTo(exchangeAmountIndicatorImageView.snp.bottom)
        }
        retryButton.snp.makeConstraints { (make) in
            make.top.equalTo(finalTitleLabel.snp.bottom).offset(6)
            make.right.equalTo(finalTitleLabel.snp.right)
            make.size.equalTo(CGSize.init(width: 42, height: 18))
        }
    }
    //MARK: - 懒加载对象
    private lazy var submitIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "transaction_detail_finish")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var submitTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_transaction_status_submitted_title")
        return label
    }()
    lazy var submitSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "999999")
        return label
    }()
    private lazy var exchangeIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "transaction_detail_uncheck")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var exchangeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "333333")
        label.text = localLanguage(keyString: "---")
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        return label
    }()
    lazy var exchangeSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "999999")
        return label
    }()
    private lazy var finalIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "transaction_detail_failed")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var finalTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.numberOfLines = 2
        return label
    }()
    lazy var retryButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_confirm_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        //        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 9
        button.tag = 100
        button.alpha = 0
        return button
    }()
    lazy var inputAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_transaction_input_amount_title")
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    lazy var inputAmountUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "Violas")
        return label
    }()
    private lazy var exchangeAmountIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "exchange_transaction_amount_indicator")
        return view
    }()
    lazy var outputAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_transaction_output_amount_title")
        return label
    }()
    lazy var outputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    lazy var outputAmountUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "7D71AA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_home_wallet_asset_title")
        return label
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            
        }
    }
    var model: AssetsPoolTransactionsDataModel? {
        didSet {
            exchangeTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_packing_title")
            if model?.status == 4001 {
                retryButton.alpha = 0
                finalTitleLabel.textColor = UIColor.init(hex: "13B788")
                if model?.transaction_type == "ADD_LIQUIDITY" {
                    finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_finish")
                    finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_transfer_in_successful_title")
                } else if model?.transaction_type == "REMOVE_LIQUIDITY" {
                    finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_finish")
                    finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_transfer_out_successful_title")
                } else {
                    finalTitleLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_invalid_title")
                }
            } else {
                retryButton.alpha = 0
                finalTitleLabel.textColor = UIColor.init(hex: "E54040")
                if model?.transaction_type == "ADD_LIQUIDITY" {
                    finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_failed")
                    finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_transfer_in_failed_title")
                } else if model?.transaction_type == "REMOVE_LIQUIDITY" {
                    finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_failed")
                    finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_transfer_out_failed_title")
                } else {
                    finalTitleLabel.text = localLanguage(keyString: "wallet_assets_pool_transaction_status_transfer_invalid_title")
                }
            }
            
            
            // 设置输入数量
            let inputAmount = getDecimalNumber(amount: NSDecimalNumber.init(value: model?.amounta ?? 0),
                                               scale: 4,
                                               unit: 1000000)
            let inputAmountString = NSAttributedString(string: inputAmount.stringValue,
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)])
            let inputUnitString = NSAttributedString(string: model?.coina ?? "---",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
            let tempInputAtt = NSMutableAttributedString.init(attributedString: inputAmountString)
            tempInputAtt.append(inputUnitString)
            inputAmountLabel.attributedText = tempInputAtt
            // 设置输出数量
            let outputAmount = getDecimalNumber(amount: NSDecimalNumber.init(value: model?.amountb ?? 0),
                                                scale: 4,
                                                unit: 1000000)
            let outputAmountString = NSAttributedString(string: outputAmount.stringValue,
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)])
            let outputUnitString = NSAttributedString(string: model?.coinb ?? "---",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
            let tempOutputAtt = NSMutableAttributedString.init(attributedString: outputAmountString)
            tempOutputAtt.append(outputUnitString)
            outputAmountLabel.attributedText = tempOutputAtt
        }
    }
    var exchangeModel: ExchangeTransactionsDataModel? {
        didSet {
            exchangeTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_exchanging_title")

            if exchangeModel?.status == 4001 {
                retryButton.alpha = 0
                finalTitleLabel.textColor = UIColor.init(hex: "13B788")
                finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_finish")
                finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_exchange_fsuccessful_title")
            } else {
                retryButton.alpha = 1
                finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_failed")
                finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_exchange_failed_title")
            }
        }
    }
}
