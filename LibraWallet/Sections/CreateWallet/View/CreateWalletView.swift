//
//  CreateWalletView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol CreateWalletViewDelegate: NSObjectProtocol {
    func comfirmCreateWallet(walletName: String, password: String)
}
class CreateWalletView: UIView {
    weak var delegate: CreateWalletViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "191F3A")
        addSubview(walletNameTextField)
        addSubview(paymentPasswordTextField)
        addSubview(paymentPasswordConfirmTextField)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("CreateWalletView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        walletNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(100)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 200, height: 44))
        }
        paymentPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(walletNameTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 200, height: 44))
        }
        paymentPasswordConfirmTextField.snp.makeConstraints { (make) in
            make.top.equalTo(paymentPasswordTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 200, height: 44))
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-50)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 200, height: 44))
        }
    }
    lazy var walletNameTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "D4D4D4")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_login_uid_password_textfield_placeholder"),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "A0A3AF"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 15))])
        textField.tintColor = DefaultGreenColor
        textField.tag = 10
        textField.backgroundColor = UIColor.gray
        return textField
    }()
    lazy var paymentPasswordTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "D4D4D4")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_login_uid_password_textfield_placeholder"),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "A0A3AF"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 15))])
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 20
        textField.backgroundColor = UIColor.gray

        return textField
    }()
    lazy var paymentPasswordConfirmTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "D4D4D4")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_login_uid_password_textfield_placeholder"),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "A0A3AF"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 15))])
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 30
        textField.backgroundColor = UIColor.gray
        return textField
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_create_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true

        return button
    }()
    @objc func buttonClick(button: UIButton) {
        guard let name = walletNameTextField.text else {
            // 拆包失败
            self.makeToast(localLanguage(keyString: "拆包失败"),
                           position: .center)
            return
        }
        guard name.isEmpty == false else {
            // 名字为空
            self.makeToast(localLanguage(keyString: "名字为空"),
                           position: .center)
            return
        }
        guard let password = paymentPasswordTextField.text else {
            // 拆包失败
            self.makeToast(localLanguage(keyString: "拆包失败"),
                           position: .center)
            return
        }
        guard password.isEmpty == false else {
            // 密码为空
            self.makeToast(localLanguage(keyString: "密码为空"),
                           position: .center)
            return
        }
        guard let passwordConfirm = paymentPasswordConfirmTextField.text else {
            // 确认密码拆包失败
            self.makeToast(localLanguage(keyString: "拆包失败"),
                           position: .center)
            return
        }
        guard passwordConfirm.isEmpty == false else {
            // 确认密码为空
            self.makeToast(localLanguage(keyString: "密码为空"),
                           position: .center)
            return
        }
        guard password == passwordConfirm else {
            // 密码不一致
            self.makeToast(localLanguage(keyString: "密码不一致"),
                           position: .center)
            return
        }
        #warning("密码规则检查")
        self.delegate?.comfirmCreateWallet(walletName: name, password: password)
    }
}
extension CreateWalletView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        #warning("规则待定")
        guard textField.tag == 10 else {
            return true
        }
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        
        return textLength<=6
    }
}
