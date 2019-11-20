//
//  AddWalletView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AddWalletViewDelegate: NSObjectProtocol {
    func confirmAddWallet(name: String, password: String)
}
class AddWalletView: UIView {
    weak var delegate: AddWalletViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(coinTypeIcon)
        addSubview(nameLabel)
        addSubview(nameTextField)
        addSubview(nameSpaceLabel)
        addSubview(passwordTextField)
        addSubview(passwordSpaceLabel)
        addSubview(passwordConfirmTextField)
        addSubview(passwordConfirmSpaceLabel)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AddWalletView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        coinTypeIcon.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(46)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 65, height: 65))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(coinTypeIcon.snp.bottom).offset(18)
        }
        nameTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.height.equalTo(51)
            make.bottom.equalTo(nameSpaceLabel.snp.top)
            make.left.right.equalTo(nameSpaceLabel)
        }
        nameSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(82)
            make.left.equalTo(self).offset(35)
            make.right.equalTo(self).offset(-35)
            make.height.equalTo(1)
        }
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameSpaceLabel.snp.bottom)
            make.bottom.equalTo(passwordSpaceLabel.snp.top)
            make.left.right.equalTo(passwordSpaceLabel)
        }
        passwordSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameSpaceLabel.snp.bottom).offset(51)
            make.left.equalTo(self).offset(35)
            make.right.equalTo(self).offset(-35)
            make.height.equalTo(1)
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
            make.height.equalTo(1)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordConfirmSpaceLabel.snp.bottom).offset(48)
            make.left.equalTo(self).offset(68)
            make.right.equalTo(self.snp.right).offset(-68)
            make.height.equalTo(40)
        }
    }
    //MARK: - 懒加载对象
    private lazy var coinTypeIcon : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "0E0051")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var nameTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_add_wallet_nickname_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BDBCC0"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var nameSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var passwordTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_add_wallet_password_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BDBCC0"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var passwordSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var passwordConfirmTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_add_wallet_password_confirm_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BDBCC0"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var passwordConfirmSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_add_wallet_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: UIScreen.main.bounds.size.width - 136, height: 40)), at: 0)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    var toastView: ToastView {
        let toast = ToastView.init()
        return toast
    }
    @objc func buttonClick(button: UIButton) {
        guard let name = nameTextField.text else {
            // 名字拆包失败
            self.makeToast(localLanguage(keyString: "名字拆包失败"),
                           position: .center)
            return
        }
        guard name.isEmpty == false else {
            // 名字为空
            self.makeToast(localLanguage(keyString: "名字为空"),
                           position: .center)
            return
        }
        guard let password = passwordTextField.text else {
            // 密码拆包失败
            self.makeToast(localLanguage(keyString: "密码拆包失败"),
                           position: .center)
            return
        }
        guard password.isEmpty == false else {
            // 密码为空
            self.makeToast(localLanguage(keyString: "密码为空"),
                           position: .center)
            return
        }
        guard let passwordConfirm = passwordConfirmTextField.text else {
            // 确认密码拆包失败
            self.makeToast(localLanguage(keyString: "确认密码拆包失败"),
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
        self.nameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordConfirmTextField.resignFirstResponder()
        self.delegate?.confirmAddWallet(name: name, password: password)
    }
    var type: String? {
        didSet {
            if type == "BTC" {
                coinTypeIcon.image = UIImage.init(named: "btc_icon")
                nameLabel.text = localLanguage(keyString: "wallet_add_wallet_btc_title")
            } else if type == "Lib" {
                coinTypeIcon.image = UIImage.init(named: "libra_icon")
                nameLabel.text = localLanguage(keyString: "wallet_add_wallet_libra_title")
            } else {
                coinTypeIcon.image = UIImage.init(named: "violas_icon")
                nameLabel.text = localLanguage(keyString: "wallet_add_wallet_violas_title")
            }
        }
    }
}
