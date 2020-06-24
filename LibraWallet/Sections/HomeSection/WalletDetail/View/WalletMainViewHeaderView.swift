//
//  WalletMainViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class WalletMainViewHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerBackgroundImageView)
        headerBackgroundImageView.addSubview(walletIndicatorImageView)
        headerBackgroundImageView.addSubview(walletTypeLabel)
        headerBackgroundImageView.addSubview(amountLabel)
        headerBackgroundImageView.addSubview(amountValueLabel)
        headerBackgroundImageView.addSubview(walletAddressLabel)
        headerBackgroundImageView.addSubview(copyAddressButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletMainViewHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerBackgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(140)
        }
        walletIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(headerBackgroundImageView).offset(18)
            make.left.equalTo(headerBackgroundImageView).offset(14)
            make.size.equalTo(CGSize.init(width: 14, height: 14))
        }
        walletTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(walletIndicatorImageView)
            make.left.equalTo(walletIndicatorImageView.snp.right).offset(5)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerBackgroundImageView).offset(14)
            make.top.equalTo(walletIndicatorImageView.snp.bottom).offset(15)
        }
        amountValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerBackgroundImageView).offset(14)
            make.top.equalTo(amountLabel.snp.bottom).offset(10)
        }
        walletAddressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerBackgroundImageView).offset(14)
            make.top.equalTo(amountValueLabel.snp.bottom).offset(13)
        }
        copyAddressButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(walletAddressLabel)
            make.left.equalTo(walletAddressLabel.snp.right).offset(9)
            make.size.equalTo(CGSize.init(width: 18, height: 18))
        }
    }
    private lazy var headerBackgroundImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_detail_header_background")
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var walletIndicatorImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var walletTypeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
        label.text = localLanguage(keyString: "Violas")
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: .bold)
        label.text = "0.00"
        return label
    }()
    lazy var amountValueLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
        label.text = "≈$0.00"
        return label
    }()
    lazy var walletAddressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: .regular)
        label.text = "---"
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 2
        return label
    }()
    private lazy var copyAddressButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_copy_address"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        // 拷贝地址
        UIPasteboard.general.string = walletAddressLabel.text
        self.makeToast(localLanguage(keyString: "wallet_copy_address_success_title"),
                       position: .center)
    }
    var model: Token? {
        didSet {

            self.walletAddressLabel.text = model?.tokenAddress
            var unit = 1000000
            switch model?.tokenType {
            case .BTC:
                self.walletIndicatorImageView.image = UIImage.init(named: "btc_icon")
                unit = 100000000
            case .Libra:
                self.walletIndicatorImageView.image = UIImage.init(named: "libra_icon")
            case .Violas:
                self.walletIndicatorImageView.image = UIImage.init(named: "violas_icon")
            default:
                self.walletIndicatorImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            self.amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model?.tokenBalance ?? 0)),
                                                                                          scale: 4,
                                                                                          unit: unit)
            let rate = NSDecimalNumber.init(string: model?.tokenPrice ?? "0.0")
            let amount = NSDecimalNumber.init(string: amountLabel.text ?? "0.0")
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let value = rate.multiplying(by: amount, withBehavior: numberConfig)
            amountValueLabel.text = "≈$\(value.stringValue)"
        }
    }
}
