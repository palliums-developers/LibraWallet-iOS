//
//  ExchangeViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
protocol ExchangeViewHeaderViewDelegate: NSObjectProtocol {
    func selectInputToken()
    func selectOutoutToken()
    func swapInputOutputToken()
    func dealTransferOutAmount(inputModule: MarketSupportTokensDataModel, outputModule: MarketSupportTokensDataModel)
    func exchangeConfirm()
}

class ExchangeViewHeaderView: UIView {
    weak var delegate: ExchangeViewHeaderViewDelegate?
    enum ExchangeViewState {
        case Normal
        case ExchangeSelectAToken
        case ExchangeSelectBToken
        case ExchangeSwap
        case LibraToViolasSwap
        case LibraToBTCSwap
        case LibraToLibraSwap
        case ViolasToLibraSwap
        case ViolasToBTCSwap
        case ViolasToViolasSwap
        case BTCToLibraSwap
        case BTCToViolasSwap
        case handleBestOutputAmount
        case handleBestInputAmount
    }
    var viewState: ExchangeViewState = .Normal
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(feeLabel)
        addSubview(inputTokenBackgroundView)
        inputTokenBackgroundView.addSubview(inputTitleLabel)
        inputTokenBackgroundView.addSubview(inputTokenAssetsImageView)
        inputTokenBackgroundView.addSubview(inputTokenAssetsLabel)
        inputTokenBackgroundView.addSubview(inputAmountTextField)
        addSubview(inputTokenButton)
        addSubview(swapButton)
        addSubview(outputTokenBackgroundView)
        outputTokenBackgroundView.addSubview(outputTitleLabel)
        outputTokenBackgroundView.addSubview(outputTokenAssetsImageView)
        outputTokenBackgroundView.addSubview(outputTokenAssetsLabel)
        outputTokenBackgroundView.addSubview(outputAmountTextField)
        addSubview(outputTokenButton)
        addSubview(exchangeRateLabel)
        addSubview(minerFeeLabel)
        addSubview(confirmButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ExchangeViewHeaderView销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        feeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-6)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6)
        }
        inputTokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(40)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 80))
        }
        inputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView).offset(16)
            make.left.equalTo(inputTokenBackgroundView).offset(15)
        }
        inputTokenAssetsImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(inputTokenAssetsLabel)
            make.right.equalTo(inputTokenAssetsLabel.snp.left).offset(-2)
            make.size.equalTo(CGSize.init(width: 12, height: 13))
        }
        inputTokenAssetsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView).offset(16)
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
        }
        inputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView).offset(15)
            make.bottom.equalTo(inputTokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-88)
        }
        inputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11).priority(250)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22)).priority(250)
        }
        swapButton.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(6)
            make.centerX.equalTo(inputTokenBackgroundView)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        outputTokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 80))
        }
        outputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView).offset(16)
            make.left.equalTo(outputTokenBackgroundView).offset(15)
        }
        outputTokenAssetsImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(outputTokenAssetsLabel)
            make.right.equalTo(outputTokenAssetsLabel.snp.left).offset(-2)
            make.size.equalTo(CGSize.init(width: 12, height: 13))
        }
        outputTokenAssetsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView).offset(16)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
        }
        outputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.bottom.equalTo(outputTokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-88)
        }
        outputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11).priority(250)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22)).priority(250)
        }
        exchangeRateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.top.equalTo(outputTokenBackgroundView.snp.bottom).offset(6)
        }
        minerFeeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.top.equalTo(exchangeRateLabel.snp.bottom).offset(6)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView.snp.bottom).offset(66)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
            make.centerX.equalTo(self)
        }
    }
    lazy var feeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "5C5C5C")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + "---"
        return label
    }()
    private lazy var inputTokenBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.init(hex: "C2C2C2").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var inputTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_input_amount_title")
        return label
    }()
    private lazy var inputTokenAssetsImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "assets_pool_token")
        return imageView
    }()
    lazy var inputTokenAssetsLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        return label
    }()
    lazy var inputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.tintColor = DefaultGreenColor
//        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.init(name: "DIN Alternate Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.tag = 10
        return textField
    }()
    lazy var inputTokenButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 11
        button.tag = 10
        return button
    }()
    lazy var swapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "swap_indicator"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    private lazy var outputTokenBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.init(hex: "C2C2C2").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var outputTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_output_amount_title")
        return label
    }()
    private lazy var outputTokenAssetsImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "assets_pool_token")
        return imageView
    }()
    lazy var outputTokenAssetsLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        return label
    }()
    lazy var outputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.tintColor = DefaultGreenColor
//        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.init(name: "DIN Alternate Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.tag = 20
        return textField
    }()
    lazy var outputTokenButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 11
        button.tag = 20
        return button
    }()
    lazy var exchangeRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
        return label
    }()
    lazy var minerFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.text = localLanguage(keyString: "wallet_market_exchange_miner_fee_title") + "---"
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 100
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.viewState = .ExchangeSelectAToken
            self.inputAmountTextField.resignFirstResponder()
            self.outputAmountTextField.resignFirstResponder()
            self.delegate?.selectInputToken()
        } else if button.tag == 20 {
            self.viewState = .ExchangeSelectBToken
            self.inputAmountTextField.resignFirstResponder()
            self.outputAmountTextField.resignFirstResponder()
            self.delegate?.selectOutoutToken()
        } else if button.tag == 30 {
            self.viewState = .ExchangeSwap
            self.delegate?.swapInputOutputToken()
        } else if button.tag == 100 {
            self.inputAmountTextField.resignFirstResponder()
            self.outputAmountTextField.resignFirstResponder()
            self.delegate?.exchangeConfirm()
        }
    }
    /// 资金池转入ModelA
    var transferInInputTokenA: MarketSupportTokensDataModel? {
        didSet {
            guard let model = transferInInputTokenA else {
                return
            }
            inputTokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let unit = 1000000

            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 6,
                                          unit: unit)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
            self.viewState = .Normal
            if let tokenA = transferInInputTokenA, let tokenB = transferInInputTokenB {
                self.delegate?.dealTransferOutAmount(inputModule: tokenA,
                                                     outputModule: tokenB)
            }
        }
    }
    /// 资金池转入ModelB
    var transferInInputTokenB: MarketSupportTokensDataModel? {
        didSet {
            guard let model = transferInInputTokenB else {
                return
            }
            outputTokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            outputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            outputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let unit = 1000000
//            if model.chainType == 2 {
//                unit = 100000000
//            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 6,
                                          unit: unit)
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
            self.viewState = .Normal
            
            if let tokenA = transferInInputTokenA, let tokenB = transferInInputTokenB {
                self.delegate?.dealTransferOutAmount(inputModule: tokenA,
                                                     outputModule: tokenB)
            }
        }
    }
    /// 兑换比例
    var exchangeModel: ExchangeInfoModel? {
        didSet {
            guard let model = exchangeModel else {
                return
            }
            if viewState == .handleBestOutputAmount {
                outputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: model.output),
                                                              scale: 6,
                                                              unit: 1000000).stringValue
                let inputAmount = NSDecimalNumber.init(string: inputAmountTextField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: 1000000))
                let outputAmount = NSDecimalNumber.init(value: model.output )
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 6,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig)
                exchangeRateLabel.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "1:\(rate.stringValue)"
                let fee = NSDecimalNumber.init(value: model.fee).dividing(by: NSDecimalNumber.init(value: model.input), withBehavior: numberConfig).multiplying(by: NSDecimalNumber.init(value: 100))
                feeLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + fee.stringValue + "%"
            } else {
                inputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: model.input),
                                                             scale: 6,
                                                             unit: 1000000).stringValue
                let inputAmount = NSDecimalNumber.init(string: outputAmountTextField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: 1000000))
                let outputAmount = NSDecimalNumber.init(value: model.input )
                let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                               scale: 6,
                                                               raiseOnExactness: false,
                                                               raiseOnOverflow: false,
                                                               raiseOnUnderflow: false,
                                                               raiseOnDivideByZero: false)
                let rate = outputAmount.dividing(by: inputAmount, withBehavior: numberConfig)
                exchangeRateLabel.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "1:\(rate.stringValue)"
                let fee = NSDecimalNumber.init(value: model.fee).dividing(by: NSDecimalNumber.init(value: model.input), withBehavior: numberConfig).multiplying(by: NSDecimalNumber.init(value: 100))
                feeLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + fee.stringValue + "%"
            }
            self.viewState = .Normal
        }
    }
    /// 语言切换
    @objc func setText() {
        feeLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + "---"
        inputTitleLabel.text = localLanguage(keyString: "wallet_market_exchange_input_amount_title")
        outputTitleLabel.text = localLanguage(keyString: "wallet_market_exchange_output_amount_title")
        exchangeRateLabel.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
        minerFeeLabel.text = localLanguage(keyString: "wallet_market_exchange_miner_fee_title") + "---"
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_exchange_button_title"), for: UIControl.State.normal)        
        if transferInInputTokenA == nil {
            inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
        if transferInInputTokenB == nil {
            outputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
            outputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            outputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenB?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
    }
}
