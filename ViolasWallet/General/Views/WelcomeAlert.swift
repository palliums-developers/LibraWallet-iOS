//
//  WelcomeAlert.swift
//  ViolasWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WelcomeAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundImageView)
        backgroundImageView.addSubview(titleLabel)
        backgroundImageView.addSubview(describeLabel)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WelcomeAlert销毁了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-11)
            make.size.equalTo(CGSize.init(width: 320, height: 185))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(51)
            make.left.equalTo(backgroundImageView).offset(20)
        }
        describeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(backgroundImageView).offset(20)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(backgroundImageView)
            make.height.equalTo(40)
        }
    }
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "welcome_alert_background")
        imageView.isUserInteractionEnabled = true
        // 定义阴影颜色
        imageView.layer.shadowColor =  UIColor.black.cgColor
        // 阴影的模糊半径
        imageView.layer.shadowRadius = 5
        // 阴影的偏移量
        imageView.layer.shadowOffset = CGSize(width: 0, height: 5)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        imageView.layer.shadowOpacity = 0.1
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_alert_welcome_title")
        return label
    }()
    private lazy var describeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_alert_welcome_detail_title")
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_alert_welcome_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: 320, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.tag = 30
        button.layer.masksToBounds = true
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.hide(tag: 99)
        setWelcomeState(show: true)
    }
}
extension WelcomeAlert: actionViewProtocol {
    
}
