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
//        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(backgroundImageView)
        addSubview(qrcodeTitleLabel)
        addSubview(qrcodeImageView)
        addSubview(addressRemarksLabel)
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
            make.top.equalTo(47)
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.height.equalTo(398)
        }
        qrcodeTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundImageView)
            make.top.equalTo(backgroundImageView).offset(27)
        }
        qrcodeImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundImageView)
            make.top.equalTo(backgroundImageView).offset(66)
            make.size.equalTo(CGSize.init(width: 156, height: 156))
        }
        addressRemarksLabel.snp.makeConstraints { (make) in
            make.top.equalTo(qrcodeImageView.snp.bottom).offset(16)
            make.centerX.equalTo(backgroundImageView)
            make.left.right.equalTo(backgroundImageView)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressRemarksLabel.snp.bottom).offset(5)
            make.centerX.equalTo(backgroundImageView)
            make.left.equalTo(backgroundImageView).offset(5)
            make.right.equalTo(backgroundImageView).offset(-5)
        }
        saveQRCodeButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(backgroundImageView.snp.bottom).offset(-22)
            make.left.equalTo(backgroundImageView).offset(30)
            make.right.equalTo(backgroundImageView.snp.right).offset(-30)
            make.height.equalTo(40)
        }
    }
    //MARK: - 懒加载对象
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "receive_background")
        imageView.isUserInteractionEnabled = true
        // 定义阴影颜色
        imageView.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        imageView.layer.shadowRadius = 3
        // 阴影的偏移量
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        imageView.layer.shadowOpacity = 0.1
        return imageView
    }()
    lazy var qrcodeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
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
    lazy var addressRemarksLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "9D9CA3")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .medium)
        label.text = "---"
        label.numberOfLines = 0
        return label
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
        button.setTitle(localLanguage(keyString: "wallet_receive_copy_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        let width = UIScreen.main.bounds.width - 70 - 70
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        UIPasteboard.general.string = addressLabel.text
        self.makeToast(localLanguage(keyString: "wallet_address_copy_success_title"),
                       position: .center)
    }
    func addShadow() {
        self.layer.backgroundColor = UIColor.white.cgColor
        // 定义阴影颜色
        self.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        self.layer.shadowRadius = 2
        // 阴影的偏移量
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        self.layer.shadowOpacity = 0.3
    }
    var wallet: Token? {
        didSet {
            guard let walletModel = wallet else {
                return
            }
            var tempAddress = walletModel.tokenAddress
            switch wallet?.tokenType {
            case .BTC:
                tempAddress = "bitcoin:" + tempAddress
                break
            case .Libra:
                tempAddress = "libra:" + tempAddress
                break
            case .Violas:
                if let name = violasTokenName, name.isEmpty == false {
                    tempAddress = "violas-\(name.lowercased()):" + tempAddress
                } else {
                    tempAddress = "violas:" + tempAddress
                }
                break
            default:
                break
            }
            qrcodeImageView.image = QRCodeGenerator.generate(from: tempAddress)
            addressRemarksLabel.text = walletModel.tokenName
            addressLabel.text = walletModel.tokenAddress ?? ""
        }
    }
    var violasTokenName: String?
}
