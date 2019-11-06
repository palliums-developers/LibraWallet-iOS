//
//  MarketView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MarketView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerBackground)
        addSubview(backgroundImageView)
        addSubview(leftCoinButton)
        addSubview(rightCoinButton)
        addSubview(exchangeCoinSpaceLabel)
        addSubview(exchangeCoinButton)
        addSubview(exchangeAmountSpaceLabel)
        addSubview(leftAmountTextField)
        addSubview(rightAmountTextField)
        addSubview(exchangeToAddressSpaceLabel)
        addSubview(exchangeToAddressTextField)
        addSubview(exchangeToAddressTitleLabel)
        addSubview(exchangeFeeTitleLabel)
        addSubview(exchangeFeeLabel)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerBackground.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(208)
        }
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(headerBackground.snp.bottom).offset(-86)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
        }
        leftCoinButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(exchangeCoinSpaceLabel.snp.top)
            make.left.equalTo(exchangeCoinSpaceLabel)
            make.right.equalTo(rightCoinButton.snp.left)
            make.height.equalTo(58)
            make.width.equalTo(rightCoinButton)
        }
        rightCoinButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(exchangeCoinSpaceLabel.snp.top)
            make.right.equalTo(exchangeCoinSpaceLabel.snp.right)
            make.height.equalTo(58)
        }
        exchangeCoinSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(69)
            make.left.equalTo(backgroundImageView).offset(17)
            make.right.equalTo(backgroundImageView.snp.right).offset(-17)
            make.height.equalTo(1)
        }
        exchangeCoinButton.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(exchangeCoinSpaceLabel)
        }
        leftAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(exchangeAmountSpaceLabel)
            make.height.equalTo(36)
            make.right.equalTo(rightAmountTextField.snp.left)
            make.bottom.equalTo(exchangeAmountSpaceLabel)
            make.width.equalTo(rightAmountTextField)
        }
        rightAmountTextField.snp.makeConstraints { (make) in
            make.right.equalTo(exchangeAmountSpaceLabel.snp.right)
            make.height.equalTo(36)
            make.bottom.equalTo(exchangeAmountSpaceLabel)
        }
        exchangeAmountSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeCoinSpaceLabel.snp.bottom).offset(63)
            make.left.equalTo(backgroundImageView).offset(17)
            make.right.equalTo(backgroundImageView.snp.right).offset(-17)
            make.height.equalTo(1)
        }
        exchangeToAddressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeAmountSpaceLabel.snp.bottom).offset(10)
            make.left.equalTo(exchangeToAddressSpaceLabel)
        }
        exchangeToAddressTextField.snp.makeConstraints { (make) in
            make.right.left.equalTo(exchangeToAddressSpaceLabel)
            make.height.equalTo(36)
            make.bottom.equalTo(exchangeToAddressSpaceLabel)
        }
        exchangeToAddressSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeAmountSpaceLabel.snp.bottom).offset(63)
            make.left.equalTo(backgroundImageView).offset(17)
            make.right.equalTo(backgroundImageView.snp.right).offset(-17)
            make.height.equalTo(1)
        }
        exchangeFeeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeToAddressSpaceLabel.snp.bottom).offset(10)
            make.left.equalTo(exchangeToAddressSpaceLabel)
        }
        exchangeFeeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeFeeTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(exchangeToAddressSpaceLabel)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(54)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
    }
    //MARK: - 懒加载对象
    private lazy var headerBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mine_header_background")
        return imageView
    }()
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "market_background")
        imageView.isUserInteractionEnabled = true
        // 定义阴影颜色
        imageView.layer.shadowColor = UIColor.black.cgColor
        // 阴影的模糊半径
        imageView.layer.shadowRadius = 3
        // 阴影的偏移量
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        imageView.layer.shadowOpacity = 0.1
        return imageView
    }()
    lazy var leftCoinButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "BTC"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "3C3848"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "btc_icon"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.imageView?.bounds.size = CGSize.init(width: 31, height: 31)
        return button
    }()
    lazy var rightCoinButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "Violas"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "3C3848"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "violas_icon"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        return button
    }()
    lazy var exchangeCoinSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var exchangeCoinButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "market_change_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        // 定义阴影颜色
        button.layer.shadowColor = UIColor.black.cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 3
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.2
        return button
    }()
    lazy var exchangeAmountSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var leftAmountTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_transfer_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.keyboardType = .decimalPad
        return textField
    }()
    lazy var rightAmountTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.right
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_receive_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.keyboardType = .decimalPad
        return textField
    }()
    lazy var exchangeToAddressSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    lazy var exchangeToAddressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_receive_address_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.rightView = addressScanButton
        textField.rightViewMode = .always
        return textField
    }()
    lazy var exchangeToAddressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "62606C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_receive_address_title")
        return label
    }()
    lazy var addressScanButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 48))
        button.setImage(UIImage.init(named: "market_address_book"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.tag = 10
        return button
    }()
    lazy var exchangeFeeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "62606C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_fee_title")
        return label
    }()
    lazy var exchangeFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_fee_describe_title")
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_confirm_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69

        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    @objc func buttonClick(button: UIButton) {
    }
}
