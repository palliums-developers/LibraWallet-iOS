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
        self.layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(walletNameTextField)
        whiteBackgroundView.addSubview(walletNameSpaceLabel)
        whiteBackgroundView.addSubview(paymentPasswordTextField)
        whiteBackgroundView.addSubview(paymentPasswordSpaceLabel)
        whiteBackgroundView.addSubview(paymentPasswordConfirmTextField)
        whiteBackgroundView.addSubview(paymentPasswordConfirmSpaceLabel)
        whiteBackgroundView.addSubview(confirmButton)
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
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self).offset(-65)
            make.left.equalTo(self).offset(47)
            make.right.equalTo(self.snp.right).offset(-47)
            make.height.equalTo(357)
        }
        walletNameTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(walletNameSpaceLabel.snp.top)
            make.left.right.equalTo(walletNameSpaceLabel)
            make.height.equalTo(51)
        }
        walletNameSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(77)
            make.left.equalTo(whiteBackgroundView).offset(17)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-17)
            make.height.equalTo(1)
        }
        paymentPasswordTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(paymentPasswordSpaceLabel.snp.top)
            make.left.right.equalTo(walletNameSpaceLabel)
            make.top.equalTo(walletNameSpaceLabel.snp.bottom)
        }
        paymentPasswordSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(walletNameSpaceLabel.snp.bottom).offset(51)
            make.left.equalTo(whiteBackgroundView).offset(17)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-17)
            make.height.equalTo(1)
        }
        paymentPasswordConfirmTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(paymentPasswordConfirmSpaceLabel.snp.top)
            make.left.right.equalTo(walletNameSpaceLabel)
            make.top.equalTo(paymentPasswordSpaceLabel.snp.bottom)
        }
        paymentPasswordConfirmSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(paymentPasswordSpaceLabel.snp.bottom).offset(51)
            make.left.equalTo(whiteBackgroundView).offset(17)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-17)
            make.height.equalTo(1)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(whiteBackgroundView.snp.bottom).offset(-56)
            make.left.equalTo(whiteBackgroundView).offset(21)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-21)
            make.height.equalTo(40)
        }
    }
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var walletNameTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_name_textfield_placeholder"),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "9D9BA2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.tintColor = DefaultGreenColor
        textField.tag = 10
        return textField
    }()
    lazy var walletNameSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var paymentPasswordTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_password_textfield_placeholder"),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "9D9BA2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 20

        return textField
    }()
    lazy var paymentPasswordSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var paymentPasswordConfirmTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_password_confirm_textfield_placeholder"),
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "9D9BA2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.isSecureTextEntry = true
        textField.tintColor = DefaultGreenColor
        textField.tag = 30
        return textField
    }()
    lazy var paymentPasswordConfirmSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_create_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 3
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: UIScreen.main.bounds.size.width - 136, height: 40)), at: 0)
        // 定义阴影颜色
        button.layer.shadowColor = UIColor.init(hex: "7038FD").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 3
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.3
        return button
    }()
    lazy var backgroundLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: mainWidth, height: mainHeight)
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.locations = [0.3,1.0]
        gradientLayer.colors = [UIColor.init(hex: "4B199F").cgColor, UIColor.init(hex: "21126B").cgColor]
        return gradientLayer
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
