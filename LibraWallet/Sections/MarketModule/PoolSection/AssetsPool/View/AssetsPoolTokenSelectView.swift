//
//  AssetsPoolTokenSelectView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/7.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

protocol AssetsPoolTokenSelectViewDelegate: NSObjectProtocol {
    func selectToken()
}
class AssetsPoolTokenSelectView: UIView {
    weak var delegate: AssetsPoolTokenSelectViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(tokenBackgroundView)
        tokenBackgroundView.addSubview(inputTitleLabel)
        tokenBackgroundView.addSubview(inputTokenAssetsImageView)
        tokenBackgroundView.addSubview(inputTokenAssetsLabel)
        tokenBackgroundView.addSubview(inputAmountTextField)
        tokenBackgroundView.addSubview(inputTokenButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolTokenSelectView销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(40)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(80)
        }
        inputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView).offset(16)
            make.left.equalTo(tokenBackgroundView).offset(15)
        }
        inputTokenAssetsImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(inputTokenAssetsLabel)
            make.right.equalTo(inputTokenAssetsLabel.snp.left).offset(-2)
            make.size.equalTo(CGSize.init(width: 12, height: 13))
        }
        inputTokenAssetsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView).offset(16)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
        }
        inputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(tokenBackgroundView).offset(15)
            make.bottom.equalTo(tokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-88)
        }
        inputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11).priority(250)
            make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22)).priority(250)
        }
    }
    private lazy var tokenBackgroundView: UIView = {
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
        textField.tintColor = DefaultGreenColor
//        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
//        textField.delegate = self
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
        if button.tag == 20 {
            self.inputAmountTextField.resignFirstResponder()
            self.delegate?.selectToken()
        }
    }
    /// 通证Model
    var liquidityTokenModel: MarketMineMainTokensDataModel? {
        didSet {
            guard let model = liquidityTokenModel else {
                return
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.token ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_token_title") + amount.stringValue
            let content = (model.coin_a?.show_name ?? "---") + "/" + (model.coin_b?.show_name ?? "---")
            inputTokenButton.setTitle(content, for: UIControl.State.normal)
            // 调整位置
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: content, fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
        }
    }
    /// 资金池转入Model
    var tokenModel: MarketSupportTokensDataModel? {
        didSet {
            guard let model = tokenModel else {
                return
            }
            inputTokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
        }
    }
    var addLiquidityMode: Bool = true {
        didSet {
            if addLiquidityMode == true {
                // 转入
                // 重置页面
                resetAssetsPoolTransferInView()
            } else {
                // 转出
                // 重置页面
                resetAssetsPoolTransferOutView()
            }
        }
    }
    /// 语言切换
    @objc func setText() {
        //  刷新类型切换大小
        inputTitleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")

        if tokenModel == nil {
            inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: tokenModel?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
        }
    }
}
extension AssetsPoolTokenSelectView: DropperDelegate {
//    func DropperSelectedRow(_ path: IndexPath, contents: String) {
//        print(contents)
//        if contents == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//            // 转入
//            self.addLiquidityMode = true
//            outputTokenButton.alpha = 1
//            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
//            // 调整位置
//            changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
//            outputAmountTextField.alpha = 1
//            outputCoinAAmountLabel.alpha = 0
//            outputCoinBAmountLabel.alpha = 0
//            outputTokenBackgroundView.snp.remakeConstraints { (make) in
//                make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
//                make.left.equalTo(self).offset(30)
//                make.right.equalTo(self.snp.right).offset(-30)
//                make.height.equalTo(80)
//            }
//            outputTokenAssetsImageView.alpha = 1
//            outputTokenAssetsLabel.alpha = 1
//            // 重置页面
//            resetAssetsPoolTransferInView()
//        } else {
//            // 转出
//            self.addLiquidityMode = false
//            outputTokenButton.alpha = 0
//            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_out_title"), for: UIControl.State.normal)
//            outputAmountTextField.alpha = 0
//            outputCoinAAmountLabel.alpha = 1
//            outputCoinBAmountLabel.alpha = 1
//            outputTokenBackgroundView.snp.remakeConstraints { (make) in
//                make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
//                make.left.equalTo(self).offset(30)
//                make.right.equalTo(self.snp.right).offset(-30)
//                make.height.equalTo(95)
//            }
//            outputTokenAssetsImageView.alpha = 0
//            outputTokenAssetsLabel.alpha = 0
//            // 重置页面
//            resetAssetsPoolTransferOutView()
//        }
//        changeTypeButton.snp.remakeConstraints { (make) in
//            make.left.equalTo(inputTokenBackgroundView.snp.left).offset(5)
//            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6)
//            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
//            make.size.equalTo(CGSize.init(width: width, height: 20))
//        }
//        // 调整位置
//        changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
//
//        transferInInputTokenA = nil
//        transferInInputTokenB = nil
//        transferOutModel = nil
//        tokenModel = nil
//    }
    func resetAssetsPoolTransferInView() {
        // 重置输入TokenA按钮
        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        inputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        // 重置数量
        inputAmountTextField.text = ""
        tokenModel = nil
        liquidityTokenModel = nil
    }
    func resetAssetsPoolTransferOutView() {
        // 重置输入TokenA按钮
        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        inputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_token_title") + "---"
        tokenModel = nil
        liquidityTokenModel = nil
    }
}
//extension AssetsPoolAddLiquidityView: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let content = textField.text else {
//            return true
//        }
//        let textLength = content.count + string.count - range.length
//        if textField.tag == 10 {
//            if textLength == 0 {
//                inputAmountTextField.text = ""
//            }
//        } else {
//            if textLength == 0 {
//                outputAmountTextField.text = ""
//            }
//        }
//        if content.contains(".") {
//            let firstContent = content.split(separator: ".").first?.description ?? "0"
//            if (textLength - firstContent.count) < 8 {
//                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
//            } else {
//                return false
//            }
//        } else {
//            if textLength <= ApplyTokenAmountLengthLimit {
//                return handleInputAmount(textField: textField, content: (content.isEmpty == true ? "0":content) + string)
//            } else {
//                return false
//            }
//        }
//    }
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//            // 转入
//            guard inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
//                textField.resignFirstResponder()
//                self.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_first_deposit_token_content"),
//                               position: .center)
//                return false
//            }
//            guard outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
//                textField.resignFirstResponder()
//                self.makeToast(localLanguage(keyString: "wallet_assets_pool_add_liquidity_unselect_second_deposit_token_content"),
//                               position: .center)
//                return false
//            }
//
//        } else {
//            // 转出
//            guard inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
//                textField.resignFirstResponder()
//                self.makeToast(localLanguage(keyString: "wallet_assets_pool_remove_liquidity_unselect_token"),
//                               position: .center)
//                return false
//            }
//        }
//        return true
//    }
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        if textField.tag == 10 {
//            guard let model = liquidityInfoModel else {
//                return
//            }
//            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//                // 资金池添加流动性
//                guard let text = textField.text, text.isEmpty == false else {
//                    self.inputAmountTextField.text = ""
//                    self.outputAmountTextField.text = ""
//                    return
//                }
//                self.viewState = .AssetsPoolTransferInBaseOnInputARequestRate
//                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
//                let coinAValue = NSDecimalNumber.init(value: model.coina?.value ?? 0)
//                let rate = amount.dividing(by: coinAValue)
//                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coinb?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                outputAmountTextField.text = amountB.stringValue
//                self.viewState = .Normal
//            } else {
//                // 资金池移除流动性
//                guard let text = textField.text, text.isEmpty == false else {
//                    self.outputCoinAAmountLabel.text = "---"
//                    self.outputCoinBAmountLabel.text = "---"
//                    return
//                }
//                self.viewState = .AssetsPoolTransferInBaseOnInputBRequestRate
//                let totalToken = NSDecimalNumber.init(value: model.liquidity_total_supply ?? 0)
//                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
//                let rate = amount.dividing(by: totalToken)
//                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coina?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                outputCoinAAmountLabel.text = amountA.stringValue + (model.coina?.name ?? "---")
//                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coinb?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                outputCoinBAmountLabel.text = amountB.stringValue + (model.coinb?.name ?? "---")
//                self.viewState = .Normal
//            }
//        } else {
//            guard outputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_output_token_button_title") else {
//                return
//            }
//            guard autoCalculateMode == true else {
//                return
//            }
//            guard let model = liquidityInfoModel else {
//                return
//            }
//            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//                // 转入
//                self.viewState = .AssetsPoolTransferInBaseOnInputBRequestRate
//                guard let text = textField.text, text.isEmpty == false else {
//                    self.inputAmountTextField.text = ""
//                    self.outputAmountTextField.text = ""
//                    return
//                }
//                self.viewState = .AssetsPoolTransferInBaseOnInputARequestRate
//                let amount = NSDecimalNumber.init(string: text).multiplying(by: NSDecimalNumber.init(value: 1000000))
//                let coinBValue = NSDecimalNumber.init(value: model.coinb?.value ?? 0)
//                let rate = amount.dividing(by: coinBValue)
//                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coina?.value ?? 0).multiplying(by: rate),
//                                               scale: 6,
//                                               unit: 1000000)
//                inputAmountTextField.text = amountA.stringValue
//                self.viewState = .Normal
//            }
//        }
//    }
//    func handleInputAmount(textField: UITextField, content: String) -> Bool {
//        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
//        if textField.tag == 10 {
//            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
//                if amount <= transferInInputTokenA?.amount ?? 0 {
//                    return true
//                } else {
//                    let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
//                                                  scale: 6,
//                                                  unit: 1000000)
//                    textField.text = amount.stringValue
//                    return false
//                }
//            } else {
//                if amount <= tokenModel?.token ?? 0 {
//                    return true
//                } else {
//                    let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: tokenModel?.token ?? 0),
//                                                  scale: 6,
//                                                  unit: 1000000)
//                    textField.text = amount.stringValue
//                    return false
//                }
//            }
//
//        } else {
//            if amount <= transferInInputTokenB?.amount ?? 0 {
//                return true
//            } else {
//                let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenB?.amount ?? 0),
//                                              scale: 6,
//                                              unit: 1000000)
//                textField.text = amount.stringValue
//                return false
//            }
//        }
//    }
//}
