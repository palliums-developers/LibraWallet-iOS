//
//  AssetsPoolViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
protocol AssetsPoolViewHeaderViewDelegate: NSObjectProtocol {
    func addLiquidityConfirm(amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String)
    func removeLiquidityConfirm(token: Double, amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String)
    func selectInputToken()
    func selectOutoutToken()
//    func swapInputOutputToken()
    func changeTrasferInOut()
    func dealTransferOutAmount(amount: Double, coinAModule: String, coinBModule: String)
    
    func getPoolLiquidity(inputModuleName: String, outputModuleName: String)
}
class AssetsPoolViewHeaderView: UIView {
    weak var delegate: AssetsPoolViewHeaderViewDelegate?
    enum AssetsPoolViewHeaderViewState {
        case Normal
        case AssetsPoolTransferInSelectAToken
        case AssetsPoolTransferInSelectBToken
        case AssetsPoolTransferInBaseOnInputARequestRate
        case AssetsPoolTransferInBaseOnInputBRequestRate
        case AssetsPoolTransferInConfirm
        
        case AssetsPoolTransferOutSelectToken
        case AssetsPoolTransferOutRequestLiquidityRate
        case AssetsPoolTransferOutAddLiquidity
        case AssetsPoolTransferOutRemoveLiquidity
    }
    var viewState: AssetsPoolViewHeaderViewState = .Normal

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(changeTypeButton)
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
        outputTokenBackgroundView.addSubview(outputAmountTextField)
        outputTokenBackgroundView.addSubview(outputTokenAssetsImageView)
        outputTokenBackgroundView.addSubview(outputTokenAssetsLabel)
        outputTokenBackgroundView.addSubview(outputCoinAAmountLabel)
        outputTokenBackgroundView.addSubview(outputCoinBAmountLabel)
        addSubview(outputTokenButton)
        addSubview(exchangeRateLabel)
        addSubview(confirmButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolViewHeaderView销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        changeTypeButton.snp.makeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView.snp.left).offset(5).priority(250)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20)).priority(250)
        }
        feeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-6)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6)
        }
        inputTokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(30)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(80)
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
            make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33).priority(250)
            make.left.equalTo(self).offset(30).priority(500)
            make.right.equalTo(self.snp.right).offset(-30).priority(500)
            make.height.equalTo(80).priority(250)
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
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView.snp.bottom).offset(66)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
            make.centerX.equalTo(self)
        }
        outputCoinAAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(11)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputCoinBAmountLabel.snp.top)

            make.height.equalTo(24)
        }
        outputCoinBAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(11)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-7)
            make.height.equalTo(24)
        }
    }
    lazy var changeTypeButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.backgroundColor = UIColor.init(hex: "F1EEFB").cgColor
        button.layer.cornerRadius = 10
        button.tag = 10
        return button
    }()
    lazy var feeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_fee_title")
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
        label.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
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
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        return label
    }()
    lazy var inputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
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
        button.tag = 20
        return button
    }()
    lazy var swapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("&", for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "999999"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
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
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
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
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        return label
    }()
    lazy var outputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.tag = 20
        return textField
    }()
    lazy var outputCoinAAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.text = "---"
        label.alpha = 0
        return label
    }()
    lazy var outputCoinBAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.text = "---"
        label.alpha = 0
        return label
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
        button.tag = 30
        return button
    }()
    lazy var exchangeRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title") + "---"
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_confirm_button_title"), for: UIControl.State.normal)
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
    func stringToDouble(string: String?) -> Double {
        guard let tempString = string, tempString.isEmpty == false else {
            return 0.0
        }
        guard isPurnDouble(string: tempString) == true else {
            return 0.0
        }
        return NSDecimalNumber.init(string: tempString).doubleValue
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.changeTrasferInOut()
            let dropper = Dropper.init(width: button.frame.size.width, height: 68)
            dropper.items = [localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), localLanguage(keyString: "wallet_assets_pool_transfer_out_title")]
            dropper.cornerRadius = 8
            dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
            dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
            dropper.cellColor = UIColor.init(hex: "333333")
            dropper.spacing = 12
            dropper.delegate = self
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                dropper.defaultSelectRow = 0
            } else {
                dropper.defaultSelectRow = 1
            }
            dropper.show(Dropper.Alignment.center, button: button)
        } else if button.tag == 20 {
            self.viewState = .AssetsPoolTransferInSelectAToken
            self.inputAmountTextField.resignFirstResponder()
            self.outputAmountTextField.resignFirstResponder()
            self.delegate?.selectInputToken()
        } else if button.tag == 30 {
            self.viewState = .AssetsPoolTransferInSelectBToken
            self.inputAmountTextField.resignFirstResponder()
            self.outputAmountTextField.resignFirstResponder()
            self.delegate?.selectOutoutToken()
        } else if button.tag == 100 {
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 转入
                self.inputAmountTextField.resignFirstResponder()
                self.outputAmountTextField.resignFirstResponder()
                // ModelA不为空
                guard let tempInputTokenA = transferInInputTokenA else {
                    self.makeToast("请选择第一个输入通证后输入",
                                   position: .center)
                    return
                }
                // ModelB不为空
                guard let tempInputTokenB = transferInInputTokenB else {
                    self.makeToast("请选择第二个输入通证后输入",
                                   position: .center)
                    return
                }
                // 金额不为空检查
                guard let amountAString = self.inputAmountTextField.text, amountAString.isEmpty == false else {
                    self.makeToast(LibraWalletError.WalletTransfer(reason: .amountEmpty).localizedDescription,
                                   position: .center)
                    return
                }
                // 金额是否纯数字检查
                guard isPurnDouble(string: amountAString) == true else {
                    self.makeToast(LibraWalletError.WalletTransfer(reason: .amountInvalid).localizedDescription,
                                   position: .center)
                    return
                }
                // 转换数字
                let amountA = NSDecimalNumber.init(string: amountAString).doubleValue
                
                // 金额不为空检查
                guard let amountBString = self.outputAmountTextField.text, amountBString.isEmpty == false else {
                    self.makeToast(LibraWalletError.WalletTransfer(reason: .amountEmpty).localizedDescription,
                                   position: .center)
                    return
                }
                // 金额是否纯数字检查
                guard isPurnDouble(string: amountBString) == true else {
                    self.makeToast(LibraWalletError.WalletTransfer(reason: .amountInvalid).localizedDescription,
                                   position: .center)
                    return
                }
                // 转换数字
                let amountB = NSDecimalNumber.init(string: amountBString).doubleValue
                
                
                
                var leastModuleA = tempInputTokenA
                var otherModuleB = tempInputTokenB
                var tempAmountA = amountA
                var tempAmountB = amountB
                if (tempInputTokenA.index ?? 0) > (tempInputTokenB.index ?? 0) {
                    leastModuleA = tempInputTokenB
                    otherModuleB = tempInputTokenA
                    tempAmountA = amountB
                    tempAmountB = amountA
                }
                // 转入
                self.viewState = .AssetsPoolTransferInConfirm
                self.delegate?.addLiquidityConfirm(amountIn: tempAmountA,
                                                   amountOut: tempAmountB,
                                                   inputModelName: leastModuleA.module ?? "",
                                                   outputModelName: otherModuleB.module ?? "")
            } else {
                // 转出
                self.inputAmountTextField.resignFirstResponder()
                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: transferOutModel?.coin_a_value ?? 0),
                                               scale: 4,
                                               unit: 1000000)
                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: transferOutModel?.coin_b_value ?? 0),
                                               scale: 4,
                                               unit: 1000000)
                // 转出
                self.delegate?.removeLiquidityConfirm(token: NSDecimalNumber.init(string: inputAmountTextField.text ?? "0").doubleValue,
                                                      amountIn: amountA.doubleValue,
                                                      amountOut: amountB.doubleValue,
                                                      inputModelName: tokenModel?.coin_a?.module ?? "",
                                                      outputModelName: tokenModel?.coin_b?.module ?? "")
            }
        }
    }
    /// 通证Model
    var tokenModel: MarketMineMainTokensDataModel? {
        didSet {
            guard let model = tokenModel else {
                return
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.token ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_token_title") + amount.stringValue
            let content = (tokenModel?.coin_a?.show_name ?? "---") + "/" + (tokenModel?.coin_b?.show_name ?? "---")
            inputTokenButton.setTitle(content, for: UIControl.State.normal)
            // 调整位置
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: content, fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
        }
    }
    /// 资金池转出Model
    var transferOutModel: AssetsPoolTransferOutInfoDataModel? {
        didSet {
            guard let model = transferOutModel else {
                return
            }
            let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coin_a_value ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            outputCoinAAmountLabel.text = amountA.stringValue + (model.coin_a_name ?? "---")
            
            let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coin_b_value ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            outputCoinBAmountLabel.text = amountB.stringValue + (model.coin_b_name ?? "---")
        }
    }
    var liquidityInfoModel: AssetsPoolsInfoDataModel? {
        didSet {
            guard let model = liquidityInfoModel else {
                return
            }
            let coinAAmount = NSDecimalNumber.init(value: model.coina?.value ?? 0)
            let coinBAmount = NSDecimalNumber.init(value: model.coinb?.value ?? 0)
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                            scale: 4,
                                                            raiseOnExactness: false,
                                                            raiseOnOverflow: false,
                                                            raiseOnUnderflow: false,
                                                            raiseOnDivideByZero: false)
            let rate = coinBAmount.dividing(by: coinAAmount, withBehavior: numberConfig)
            self.exchangeRateLabel.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title") + "1:\(rate.stringValue)"
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
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
            // 重置View 状态
            self.viewState = .Normal
            self.autoCalculateMode = true
            
            if let tokenB = transferInInputTokenB {
                self.delegate?.getPoolLiquidity(inputModuleName: model.module ?? "",
                                                outputModuleName: tokenB.module ?? "")
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
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
            
            // 重置View 状态
            self.viewState = .Normal
            self.autoCalculateMode = true
            
            if let tokenA = transferInInputTokenA {
                self.delegate?.getPoolLiquidity(inputModuleName: tokenA.module ?? "",
                                                outputModuleName: model.module ?? "")
            }
        }
    }
    /// 自动试算模式
    var autoCalculateMode: Bool = true
    /// 语言切换
    @objc func setText() {
        if changeTypeButton.titleLabel?.text == localLanguage(keyString: "wallet_assets_pool_transfer_in_title") {
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
        } else {
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_out_title"), for: UIControl.State.normal)
        }
        changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        feeLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_fee_title")
        if transferInInputTokenA == nil {
            inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
//        inputTokenButton.snp.remakeConstraints { (make) in
//            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
//            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
//            let width = libraWalletTool.ga_widthForComment(content: content, fontSize: 12, height: 22) + 8 + 19
//            make.size.equalTo(CGSize.init(width: width, height: 22))
//        }
        if transferInInputTokenB == nil {
            outputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
            outputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenB?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
//        outputTokenButton.snp.remakeConstraints { (make) in
//            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
//            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
//            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
//            make.size.equalTo(CGSize.init(width: width, height: 22))
//        }
    }
}
extension AssetsPoolViewHeaderView: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        print(contents)
        if contents == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            outputTokenButton.alpha = 1
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
            // 调整位置
            changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            outputAmountTextField.alpha = 1
            outputCoinAAmountLabel.alpha = 0
            outputCoinBAmountLabel.alpha = 0
            outputTokenBackgroundView.snp.remakeConstraints { (make) in
                make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
                make.left.equalTo(self).offset(30)
                make.right.equalTo(self.snp.right).offset(-30)
                make.height.equalTo(80)
            }
            outputTokenAssetsImageView.alpha = 1
            outputTokenAssetsLabel.alpha = 1
            // 重置页面
            resetAssetsPoolTransferInView()
        } else {
            // 转出
            outputTokenButton.alpha = 0
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_out_title"), for: UIControl.State.normal)
            outputAmountTextField.alpha = 0
            outputCoinAAmountLabel.alpha = 1
            outputCoinBAmountLabel.alpha = 1
            outputTokenBackgroundView.snp.remakeConstraints { (make) in
                make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
                make.left.equalTo(self).offset(30)
                make.right.equalTo(self.snp.right).offset(-30)
                make.height.equalTo(95)
            }
            outputTokenAssetsImageView.alpha = 0
            outputTokenAssetsLabel.alpha = 0
            // 重置页面
            resetAssetsPoolTransferOutView()
        }
        changeTypeButton.snp.remakeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView.snp.left).offset(5)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20))
        }
        // 调整位置
        changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        
        transferInInputTokenA = nil
        transferInInputTokenB = nil
        transferOutModel = nil
        tokenModel = nil
    }
    func resetAssetsPoolTransferInView() {
        // 重置输入TokenA按钮
        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        inputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        // 重置数量
        inputAmountTextField.text = ""
        // 重置输入TokenB按钮
        outputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
        outputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        // 调整位置
        outputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        // 重置数量
        outputAmountTextField.text = ""
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_confirm_button_title"), for: UIControl.State.normal)
    }
    func resetAssetsPoolTransferOutView() {
        // 重置输入TokenA按钮
        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        inputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_token_title") + "---"
        // 重置试算数量
        outputCoinAAmountLabel.text = "---"
        outputCoinBAmountLabel.text = "---"
        // 重置数量
        inputAmountTextField.text = ""
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_confirm_button_title"), for: UIControl.State.normal)
    }
}
extension AssetsPoolViewHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                inputAmountTextField.text = ""
            }
        } else {
            if textLength == 0 {
                outputAmountTextField.text = ""
            }
        }
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 6 {
                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
            } else {
                return false
            }
        } else {
            if textLength <= ApplyTokenAmountLengthLimit {
                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
            } else {
                return false
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            guard inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
                textField.resignFirstResponder()
                self.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_first_deposit_token_content"),
                               position: .center)
                return false
            }
            guard outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
                textField.resignFirstResponder()
                self.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_second_deposit_token_content"),
                               position: .center)
                return false
            }
            
        } else {
            // 转出
            guard inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
                textField.resignFirstResponder()
                self.makeToast(localLanguage(keyString: "wallet_assets_pool_remove_liquidity_unselect_token"),
                               position: .center)
                return false
            }
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.tag == 10 {
            guard let model = liquidityInfoModel else {
                return
            }
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 资金池添加流动性
                guard let text = textField.text, text.isEmpty == false else {
                    self.inputAmountTextField.text = ""
                    self.outputAmountTextField.text = ""
                    return
                }
                self.viewState = .AssetsPoolTransferInBaseOnInputARequestRate
                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
                let coinAValue = NSDecimalNumber.init(value: model.coina?.value ?? 0)
                let rate = amount.dividing(by: coinAValue)
                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coinb?.value ?? 0).multiplying(by: rate),
                                               scale: 4,
                                               unit: 1000000)
                outputAmountTextField.text = amountB.stringValue
                self.viewState = .Normal
            } else {
                // 资金池移除流动性
                guard let text = textField.text, text.isEmpty == false else {
                    self.outputCoinAAmountLabel.text = "---"
                    self.outputCoinBAmountLabel.text = "---"
                    return
                }
                self.viewState = .AssetsPoolTransferInBaseOnInputBRequestRate
                let totalToken = NSDecimalNumber.init(value: model.liquidity_total_supply ?? 0)
                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
                let rate = amount.dividing(by: totalToken)
                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coina?.value ?? 0).multiplying(by: rate),
                                               scale: 4,
                                               unit: 1000000)
                outputCoinAAmountLabel.text = amountA.stringValue + (model.coina?.name ?? "---")
                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coinb?.value ?? 0).multiplying(by: rate),
                                               scale: 4,
                                               unit: 1000000)
                outputCoinBAmountLabel.text = amountB.stringValue + (model.coinb?.name ?? "---")
                self.viewState = .Normal
            }
        } else {
            guard outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
                return
            }
            guard autoCalculateMode == true else {
                return
            }
            guard let model = liquidityInfoModel else {
                return
            }
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 转入
                self.viewState = .AssetsPoolTransferInBaseOnInputBRequestRate
                guard let text = textField.text, text.isEmpty == false else {
                    self.inputAmountTextField.text = ""
                    self.outputAmountTextField.text = ""
                    return
                }
                self.viewState = .AssetsPoolTransferInBaseOnInputARequestRate
                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
                let coinBValue = NSDecimalNumber.init(value: model.coinb?.value ?? 0)
                let rate = amount.dividing(by: coinBValue)
                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coina?.value ?? 0).multiplying(by: rate),
                                               scale: 4,
                                               unit: 1000000)
                inputAmountTextField.text = amountA.stringValue
                self.viewState = .Normal
            }
        }
    }
    func handleInputAmount(textField: UITextField, content: String) -> Bool {
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        if textField.tag == 10 {
            if amount <= transferInInputTokenA?.amount ?? 0 {
                return true
            } else {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
                                              scale: 4,
                                              unit: 1000000)
                textField.text = amount.stringValue
                return false
            }
        } else {
            if amount <= transferInInputTokenB?.amount ?? 0 {
                return true
            } else {
                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenB?.amount ?? 0),
                                              scale: 4,
                                              unit: 1000000)
                textField.text = amount.stringValue
                return false
            }
        }
    }
}
