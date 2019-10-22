//
//  ImportWalletLastView.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol ImportWalletLastViewDelegate: NSObjectProtocol {
    func nextStepClickClickMethod(button: UIButton)
}
class ImportWalletLastView: UIView {
    weak var delegate: ImportWalletLastViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.whiteBackgroundView)
        whiteBackgroundView.addSubview(self.walletNameTextField)
        whiteBackgroundView.addSubview(self.walletNameSpaceLabel)
        
        whiteBackgroundView.addSubview(self.walletPasswordTextField)
        whiteBackgroundView.addSubview(self.showPasswordButton)
        whiteBackgroundView.addSubview(self.walletPasswordSpaceLabel)
        
        whiteBackgroundView.addSubview(self.walletPasswordAgainTextField)
        whiteBackgroundView.addSubview(self.showPasswordAgainButton)
        whiteBackgroundView.addSubview(self.walletPasswordAgainSpaceLabel)
        
        whiteBackgroundView.addSubview(self.walletPasswordRemarksTextField)
        whiteBackgroundView.addSubview(self.walletPasswordRemarksSpaceLabel)
        
        self.addSubview(self.makeSureButton)
 
        self.addGestureRecognizer(tapTohide)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ImportWalletLastView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        self.whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.height.equalTo(254)
        }
        self.walletNameTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.walletNameSpaceLabel.snp.top).offset(0)
            make.right.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(50)
        }
        self.walletNameSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(63)
            make.right.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(1)
        }
        self.walletPasswordTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.walletPasswordSpaceLabel.snp.top).offset(0)
            make.right.equalTo(self.showPasswordButton.snp.left).offset(-5)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(50)
        }
        self.showPasswordButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.walletPasswordTextField)
            make.right.equalTo(self).offset(-30)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        self.walletPasswordSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletNameSpaceLabel.snp.bottom).offset(53)
            make.right.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(1)
        }
        self.walletPasswordAgainTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.walletPasswordAgainSpaceLabel.snp.top).offset(0)
            make.right.equalTo(self.showPasswordAgainButton.snp.left).offset(-5)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(50)
        }
        self.showPasswordAgainButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.walletPasswordAgainTextField)
            make.right.equalTo(self).offset(-30)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        self.walletPasswordAgainSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletPasswordSpaceLabel.snp.bottom).offset(53)
            make.right.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(1)
        }
        self.walletPasswordRemarksTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.walletPasswordRemarksSpaceLabel.snp.top).offset(0)
            make.right.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(50)
        }
        self.walletPasswordRemarksSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletPasswordAgainSpaceLabel.snp.bottom).offset(53)
            make.right.equalTo(self).offset(-30)
            make.left.equalTo(self).offset(30)
            make.height.equalTo(1)
        }
        self.makeSureButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.whiteBackgroundView.snp.bottom).offset(40)
            make.left.equalTo(self).offset(52)
            make.right.equalTo(self).offset(-52)
            make.height.equalTo(40)
        }
    }
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var walletNameTextField: UITextField = {
        //#263C4E
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_name_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)])
        return textField
    }()
    lazy var walletNameSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "E5E8F6")
        return label
    }()
    lazy var walletPasswordTextField: UITextField = {
        //#263C4E
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_password_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)])
        return textField
    }()
    lazy var showPasswordButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "password_invisible"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(showPasswordMathod), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var walletPasswordSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "E5E8F6")
        return label
    }()
    lazy var walletPasswordAgainTextField: UITextField = {
        //#263C4E
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_password_again_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)])
        return textField
    }()
    lazy var showPasswordAgainButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "password_invisible"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(showPasswordMathod), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var walletPasswordAgainSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "E5E8F6")
        return label
    }()
    lazy var walletPasswordRemarksTextField: UITextField = {
        //#263C4E
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_create_password_remarks_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)])
        return textField
    }()
    lazy var walletPasswordRemarksSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "E5E8F6")
        return label
    }()
    lazy var makeSureButton: UIButton = {
        let button = UIButton.init()
        button.setTitle(localLanguage(keyString: "wallet_import_success_alert_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        let width = UIScreen.main.bounds.width - 104
//        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 44)), at: 0)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(nextStepClick(button:)), for: UIControl.Event.touchUpInside)
        
        return button
    }()

    lazy var tapTohide: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapToHideKeyboard))
        return tap
    }()
    @objc func tapToHideKeyboard() {
        self.walletNameTextField.resignFirstResponder()
        self.walletPasswordTextField.resignFirstResponder()
        self.walletPasswordAgainTextField.resignFirstResponder()
        self.walletPasswordRemarksTextField.resignFirstResponder()

    }
    @objc func nextStepClick(button:UIButton) {
        self.delegate?.nextStepClickClickMethod(button: button)
    }
    @objc func showPasswordMathod(button: UIButton) {
        if button.tag == 10 {
            let status = self.walletPasswordTextField.isSecureTextEntry
            self.walletPasswordTextField.isSecureTextEntry = status == true ? false: true
            let image = status == true ? UIImage.init(named: "password_visible"): UIImage.init(named: "password_invisible")
            button.setImage(image, for: UIControl.State.normal)
        } else if button.tag == 20 {
            let status = self.walletPasswordAgainTextField.isSecureTextEntry
            self.walletPasswordAgainTextField.isSecureTextEntry = status == true ? false: true
            let image = status == true ? UIImage.init(named: "password_visible"): UIImage.init(named: "password_invisible")
            button.setImage(image, for: UIControl.State.normal)
        }
    }
}
