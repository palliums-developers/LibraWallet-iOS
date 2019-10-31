//
//  TransferView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol TransferViewDelegate: NSObjectProtocol {
    func scanAddressQRcode()
    func chooseAddress()
    func confirmWithdraw()
}
class TransferView: UIView {
    weak var delegate: TransferViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scrollView)
        scrollView.addSubview(walletWhiteBackgroundView)
//        walletWhiteBackgroundView.addSubview(walletIconImageView)

//        walletWhiteBackgroundView.addSubview(addressScanButton)
////        walletWhiteBackgroundView.addSubview(addressMiddleSpaceLabel)
//        walletWhiteBackgroundView.addSubview(addressSpaceLabel)
        
        walletWhiteBackgroundView.addSubview(amountTitleLabel)
        walletWhiteBackgroundView.addSubview(amountTextField)
        walletWhiteBackgroundView.addSubview(walletBalanceLabel)
        
        walletWhiteBackgroundView.addSubview(addressTitleLabel)
        walletWhiteBackgroundView.addSubview(addressTextField)
        walletWhiteBackgroundView.addSubview(addressContactButton)


//        walletWhiteBackgroundView.addSubview(coinUnitLabel)
//        walletWhiteBackgroundView.addSubview(amountUnitChangeButton)
        
//        walletWhiteBackgroundView.addSubview(selectTotalCoinButton)
//
        walletWhiteBackgroundView.addSubview(transferFeeTitleLabel)

        walletWhiteBackgroundView.addSubview(transferSpeedLeftTitleLabel)
        walletWhiteBackgroundView.addSubview(transferSpeedRightTitleLabel)
        walletWhiteBackgroundView.addSubview(transferFeeLabel)
        walletWhiteBackgroundView.addSubview(transferFeeSlider)
//        walletWhiteBackgroundView.addSubview(transactionFeeLabel)
//        walletWhiteBackgroundView.addSubview(transactionFeeUnitLabel)
//        walletWhiteBackgroundView.addSubview(transactionFeeSpaceLabel)
//
        walletWhiteBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TransferView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo((444 * ratio))
            make.top.equalTo(scrollView).offset(30)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(amountTextField.snp.top).offset(-7)
            make.left.equalTo(walletWhiteBackgroundView).offset(22)
        }
        amountTextField.snp.makeConstraints { (make) in
            make.top.equalTo(walletWhiteBackgroundView).offset(52)
            make.left.equalTo(walletWhiteBackgroundView).offset(15)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-15)
            make.height.equalTo(48)
        }
        walletBalanceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(amountTextField.snp.top).offset(-7)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
        }
        addressTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(addressTextField .snp.top).offset(-7)
            make.left.equalTo(walletWhiteBackgroundView).offset(22)
        }
        addressTextField.snp.makeConstraints { (make) in
            make.top.equalTo(amountTextField.snp.bottom).offset(50)
            make.left.equalTo(walletWhiteBackgroundView).offset(15)
            make.right.equalTo(walletWhiteBackgroundView).offset(-15)
            make.height.equalTo(48)
        }
        addressContactButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(addressTextField.snp.top).offset(-7)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
        }
//        addressSpaceLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(addressContactButton.snp.bottom).offset(10)
//            make.left.equalTo(walletWhiteBackgroundView).offset(21)
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
//            make.height.equalTo(1)
//        }
//
//        amountSpaceLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(addressSpaceLabel.snp.bottom).offset(83)
//            make.left.equalTo(walletWhiteBackgroundView).offset(21)
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
//            make.height.equalTo(1)
//        }
        transferFeeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressTextField.snp.bottom).offset(27)
            make.left.equalTo(walletWhiteBackgroundView).offset(15)
        }
        transferSpeedLeftTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.transferFeeSlider.snp.top).offset(-4)
            make.left.equalTo(self.transferFeeSlider.snp.left)
        }
        transferSpeedRightTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.transferFeeSlider.snp.top).offset(-4)
            make.right.equalTo(self.transferFeeSlider.snp.right)
        }
        transferFeeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.transferFeeSlider.snp.bottom).offset(6)
            make.left.equalTo(walletWhiteBackgroundView).offset(15)
        }
        transferFeeSlider.snp.makeConstraints { (make) in
            make.top.equalTo(addressTextField.snp.bottom).offset(78)
            make.left.equalTo(walletWhiteBackgroundView).offset(15)
            make.right.equalTo(walletWhiteBackgroundView).offset(-15)
        }
//
//        transactionFeeTitleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(amountSpaceLabel.snp.bottom).offset(28)
//            make.left.equalTo(walletWhiteBackgroundView).offset(21)
//        }
//        transactionFeeLabel.snp.makeConstraints { (make) in
//            make.bottom.equalTo(transactionFeeSpaceLabel.snp.top)
//            make.left.equalTo(walletWhiteBackgroundView).offset(21)
//            make.right.equalTo(transactionFeeUnitLabel.snp.left)
//            make.height.equalTo(40)
//        }
//        transactionFeeUnitLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(transactionFeeLabel)
//            make.right.equalTo(walletWhiteBackgroundView).offset(-21)
//            make.width.equalTo(50)
//        }
//        transactionFeeSpaceLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(amountSpaceLabel.snp.bottom).offset(93)
//            make.left.equalTo(walletWhiteBackgroundView).offset(21)
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
//            make.height.equalTo(1)
//        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(walletWhiteBackgroundView.snp.bottom).offset(-51)
            make.left.equalTo(walletWhiteBackgroundView).offset(54)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-54)
            make.height.equalTo(40)
        }
        scrollView.contentSize = CGSize.init(width: mainWidth, height: walletWhiteBackgroundView.frame.maxY + 10)
    }
    //MARK: - 懒加载对象
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        return scrollView
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
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = localLanguage(keyString: "wallet_withdraw_amount_title")
        return label
    }()
    lazy var amountTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_transfer_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C4C3C7"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        textField.layer.borderColor = UIColor.init(hex: "D8D7DA").cgColor
        textField.layer.borderWidth = 1
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 7, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        return textField
    }()
    lazy var walletBalanceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = localLanguage(keyString: "wallet_transfer_balance_title") + " --- Libra"
        return label
    }()
    lazy var addressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = localLanguage(keyString: "wallet_transfer_address_title")
        return label
    }()
    lazy var addressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_transfer_address_btc_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C4C3C7"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        textField.layer.borderColor = UIColor.init(hex: "D8D7DA").cgColor
        textField.layer.borderWidth = 1
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 7, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        textField.rightView = addressScanButton
        textField.rightViewMode = .always
        return textField
    }()
    lazy var addressScanButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 48))
        button.setImage(UIImage.init(named: "scan"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.tag = 10
        return button
    }()
    lazy var addressContactButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_transfer_address_contact_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "3C3848"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 15
        return button
    }()
    lazy var transferFeeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = localLanguage(keyString: "wallet_transfer_transaction_fee_title")
        return label
    }()
    lazy var transferFeeSlider: TransferFeeSliderCustom = {
        let slide = TransferFeeSliderCustom.init()
        slide.value = 0.2
        slide.setThumbImage(UIImage.init(named: "slide_button"), for: UIControl.State.normal)
        slide.setThumbImage(UIImage.init(named: "slide_button"), for: UIControl.State.highlighted)
        slide.setMinimumTrackImage(UIImage().imageWithColor(color: UIColor.init(hex: "9339F3")), for: UIControl.State.normal)
        slide.setMinimumTrackImage(UIImage().imageWithColor(color: UIColor.init(hex: "9339F3")), for: UIControl.State.highlighted)
        slide.setMaximumTrackImage(UIImage().imageWithColor(color: UIColor.init(hex: "F5F5F5")), for: UIControl.State.normal)
        slide.setMaximumTrackImage(UIImage().imageWithColor(color: UIColor.init(hex: "F5F5F5")), for: UIControl.State.highlighted)
        slide.addTarget(self, action: #selector(slideValueDidChange(slide:)
            ), for: UIControl.Event.valueChanged)
        return slide
    }()
    lazy var transferSliderBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "slider_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var transferSpeedLeftTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = localLanguage(keyString: "wallet_transfer_transaction_fee_least_title")
        return label
    }()
    lazy var transferSpeedRightTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "263C4E")
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = localLanguage(keyString: "wallet_transfer_transaction_fee_max_title")
        return label
    }()
    lazy var transferFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = NSTextAlignment.center
        let fee = Float(transferFeeMax - transferFeeMin) * Float(0.2) + Float(transferFeeMin)
        let fee8 = NSString.init(format: "%.8f", fee)
        label.text = "\(fee8) BTC"
        return label
    }()


    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_transfer_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69

        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
//        button.layer.cornerRadius = 7
//        //        button.layer.masksToBounds = true
//        button.tag = 30
//        // 定义阴影颜色
//        button.layer.shadowColor = DefaultGreenColor.cgColor
//        // 阴影的模糊半径
//        button.layer.shadowRadius = 8
//        // 阴影的偏移量
//        button.layer.shadowOffset = CGSize(width: 0, height: 8)
//        // 阴影的透明度，默认为0，不设置则不会显示阴影****
//        button.layer.shadowOpacity = 0.2
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // 扫描地址
            self.delegate?.scanAddressQRcode()
        } else if button.tag == 15 {
            // 常用地址
            self.delegate?.chooseAddress()
        } else {
            // 确认提交
            self.delegate?.confirmWithdraw()
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
//    var toastView: ToastView? {
//        let toast = ToastView.init()
//        return toast
//    }
    var originFee: Int64?
    var model: LibraWalletManager? {
        didSet {
            guard let balance = model?.walletBalance else { return }
            walletBalanceLabel.text = "\(balance)" + "Libra"
        }
    }
    @objc func slideValueDidChange(slide: UISlider) {
        let fee = Float(transferFeeMax - transferFeeMin) * slide.value + Float(transferFeeMin)
        let fee8 = NSString.init(format: "%.8f", fee)
        self.transferFeeLabel.text = "\(fee8) BTC"
    }
}
// = "余额";
// = "输入金额";
// = "收款地址";
// = "地址簿";
// = "输入BTC收款地址";
//wallet_transfer_address_libra_textfield_placeholder = "输入Libra收款地址";
//wallet_transfer_address_violas_textfield_placeholder = "输入Violas收款地址";
// = "手续费";
// = "慢";
// = "快";
// = "确认转账";
