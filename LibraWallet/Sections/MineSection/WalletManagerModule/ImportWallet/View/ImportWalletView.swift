//
//  ImportWalletView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
protocol ImportWalletViewDelegate: NSObjectProtocol {
    func confirmAddWallet(name: String, password: String, mnemonicArray: [String])
}
class ImportWalletView: UIView {
    weak var delegate: ImportWalletViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(coinTypeIcon)
        addSubview(nameLabel)
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
        print("ImportWalletView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        coinTypeIcon.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(36)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 65, height: 65))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(coinTypeIcon.snp.bottom).offset(18)
        }
        mnemonicTextView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(coinTypeIcon.snp.bottom).offset(66)
            make.left.equalTo(self).offset(19)
            make.right.equalTo(self).offset(-19)
            make.height.equalTo(135)
        }
        nameTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.height.equalTo(51)
            make.bottom.equalTo(nameSpaceLabel.snp.top)
            make.left.right.equalTo(nameSpaceLabel)
        }
        nameSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mnemonicTextView.snp.bottom).offset(66)
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
        //#263C4E
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
        textField.delegate = self
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        textField.tag = 10
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
        textField.delegate = self
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 20
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

        guard let name = nameTextField.text, name.isEmpty == false else {
            // 名字拆包失败
            self.makeToast(LibraWalletError.WalletAddWallet(reason: .walletNameEmptyError).localizedDescription,
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
        self.delegate?.confirmAddWallet(name: name, password: password, mnemonicArray: tempArray)
    }
    var type: String? {
        didSet {
            if type == "BTC" {
                coinTypeIcon.image = UIImage.init(named: "btc_icon")
                nameLabel.text = localLanguage(keyString: "wallet_import_wallet_btc_title")
            } else if type == "Libra" {
                coinTypeIcon.image = UIImage.init(named: "libra_icon")
                nameLabel.text = localLanguage(keyString: "wallet_import_wallet_libra_title")
            } else {
                coinTypeIcon.image = UIImage.init(named: "violas_icon")
                nameLabel.text = localLanguage(keyString: "wallet_import_wallet_violas_title")
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
}
