//
//  WalletReceiveView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletReceiveViewDelegate: NSObjectProtocol {
//    func setAmountToQRCode()
//    func clearAmountToQRCode()
    func saveQrcode()
//    func checkReceiveHistory()
}
class WalletReceiveView: UIView {
    weak var delegate: WalletReceiveViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = defaultBackgroundColor
        addSubview(topBackgroundImageView)
        addSubview(walletWhiteBackgroundView)
        addSubview(qrcodeTitleLabel)
        addSubview(qrcodeImageView)
        addSubview(avatarImageView)
        //        addSubview(receiveAmountLabel)
        addSubview(receiveAmountValueLabel)
        addSubview(saveQRCodeButton)
//        addSubview(checkReceiveHistoryButton)
//        insertSubview(bottomBackgroungImageView, at: 0)
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
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(202)
        }
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(21)
            make.right.equalTo(self).offset(-21)
            make.height.equalTo((340 * ratio)).priority(250)
            make.top.equalTo(self).offset(130)
        }
        qrcodeTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.walletWhiteBackgroundView)
            make.top.equalTo(self.walletWhiteBackgroundView).offset(54)
        }
        qrcodeImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.walletWhiteBackgroundView)
            make.top.equalTo(self.walletWhiteBackgroundView).offset(86)
            make.size.equalTo(CGSize.init(width: 164, height: 164))
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self.qrcodeImageView)
            make.size.equalTo(CGSize.init(width: 36, height: 36))
        }
        receiveAmountValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.qrcodeImageView.snp.bottom).offset(14)
            make.centerX.equalTo(self.walletWhiteBackgroundView)
            make.left.right.equalTo(self.walletWhiteBackgroundView)
        }
        saveQRCodeButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.walletWhiteBackgroundView.snp.bottom).offset(0)
            make.centerX.equalTo(self)
        }
//        checkReceiveHistoryButton.snp.makeConstraints { (make) in
//            make.left.equalTo(self).offset(21)
//            make.right.equalTo(self).offset(-21)
//            make.top.equalTo(self.walletWhiteBackgroundView.snp.bottom).offset(11)
//            make.height.equalTo(61)
//        }
//        bottomBackgroungImageView.snp.makeConstraints { (make) in
//            make.size.equalTo(CGSize.init(width: 316, height: 239))
//            make.right.bottom.equalTo(self)
//        }
    }
    //MARK: - 懒加载对象
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "navigation_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        // 定义阴影颜色
        view.layer.shadowColor = UIColor.init(hex: "E5E5E5").cgColor
        // 阴影的模糊半径
        view.layer.shadowRadius = 16
        // 阴影的偏移量
        view.layer.shadowOffset = CGSize(width: 0, height: 16)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        view.layer.shadowOpacity = 0.3
        return view
    }()
    lazy var qrcodeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 17), weight: .regular)
        label.text = localLanguage(keyString: "wallet_receive_title")
        return label
    }()
    lazy var qrcodeImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "default_qrcode")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var avatarImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "default_avatar")
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var receiveAmountValueLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    lazy var saveQRCodeButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_receive_save_qrcode_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "19CB98"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 17), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 15
        return button
    }()
    lazy var checkReceiveHistoryButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_receive_get_receive_history_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        button.setImage(UIImage.init(named: "check_receive_history"), for: UIControl.State.normal)
        button.backgroundColor = UIColor.white
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        // 定义阴影颜色
        button.layer.shadowColor = UIColor.init(hex: "E5E5E5").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 16
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 16)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.3
        return button
    }()
    private lazy var bottomBackgroungImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_bottom_background")
        return imageView
    }()
    @objc func buttonClick(button: UIButton) {
//        if button.tag == 10 {
//            if let content = receiveAmountValueLabel.text, content.isEmpty == false {
//                // 重制二维码
//                let jsonData = "{\"uid\":\"\(WalletData.wallet.walletUID!)\",\"amount\":0}"
//                qrcodeImageView.image = QRCodeGenerator.generate(from: jsonData)
//
//                let url = URL(string: model?.walletAvatarURL ?? "")
//                avatarImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "default_avatar"))
//                // 重绘UI
//                receiveAmountValueLabel.text = ""
//                setAndClearAmountButton.setTitle(localLanguage(keyString: "wallet_receive_set_qrcode_amout_button_title"), for: UIControl.State.normal)
//
//                walletWhiteBackgroundView.snp.remakeConstraints { (make) in
//                    make.left.equalTo(self).offset(21)
//                    make.right.equalTo(self).offset(-21)
//                    make.height.equalTo((340 * ratio))
//                    make.top.equalTo(self).offset(130)
//                }
//                UIView.animate(withDuration: 0.3) {
//                    self.layoutIfNeeded()
//                }
//            } else {
//                self.delegate?.setAmountToQRCode()
//            }
//        } else if button.tag == 15 {
//            self.delegate?.saveQrcode()
//        } else {
//            self.delegate?.checkReceiveHistory()
//        }
        if button.tag == 15 {
            self.delegate?.saveQrcode()
        }
    }
    var model: LibraWalletManager? {
        didSet {
            guard let address = model?.walletAddress else { return }
            receiveAmountValueLabel.text = address
            qrcodeImageView.image = QRCodeGenerator.generate(from: address)
        }
    }
    func updateBackgroundView(reset: Bool) {
        if reset == true {
            walletWhiteBackgroundView.snp.remakeConstraints { (make) in
                make.left.equalTo(self).offset(21)
                make.right.equalTo(self).offset(-21)
                make.height.equalTo((340 * ratio))
                make.top.equalTo(self).offset(130)
            }
        } else {
            walletWhiteBackgroundView.snp.remakeConstraints { (make) in
                make.left.equalTo(self).offset(21)
                make.right.equalTo(self).offset(-21)
                make.height.equalTo((357 * ratio))
                make.top.equalTo(self).offset(130)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

}
