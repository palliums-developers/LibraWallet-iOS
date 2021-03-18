//
//  MarketTokenSelectView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/3/15.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

protocol MarketTokenSelectViewViewDelegate: NSObjectProtocol {
    func selectToken(tag: Int)
    func calculateOutput(tag: Int, amountString: String)
}
class MarketTokenSelectView: UIView {
    weak var delegate: MarketTokenSelectViewViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(tokenBackgroundView)
        tokenBackgroundView.addSubview(titleLabel)
        tokenBackgroundView.addSubview(balanceIndicatorImageView)
        tokenBackgroundView.addSubview(balanceAmountLabel)
        tokenBackgroundView.addSubview(inputAmountTextField)
        tokenBackgroundView.addSubview(tokenButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketTokenSelectView销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView).offset(16)
            make.left.equalTo(tokenBackgroundView).offset(15)
        }
        balanceIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(balanceAmountLabel)
            make.right.equalTo(balanceAmountLabel.snp.left).offset(-2)
            make.size.equalTo(CGSize.init(width: 12, height: 13))
        }
        balanceAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView).offset(16)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
        }
        inputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(tokenBackgroundView).offset(15)
            make.bottom.equalTo(tokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-88)
        }
        tokenButton.snp.makeConstraints { (make) in
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
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
        return label
    }()
    private lazy var balanceIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "assets_pool_token")
        return imageView
    }()
    lazy var balanceAmountLabel: UILabel = {
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
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.tag = 10
        return textField
    }()
    lazy var tokenButton: UIButton = {
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
    @objc func buttonClick(button: UIButton) {
        if button.tag == 20 {
            self.inputAmountTextField.resignFirstResponder()
            self.delegate?.selectToken(tag: self.tag)
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
            balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_token_title") + amount.stringValue
            let content = (model.coin_a?.show_name ?? "---") + "/" + (model.coin_b?.show_name ?? "---")
            tokenButton.setTitle(content, for: UIControl.State.normal)
            // 调整位置
            tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            tokenButton.snp.remakeConstraints { (make) in
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
            tokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
        }
    }
    var swapTokenModel: MarketSupportTokensDataModel? {
        didSet {
            guard let model = swapTokenModel else {
                return
            }
            self.tokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            self.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            self.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-11)
                make.bottom.equalTo(self.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let unit = 1000000
            
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 6,
                                          unit: unit)
            self.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
        }
    }
    /// 语言切换
    @objc func setText() {
        //  刷新类型切换大小
        titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")

        if tokenModel == nil {
            tokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
            tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: tokenModel?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
        }
//        if transferInInputTokenA == nil {
//            self.tokenSelectViewA.tokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
//            self.tokenSelectViewA.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
//            self.tokenSelectViewA.tokenButton.snp.remakeConstraints { (make) in
//                make.right.equalTo(self.tokenSelectViewA.snp.right).offset(-11)
//                make.bottom.equalTo(self.tokenSelectViewA.snp.bottom).offset(-11)
//                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
//                make.size.equalTo(CGSize.init(width: width, height: 22))
//            }
//            self.tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + "---"
//        } else {
//            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: transferInInputTokenA?.amount ?? 0),
//                                          scale: 6,
//                                          unit: 1000000)
//            self.tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_exchange_token_title") + amount.stringValue
//        }
    }
}
extension MarketTokenSelectView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = (content.count + string.count) - range.length
        if textLength == 0 {
            self.inputAmountTextField.text = ""
        }
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 8 {
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
        guard self.tokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") else {
            textField.resignFirstResponder()
            self.makeToast(localLanguage(keyString: "wallet_market_exchange_input_token_unselect"), position: .center)
            return false
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.delegate?.calculateOutput(tag: self.tag, amountString: textField.text ?? "")
    }
    func handleInputAmount(textField: UITextField, content: String) -> Bool {
        guard isPurnDouble(string: content) else {
            return false
        }
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).int64Value
        if amount <= self.swapTokenModel?.amount ?? 0 {
            return true
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: self.swapTokenModel?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            textField.text = amount.stringValue
            return false
        }
    }
}
