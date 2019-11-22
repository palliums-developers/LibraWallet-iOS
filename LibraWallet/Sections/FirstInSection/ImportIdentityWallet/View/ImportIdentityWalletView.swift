//
//  ImportIdentityWalletView.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
protocol ImportIdentityWalletViewDelegate: NSObjectProtocol {
    func confirmImportWallet(walletName: String, password: String, mnemonic: [String])
}
class ImportIdentityWalletView: UIView {
    weak var delegate: ImportIdentityWalletViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mnemonicTextView)
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
        print("ImportIdentityWalletView销毁了")
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
        nameTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.height.equalTo(51)
            make.bottom.equalTo(nameSpaceLabel.snp.top)
            make.left.right.equalTo(nameSpaceLabel)
        }
        nameSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mnemonicTextView.snp.bottom).offset(76)
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
    lazy var mnemonicTextView: RSKPlaceholderTextView = {
        let textView = RSKPlaceholderTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.textColor = UIColor.init(hex: "62606B")
        textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        textView.backgroundColor = UIColor.init(hex: "F8F7FA")
        textView.tintColor = DefaultGreenColor
        textView.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_import_mnemonic_textview_placeholder"),
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),
                                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        return textView
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
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
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
    var toastView: ToastView {
        let toast = ToastView.init()
        return toast
    }
    @objc func buttonClick(button: UIButton) {
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
//        24 21 18 15 12
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

        guard let name = nameTextField.text else {
            // 名字拆包失败
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .walletNameInvalidError).localizedDescription,
                           position: .center)
            return
        }
        guard name.isEmpty == false else {
            // 名字为空
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .walletNameEmptyError).localizedDescription,
                           position: .center)
            return
        }
        guard let password = passwordTextField.text else {
            // 密码拆包失败
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordInvalidError).localizedDescription,
                           position: .center)
            return
        }
        guard password.isEmpty == false else {
            // 密码为空
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordEmptyError).localizedDescription,
                           position: .center)
            return
        }
        guard let passwordConfirm = passwordConfirmTextField.text else {
            // 确认密码拆包失败
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordCofirmInvalidError).localizedDescription,
                           position: .center)
            return
        }
        guard passwordConfirm.isEmpty == false else {
            // 确认密码为空
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordConfirmEmptyError).localizedDescription,
                           position: .center)
            return
        }
        guard password == passwordConfirm else {
            // 密码不一致
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordCheckFailed).localizedDescription,
                           position: .center)
            return
        }
        self.mnemonicTextView.resignFirstResponder()
        self.nameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordConfirmTextField.resignFirstResponder()
        self.delegate?.confirmImportWallet(walletName: name, password: password, mnemonic: tempArray)
    }
}
