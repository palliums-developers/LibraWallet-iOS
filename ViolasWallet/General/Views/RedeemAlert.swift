//
//  RedeemAlert.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/9/8.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class RedeemAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(titleLabel)
        whiteBackgroundView.addSubview(closeButton)
        whiteBackgroundView.addSubview(amountTextField)
        whiteBackgroundView.addSubview(tokenIndicatorImageView)
        whiteBackgroundView.addSubview(tokenAmountTitleLabel)
        whiteBackgroundView.addSubview(tokenAmountLabel)
        whiteBackgroundView.addSubview(totalAmountSelectButton)
        whiteBackgroundView.addSubview(grayBackgroundView)
        grayBackgroundView.addSubview(redeemAlertIndicatorImageView)
        grayBackgroundView.addSubview(redeemAlertContentLabel)
        whiteBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("RedeemAlert销毁了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(-100)
            make.left.equalTo(self).offset(43)
            make.right.equalTo(self.snp.right).offset(-43)
            make.height.equalTo(342)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(whiteBackgroundView)
            make.top.equalTo(whiteBackgroundView).offset(21)
        }
        closeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-21)
        }
        amountTextField.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(67)
            make.left.equalTo(whiteBackgroundView).offset(23)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-23)
            make.height.equalTo(48)
        }
        tokenIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(amountTextField.snp.bottom).offset(13)
            make.left.equalTo(whiteBackgroundView).offset(34)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        tokenAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIndicatorImageView)
            make.left.equalTo(tokenIndicatorImageView.snp.right).offset(4)
        }
        tokenAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIndicatorImageView)
            make.left.equalTo(tokenAmountTitleLabel.snp.right).offset(4)
        }
        totalAmountSelectButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIndicatorImageView)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-30)
        }
        grayBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(amountTextField.snp.bottom).offset(45)
            make.left.equalTo(whiteBackgroundView).offset(23)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-23)
            let height = 7 + libraWalletTool.ga_heightForComment(content: localLanguage(keyString: "wallet_bank_redeem_alert_warring_content"), fontSize: 11, width: (mainWidth - 46 - 86 - 24 - 7)) + 7
            make.height.equalTo(height)
        }
        redeemAlertIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(grayBackgroundView).offset(10)
            make.left.equalTo(grayBackgroundView).offset(8)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        redeemAlertContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(grayBackgroundView).offset(7)
            make.left.equalTo(grayBackgroundView).offset(24)
            make.bottom.equalTo(grayBackgroundView.snp.bottom).offset(-7)
            make.right.equalTo(grayBackgroundView.snp.right).offset(-7)

        }
        confirmButton.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(26)
            make.bottom.equalTo(whiteBackgroundView.snp.bottom).offset(-46)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-26)
            make.height.equalTo(40)
        }
    }
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 4
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_redeem_alert_title")
        return label
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "close_black"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var amountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_bank_redeem_alert_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        textField.layer.borderColor = UIColor.init(hex: "DEDEDE").cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 3
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 8, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 48))
        rightView.addSubview(amountUnitTitleLabel)
        textField.rightView = rightView
        textField.rightViewMode = .always
        textField.tag = 20
        textField.delegate = self
        return textField
    }()
    lazy var amountUnitTitleLabel: UILabel = {
        let width = 16 + libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "---"), fontSize: 12, height: 22) + 16
        let label = UILabel.init(frame: CGRect.init(x: 100 - width, y: 0, width: width, height: 48))
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var tokenIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.image = UIImage.init(named: "wallet_bank_deposit_balance")
        return imageView
    }()
    lazy var tokenAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_redeem_alert_amount_title")
        return label
    }()
    lazy var tokenAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.medium)
        label.text = "---"
        return label
    }()
    lazy var totalAmountSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_redeem_alert_amount_select_total_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    private lazy var grayBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.init(hex: "F7F7F7").cgColor
        view.layer.cornerRadius = 3
        return view
    }()
    private lazy var redeemAlertIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.image = UIImage.init(named: "bank_redeem_alert")
        return imageView
    }()
    lazy var redeemAlertContentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_redeem_alert_warring_content")
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_bank_redeem_alert_confirm_button_title"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = DefaultGreenColor.cgColor
        button.layer.cornerRadius = 4
        button.tag = 30
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.amountTextField.resignFirstResponder()
        if button.tag == 10 {
            self.hide(tag: self.tag)
        } else if button.tag == 20 {
            guard let tempModel = model else {
                return
            }
            amountTextField.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.available_quantity ?? 0),
                                                    scale: 6,
                                                    unit: 1000000).stringValue
        } else {
            do {
                let amount = try handleConfirmCondition()
                if let action = self.withdrawClosure {
                    action(amount)
                }
            } catch {
                self.whiteBackgroundView.makeToast(error.localizedDescription, position: .center)
            }
        }
    }
    func handleConfirmCondition() throws -> (UInt64) {
        // 获取输入借贷金额
        guard let amountString = self.amountTextField.text, amountString.isEmpty == false else {
            throw LibraWalletError.WalletBankWithdraw(reason: .amountEmpty)
        }
        // 检查金额是否为纯数字
        guard isPurnDouble(string: amountString) else {
            throw LibraWalletError.WalletBankWithdraw(reason: .amountInvalid)
        }
        let amount = NSDecimalNumber.init(string: amountString).multiplying(by: NSDecimalNumber.init(value: 1000000))
        // 检查是否低于最低借贷金额
        guard amount.uint64Value <= (self.model?.available_quantity ?? 0) else {
            throw LibraWalletError.WalletBankWithdraw(reason: .amountTooLarge)
        }
        return amount.uint64Value
    }
    var withdrawClosure: ((UInt64) -> Void)?
    var model: DepositOrderWithdrawMainDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            self.amountUnitTitleLabel.text = tempModel.token_show_name
            self.tokenAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.available_quantity ?? 0),
                                                          scale: 6,
                                                          unit: 1000000).stringValue + (tempModel.token_show_name ?? "")
        }
    }
}
extension RedeemAlert: actionViewProtocol {
    
}
extension RedeemAlert: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                textField.text = ""
            }
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
    private func handleInputAmount(textField: UITextField, content: String) -> Bool {
        let amount = NSDecimalNumber.init(string: content).multiplying(by: NSDecimalNumber.init(value: 1000000)).uint64Value
        let leastAmount = NSDecimalNumber.init(value: self.model?.available_quantity ?? 0)
        if amount <= leastAmount.uint64Value {
            return true
        } else {
            let amount = getDecimalNumber(amount: leastAmount,
                                          scale: 6,
                                          unit: 1000000)
            textField.text = amount.stringValue
            return false
        }
    }
}
