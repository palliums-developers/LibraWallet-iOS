//
//  PrivateAlertView.swift
//  SSO
//
//  Created by palliums on 2019/12/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import AttributedTextView
class PrivateAlertView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        addSubview(walletWhiteBackgroundView)

        walletWhiteBackgroundView.addSubview(titleLabel)
        walletWhiteBackgroundView.addSubview(contentTextView)
        walletWhiteBackgroundView.addSubview(cancelButton)
        walletWhiteBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(openPrivateLegal: @escaping openPrivateLegalClosure, openUseLegal: @escaping openUseLegalClosure) {
        self.init(frame: CGRect.zero)
        self.openPrivateLegalAction = openPrivateLegal
        self.openUseLegalAction = openUseLegal
    }
    deinit {
        print("PrivateAlertView销毁了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-20)
            make.left.equalTo(self).offset(27)
            make.right.equalTo(self).offset(-27)
            make.height.equalTo(404)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(walletWhiteBackgroundView)
            make.left.right.top.equalTo(walletWhiteBackgroundView)
            make.height.equalTo(50)
        }
        contentTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(walletWhiteBackgroundView).offset(15)
            make.right.equalTo(walletWhiteBackgroundView).offset(-15)
            make.bottom.equalTo(cancelButton.snp.top).offset(-15)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(walletWhiteBackgroundView.snp.bottom).offset(-18)
            make.left.equalTo(walletWhiteBackgroundView).offset(25)
            make.height.equalTo(37)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(walletWhiteBackgroundView.snp.bottom).offset(-18)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-25)
            make.left.equalTo(cancelButton.snp.right).offset(13)
            make.height.width.equalTo(cancelButton)
        }
    }
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: .medium)
        label.text = localLanguage(keyString: "wallet_private_and_use_legal_title")
        return label
    }()
    private lazy var contentTextView: AttributedTextView = {
        let textView = AttributedTextView.init()
        textView.textAlignment = NSTextAlignment.left
//        textView.textColor = UIColor.init(hex: "62606B")
//        textView.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        textView.backgroundColor = UIColor.white
        textView.isEditable = false
        textView.attributer = privateAndUseLegal
            .color(UIColor.init(hex: "62606B"))
            .font(UIFont.systemFont(ofSize: 16, weight: .regular))
            .match("《隐私政策》").underline.makeInteract({ _ in
                if let action = self.openPrivateLegalAction {
                    action()
                }
            })
            .match("《服务协议》").underline.makeInteract({ _ in
                if let action = self.openUseLegalAction {
                    action()
                }
            })
        return textView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_private_and_use_legal_cancel_button_title"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.init(hex: "979797").alpha(0.8).cgColor
        button.layer.masksToBounds = true
        return button
    }()
    private lazy var confirmButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_private_and_use_legal_confirm_button_title"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: (UIScreen.main.bounds.size.width - 54 - 50 - 13) / 2, height: 37)), at: 0)
        button.tag = 15
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            abort()
        } else {
            setConfirmPrivateAndUseLegalState(show: true)
            self.hide()
        }
    }
    typealias openPrivateLegalClosure = () -> Void
    var openPrivateLegalAction: openPrivateLegalClosure?
    typealias openUseLegalClosure = () -> Void
    var openUseLegalAction: openUseLegalClosure?

}
extension PrivateAlertView: actionViewProtocol {
    
}
