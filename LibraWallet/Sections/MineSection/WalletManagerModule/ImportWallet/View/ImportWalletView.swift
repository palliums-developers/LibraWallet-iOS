//
//  ImportWalletView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import AttributedTextView
protocol ImportWalletViewDelegate: NSObjectProtocol {
    func confirmImportWallet(password: String, mnemonics: [String])
    func openPrivacyPolicy()
    func openServiceAgreement()
}
class ImportWalletView: UIView {
    weak var delegate: ImportWalletViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mnemonicTextView)
        addSubview(passwordTextField)
        addSubview(passwordSpaceLabel)
        addSubview(passwordConfirmTextField)
        addSubview(passwordConfirmSpaceLabel)
        addSubview(confirmButton)
        addSubview(legalButton)
        addSubview(legalContentTextView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ImportWalletView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        mnemonicTextView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(17)
            make.left.equalTo(self).offset(19)
            make.right.equalTo(self).offset(-19)
            make.height.equalTo(165)
        }
        passwordTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(passwordSpaceLabel.snp.top)
            make.left.right.equalTo(passwordSpaceLabel)
            make.height.equalTo(51)
        }
        passwordSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mnemonicTextView.snp.bottom).offset(76)
            make.left.equalTo(self).offset(35)
            make.right.equalTo(self).offset(-35)
            make.height.equalTo(0.5)
        }
        passwordConfirmTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordSpaceLabel.snp.bottom)
            make.bottom.equalTo(passwordConfirmSpaceLabel.snp.top)
            make.left.right.equalTo(passwordConfirmSpaceLabel)
        }
        passwordConfirmSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(passwordSpaceLabel.snp.bottom).offset(51)
            make.left.equalTo(self).offset(35)
            make.right.equalTo(self).offset(-35)
            make.height.equalTo(0.5)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordConfirmSpaceLabel.snp.bottom).offset(48)
            make.left.equalTo(self).offset(68)
            make.right.equalTo(self.snp.right).offset(-68)
            make.height.equalTo(40)
        }
        legalButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmButton.snp.bottom).offset(10)
            make.left.equalTo(confirmButton).offset(15)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        legalContentTextView.snp.makeConstraints { (make) in
            make.top.equalTo(legalButton).offset(-3)
            make.left.equalTo(legalButton.snp.right)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(60)
        }
    }
    // MARK: - 懒加载对象
    lazy var mnemonicTextView: RSKPlaceholderTextView = {
        //#263C4E
        let textView = RSKPlaceholderTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.textColor = UIColor.init(hex: "62606B")
        textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        textView.backgroundColor = UIColor.init(hex: "F8F7FA")
        textView.tintColor = DefaultGreenColor
        textView.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_import_mnemonic_textview_placeholder"),
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),
                                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        return textView
    }()
    lazy var passwordTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_add_wallet_password_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BDBCC0"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        textField.delegate = self
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 20
        textField.rightView = showPasswordButton
        textField.rightViewMode = .always
        return textField
    }()
    lazy var passwordSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var passwordConfirmTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_add_wallet_password_confirm_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BDBCC0"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        textField.delegate = self
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 30
        return textField
    }()
    lazy var passwordConfirmSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var showPasswordButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "eyes_close_black"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_import_wallet_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: UIScreen.main.bounds.size.width - 136, height: 40)), at: 0)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    lazy var legalButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "unselect"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    private lazy var legalContentTextView: AttributedTextView = {
        let textView = AttributedTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.attributer = localLanguage(keyString: "wallet_import_wallet_legal_content_title")
            .color(UIColor.init(hex: "999999"))
            .font(UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular))
            .match(localLanguage(keyString: "wallet_private_agreement_title")).underline.makeInteract({ _ in
                self.delegate?.openPrivacyPolicy()
            })
            .match(localLanguage(keyString: "wallet_user_agreement_title")).underline.makeInteract({ _ in
                self.delegate?.openServiceAgreement()
            })
        return textView
    }()
    var toastView: ToastView {
        let toast = ToastView.init()
        return toast
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            guard let mnemonic = mnemonicTextView.text else {
                //助记词拆包异常
                self.makeToast(LibraWalletError.WalletImportWallet(reason: .mnemonicInvalidError).localizedDescription,
                               position: .center)
                return
            }
            guard mnemonic.isEmpty == false else {
                //助记词为空
                self.makeToast(LibraWalletError.WalletImportWallet(reason: .mnemonicEmptyError).localizedDescription,
                               position: .center)
                return
            }
            let tempArray = mnemonic.split(separator: " ").map {
                $0.description
            }
            guard tempArray.isEmpty == false else {
                //请输入助记词
                self.makeToast(LibraWalletError.WalletImportWallet(reason: .mnemonicSplitFailedError).localizedDescription,
                               position: .center)
                return
            }
//            24 21 18 15 12
            if tempArray.count == 24 || tempArray.count == 21 || tempArray.count == 18 || tempArray.count == 15 || tempArray.count == 12 {
                guard checkMnenoicInvalid(mnemonicArray: tempArray) == true else {
                    // 助记词不正确
                    self.makeToast(LibraWalletError.WalletImportWallet(reason: .mnemonicCheckFailed).localizedDescription,
                                   position: .center)
                    return
                }
            } else {
                // 助记词数量不对
                self.makeToast(LibraWalletError.WalletImportWallet(reason: .mnemonicCountUnsupportError).localizedDescription,
                               position: .center)
                return
            }
            guard let password = passwordTextField.text, password.isEmpty == false else {
                // 密码为空
                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordEmptyError).localizedDescription,
                               position: .center)
                return
            }
            guard handlePassword(password: password) else {
                // 密码规则
                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordInvalidError).localizedDescription,
                               position: .center)
                return
            }
            guard let passwordConfirm = passwordConfirmTextField.text, passwordConfirm.isEmpty == false else {
                // 确认密码为空
                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordConfirmEmptyError).localizedDescription,
                               position: .center)
                return
            }
            guard handlePassword(password: passwordConfirm) else {
                // 密码规则
                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordCofirmInvalidError).localizedDescription,
                               position: .center)
                return
            }
            guard password == passwordConfirm else {
                // 密码不一致
                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordCheckFailed).localizedDescription,
                               position: .center)
                return
            }
            guard legalButton.imageView?.image != UIImage.init(named: "unselect") else {
                // 未同意协议
                self.makeToast(LibraWalletError.WalletAddWallet(reason: .notAgreeLegalError).localizedDescription,
                               position: .center)
                return
            }
            self.passwordTextField.resignFirstResponder()
            self.passwordConfirmTextField.resignFirstResponder()
            self.delegate?.confirmImportWallet(password: password, mnemonics: tempArray)
        } else if button.tag == 20 {
            if button.imageView?.image == UIImage.init(named: "eyes_close_black") {
                self.passwordTextField.isSecureTextEntry = false
                self.passwordConfirmTextField.isSecureTextEntry = false
                button.setImage(UIImage.init(named: "eyes_open_black"), for: UIControl.State.normal)
            } else {
                self.passwordTextField.isSecureTextEntry = true
                self.passwordConfirmTextField.isSecureTextEntry = true
                button.setImage(UIImage.init(named: "eyes_close_black"), for: UIControl.State.normal)
            }
        } else {
            if button.imageView?.image == UIImage.init(named: "unselect") {
                button.setImage(UIImage.init(named: "selected"), for: UIControl.State.normal)
            } else {
                button.setImage(UIImage.init(named: "unselect"), for: UIControl.State.normal)
            }
        }
    }
}
extension ImportWalletView: UITextFieldDelegate {
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
          if textField.tag == 20 {
              self.passwordSpaceLabel.backgroundColor = UIColor.init(hex: "7038FD")
              self.passwordConfirmSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
          } else {
              self.passwordSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
              self.passwordConfirmSpaceLabel.backgroundColor = UIColor.init(hex: "7038FD")
          }
      }
      func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
          if self.passwordTextField.isEditing == false && self.passwordConfirmTextField.isEditing == false {
              self.passwordSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
              self.passwordConfirmSpaceLabel.backgroundColor = UIColor.init(hex: "DEDFE0")
          }
      }
}
