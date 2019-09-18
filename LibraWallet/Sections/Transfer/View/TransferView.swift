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
        self.layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(scrollView)
        insertSubview(backgroundImageView, at: 1)
        
        scrollView.addSubview(walletWhiteBackgroundView)
        walletWhiteBackgroundView.addSubview(walletIconImageView)
        walletWhiteBackgroundView.addSubview(addressTitleLabel)
        walletWhiteBackgroundView.addSubview(addressTextField)
        walletWhiteBackgroundView.addSubview(addressScanButton)
        walletWhiteBackgroundView.addSubview(addressMiddleSpaceLabel)
        walletWhiteBackgroundView.addSubview(addressContactButton)
        walletWhiteBackgroundView.addSubview(addressSpaceLabel)
        
        walletWhiteBackgroundView.addSubview(amountTitleLabel)
        walletWhiteBackgroundView.addSubview(amountTextField)
//        walletWhiteBackgroundView.addSubview(coinUnitLabel)
//        walletWhiteBackgroundView.addSubview(amountUnitChangeButton)
        walletWhiteBackgroundView.addSubview(amountSpaceLabel)
        
        walletWhiteBackgroundView.addSubview(walletBalanceLabel)
        walletWhiteBackgroundView.addSubview(selectTotalCoinButton)
        
        walletWhiteBackgroundView.addSubview(transactionFeeTitleLabel)
        walletWhiteBackgroundView.addSubview(transactionFeeLabel)
        walletWhiteBackgroundView.addSubview(transactionFeeUnitLabel)
        walletWhiteBackgroundView.addSubview(transactionFeeSpaceLabel)
        
        walletWhiteBackgroundView.addSubview(confirmButton)
//        walletWhiteBackgroundView.addSubview(amountUnitAlertLabel)
//
//        walletWhiteBackgroundView.addSubview(amountUnitAlertLabel)
        
//        scrollView.addSubview(transactionAlertLabel)
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
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self)
        }
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(21)
            make.right.equalTo(self).offset(-21)
            make.height.equalTo((395 * ratio))
            make.top.equalTo(scrollView).offset(57 + navigationBarHeight)
        }
        walletIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.walletWhiteBackgroundView)
            make.top.equalTo(self.walletWhiteBackgroundView).offset(-34)
        }
        addressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletWhiteBackgroundView).offset(57)
            make.left.equalTo(self.walletWhiteBackgroundView).offset(21)
        }
        addressTextField.snp.makeConstraints { (make) in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(self.walletWhiteBackgroundView).offset(21)
            make.right.equalTo(self.addressScanButton.snp.left).offset(-5)
            make.height.equalTo(40)
        }
        addressScanButton.snp.makeConstraints { (make) in
            make.right.equalTo(addressMiddleSpaceLabel.snp.left).offset(-16)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
            make.centerY.equalTo(addressTextField)
        }
        addressMiddleSpaceLabel.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize.init(width: 1, height: 20))
            make.centerY.equalTo(addressContactButton)
            make.right.equalTo(addressContactButton.snp.left).offset(-18)
        }
        addressContactButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTextField)
            make.size.equalTo(CGSize.init(width: 21, height: 20))
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-16)
        }
        addressSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressContactButton.snp.bottom).offset(10)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
            make.height.equalTo(1)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressSpaceLabel.snp.bottom).offset(15)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
        }
        amountTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(amountSpaceLabel.snp.top)
            make.left.equalTo(self.walletWhiteBackgroundView).offset(21)
            make.right.equalTo(self.walletWhiteBackgroundView.snp.right).offset(0)
            make.height.equalTo(40)
        }
//        coinUnitLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(amountTextField)
//            make.right.equalTo(amountUnitChangeButton.snp.left).offset(-1)
//            make.width.equalTo(50)
//        }
//        amountUnitChangeButton.snp.makeConstraints { (make) in
//            make.centerY.equalTo(amountTextField)
//            make.size.equalTo(CGSize.init(width: 11, height: 13))
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-9)
//        }
        amountSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressSpaceLabel.snp.bottom).offset(83)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
            make.height.equalTo(1)
        }
        walletBalanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountSpaceLabel).offset(3)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
        }
        selectTotalCoinButton.snp.makeConstraints { (make) in
            make.top.equalTo(amountSpaceLabel).offset(1)
            make.right.equalTo(walletWhiteBackgroundView).offset(-21)
        }
        
        transactionFeeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountSpaceLabel.snp.bottom).offset(28)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
        }
        transactionFeeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(transactionFeeSpaceLabel.snp.top)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
            make.right.equalTo(transactionFeeUnitLabel.snp.left)
            make.height.equalTo(40)
        }
        transactionFeeUnitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(transactionFeeLabel)
            make.right.equalTo(walletWhiteBackgroundView).offset(-21)
            make.width.equalTo(50)
        }
        transactionFeeSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountSpaceLabel.snp.bottom).offset(93)
            make.left.equalTo(walletWhiteBackgroundView).offset(21)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-19)
            make.height.equalTo(1)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.walletWhiteBackgroundView)
            make.top.equalTo(self.transactionFeeSpaceLabel.snp.bottom).offset(16)
            make.left.equalTo(walletWhiteBackgroundView).offset(76)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-76)
            make.height.equalTo(37)
        }
//        amountUnitAlertLabel.snp.makeConstraints { (make) in
//            make.centerX.equalTo(self.walletWhiteBackgroundView)
//            make.top.equalTo(self.confirmButton.snp.bottom).offset(10)
//            make.left.equalTo(walletWhiteBackgroundView).offset(60)
//            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-60)
//        }
//        transactionAlertLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(walletWhiteBackgroundView.snp.bottom).offset(15)
//            make.left.equalTo(self).offset(21)
//            make.right.equalTo(self).offset(-21)
//            make.height.equalTo(51)
//        }
        scrollView.contentSize = CGSize.init(width: mainWidth, height: walletWhiteBackgroundView.frame.maxY + 10)
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = localLanguage(keyString: "wallet_withdraw_address_title")
        return label
    }()
    lazy var addressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_withdraw_address_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "B5B5B5"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .default
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var addressScanButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "withdraw_address_scan"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        
        button.tag = 10
        return button
    }()
    lazy var addressMiddleSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "515151")
        return label
    }()
    lazy var addressContactButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "withdraw_address_contact"), for: UIControl.State.normal)
        
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 15
        return button
    }()
    lazy var addressSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "2E2E2E")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = localLanguage(keyString: "wallet_withdraw_amount_title")
        return label
    }()
    lazy var amountTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_withdraw_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "B5B5B5"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        //        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var coinUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "mBTC"
        return label
    }()
    lazy var amountUnitChangeButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "home_select_unit_icon"), for: UIControl.State.normal)
        
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var amountSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var walletBalanceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.text = localLanguage(keyString: "wallet_withdraw_wallet_balance_prefix_title") + " --- Libra"
        return label
    }()
    lazy var selectTotalCoinButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_withdraw_select_total_coin_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "515151"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 25
        return button
    }()
    lazy var transactionFeeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "2E2E2E")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = localLanguage(keyString: "wallet_withdraw_transaction_fee_title")
        return label
    }()
    lazy var transactionFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "0.0"
        return label
    }()
    lazy var transactionFeeUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "2E2E2E")
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.text = "Libra"
        return label
    }()
    lazy var transactionFeeSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_withdraw_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        button.layer.cornerRadius = 7
        //        button.layer.masksToBounds = true
        button.tag = 30
        // 定义阴影颜色
        button.layer.shadowColor = DefaultGreenColor.cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 8
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.2
        return button
    }()
    lazy var amountUnitAlertLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "B1B1B1")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = ""
        return label
    }()
    lazy var transactionAlertLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "2E3550")
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "9EA1AD")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = ""
        return label
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // 扫描地址
            self.delegate?.scanAddressQRcode()
        } else if button.tag == 15 {
            // 常用地址
            self.delegate?.chooseAddress()
        } else if button.tag == 20 {
            // 切换单位
//            var configArray = [FTCellConfiguration]()
//            let titleArray = ["BTC", "mBTC", "Sat"]
//            for unit in titleArray {
//                let cellConfig = FTCellConfiguration()
//                cellConfig.textColor = unit == selectUnit?.description ? DefaultGreenColor:UIColor.init(hex: "515151")
//                cellConfig.textFont = UIFont.systemFont(ofSize: 19)
//                cellConfig.textAlignment = .center
//                configArray.append(cellConfig)
//            }
//            loadPopMenuConfig()
//            FTPopOverMenu.showForSender(sender: button, with: ["BTC", "mBTC", "Sat"], menuImageArray: nil, cellConfigurationArray: configArray, done: { [weak self](selectedIndex) in
//                print(selectedIndex)
//                var rate = 0.0
//                if selectedIndex == 0 {
//                    rate = Double(BTCUnit.BTC.rate)
//                    self?.selectUnit = BTCUnit.BTC
//                    self?.coinUnitLabel.text = BTCUnit.BTC.description
//                    self?.transactionFeeUnitLabel.text = BTCUnit.BTC.description
//                } else if selectedIndex == 1 {
//                    rate = Double(BTCUnit.mBTC.rate)
//                    self?.selectUnit = BTCUnit.mBTC
//                    self?.coinUnitLabel.text = BTCUnit.mBTC.description
//                    self?.transactionFeeUnitLabel.text = BTCUnit.mBTC.description
//                } else {
//                    rate = Double(BTCUnit.Sat.rate)
//                    self?.selectUnit = BTCUnit.Sat
//                    self?.coinUnitLabel.text = BTCUnit.Sat.description
//                    self?.transactionFeeUnitLabel.text = BTCUnit.Sat.description
//                }
//                let balance = Double(WalletData.wallet.walletBalance!) / rate
//                if let fee = self?.originFee {
//                    self?.transactionFeeLabel.text = "\(Double(fee) / rate)"
//                }
//                let balanceString = "\(balance)"
//                if balanceString.hasSuffix(".0") {
//                    self?.walletBalanceLabel.text = localLanguage(keyString: "wallet_pay_wallet_balance_prefix_title") + " \(balanceString.replacingOccurrences(of: ".0", with: "")) \((self?.selectUnit!.description)!)"
//                } else {
//                    self?.walletBalanceLabel.text = localLanguage(keyString: "wallet_pay_wallet_balance_prefix_title") + " \(balanceString) \((self?.selectUnit!.description)!)"
//                }
//            })
        } else if button.tag == 25 {
            // 选择全部
//            self.amountTextField.text = WalletData.wallet.walletBalanceWithUnit
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
}
