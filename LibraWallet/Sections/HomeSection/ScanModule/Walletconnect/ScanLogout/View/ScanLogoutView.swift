//
//  ScanLogoutView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/28.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol ScanLogoutViewDelegate: NSObjectProtocol {
    func logout()
    func cancelLogout()
}
class ScanLogoutView: UIView {
    weak var delegate: ScanLogoutViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanLogoutView销毁了")
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
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(241)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-29)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
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
        label.text = localLanguage(keyString: "wallet_wallet_connect_logout_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_logout_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "close_black"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var toastView: ToastView = {
        let toast = ToastView.init()
        return toast
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.logout()
        } else if button.tag == 20 {
            self.delegate?.cancelLogout()
        }
    }
}
