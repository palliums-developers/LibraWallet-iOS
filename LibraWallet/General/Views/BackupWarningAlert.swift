//
//  BackupWarningAlert.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

protocol BackupWarningAlertDelegate: NSObjectProtocol {
    func backupMenmonic()
}
class BackupWarningAlert: UIView {
    weak var delegate: BackupWarningAlertDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(describeLabel)
        addSubview(confirmButton)
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
        backgroundImageView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(107)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundImageView).offset(100)
            make.top.equalTo(backgroundImageView).offset(20)
        }
        describeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(55)
            make.left.equalTo(backgroundImageView).offset(31)
            make.right.equalTo(backgroundImageView.snp.right).offset(-31)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(17)
            make.right.equalTo(backgroundImageView.snp.right).offset(-21)
            make.size.equalTo(CGSize.init(width: 64, height: 24))
        }
    }
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "backup_warning_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hex: "FB8F0B")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.medium)
        label.text = localLanguage(keyString: "wallet_alert_backup_warning_title")
        return label
    }()
    private lazy var describeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hex: "333333")
        let paraph = NSMutableParagraphStyle()
        // 将行间距设置为10
        paraph.lineSpacing = 15
        // 样式属性集合
        //行间距调整 ,NSAttributedString.Key.paragraphStyle: paraph
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)]
        label.attributedText = NSAttributedString(string: localLanguage(keyString: "wallet_alert_backup_warning_detail_title"), attributes: attributes)
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_alert_backup_warning_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: 64, height: 24), cornerRadius: 12), at: 0)
        // 定义阴影颜色
        button.layer.shadowColor =  UIColor.init(hex: "7038FD").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 5
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.3
        button.tag = 10
        return button
    }()
    typealias backupClosure = () -> Void
    var actionClosure: backupClosure?
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            if let action = self.actionClosure {
                action()
//                self.hide(tag: 99)
            }
            self.delegate?.backupMenmonic()
        } else {
//            self.hide(tag: 99)
        }
    }
}
//extension BackupWarningAlert: actionViewProtocol {
//
//}
