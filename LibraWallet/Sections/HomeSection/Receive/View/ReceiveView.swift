//
//  ReceiveView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol ReceiveViewDelegate: NSObjectProtocol {
    func chooseCoin()
}
class ReceiveView: UIView {
    weak var delegate: ReceiveViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(backgroundImageView)
        backgroundImageView.addSubview(qrcodeTitleLabel)
        backgroundImageView.addSubview(coinSelectButton)
        backgroundImageView.addSubview(qrcodeImageView)
        backgroundImageView.addSubview(addressLabel)
        backgroundImageView.addSubview(saveQRCodeButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ReceiveView销毁了")
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
        coinSelectButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).priority(250)
            make.top.equalTo(backgroundImageView).offset(68).priority(250)
            let width = 9 + libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_transfer_token_default_title"), fontSize: 12, height: 22) + 9 + 7
            make.size.equalTo(CGSize.init(width: width, height: 22)).priority(250)
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
        imageView.isUserInteractionEnabled = true
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
    lazy var coinSelectButton: UIButton = {
        let button = UIButton.init(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_transfer_token_default_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 11
        button.tag = 10
        return button
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
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.chooseCoin()
        } else {
            UIPasteboard.general.string = addressLabel.text
            self.makeToast(localLanguage(keyString: "wallet_address_copy_success_title"),
                           position: .center)
        }
    }
    var token: Token? {
        didSet {
            guard let model = token else {
                return
            }
            coinSelectButton.setTitle(model.tokenName, for: UIControl.State.normal)
            coinSelectButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            coinSelectButton.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(backgroundImageView).offset(68)
                let width = 9 + libraWalletTool.ga_widthForComment(content: model.tokenName, fontSize: 12, height: 22) + 9 + 7
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            
            var tempAddress = model.tokenAddress
            switch model.tokenType {
            case .BTC:
                tempAddress = "bitcoin:" + tempAddress
                break
            case .Libra:
                tempAddress = "diem://" + DiemManager.getQRAddress(address: tempAddress, rootAccount: true) + "?c=\(model.tokenModule.lowercased())"
                break
            case .Violas:
                tempAddress = "violas://" + ViolasManager.getQRAddress(address: tempAddress, rootAccount: true) + "?c=\(model.tokenModule.lowercased())"
                break
            }
            qrcodeImageView.image = QRCodeGenerator.generate(from: tempAddress)
            addressLabel.text = model.tokenAddress
        }
    }
}
