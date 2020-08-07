//
//  ScanSwapView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ScanSwapView: UIView {
    weak var delegate: ScanSendTransactionViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(swapWhiteBackgroundView)
        swapWhiteBackgroundView.addSubview(inputAmountTitleLabel)
        swapWhiteBackgroundView.addSubview(inputAmountLabel)
        swapWhiteBackgroundView.addSubview(outputAmountTitleLabel)
        swapWhiteBackgroundView.addSubview(outputAmountLabel)
        swapWhiteBackgroundView.addSubview(amountIndicatorImageView)
        swapWhiteBackgroundView.addSubview(spaceLabel)
        swapWhiteBackgroundView.addSubview(swapRateTitleLabel)
        swapWhiteBackgroundView.addSubview(swapRateLabel)
        swapWhiteBackgroundView.addSubview(swapFeesTitleLabel)
        swapWhiteBackgroundView.addSubview(swapFeesLabel)
        swapWhiteBackgroundView.addSubview(minerFeesTitleLabel)
        swapWhiteBackgroundView.addSubview(minerFeesLabel)
        
        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanPublishView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scanLoginIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(101)
            make.centerX.equalTo(self)
        }
        scanLoginTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(28)
            make.centerX.equalTo(self)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        swapWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(88)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(176)
        }
        inputAmountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(swapWhiteBackgroundView).offset(12)
            make.left.equalTo(swapWhiteBackgroundView).offset(14)
        }
        inputAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(amountIndicatorImageView)
            make.left.equalTo(swapWhiteBackgroundView).offset(14)
            make.right.equalTo(amountIndicatorImageView.snp.left).offset(-3)
        }
        amountIndicatorImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(swapWhiteBackgroundView)
            make.top.equalTo(swapWhiteBackgroundView).offset(37)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        outputAmountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(swapWhiteBackgroundView).offset(12)
            make.left.equalTo(amountIndicatorImageView.snp.centerX)
            make.right.equalTo(swapWhiteBackgroundView.snp.right).offset(-14)
        }
        outputAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(amountIndicatorImageView)
            make.left.equalTo(amountIndicatorImageView.snp.right).offset(3)
            make.right.equalTo(swapWhiteBackgroundView.snp.right).offset(-14)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(swapWhiteBackgroundView).offset(71)
            make.left.equalTo(swapWhiteBackgroundView).offset(14)
            make.right.equalTo(swapWhiteBackgroundView.snp.right).offset(-14)
            make.height.equalTo(0.5)
        }
        swapRateTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceLabel.snp.bottom).offset(10)
            make.left.equalTo(swapWhiteBackgroundView).offset(14)
        }
        swapRateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(swapRateTitleLabel)
            make.left.equalTo(swapWhiteBackgroundView).offset(122)
            make.right.equalTo(swapWhiteBackgroundView.snp.right).offset(-14)
        }
        swapFeesTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(swapRateTitleLabel.snp.bottom).offset(12)
            make.left.equalTo(swapWhiteBackgroundView).offset(14)
        }
        swapFeesLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(swapFeesTitleLabel)
            make.left.equalTo(swapWhiteBackgroundView).offset(122)
            make.right.equalTo(swapWhiteBackgroundView.snp.right).offset(-14)
        }
        minerFeesTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(swapFeesTitleLabel.snp.bottom).offset(12)
            make.left.equalTo(swapWhiteBackgroundView).offset(14)
        }
        minerFeesLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minerFeesTitleLabel)
            make.left.equalTo(swapWhiteBackgroundView).offset(122)
            make.right.equalTo(swapWhiteBackgroundView.snp.right).offset(-14)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(swapWhiteBackgroundView.snp.bottom).offset(50)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-29)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
    }
    //MARK: - 懒加载对象
    lazy var scanLoginIndicator : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "scan_login_indicator")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var scanLoginTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = localLanguage(keyString: "wallet_wallet_connect_swap_title")
        label.numberOfLines = 0
        return label
    }()
    private lazy var swapWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        // 定义阴影颜色
        view.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        view.layer.shadowRadius = 3
        // 阴影的偏移量
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        view.layer.shadowOpacity = 0.1
        return view
    }()
    lazy var inputAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_input_amount_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var amountIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "exchange_transaction_amount_indicator")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var outputAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_output_amount_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var outputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var swapRateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_rate_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var swapRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var swapFeesTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = localLanguage(keyString: "wallet_market_transaction_content_order_fee_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var swapFeesLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var minerFeesTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_miner_fee_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var minerFeesLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_exchange_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69
        
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "close_black"), for: UIControl.State.normal)
        
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.confirmLogin(password: "password")
        } else if button.tag == 20 {
            // 常用地址
            self.delegate?.cancelLogin()
        }
    }
    var model: WCRawTransaction? {
        didSet {
            if model?.payload?.code == "a11ceb0b010006010002030207040902050b0d071817082f10000000010001020101000205060c030303030002090009010845786368616e67650d6164645f6c6971756964697479000000000000000000000000000000010201010001070b000a010a020a030a04380002" {
                // 添加流动性
                inputAmountTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
                outputAmountTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
                scanLoginTitleLabel.text = localLanguage(keyString: "wallet_wallet_connect_add_liquidity_title")
                swapRateTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title")
                // 输人数量1
                let inputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[0].value ?? "0"),
                                                   scale: 6,
                                                   unit: 1000000)
                let inputAmountString = NSAttributedString(string: inputAmount.stringValue,
                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
                let (_, module) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?.first ?? "") ?? Data(), typeTagCount: 1)

                let inputUnitString = NSAttributedString(string: module,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
                let tempInputAtt = NSMutableAttributedString.init(attributedString: inputAmountString)
                tempInputAtt.append(inputUnitString)
                inputAmountLabel.attributedText = tempInputAtt
                // 输人数量2
                let outputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[1].value ?? "0"),
                                                    scale: 6,
                                                    unit: 1000000)
                let outputAmountString = NSAttributedString(string: outputAmount.stringValue,
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
                let (_, module2) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?[1] ?? "") ?? Data(), typeTagCount: 1)

                let outputUnitString = NSAttributedString(string: module2,
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
                let tempOutputAtt = NSMutableAttributedString.init(attributedString: outputAmountString)
                tempOutputAtt.append(outputUnitString)
                outputAmountLabel.attributedText = tempOutputAtt
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 6,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig).stringValue
                swapRateLabel.text = "1:\(rate)"
            } else if model?.payload?.code == "a11ceb0b010006010002030207040902050b0c07171a083110000000010001020101000204060c0303030002090009010845786368616e67651072656d6f76655f6c6971756964697479000000000000000000000000000000010201010001060b000a010a020a03380002" {
                // 移除流动性
                inputAmountTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_output_amount_title")
                outputAmountTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_output_amount_title")
                scanLoginTitleLabel.text = localLanguage(keyString: "wallet_wallet_connect_remove_liquidity_title")
                swapRateTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_output_token_wallet_connect_title")
                swapFeesTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title")
                // 通证数量
                let tokenAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?.first?.value ?? "0"),
                                                   scale: 6,
                                                   unit: 1000000)
                swapRateLabel.text = "-\(tokenAmount)"
                // 输出数量1
                let inputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[1].value ?? "0"),
                                                   scale: 6,
                                                   unit: 1000000)
                let inputAmountString = NSAttributedString(string: inputAmount.stringValue,
                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
                let (_, module) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?.first ?? "") ?? Data(), typeTagCount: 1)

                let inputUnitString = NSAttributedString(string: module,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
                let tempInputAtt = NSMutableAttributedString.init(attributedString: inputAmountString)
                tempInputAtt.append(inputUnitString)
                inputAmountLabel.attributedText = tempInputAtt

                
                // 输出数量2
                let outputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[2].value ?? "0"),
                                                    scale: 6,
                                                    unit: 1000000)
                let outputAmountString = NSAttributedString(string: outputAmount.stringValue,
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
                let (_, module2) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?[1] ?? "") ?? Data(), typeTagCount: 1)

                let outputUnitString = NSAttributedString(string: module2,
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
                let tempOutputAtt = NSMutableAttributedString.init(attributedString: outputAmountString)
                tempOutputAtt.append(outputUnitString)
                outputAmountLabel.attributedText = tempOutputAtt
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 6,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig).stringValue
                if rate == "NaN" {
                    swapFeesLabel.text = "---"
                } else {
                    swapFeesLabel.text = "1:\(rate)"
                }
            } else {
                // 交换
                // 设置输入数量
                let inputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[1].value ?? "0"),
                                                   scale: 6,
                                                   unit: 1000000)
                let inputAmountString = NSAttributedString(string: inputAmount.stringValue,
                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
                let (_, module) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?.first ?? "") ?? Data(), typeTagCount: 1)

                let inputUnitString = NSAttributedString(string: module,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
                let tempInputAtt = NSMutableAttributedString.init(attributedString: inputAmountString)
                tempInputAtt.append(inputUnitString)
                inputAmountLabel.attributedText = tempInputAtt
                // 设置输出数量
                let outputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[2].value ?? "0"),
                                                    scale: 6,
                                                    unit: 1000000)
                let outputAmountString = NSAttributedString(string: outputAmount.stringValue,
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
                let (_, module2) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?[1] ?? "") ?? Data(), typeTagCount: 1)

                let outputUnitString = NSAttributedString(string: module2,
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
                let tempOutputAtt = NSMutableAttributedString.init(attributedString: outputAmountString)
                tempOutputAtt.append(outputUnitString)
                outputAmountLabel.attributedText = tempOutputAtt
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 6,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig).stringValue
                swapRateLabel.text = "1:\(rate)"
            }
        }
    }
}
