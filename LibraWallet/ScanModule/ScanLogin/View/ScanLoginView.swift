//
//  ScanLoginView.swift
//  SSO
//
//  Created by wangyingdong on 2020/3/16.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import AttributedTextView
protocol ScanLoginViewDelegate: NSObjectProtocol {
    func cancelLogin()
    func confirmLogin(password: String)
    func openUserAgreement()
    func openPrivateAgreement()
}
class ScanLoginView: UIView {
    weak var delegate: ScanLoginViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(warnningWhiteBackgroundView)
        warnningWhiteBackgroundView.addSubview(warnningContentLabel)
        addSubview(lawLabel)
        
        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanLoginView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scanLoginIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(101)
            make.centerX.equalTo(self)
        }
        scanLoginTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(28)
            make.centerX.equalTo(self)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        warnningWhiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self).offset(-22)
            make.centerX.equalTo(self)
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(91)
            let height = libraWalletTool.ga_heightForComment(content: localLanguage(keyString: "wallet_wallet_connect_login_warnning_content"),
                                                             fontSize: 14,
                                                             width: mainWidth - 44 - 40)
            make.height.equalTo(height + 16)
        }
        warnningContentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(warnningWhiteBackgroundView).offset(20)
            make.right.equalTo(warnningWhiteBackgroundView.snp.right).offset(-20)
            make.top.equalTo(warnningWhiteBackgroundView).offset(8)
            make.bottom.equalTo(warnningWhiteBackgroundView.snp.bottom).offset(-8)
        }
        lawLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(warnningWhiteBackgroundView)
            make.top.equalTo(warnningWhiteBackgroundView.snp.bottom).offset(5)
            make.height.equalTo(50)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(warnningWhiteBackgroundView.snp.bottom).offset(96)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmButton.snp.bottom).offset(20)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
    }
    //MARK: - 懒加载对象
    lazy var scanLoginIndicator : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "scan_login_indicator")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var scanLoginTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = localLanguage(keyString: "wallet_wallet_connect_login_title")
        label.numberOfLines = 0
        return label
    }()
    private lazy var warnningWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        // 定义阴影颜色
        view.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        view.layer.shadowRadius = 3
        // 阴影的偏移量
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        view.layer.shadowOpacity = 0.1
        return view
    }()
    lazy var warnningContentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = localLanguage(keyString: "wallet_wallet_connect_login_warnning_content")
        label.numberOfLines = 0
        return label
    }()
    lazy var lawLabel: AttributedTextView = {
        let textView = AttributedTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.attributer = localLanguage(keyString: "wallet_wallet_connect_login_warnning_describe")
            .color(UIColor.init(hex: "999999"))
            .font(UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular))
            .match(localLanguage(keyString: "wallet_private_agreement_title")).makeInteract({ _ in
                self.delegate?.openPrivateAgreement()
            })
            .match(localLanguage(keyString: "wallet_user_agreement_title")).color(UIColor.init(hex: "333333")).makeInteract({ _ in
                self.delegate?.openUserAgreement()
            })
        return textView
    }()

    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_login_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69

        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_scan_login_cancel_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "ADABB3"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
//            self.passwordTextField.resignFirstResponder()
//            // 扫描地址
//            guard let password = passwordTextField.text, password.isEmpty == false else {
//                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordEmptyError).localizedDescription,
//                               position: .center)
//                return
//            }
            self.delegate?.confirmLogin(password: "password")
        } else if button.tag == 20 {
            // 常用地址
            self.delegate?.cancelLogin()
        }
    }
}
extension ScanLoginView: UITextFieldDelegate {
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       guard let content = textField.text else {
           return true
       }
       let textLength = content.count + string.count - range.length
       if content.contains(".") {
           let firstContent = content.split(separator: ".").first?.description ?? "0"
           if (textLength - firstContent.count) < 6 {
               return true
           } else {
               return false
           }
       } else {
           return textLength <= ApplyTokenAmountLengthLimit
       }
   }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.init(hex: "0087E3").cgColor
        textField.layer.borderWidth = 1
        // 定义阴影颜色
        textField.layer.shadowColor = UIColor.init(hex: "0087E3").cgColor
        // 阴影的模糊半径
        textField.layer.shadowRadius = 1
        // 阴影的偏移量
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        textField.layer.shadowOpacity = 0.3
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderColor = UIColor.init(hex: "D8D7DA").cgColor
        textField.layer.borderWidth = 1
        // 定义阴影颜色
        textField.layer.shadowColor = UIColor.white.cgColor
        // 阴影的模糊半径
        textField.layer.shadowRadius = 3
        // 阴影的偏移量
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        textField.layer.shadowOpacity = 0
    }
    
}
//wallet_wallet_connect_login_title = "网页ViolasPay钱包登录确认";
//wallet_wallet_connect_logout_title = "网页ViolasPay钱包已登录";
//wallet_wallet_connect_exchange_title = "网页ViolasPay钱包兑换确认";
//wallet_wallet_connect_sign_title = "网页ViolasPay钱包请求签名";
//wallet_wallet_connect_transfer_title = "网页ViolasPay钱包转账";
//wallet_wallet_connect_transfer_receive_address_title = "转账地址";
//wallet_wallet_connect_transfer_amount_title = "金额";
//wallet_wallet_connect_transfer_confirm_button_title = "确认转账";
//wallet_wallet_connect_login_confirm_button_title = "确认登录";
//wallet_wallet_connect_exchange_confirm_button_title = "确认兑换";
//wallet_wallet_connect_sign_button_title = "确认签名";
