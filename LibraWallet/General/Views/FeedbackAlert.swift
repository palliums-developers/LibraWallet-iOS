//
//  FeedbackAlert.swift
//  HKWallet
//
//  Created by palliums on 2019/8/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
class FeedbackAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(self.titleLabel)
        whiteBackgroundView.addSubview(self.cancelButton)
        whiteBackgroundView.addSubview(self.contentTextView)
        whiteBackgroundView.addSubview(self.countLabel)
        whiteBackgroundView.addSubview(self.contentTextViewSpaceLabel)
        whiteBackgroundView.addSubview(self.contactTextField)
        whiteBackgroundView.addSubview(self.contactTextFieldSpaceLabel)

        whiteBackgroundView.addSubview(self.confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(successClosure: @escaping successClosure) {
        self.init(frame: CGRect.zero)
        self.actionClosure = successClosure
    }
    deinit {
        print("AlertToSetPasswordAlertView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-20)
            make.left.equalTo(self).offset(28)
            make.right.equalTo(self).offset(-28)
            make.height.equalTo(335)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(whiteBackgroundView)
            make.height.equalTo(41)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(whiteBackgroundView)
            make.size.equalTo(CGSize.init(width: 41, height: 41))
        }
        contentTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(26)
            make.left.equalTo(whiteBackgroundView).offset(22)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-22)
            make.height.equalTo(135)
        }
        countLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentTextViewSpaceLabel.snp.top).offset(-5)
            make.right.equalTo(contentTextViewSpaceLabel)
        }
        contentTextViewSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(142)
            make.left.equalTo(whiteBackgroundView).offset(20)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-20)
            make.height.equalTo(1)
        }
        contactTextField.snp.makeConstraints { (make) in
            make.top.equalTo(contentTextViewSpaceLabel.snp.bottom)
            make.bottom.equalTo(contactTextFieldSpaceLabel.snp.top)
            make.left.equalTo(whiteBackgroundView).offset(20)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-20)
        }
        contactTextFieldSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentTextViewSpaceLabel.snp.bottom).offset(52)
            make.left.equalTo(whiteBackgroundView).offset(20)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-20)
            make.height.equalTo(1)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(whiteBackgroundView).offset(-26)
            make.right.equalTo(whiteBackgroundView).offset(-68)
            make.left.equalTo(whiteBackgroundView).offset(68)
            make.height.equalTo(42)
        }
    }
    //MARK: - 懒加载对象
    //懒加载子View
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = DefaultGreenColor
        label.text = localLanguage(keyString: "wallet_alert_feedback_title")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        return label
    }()
    private lazy var contentTextView : RSKPlaceholderTextView = {
        let textView = RSKPlaceholderTextView.init()
        textView.backgroundColor = UIColor.white
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        textView.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_alert_feedback_textview_placeholder"),
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),
                                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textView.tintColor = DefaultGreenColor
        return textView
    }()
    lazy var countLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "BABABA")
        //        label.text = localLanguage(keyString: "wallet_import_success_alert_detail_title")
        label.text = "0/200"
        return label
    }()
    lazy var contentTextViewSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var contactTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.black
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_alert_feedback_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var contactTextFieldSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "feedback_close"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_alert_feedback_confirm_button_title"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = DefaultGreenColor.cgColor
        button.layer.cornerRadius = 7
        return button
    }()
    typealias successClosure = (String, String) -> Void
    var actionClosure: successClosure?
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.hide()
        } else {
            guard let content = self.contentTextView.text else {
                self.makeToast(localLanguage(keyString: "wallet_alert_feedback_content_empty"), position: .center)
                return
            }
            guard content.isEmpty == false else {
                self.makeToast(localLanguage(keyString: "wallet_alert_feedback_content_empty"), position: .center)
                return
            }
            guard let contact = self.contactTextField.text else {
                self.makeToast(localLanguage(keyString: "wallet_alert_feedback_contact_empty"), position: .center)
                return
            }
            guard contact.isEmpty == false else {
                self.makeToast(localLanguage(keyString: "wallet_alert_feedback_contact_empty"), position: .center)
                return
            }
            if let action = self.actionClosure {
                self.makeToastActivity(.center)
                action(content, contact)
            }
        }
    }
}
extension FeedbackAlert: actionViewProtocol {
    
}
extension FeedbackAlert: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let content = textView.text else {
            return true
        }
        let textLength = content.count + text.count - range.length
        
        let status = textLength<=200
        if status == true {
            self.countLabel.text = "\(textLength)/200"
        }
        return status
    }
}
