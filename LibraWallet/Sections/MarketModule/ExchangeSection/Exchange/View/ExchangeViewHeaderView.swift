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
//    func dealTransferOutAmount(inputModule: MarketSupportTokensDataModel, outputModule: MarketSupportTokensDataModel)
    func exchangeConfirm()
    func filterBestOutput(amount: Int64)
    func filterBestIntput(amount: Int64)
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
        addSubview(tokenSelectViewA)
        addSubview(swapButton)
        addSubview(tokenSelectViewB)
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
            make.right.equalTo(self.tokenSelectViewA.snp.right).offset(-6)
            make.bottom.equalTo(self.tokenSelectViewA.snp.top).offset(-6)
        }
        tokenSelectViewA.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(40)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 80))
        }
        swapButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.tokenSelectViewA.snp.bottom).offset(6)
            make.centerX.equalTo(self.tokenSelectViewA)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        tokenSelectViewB.snp.makeConstraints { (make) in
            make.top.equalTo(self.tokenSelectViewA.snp.bottom).offset(33)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 80))
        }
        exchangeRateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.tokenSelectViewB).offset(15)
            make.top.equalTo(self.tokenSelectViewB.snp.bottom).offset(6)
        }
        minerFeeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.tokenSelectViewB).offset(15)
            make.top.equalTo(exchangeRateLabel.snp.bottom).offset(6)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.tokenSelectViewB.snp.bottom).offset(66)
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
    lazy var tokenSelectViewA: MarketTokenSelectView = {
        let view = MarketTokenSelectView.init()
        view.tag = 10
        view.delegate = self
        return view
    }()
    lazy var swapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "swap_indicator"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    lazy var tokenSelectViewB: MarketTokenSelectView = {
        let view = MarketTokenSelectView.init()
        view.tag = 20
        view.delegate = self
        return view
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
            self.tokenSelectViewA.inputAmountTextField.resignFirstResponder()
            self.tokenSelectViewB.inputAmountTextField.resignFirstResponder()
            self.delegate?.selectInputToken()
        } else if button.tag == 20 {
            self.viewState = .ExchangeSelectBToken
            self.tokenSelectViewA.inputAmountTextField.resignFirstResponder()
            self.tokenSelectViewB.inputAmountTextField.resignFirstResponder()
            self.delegate?.selectOutoutToken()
        } else if button.tag == 30 {
            self.viewState = .ExchangeSwap
            self.delegate?.swapInputOutputToken()
        } else if button.tag == 100 {
            self.tokenSelectViewA.inputAmountTextField.resignFirstResponder()
            self.tokenSelectViewB.inputAmountTextField.resignFirstResponder()
            self.delegate?.exchangeConfirm()
        }
    }
    /// 资金池转入ModelA
    var transferInInputTokenA: MarketSupportTokensDataModel? {
        didSet {
            guard let model = transferInInputTokenA else {
                return
            }
            self.tokenSelectViewA.tokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            self.tokenSelectViewA.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            self.tokenSelectViewA.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.tokenSelectViewA.snp.right).offset(-11)
                make.bottom.equalTo(self.tokenSelectViewA.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let unit = 1000000

            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 6,
                                          unit: unit)
            self.tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
            self.viewState = .Normal
        }
    }
    /// 资金池转入ModelB
    var transferInInputTokenB: MarketSupportTokensDataModel? {
        didSet {
            guard let model = transferInInputTokenB else {
                return
            }
            self.tokenSelectViewB.tokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            self.tokenSelectViewB.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            self.tokenSelectViewB.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.tokenSelectViewB.snp.right).offset(-11)
                make.bottom.equalTo(self.tokenSelectViewB.snp.bottom).offset(-11)
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
            self.tokenSelectViewB.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
            self.viewState = .Normal
        }
    }
    /// 兑换比例
    var exchangeModel: ExchangeInfoModel? {
        didSet {
            guard let model = exchangeModel else {
                return
            }
            if self.tokenSelectViewA.inputAmountTextField.isFirstResponder == true {
                self.tokenSelectViewB.inputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: model.output),
                                                              scale: 6,
                                                              unit: 1000000).stringValue
                let inputAmount = NSDecimalNumber.init(string: self.tokenSelectViewA.inputAmountTextField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: 1000000))
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
                self.tokenSelectViewA.inputAmountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: model.input),
                                                             scale: 6,
                                                             unit: 1000000).stringValue
                let inputAmount = NSDecimalNumber.init(string: self.tokenSelectViewB.inputAmountTextField.text ?? "0").multiplying(by: NSDecimalNumber.init(value: 1000000))
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
        }
    }
    // 语言切换
    @objc func setText() {
        feeLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + "---"
        self.tokenSelectViewA.titleLabel.text = localLanguage(keyString: "wallet_market_exchange_input_amount_title")
        self.tokenSelectViewB.titleLabel.text = localLanguage(keyString: "wallet_market_exchange_output_amount_title")
        exchangeRateLabel.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
        minerFeeLabel.text = localLanguage(keyString: "wallet_market_exchange_miner_fee_title") + "---"
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_exchange_button_title"), for: UIControl.State.normal)        
        if transferInInputTokenA == nil {
            self.tokenSelectViewA.tokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
            self.tokenSelectViewA.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            self.tokenSelectViewA.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.tokenSelectViewA.snp.right).offset(-11)
                make.bottom.equalTo(self.tokenSelectViewA.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            self.tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            self.tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
        if transferInInputTokenB == nil {
            self.tokenSelectViewB.tokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
            self.tokenSelectViewB.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            self.tokenSelectViewB.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.tokenSelectViewB.snp.right).offset(-11)
                make.bottom.equalTo(self.tokenSelectViewB.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            self.tokenSelectViewB.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenB?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            self.tokenSelectViewB.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
    }
}
extension ExchangeViewHeaderView: MarketTokenSelectViewViewDelegate {
    func selectToken(tag: Int) {
        if tag == 10 {
            self.viewState = .ExchangeSelectAToken
            self.tokenSelectViewA.inputAmountTextField.resignFirstResponder()
            self.tokenSelectViewB.inputAmountTextField.resignFirstResponder()
            self.delegate?.selectInputToken()
        } else if tag == 20 {
            self.viewState = .ExchangeSelectBToken
            self.tokenSelectViewA.inputAmountTextField.resignFirstResponder()
            self.tokenSelectViewB.inputAmountTextField.resignFirstResponder()
            self.delegate?.selectOutoutToken()
        }
    }
    func calculateOutput(tag: Int, amountString: String) {
        if tag == 10 {
            guard amountString.isEmpty == false else {
                self.tokenSelectViewB.inputAmountTextField.text = ""
                return
            }
            let amount = NSDecimalNumber.init(string: amountString)
            guard amount.int64Value > 0 else {
                print("小于0")
                self.tokenSelectViewB.inputAmountTextField.text = ""
                return
            }
            let tempAmount = amount.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
            self.delegate?.filterBestOutput(amount: tempAmount)
        } else if tag == 20 {
            guard amountString.isEmpty == false else {
                self.tokenSelectViewA.inputAmountTextField.text = ""
                return
            }
            let amount = NSDecimalNumber.init(string: amountString)
            guard amount.int64Value > 0 else {
                self.tokenSelectViewA.inputAmountTextField.text = ""
                return
            }
            let tempAmount = amount.multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
            self.delegate?.filterBestIntput(amount: tempAmount)
        }
    }
}
