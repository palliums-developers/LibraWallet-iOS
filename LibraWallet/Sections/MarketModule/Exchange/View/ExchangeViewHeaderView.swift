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
    func exchangeConfirm()
    func selectInputToken()
    func selectOutoutToken()
    func swapInputOutputToken()
}
class ExchangeViewHeaderView: UIView {
    weak var delegate: ExchangeViewHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(feeLabel)
        addSubview(inputTokenBackgroundView)
        addSubview(inputTitleLabel)
        addSubview(inputAmountTextField)
        addSubview(inputTokenButton)
        addSubview(swapButton)
        addSubview(outputTokenBackgroundView)
        addSubview(outputTitleLabel)
        addSubview(outputAmountTextField)
        addSubview(outputTokenButton)
        addSubview(exchangeRateLabel)
        addSubview(minerFeeLabel)
        addSubview(confirmButton)
//        addSubview(exchangeTransactionsTitleLabel)
//        addSubview(titleIndicatorLabel)
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
            make.top.equalTo(self).offset(30)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(80)
        }
        inputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView).offset(16)
            make.left.equalTo(inputTokenBackgroundView).offset(15)
        }
        inputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView).offset(15)
            make.bottom.equalTo(inputTokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-88)
        }
        inputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
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
            make.height.equalTo(80)
        }
        outputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView).offset(16)
            make.left.equalTo(outputTokenBackgroundView).offset(15)
        }
        outputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.bottom.equalTo(outputTokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-88)
        }
        outputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
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
//        exchangeTransactionsTitleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(self).offset(14)
//            make.bottom.equalTo(titleIndicatorLabel.snp.top).offset(-6)
//        }
//        titleIndicatorLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(self).offset(14)
//            make.bottom.equalTo(self.snp.bottom).offset(-6)
//            make.size.equalTo(CGSize.init(width: 12, height: 2))
//        }
    }
    lazy var feeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
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
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_output_amount_title")
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
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
        return label
    }()
    lazy var minerFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
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
//    lazy var exchangeTransactionsTitleLabel: UILabel = {
//        let label = UILabel.init()
//        label.textAlignment = NSTextAlignment.left
//        label.textColor = UIColor.init(hex: "3D3949")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
//        label.text = localLanguage(keyString: "wallet_market_exchange_transactions_title")
//        return label
//    }()
//    lazy var titleIndicatorLabel: UILabel = {
//        let label = UILabel.init()
//        label.layer.backgroundColor = UIColor.init(hex: "#7038FD").cgColor
//        label.layer.cornerRadius = 3
//        return label
//    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.selectInputToken()
        } else if button.tag == 20 {
            self.delegate?.selectOutoutToken()
        } else if button.tag == 30 {
            self.delegate?.swapInputOutputToken()
        } else if button.tag == 100 {
            self.delegate?.exchangeConfirm()
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
//        exchangeTransactionsTitleLabel.text = localLanguage(keyString: "wallet_market_exchange_transactions_title")
        if inputTokenButton.titleLabel?.text == localLanguage(keyString: "wallet_market_exchange_input_token_button_title") {        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        }
        if outputTokenButton.titleLabel?.text == localLanguage(keyString: "wallet_market_exchange_output_token_button_title") {        outputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
        }
        
    }
}
extension ExchangeViewHeaderView: UITextFieldDelegate {
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        guard let content = textField.text else {
    //            return true
    //        }
    //        let textLength = content.count + string.count - range.length
    //        if textField.tag == 10 {
    //            if textLength == 0 {
    //                rightAmountTextField.text = ""
    //            }
    //        } else {
    //            if textLength == 0 {
    //                leftAmountTextField.text = ""
    //            }
    //        }
    //        if content.contains(".") {
    //            let firstContent = content.split(separator: ".").first?.description ?? "0"
    //            if (textLength - firstContent.count) < 6 {
    //                return true
    //            } else {
    //                return false
    //            }
    //        } else {
    //            return textLength <= ApplyTokenAmountLengthLimit
    //        }
    //    }
    //    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    //        if self.leftCoinButton.titleLabel?.text != "---" && self.rightCoinButton.titleLabel?.text != "---" {
    //            print("true")
    //            return true
    //        } else {
    //            print("false")
    //            return false
    //        }
    //    }
}
