//
//  MarketExchangeHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
protocol MarketExchangeHeaderViewDelegate: NSObjectProtocol {
    func selectToken(button: UIButton, leftModelName: String, rightModelName: String, header: MarketExchangeHeaderView)
    func exchangeToken(payToken: MarketSupportCoinDataModel, receiveToken: MarketSupportCoinDataModel, amount: Double, exchangeAmount: Double)
    func changeLeftRightTokenModel(leftModel: MarketSupportCoinDataModel, rightModel: MarketSupportCoinDataModel)
}
class MarketExchangeHeaderView: UITableViewHeaderFooterView {
    weak var delegate: MarketExchangeHeaderViewDelegate?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(backgroundImageView)
        backgroundImageView.addSubview(leftCoinButton)
        backgroundImageView.addSubview(rightCoinButton)
        backgroundImageView.addSubview(exchangeCoinSpaceLabel)
        
        backgroundImageView.addSubview(exchangeCoinButton)
        backgroundImageView.addSubview(exchangeAmountSpaceLabel)
        
        backgroundImageView.addSubview(leftAmountTextField)
        backgroundImageView.addSubview(rightAmountTextField)
//        backgroundImageView.addSubview(exchangeToAddressSpaceLabel)
//        
//        backgroundImageView.addSubview(exchangeToAddressTextField)
//        backgroundImageView.addSubview(exchangeToAddressTitleLabel)
        backgroundImageView.addSubview(exchangeRateTitleLabel)
        backgroundImageView.addSubview(exchangeRateLabel)
        backgroundImageView.addSubview(exchangeRateSpaceLabel)
        
        backgroundImageView.addSubview(transferFeeTitleLabel)
        backgroundImageView.addSubview(transferSpeedLeftTitleLabel)
        backgroundImageView.addSubview(transferSpeedRightTitleLabel)
        backgroundImageView.addSubview(transferFeeLabel)
        backgroundImageView.addSubview(transferFeeSlider)
        
        backgroundImageView.addSubview(confirmButton)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("MarketExchangeHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(377)
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
            make.height.equalTo(0.5)
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
            make.height.equalTo(0.5)
        }
//        exchangeToAddressTitleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(exchangeAmountSpaceLabel.snp.bottom).offset(10)
//            make.left.equalTo(exchangeToAddressSpaceLabel)
//        }
//        exchangeToAddressTextField.snp.makeConstraints { (make) in
//            make.right.left.equalTo(exchangeToAddressSpaceLabel)
//            make.height.equalTo(36)
//            make.bottom.equalTo(exchangeToAddressSpaceLabel)
//        }
//        exchangeToAddressSpaceLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(exchangeAmountSpaceLabel.snp.bottom).offset(63)
//            make.left.equalTo(backgroundImageView).offset(17)
//            make.right.equalTo(backgroundImageView.snp.right).offset(-17)
//            make.height.equalTo(1)
//        }
        exchangeRateTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeAmountSpaceLabel.snp.bottom).offset(10)
            make.left.equalTo(exchangeAmountSpaceLabel)
        }
        exchangeRateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeRateTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(exchangeAmountSpaceLabel)
        }
        exchangeRateSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeAmountSpaceLabel.snp.bottom).offset(63)
            make.left.equalTo(backgroundImageView).offset(17)
            make.right.equalTo(backgroundImageView.snp.right).offset(-17)
            make.height.equalTo(0.5)
        }
        transferFeeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeRateSpaceLabel.snp.bottom).offset(10)
            make.left.equalTo(backgroundImageView).offset(15)
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
            make.left.equalTo(backgroundImageView).offset(15)
        }
        transferFeeSlider.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeRateSpaceLabel.snp.bottom).offset(50)
            make.left.equalTo(backgroundImageView).offset(15)
            make.right.equalTo(backgroundImageView).offset(-15)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(backgroundImageView.snp.bottom).offset(-28)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
    }
    //MARK: - 懒加载对象
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
        imageView.layer.shadowOpacity = 0.05
        return imageView
    }()
    lazy var leftCoinButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle("---", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "3C3848"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(selectExchangeToken(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var rightCoinButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle("---", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "3C3848"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(selectExchangeToken(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    lazy var exchangeCoinSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
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
        button.tag = 50
        return button
    }()
    lazy var exchangeAmountSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var leftAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_transfer_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.tag = 10
        return textField
    }()
    lazy var rightAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.right
        textField.textColor = UIColor.init(hex: "263C4E")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_receive_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.tag = 20
        return textField
    }()
//    lazy var exchangeToAddressSpaceLabel: UILabel = {
//        let label = UILabel.init()
//        label.backgroundColor = DefaultSpaceColor
//        return label
//    }()
//    lazy var exchangeToAddressTextField: UITextField = {
//        let textField = UITextField.init()
//        textField.textAlignment = NSTextAlignment.left
//        textField.textColor = UIColor.init(hex: "263C4E")
//        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_receive_address_textfield_placeholder"),
//                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
//        textField.rightView = addressScanButton
//        textField.rightViewMode = .always
//        return textField
//    }()
//    lazy var exchangeToAddressTitleLabel: UILabel = {
//        let label = UILabel.init()
//        label.textAlignment = NSTextAlignment.center
//        label.textColor = UIColor.init(hex: "3C3848")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
//        label.text = localLanguage(keyString: "wallet_market_receive_address_title")
//        return label
//    }()
//    lazy var addressScanButton: UIButton = {
//        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 48))
//        button.setImage(UIImage.init(named: "market_address_book"), for: UIControl.State.normal)
////        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
//        button.tag = 10
//        return button
//    }()
    lazy var exchangeRateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_fee_title")
        return label
    }()
    lazy var exchangeRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var exchangeRateSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var transferFeeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
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
        label.textColor = UIColor.init(hex: "3C3848")
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
        label.text = "\(fee8) vtoken"
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
        button.tag = 100
        return button
    }()
    @objc func slideValueDidChange(slide: UISlider) {
        let fee = Float(transferFeeMax - transferFeeMin) * slide.value + Float(transferFeeMin)
        let fee8 = NSString.init(format: "%.8f", fee)
        self.transferFeeLabel.text = "\(fee8) vtoken"
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 50 {
            guard let tempLeftModel = self.leftTokenModel else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payTokenNotSelect).localizedDescription, position: .center)
                return
            }
            guard let tempRightModel = self.rightTokenModel else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .exchangeTokenNotSelect).localizedDescription, position: .center)
                return
            }
            guard tempRightModel.enable == true else {
                let content = (tempRightModel.name ?? "") + LibraWalletError.WalletMarket(reason: .swpUnpublishTokenError).localizedDescription
                self.makeToast(content, position: .center)
                return
            }
            guard isPurnDouble(string: self.rightAmountTextField.text ?? "0") == true else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .exchangeAmountInvalid).localizedDescription, position: .center)
                return
            }
            guard Int64(Double(self.rightAmountTextField.text ?? "0")!) < ApplyTokenMaxLimit else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .exchangeAmountMaxLimit).localizedDescription, position: .center)
                return
            }
            guard isPurnDouble(string: self.leftAmountTextField.text ?? "0") == true else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payAmountInvalid).localizedDescription, position: .center)
                return
            }
            guard Int64(Double(self.leftAmountTextField.text ?? "0")!) < ApplyTokenMaxLimit else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payAmountMaxLimit).localizedDescription, position: .center)
                return
            }
            let tempModel = tempLeftModel
            self.rightTokenModel = tempModel
            self.leftTokenModel = tempRightModel
            // 交换后请求数据
            self.delegate?.changeLeftRightTokenModel(leftModel: tempRightModel, rightModel: tempLeftModel)
        } else {
            // 兑换
            self.leftAmountTextField.resignFirstResponder()
            self.rightAmountTextField.resignFirstResponder()
            guard let tempLeftModel = self.leftTokenModel else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payTokenNotSelect).localizedDescription, position: .center)

                return
            }
            guard let tempRightModel = self.rightTokenModel else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .exchangeTokenNotSelect).localizedDescription, position: .center)

                return
            }
            guard let payAmountString = leftAmountTextField.text, payAmountString.isEmpty == false else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payAmountEmpty).localizedDescription, position: .center)
                return
            }
            guard isPurnDouble(string: payAmountString) == true else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payAmountInvalid).localizedDescription, position: .center)
                return
            }
            let payAmount = NSDecimalNumber.init(string: payAmountString).doubleValue
            guard payAmount != 0 else {
                self.makeToast(localLanguage(keyString: "wallet_market_pay_amount_least_title") + "\(transferViolasLeast)", position: .center)
                return
            }
            guard let exchangeAmountString = rightAmountTextField.text, exchangeAmountString.isEmpty == false else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .exchangeAmountEmpty).localizedDescription, position: .center)
                return
            }
            guard isPurnDouble(string: exchangeAmountString) == true else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .exchangeAmountInvalid).localizedDescription, position: .center)
                return
            }
            let exchangeAmount = NSDecimalNumber.init(string: exchangeAmountString).doubleValue
            guard exchangeAmount != 0 else {
                self.makeToast(localLanguage(keyString: "wallet_market_exchange_amount_least_title") + "\(transferViolasLeast)", position: .center)
                return
            }
            self.delegate?.exchangeToken(payToken: tempLeftModel,
                                         receiveToken: tempRightModel,
                                         amount: payAmount,
                                         exchangeAmount: exchangeAmount)
        }
    }
    @objc func selectExchangeToken(button: UIButton) {
        // 选择要兑换的币
        self.leftAmountTextField.resignFirstResponder()
        self.rightAmountTextField.resignFirstResponder()
        if button.tag == 30 {
            guard self.leftCoinButton.titleLabel?.text != "---" else {
                self.makeToast(LibraWalletError.WalletMarket(reason: .payTokenNotSelect).localizedDescription, position: .center)
                return
            }
        }
        self.delegate?.selectToken(button: button, leftModelName: self.leftTokenModel?.name ?? "---", rightModelName: self.rightTokenModel?.name ?? "---", header: self)
    }
    
    var leftTokenModel: MarketSupportCoinDataModel? {
        didSet {
            UIView.animate(withDuration: 2) {
                self.leftCoinButton.setTitle(self.leftTokenModel?.name ?? "---", for: UIControl.State.normal)
            }
//            calculateRate()
            // 点击左边处理左边
            guard let payAmountString = rightAmountTextField.text, payAmountString.isEmpty == false else {
                return
            }
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .up,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let number = NSDecimalNumber.init(string: payAmountString).dividing(by: NSDecimalNumber.init(string: self.exchangeRateLabel.text ?? "0"), withBehavior: numberConfig)
            leftAmountTextField.text = number.stringValue
        }
    }
    var rightTokenModel: MarketSupportCoinDataModel? {
        didSet {
            UIView.animate(withDuration: 2) {
                self.rightCoinButton.setTitle(self.rightTokenModel?.name ?? "---", for: UIControl.State.normal)
            }
//            calculateRate()
            // 点击右边处理右边
            guard let exchangeAmountString = leftAmountTextField.text, exchangeAmountString.isEmpty == false else {
                return
            }
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let number = NSDecimalNumber.init(string: exchangeAmountString).multiplying(by: NSDecimalNumber.init(string: self.exchangeRateLabel.text ?? "0"), withBehavior: numberConfig)
            rightAmountTextField.text = number.stringValue
        }
    }
    var rate: Double? {
        didSet {
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            self.exchangeRateLabel.text =  NSDecimalNumber.init(value: rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 1), withBehavior: numberConfig).stringValue
        }
    }
//    func calculateRate() {
//        guard let mainPrice = self.leftTokenModel?.price, mainPrice > 0 else {
//            return
//        }
//        guard let exchangePrice = self.rightTokenModel?.price, exchangePrice > 0 else {
//            return
//        }
//        if mainPrice == exchangePrice {
//            self.rate = 1
//        } else {
//            self.rate = mainPrice / exchangePrice
//        }
//        if let leftName = self.leftCoinButton.titleLabel?.text, let rightName = self.rightCoinButton.titleLabel?.text, leftName.isEmpty == false, rightName.isEmpty == false {
//            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
//                                                           scale: 4,
//                                                           raiseOnExactness: false,
//                                                           raiseOnOverflow: false,
//                                                           raiseOnUnderflow: false,
//                                                           raiseOnDivideByZero: false)
//            let number = NSDecimalNumber.init(value: self.rate).multiplying(by: NSDecimalNumber.init(value: 1), withBehavior: numberConfig)
//            self.exchangeRateLabel.text = "1 \(leftName) = \(number.stringValue) \(rightName)"
//
//        } else {
//            self.exchangeRateLabel.text = "---"
//        }
//        print("Rate:\(self.rate)")
//    }
    @objc func textFieldDidChange() {
        guard let payAmountString = leftAmountTextField.text else {
            return
        }
        guard let exchangeAmountString = rightAmountTextField.text else {
            return
        }
        if leftAmountTextField.isFirstResponder {
            guard isPurnDouble(string: payAmountString) else {
                return
            }
            //正在编辑左边
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let number = NSDecimalNumber.init(string: payAmountString).multiplying(by: NSDecimalNumber.init(string: self.exchangeRateLabel.text ?? "0"), withBehavior: numberConfig)
            rightAmountTextField.text = number.stringValue
        } else {
            guard isPurnDouble(string: exchangeAmountString) else {
                return
            }
            //正在编辑右边
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .up,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let number = NSDecimalNumber.init(string: exchangeAmountString).dividing(by: NSDecimalNumber.init(string: self.exchangeRateLabel.text ?? "0"), withBehavior: numberConfig)
            leftAmountTextField.text = number.stringValue
        }
    }
    @objc func setText() {
        leftAmountTextField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_transfer_amount_textfield_placeholder"),
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        rightAmountTextField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_market_receive_amount_textfield_placeholder"),
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        exchangeRateTitleLabel.text = localLanguage(keyString: "wallet_market_exchange_fee_title")
        transferFeeTitleLabel.text = localLanguage(keyString: "wallet_transfer_transaction_fee_title")
        transferSpeedLeftTitleLabel.text = localLanguage(keyString: "wallet_transfer_transaction_fee_least_title")
        transferSpeedRightTitleLabel.text = localLanguage(keyString: "wallet_transfer_transaction_fee_max_title")
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_exchange_confirm_title"), for: UIControl.State.normal)
    }
}
extension MarketExchangeHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                rightAmountTextField.text = ""
            }
        } else {
            if textLength == 0 {
                leftAmountTextField.text = ""
            }
        }
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 6 {
                return true
            } else {
                return false
            }
        } else {
            return textLength <= ApplyTokenAmountLengthLimit
        }
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.leftCoinButton.titleLabel?.text != "---" && self.rightCoinButton.titleLabel?.text != "---" {
            print("true")
            return true
        } else {
            print("false")
            return false
        }
    }
}
