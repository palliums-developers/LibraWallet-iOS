//
//  WelcomeAlert.swift
//  LibraWallet
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
            make.size.equalTo(CGSize.init(width: 272, height: 380))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(37)
            make.centerX.equalTo(backgroundImageView)
        }
        describeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalTo(backgroundImageView)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(backgroundImageView.snp.bottom).offset(14)
            make.left.equalTo(backgroundImageView).offset(16)
            make.right.equalTo(backgroundImageView.snp.right).offset(-16)
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
        label.font = UIFont.systemFont(ofSize: 38, weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_alert_welcome_detail_title")
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_alert_welcome_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "934701"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "FFD701").cgColor
        button.layer.cornerRadius = 3
//        button.layer.masksToBounds = true
        button.tag = 30
        // 定义阴影颜色
        button.layer.shadowColor =  UIColor.init(hex: "FFD701").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 5
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.3
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.hide(tag: 99)
        setWelcomeState(show: true)
    }
}
extension WelcomeAlert: actionViewProtocol {
    
}
