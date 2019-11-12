//
//  WalletCreateView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletCreateViewDelegate: NSObjectProtocol {
    func createWallet()
    func importWallet()
}
class WalletCreateView: UIView {
    weak var delegate: WalletCreateViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(walletIconImageView)
        addSubview(walletNameLabel)
        addSubview(createButton)
        addSubview(importButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletCreateView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        walletIconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(171)
            make.centerX.equalTo(self)
        }
        walletNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(walletIconImageView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
        }
        createButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(walletIconImageView.snp.bottom).offset(165)
            make.left.equalTo(self).offset(46)
            make.right.equalTo(self.snp.right).offset(-46)
            make.height.equalTo(46)
        }
        importButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(createButton.snp.bottom).offset(28)
            make.left.equalTo(self).offset(46)
            make.right.equalTo(self.snp.right).offset(-46)
            make.height.equalTo(46)
        }
    }
    lazy var walletNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 32), weight: UIFont.Weight.semibold)
        label.text = "Violas"
        return label
    }()
    lazy var walletIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "default_avatar")
        return imageView
    }()
    lazy var createButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_create_choose_type_create_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 3
        button.tag = 10
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: UIScreen.main.bounds.size.width - 92, height: 46)), at: 0)
        button.layer.masksToBounds = true
        return button
    }()
    lazy var importButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_create_choose_type_import_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.init(hex: "8A7FB6").cgColor
        button.layer.borderWidth = 1
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.createWallet()
        } else {
            self.delegate?.importWallet()
        }
    }
    lazy var backgroundLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: mainWidth, height: mainHeight)
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.locations = [0.3,1.0]
        gradientLayer.colors = [UIColor.init(hex: "4B199F").cgColor, UIColor.init(hex: "21126B").cgColor]
        return gradientLayer
    }()
}
