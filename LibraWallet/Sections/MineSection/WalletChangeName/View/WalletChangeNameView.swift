//
//  WalletChangeNameView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletChangeNameViewDelegate: NSObjectProtocol {
    func changeNameButtonClickMethod(button: UIButton, name: String)
}
class WalletChangeNameView: UIView {
    weak var delegate: WalletChangeNameViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        self.addSubview(textFieldBackgroundView)
        textFieldBackgroundView.addSubview(walletNameTextField)
        textFieldBackgroundView.addSubview(nameLabel)
        self.addSubview(confirmButton)
        self.addSubview(cancelChangeButton)
        self.addGestureRecognizer(tapTohide)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletChangeNameView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        textFieldBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(13)
            make.left.right.equalTo(self)
            make.height.equalTo(60)
        }
        walletNameTextField.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(textFieldBackgroundView)
            make.left.equalTo(nameLabel.snp.right).offset(14)
            make.right.equalTo(textFieldBackgroundView).offset(-14)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(textFieldBackgroundView)
            make.left.equalTo(textFieldBackgroundView).offset(14)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(textFieldBackgroundView.snp.bottom).offset(36)
            make.left.equalTo(self).offset(49)
            make.right.equalTo(self).offset(-49)
            make.height.equalTo(44)
        }
        cancelChangeButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmButton.snp.bottom).offset(10)
            make.left.equalTo(self).offset(49)
            make.right.equalTo(self).offset(-49)
            make.height.equalTo(44)
        }
    }
    //MARK: - 懒加载对象
    private lazy var textFieldBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "0E0051")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "更换钱包名"
        return label
    }()
    lazy var walletNameTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.right
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_manager_change_wallet_name_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        return textField
    }()

    lazy var confirmButton: UIButton = {
        let button = UIButton.init()
        button.setTitle(localLanguage(keyString: "wallet_manager_change_wallet_name_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        let width = UIScreen.main.bounds.width - 49 - 49
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 44)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changeNameButtonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var cancelChangeButton: UIButton = {
        let button = UIButton.init()
        button.setTitle(localLanguage(keyString: "wallet_manager_change_wallet_name_cancel_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "D3D7E7"), for: UIControl.State.normal)
        
        button.addTarget(self, action: #selector(changeNameButtonClick(button:)), for: UIControl.Event.touchUpInside)
        //        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        button.tag = 20
        return button
    }()
    lazy var tapTohide: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapToHideKeyboard))
        return tap
    }()
    @objc func tapToHideKeyboard() {
        self.walletNameTextField.resignFirstResponder()
    }    
    @objc func changeNameButtonClick(button: UIButton) {
        if button.tag == 10 {
            // 拆包检测
            guard let walletName = walletNameTextField.text else {
                self.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_invalid_title"),
                                    position: .center)
                return
            }
            //没输入
            guard walletName.isEmpty == false else {
                self.makeToast(localLanguage(keyString: "wallet_manager_change_wallet_name_without_insert_error"),
                                    position: .center)
                return
            }
            self.delegate?.changeNameButtonClickMethod(button: button, name: walletName)
        }
    }
}
