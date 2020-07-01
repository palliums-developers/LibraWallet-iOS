//
//  ScanPublishView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ScanPublishView: UIView {
    weak var delegate: ScanSendTransactionViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(addressWhiteBackgroundView)
        addressWhiteBackgroundView.addSubview(transactionReceiveAddressTitleLabel)
        addressWhiteBackgroundView.addSubview(transactionReceiveAddressLabel)
        addSubview(tokenWhiteBackgroundView)
        tokenWhiteBackgroundView.addSubview(transactionTokenTitleLabel)
        tokenWhiteBackgroundView.addSubview(transactionTokenLabel)

        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanPublishView销毁了")
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
        addressWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(88)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(70)
        }
        transactionReceiveAddressTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressWhiteBackgroundView)
            make.left.equalTo(addressWhiteBackgroundView).offset(14)
        }
        transactionReceiveAddressLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressWhiteBackgroundView)
            make.left.equalTo(addressWhiteBackgroundView).offset(100)
            make.right.equalTo(addressWhiteBackgroundView.snp.right).offset(-14)
        }
        tokenWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(addressWhiteBackgroundView.snp.bottom).offset(20)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(70)
        }
        transactionTokenTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenWhiteBackgroundView)
            make.left.equalTo(addressWhiteBackgroundView).offset(14)
        }
        transactionTokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenWhiteBackgroundView)
            make.left.equalTo(tokenWhiteBackgroundView).offset(100)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(tokenWhiteBackgroundView.snp.bottom).offset(50)
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
        label.text = localLanguage(keyString: "wallet_wallet_connect_publish_title")
        label.numberOfLines = 0
        return label
    }()
    private lazy var addressWhiteBackgroundView: UIView = {
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
    lazy var transactionReceiveAddressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_wallet_connect_publish_address_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var transactionReceiveAddressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    private lazy var tokenWhiteBackgroundView: UIView = {
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
    lazy var transactionTokenTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_wallet_connect_publish_module_title")
        return label
    }()
    lazy var transactionTokenLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_publish_confirm_button_title"), for: UIControl.State.normal)
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
        button.setImage(UIImage.init(named: "close_black"), for: UIControl.State.normal)
        
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
            self.delegate?.confirmLogin(password: "password")
        } else if button.tag == 20 {
            // 常用地址
            self.delegate?.cancelLogin()
        }
    }
    var model: WCRawTransaction? {
        didSet {
            transactionReceiveAddressLabel.text = model?.from
            if let typeArgument = model?.payload?.tyArgs, typeArgument.isEmpty == false {
                let (_, module) = ViolasManager.readTypeTags(data: Data.init(hex: typeArgument.first ?? "") ?? Data(), typeTagCount: typeArgument.count)
                transactionTokenLabel.text = module
            }
        }
    }
}
