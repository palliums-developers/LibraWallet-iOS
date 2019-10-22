//
//  AddAddressView.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AddAddressViewDelegate: NSObjectProtocol {
    func confirmAddress()
}
class AddAddressView: UIView {
    weak var delegate: AddAddressViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(scrollView)
        insertSubview(backgroundImageView, at: 1)
        
        scrollView.addSubview(walletWhiteBackgroundView)
        walletWhiteBackgroundView.addSubview(walletIconImageView)
        walletWhiteBackgroundView.addSubview(addressTitleLabel)
        walletWhiteBackgroundView.addSubview(addressTextField)
        walletWhiteBackgroundView.addSubview(addressSpaceLabel)
        
        walletWhiteBackgroundView.addSubview(remarksTitleLabel)
        walletWhiteBackgroundView.addSubview(remarksTextField)
        walletWhiteBackgroundView.addSubview(remarksSpaceLabel)
    
        scrollView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AddAddressView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self)
        }
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(21)
            make.right.equalTo(self).offset(-21)
            make.height.equalTo((238 * ratio))
            make.top.equalTo(scrollView).offset(101 + navigationBarHeight)
        }
        walletIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.walletWhiteBackgroundView)
            make.top.equalTo(self.walletWhiteBackgroundView).offset(-34)
        }
        addressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletWhiteBackgroundView).offset(53)
            make.left.equalTo(self.walletWhiteBackgroundView).offset(20)
        }
        addressTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(addressSpaceLabel.snp.top)
            make.left.right.equalTo(self.addressSpaceLabel)
            make.height.equalTo(40)
        }
        addressSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(walletWhiteBackgroundView).offset(118)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
            make.height.equalTo(1)
        }
        remarksTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressSpaceLabel.snp.bottom).offset(15)
            make.left.equalTo(walletWhiteBackgroundView).offset(20)
        }
        remarksTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(remarksSpaceLabel.snp.top)
            make.left.right.equalTo(self.remarksSpaceLabel)
            make.height.equalTo(40)
        }
        remarksSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressSpaceLabel.snp.bottom).offset(80)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
            make.height.equalTo(1)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.walletWhiteBackgroundView.snp.bottom).offset(119)
            make.left.equalTo(walletWhiteBackgroundView).offset(97)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-97)
            make.height.equalTo(37)
        }
        scrollView.contentSize = CGSize.init(width: mainWidth, height: confirmButton.frame.maxY + 10)
    }
    //MARK: - 懒加载对象
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        return scrollView
    }()
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "wallet_recharge_top_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    private lazy var walletIconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_icon")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var addressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: .regular)
        label.text = localLanguage(keyString: "wallet_address_manager_address_title")
        return label
    }()
    lazy var addressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_withdraw_address_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "B5B5B5"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var addressSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    
    lazy var remarksTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "2E2E2E")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 13), weight: .regular)
        label.text = localLanguage(keyString: "wallet_address_manager_remarks_title")
        return label
    }()
    lazy var remarksTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_address_manager_remarks_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "B5B5B5"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var remarksSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_address_manager_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            //添加地址
            self.delegate?.confirmAddress()
        } else {
            
        }
    }
    lazy var backgroundLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: mainWidth, height: mainHeight)
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.locations = [0.5,1.0]
        gradientLayer.colors = [UIColor.init(hex: "363E57").cgColor, UIColor.init(hex: "101633").cgColor]
        return gradientLayer
    }()
}
