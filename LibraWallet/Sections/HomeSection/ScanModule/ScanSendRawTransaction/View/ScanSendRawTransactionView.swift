//
//  ScanSendRawTransactionView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol ScanSendRawTransactionViewDelegate: NSObjectProtocol {
    func cancelLogin()
    func confirmLogin(password: String)
}
class ScanSendRawTransactionView: UIView {
    weak var delegate: ScanSendRawTransactionViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(walletWhiteBackgroundView)
        walletWhiteBackgroundView.addSubview(transactionAmountTitleLabel)
        walletWhiteBackgroundView.addSubview(transactionAmountLabel)
        walletWhiteBackgroundView.addSubview(transactionAmountUnitLabel)
        walletWhiteBackgroundView.addSubview(spaceLabel)
        walletWhiteBackgroundView.addSubview(transactionReceiveAddressTitleLabel)
        walletWhiteBackgroundView.addSubview(transactionReceiveAddressLabel)
        
        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanSendRawTransactionView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scanLoginIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(177)
            make.centerX.equalTo(self)
        }
        scanLoginTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(28)
            make.centerX.equalTo(self)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(88)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(151)
        }
        transactionAmountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(walletWhiteBackgroundView).offset(14)
            make.left.equalTo(walletWhiteBackgroundView).offset(14)
        }
        transactionAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(walletWhiteBackgroundView).offset(26)
            make.left.equalTo(walletWhiteBackgroundView).offset(14)
            make.bottom.equalTo(spaceLabel.snp.top)
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-14)
        }
        transactionAmountUnitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionAmountLabel.snp.right).offset(10)
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-14)
            make.centerY.equalTo(transactionAmountLabel)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(walletWhiteBackgroundView).offset(14)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-14)
            make.height.equalTo(1)
            make.top.equalTo(walletWhiteBackgroundView).offset(71)
        }
        transactionReceiveAddressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceLabel.snp.bottom).offset(17)
            make.left.equalTo(walletWhiteBackgroundView).offset(14)
        }
        transactionReceiveAddressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceLabel.snp.bottom).offset(12)
            make.left.equalTo(walletWhiteBackgroundView).offset(100)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-14)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(walletWhiteBackgroundView.snp.bottom).offset(53)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-29)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        //抱紧内容
        transactionAmountTitleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
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
        label.text = localLanguage(keyString: "wallet_wallet_connect_transfer_title")
        label.numberOfLines = 0
        return label
    }()
    private lazy var walletWhiteBackgroundView: UIView = {
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
    lazy var transactionAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_wallet_connect_transfer_amount_title")
        return label
    }()
    lazy var transactionAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var transactionAmountUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "Violas"
        label.numberOfLines = 0
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var transactionReceiveAddressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_wallet_connect_transfer_receive_address_title")
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
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_transfer_confirm_button_title"), for: UIControl.State.normal)
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
    var model: WCDataModel? {
        didSet {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model?.amount ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            transactionAmountLabel.text = amount.stringValue
            transactionReceiveAddressLabel.text = model?.receive
        }
    }
}
