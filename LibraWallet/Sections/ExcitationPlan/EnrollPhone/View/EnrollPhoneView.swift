//
//  EnrollPhoneView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import AttributedTextView

protocol EnrollPhoneViewDelegate: NSObjectProtocol {
    func selectPhoneArea()
    func getSecureCode()
    func confirmVerifyMobilePhone()
}
class EnrollPhoneView: UIView {
    weak var delegate: EnrollPhoneViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tipsTextView)
        addSubview(phoneNumberTextField)
        addSubview(phoneNumberSpaceLabel)
        addSubview(secureCodeTextField)
        addSubview(secureCodeSpaceLabel)
        addSubview(invitedAddressTextField)
        addSubview(invitedAddressSpaceLabel)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("EnrollPhoneView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tipsTextView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(88)
        }
        phoneNumberTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneNumberSpaceLabel.snp.top)
            make.left.right.equalTo(phoneNumberSpaceLabel)
            make.height.equalTo(52)
        }
        phoneNumberSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipsTextView.snp.bottom).offset(82)
            make.left.equalTo(self).offset(34)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(0.5)
        }
        secureCodeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumberSpaceLabel.snp.bottom)
            make.bottom.equalTo(secureCodeSpaceLabel.snp.top)
            make.left.right.equalTo(secureCodeSpaceLabel)
        }
        secureCodeSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumberSpaceLabel.snp.bottom).offset(52)
            make.left.equalTo(self).offset(34)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(0.5)
        }
        invitedAddressTextField.snp.makeConstraints { (make) in
            make.top.equalTo(secureCodeSpaceLabel.snp.bottom)
            make.bottom.equalTo(invitedAddressSpaceLabel.snp.top)
            make.left.right.equalTo(invitedAddressSpaceLabel)
        }
        invitedAddressSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(secureCodeSpaceLabel.snp.bottom).offset(52)
            make.left.equalTo(self).offset(34)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(0.5)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(invitedAddressSpaceLabel.snp.bottom).offset(57)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
        }
    }
    // MARK: - 懒加载对象
    lazy var tipsTextView: RSKPlaceholderTextView = {
        let textView = RSKPlaceholderTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.textColor = UIColor.init(hex: "5C5C5C")
        textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        textView.backgroundColor = UIColor.init(hex: "F7F7F7")
        textView.layer.cornerRadius = 16
        textView.tintColor = DefaultGreenColor
        textView.isEditable = false
        textView.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_bind_phone_tips_content"),
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "5C5C5C"),
                                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        return textView
    }()
    lazy var phoneNumberTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_bind_phone_phone_number_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        textField.delegate = self
        textField.keyboardType = .phonePad
        textField.tintColor = DefaultGreenColor
        textField.tag = 10
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 52))
        leftView.addSubview(phoneAreaButton)
        textField.leftView = leftView
        textField.leftViewMode = .always
        return textField
    }()
    lazy var phoneNumberSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var secureCodeTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_bind_phone_phone_secure_code_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.tintColor = DefaultGreenColor
        textField.tag = 20
        let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_bind_phone_get_secure_code_button_title"),
                                                       fontSize: 12,
                                                       height: 52)
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width + 2.5, height: 52))
        rightView.addSubview(secureCodeButtonSpaceLabel)
        rightView.addSubview(secureCodeButton)
        textField.rightView = rightView
        textField.rightViewMode = .always
        return textField
    }()
    lazy var secureCodeSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var invitedAddressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_bind_phone_phone_invited_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        textField.delegate = self
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        textField.tag = 30
        return textField
    }()
    lazy var invitedAddressSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var phoneAreaButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 52))
        button.setTitle("+ 00", for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "333333"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.bold)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var secureCodeButtonSpaceLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 14, width: 1, height: 24))
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var secureCodeButton: GSCaptchaButton = {
        let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_bind_phone_get_secure_code_button_title"),
                                                       fontSize: 12,
                                                       height: 52)
        let button = GSCaptchaButton.init(frame: CGRect.init(x: 2.5, y: 0, width: width, height: 52))
        button.setTitle(localLanguage(keyString: "wallet_bind_phone_get_secure_code_button_title"), for: UIControl.State.normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "5C5C5C"), for: UIControl.State.disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.bold)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bind_phone_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: 238, height: 40)), at: 0)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    lazy var toastView: ToastView = {
        let toast = ToastView.init()
        return toast
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.confirmVerifyMobilePhone()
        } else if button.tag == 20 {
            self.delegate?.selectPhoneArea()
        } else {
            self.delegate?.getSecureCode()
        }
    }
}
extension EnrollPhoneView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        
        if tag == 10 {
            return textLength <= NameMaxLimit
        } else {
            return textLength <= PasswordMaxLimit
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            self.phoneNumberSpaceLabel.backgroundColor = UIColor.init(hex: "7038FD")
            self.secureCodeSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
            self.invitedAddressSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
        } else if textField.tag == 20 {
            self.phoneNumberSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
            self.secureCodeSpaceLabel.backgroundColor = UIColor.init(hex: "7038FD")
            self.invitedAddressSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
        } else {
            self.phoneNumberSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
            self.secureCodeSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
            self.invitedAddressSpaceLabel.backgroundColor = UIColor.init(hex: "7038FD")
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if self.phoneNumberTextField.isEditing == false && self.secureCodeTextField.isEditing == false {
            self.phoneNumberSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
            self.secureCodeSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
            self.invitedAddressSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
        }
    }
}
