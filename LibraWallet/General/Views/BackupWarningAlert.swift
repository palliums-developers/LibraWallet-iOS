//
//  BackupWarningAlert.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BackupWarningAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(topBackgroundImageView)
        topBackgroundImageView.addSubview(titleLabel)
        topBackgroundImageView.addSubview(topIconImageView)
        topBackgroundImageView.addSubview(closeButton)
        
        whiteBackgroundView.addSubview(describeLabel)
        whiteBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(goBackupClosure: @escaping backupClosure) {
        self.init(frame: CGRect.zero)
        self.actionClosure = goBackupClosure
    }
    deinit {
        print("BackupWarningAlert销毁了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(254)
        }
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(whiteBackgroundView)
            make.height.equalTo(53)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(topBackgroundImageView).offset(15)
            make.centerY.equalTo(topBackgroundImageView)
        }
        topIconImageView.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel.snp.left).offset(-10)
            make.centerY.equalTo(titleLabel)
        }
        closeButton.snp.makeConstraints { (make) in
            make.right.equalTo(topBackgroundImageView).offset(-15)
            make.centerY.equalTo(topBackgroundImageView)
        }
        describeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topBackgroundImageView.snp.bottom).offset(20)
            make.left.equalTo(whiteBackgroundView).offset(42)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-42)
//            make.bottom
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(whiteBackgroundView.snp.bottom).offset(-20)
            make.left.equalTo(whiteBackgroundView).offset(114)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-114)
            make.height.equalTo(35)
        }
    }
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "backup_warning_top_background")
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
    private lazy var topIconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "backup_warning_top_icon")
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_alert_backup_warning_title")
        return label
    }()
    private lazy var describeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hex: "63616C")
        let paraph = NSMutableParagraphStyle()
        // 将行间距设置为10
        paraph.lineSpacing = 15
        // 样式属性集合
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular),
                          NSAttributedString.Key.paragraphStyle: paraph]
        label.attributedText = NSAttributedString(string: localLanguage(keyString: "wallet_alert_backup_warning_detail_title"), attributes: attributes)
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_alert_backup_warning_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        let width = UIScreen.main.bounds.width - 114 - 114
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 35)), at: 0)
        // 定义阴影颜色
        button.layer.shadowColor =  UIColor.init(hex: "7038FD").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 5
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 3
        button.tag = 10
        return button
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "close"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    typealias backupClosure = () -> Void
    var actionClosure: backupClosure?
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            if let action = self.actionClosure {
                action()
                self.hide(tag: 99)
            }
        } else {
            self.hide(tag: 99)
        }
    }
}
extension BackupWarningAlert: actionViewProtocol {
    
}
