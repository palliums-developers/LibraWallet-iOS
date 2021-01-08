//
//  TransferView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/12.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol TransferViewDelegate: NSObjectProtocol {
    func scanAddressQRcode()
    func chooseAddress()
    func confirmTransfer()
    func chooseCoin()
}
class TransferView: UIView {
    weak var delegate: TransferViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(walletWhiteBackgroundView)
        
        walletWhiteBackgroundView.addSubview(amountTitleLabel)
        walletWhiteBackgroundView.addSubview(amountTextField)
        walletWhiteBackgroundView.addSubview(walletBalanceLabel)
        
        walletWhiteBackgroundView.addSubview(addressTitleLabel)
        walletWhiteBackgroundView.addSubview(addressTextField)
        walletWhiteBackgroundView.addSubview(addressContactButton)
        
        walletWhiteBackgroundView.addSubview(transferFeeTitleLabel)
        
        walletWhiteBackgroundView.addSubview(transferSpeedLeftTitleLabel)
        walletWhiteBackgroundView.addSubview(transferSpeedRightTitleLabel)
        walletWhiteBackgroundView.addSubview(transferFeeLabel)
        walletWhiteBackgroundView.addSubview(transferFeeSlider)
        
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
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-22)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
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
        return view
    }()
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_transfer_amount_title")
        return label
    }()
    lazy var amountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 14)
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_transfer_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        textField.layer.borderColor = UIColor.init(hex: "D8D7DA").cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 16
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 7, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 48))
        rightView.addSubview(coinSelectButton)
        textField.rightView = rightView
        textField.rightViewMode = .always
        return textField
    }()
    lazy var rightTokenView: UIView = {
        let view = UIView.init()
        return view
    }()
    lazy var coinSelectButton: UIButton = {
        let width = 9 + libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_transfer_token_default_title"), fontSize: 12, height: 22) + 9 + 7
        let button = UIButton.init(frame: CGRect.init(x: 120 - width - 9, y: (24 - 11), width: width, height: 22))
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
        button.tag = 40
        return button
    }()
    lazy var walletBalanceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "5C5C5C")
//        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 14)
        label.text = localLanguage(keyString: "wallet_transfer_balance_title") + " ---"
        return label
    }()
    lazy var addressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_transfer_address_title")
        return label
    }()
    lazy var addressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_transfer_address_libra_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        textField.layer.borderColor = UIColor.init(hex: "D8D7DA").cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 16
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 7, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 31.5, height: 48))
        rightView.addSubview(addressScanButton)
        textField.rightView = rightView
        textField.rightViewMode = .always
        return textField
    }()
    lazy var addressScanButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 48))
        button.setImage(UIImage.init(named: "scan"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var addressContactButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "contact_address"), for: UIControl.State.normal)
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
        slide.value = 0
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
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = localLanguage(keyString: "wallet_transfer_transaction_fee_least_title")
        return label
    }()
    lazy var transferSpeedRightTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = localLanguage(keyString: "wallet_transfer_transaction_fee_max_title")
        return label
    }()
    lazy var transferFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "3C3848")
//        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.textAlignment = NSTextAlignment.center
        label.text = "0.00"
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
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // 扫描地址
            self.delegate?.scanAddressQRcode()
        } else if button.tag == 15 {
            // 常用地址
            self.delegate?.chooseAddress()
        } else if button.tag == 20 {
            // 确认提交
            self.delegate?.confirmTransfer()
        } else if button.tag == 40 {
            self.delegate?.chooseCoin()
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
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
    var originFee: Int64?
    @objc func slideValueDidChange(slide: UISlider) {
//        let fee = Float(transferFeeMax - transferFeeMin) * slide.value + Float(transferFeeMin)
//        let fee8 = NSString.init(format: "%.8f", fee)
//        self.transferFeeLabel.text = "\(fee8) Libra"
        guard let model = token else {
            return
        }
        let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                       scale: 6,
                                                       raiseOnExactness: false,
                                                       raiseOnOverflow: false,
                                                       raiseOnUnderflow: false,
                                                       raiseOnDivideByZero: false)
        if model.tokenType == .Libra {
            let region = NSDecimalNumber.init(value: 0.0001).subtracting(NSDecimalNumber.init(value: 0))
            let fee = region.multiplying(by: NSDecimalNumber(value: slide.value)).adding(NSDecimalNumber.init(value: 0))
            let feeString = fee.multiplying(by: NSDecimalNumber.init(value: 1), withBehavior: numberConfig).stringValue
            transferFeeLabel.text = feeString + " " + model.tokenName
        } else if model.tokenType == .Violas {
            let region = NSDecimalNumber.init(value: 0.0001).subtracting(NSDecimalNumber.init(value: 0))
            let fee = region.multiplying(by: NSDecimalNumber(value: slide.value)).adding(NSDecimalNumber.init(value: 0))
            let feeString = fee.multiplying(by: NSDecimalNumber.init(value: 1), withBehavior: numberConfig).stringValue
            transferFeeLabel.text = feeString + " " + model.tokenName
        } else if model.tokenType == .BTC {
            let region = NSDecimalNumber.init(value: transferFeeMax).subtracting(NSDecimalNumber.init(value: transferFeeMin))
            let fee = region.multiplying(by: NSDecimalNumber(value: slide.value)).adding(NSDecimalNumber.init(value: transferFeeMin))
            let feeString = fee.multiplying(by: NSDecimalNumber.init(value: 1), withBehavior: numberConfig).stringValue
            transferFeeLabel.text = feeString + " " + model.tokenName
        }
    }
    var token: Token? {
        didSet {
            guard let model = token else {
                return
            }
            let balance = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.tokenBalance )),
                                                 scale: 6,
                                                 unit: 1000000)
            walletBalanceLabel.text = localLanguage(keyString: "wallet_transfer_balance_title") + balance + " \(model.tokenName)"
            coinSelectButton.setTitle(model.tokenName, for: UIControl.State.normal)
            coinSelectButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            let oldFrame = coinSelectButton.frame
            let width = 9 + libraWalletTool.ga_widthForComment(content: model.tokenName, fontSize: 12, height: 22) + 9 + 7
            coinSelectButton.frame = CGRect.init(x: 120 - width - 9, y: oldFrame.origin.y, width: width, height: oldFrame.size.height)
            
            if model.tokenType == .Libra {
                transferFeeSlider.value = 0.2
                let region = NSDecimalNumber.init(value: 0.0001).subtracting(NSDecimalNumber.init(value: 0))
                let fee = region.multiplying(by: 0.2).adding(NSDecimalNumber.init(value: 0))
                transferFeeLabel.text = fee.stringValue + " " + model.tokenName
            } else if model.tokenType == .Violas {
                let region = NSDecimalNumber.init(value: 0.0001).subtracting(NSDecimalNumber.init(value: 0))
                let fee = region.multiplying(by: 0.2).adding(NSDecimalNumber.init(value: 0))
                transferFeeLabel.text = fee.stringValue + " " + model.tokenName
            } else if model.tokenType == .BTC {
                let region = NSDecimalNumber.init(value: transferFeeMax).subtracting(NSDecimalNumber.init(value: transferFeeMin))
                let fee = region.multiplying(by: 0.2).adding(NSDecimalNumber.init(value: transferFeeMin))
                transferFeeLabel.text = fee.stringValue + " " + model.tokenName
            }
        }
    }
}
extension TransferView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 8 {
                return true
            } else {
                return false
            }
        } else {
            return textLength <= ApplyTokenAmountLengthLimit
        }
    }
}
