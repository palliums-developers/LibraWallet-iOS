//
//  WalletReceiveView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
class WalletReceiveView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(backgroundImageView)
        addSubview(qrcodeTitleLabel)
        addSubview(qrcodeImageView)
        addSubview(addressLabel)
        addSubview(saveQRCodeButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletReceiveView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(48)
            make.left.equalTo(39)
            make.right.equalTo(-39)
            make.height.equalTo(350)
        }
        qrcodeTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundImageView)
            make.top.equalTo(backgroundImageView).offset(27)
        }
        qrcodeImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundImageView)
            make.top.equalTo(backgroundImageView).offset(108)
            make.size.equalTo(CGSize.init(width: 156, height: 156))
        }
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(qrcodeImageView.snp.bottom).offset(21)
            make.left.equalTo(backgroundImageView).offset(25)
            make.right.equalTo(backgroundImageView).offset(-44)
        }
        saveQRCodeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressLabel)
            make.left.equalTo(addressLabel.snp.right).offset(5)
            make.size.equalTo(CGSize.init(width: 14, height: 14))
        }
    }
    //MARK: - 懒加载对象
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.white
        return imageView
    }()
    lazy var qrcodeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: .regular)
        label.text = localLanguage(keyString: "wallet_receive_qrcode_title")
        return label
    }()
    lazy var qrcodeImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "default_qrcode")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
        label.numberOfLines = 0
        label.text = "---"
        return label
    }()
    lazy var saveQRCodeButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "copy_address"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        UIPasteboard.general.string = addressLabel.text
        self.makeToast(localLanguage(keyString: "wallet_address_copy_success_title"),
                       position: .center)
    }
    var token: Token? {
        didSet {
            guard let tokenModel = token else {
                return
            }
            var tempAddress = tokenModel.tokenAddress
            switch tokenModel.tokenType {
            case .BTC:
                tempAddress = "bitcoin:" + tempAddress
                break
            case .Libra:
                tempAddress = "diem://" + DiemManager.getQRAddress(address: tempAddress, rootAccount: true) + "?c=\(tokenModel.tokenModule.lowercased())"
                break
            case .Violas:
                tempAddress = "violas://" + ViolasManager.getQRAddress(address: tempAddress, rootAccount: true) + "?c=\(tokenModel.tokenModule.lowercased())"
                break
            }
            qrcodeImageView.image = QRCodeGenerator.generate(from: tempAddress)
            addressLabel.text = tokenModel.tokenAddress
        }
    }
}
