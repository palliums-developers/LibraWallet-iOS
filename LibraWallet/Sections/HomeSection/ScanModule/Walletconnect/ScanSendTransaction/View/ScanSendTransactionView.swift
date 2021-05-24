//
//  ScanSendTransactionView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol ScanSendTransactionViewDelegate: NSObjectProtocol {
    func cancelLogin()
    func confirmLogin(password: String)
}
class ScanSendTransactionView: UIView {
    weak var delegate: ScanSendTransactionViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(transactionAmountTitleLabel)
        whiteBackgroundView.addSubview(transactionAmountLabel)
        whiteBackgroundView.addSubview(transactionReceiveAddressTitleLabel)
        whiteBackgroundView.addSubview(transactionReceiveAddressLabel)
        whiteBackgroundView.addSubview(spaceLabel)
        whiteBackgroundView.addSubview(minerFeesTitleLabel)
        whiteBackgroundView.addSubview(minerFeesLabel)
        
        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanSendTransactionView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scanLoginIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(101)
            make.centerX.equalTo(self)
        }
        scanLoginTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(28)
            make.centerX.equalTo(self)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(88)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(68 + 68 + 1 + 55)
        }
        transactionAmountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(14)
            make.left.equalTo(whiteBackgroundView).offset(14)
        }
        transactionAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(transactionAmountTitleLabel.snp.bottom).offset(8)
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
        }
        transactionReceiveAddressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(transactionAmountLabel.snp.bottom).offset(16)
            make.left.equalTo(whiteBackgroundView).offset(14)
        }
        transactionReceiveAddressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(transactionReceiveAddressTitleLabel.snp.bottom).offset(12)
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
            make.height.equalTo(0.5)
            make.top.equalTo(whiteBackgroundView).offset(138)
        }
        minerFeesTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(spaceLabel.snp.bottom)
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.bottom.equalTo(whiteBackgroundView)
        }
        minerFeesLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minerFeesTitleLabel)
            make.left.equalTo(whiteBackgroundView).offset(130)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView.snp.bottom).offset(53)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-29)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        //抱紧内容
        transactionAmountTitleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    //MARK: - 懒加载对象
    lazy var scanLoginIndicator : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "scan_login_indicator")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var scanLoginTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = localLanguage(keyString: "wallet_wallet_connect_transfer_title")
        label.numberOfLines = 0
        return label
    }()
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
//        // 定义阴影颜色
//        view.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
//        // 阴影的模糊半径
//        view.layer.shadowRadius = 3
//        // 阴影的偏移量
//        view.layer.shadowOffset = CGSize(width: 0, height: 0)
//        // 阴影的透明度，默认为0，不设置则不会显示阴影****
//        view.layer.shadowOpacity = 0.1
        return view
    }()
    lazy var transactionAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_wallet_connect_transfer_amount_title")
        return label
    }()
    lazy var transactionAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 16)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
//    lazy var transactionAmountUnitLabel: UILabel = {
//        let label = UILabel.init()
//        label.textAlignment = NSTextAlignment.left
//        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        label.text = "---"
//        label.numberOfLines = 0
//        return label
//    }()
    lazy var transactionReceiveAddressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_wallet_connect_transfer_receive_address_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var transactionReceiveAddressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()

    lazy var minerFeesTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_repayment_miner_fees_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var minerFeesLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_transfer_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69

        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "close_black"), for: UIControl.State.normal)

        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var toastView: ToastView = {
        let toast = ToastView.init()
        return toast
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
//            self.passwordTextField.resignFirstResponder()
//            // 扫描地址
//            guard let password = passwordTextField.text, password.isEmpty == false else {
//                self.makeToast(LibraWalletError.WalletAddWallet(reason: .passwordEmptyError).localizedDescription,
//                               position: .center)
//                return
//            }
            self.delegate?.confirmLogin(password: "password")
        } else if button.tag == 20 {
            // 常用地址
            self.delegate?.cancelLogin()
        }
    }
    var model: WCRawTransaction? {
        didSet {
            if let args = model?.payload?.args, args.count > 0 {
                for item in args {
                    if item.type?.lowercased() == "address" {
                        transactionReceiveAddressLabel.text = item.value
                    } else if item.type?.lowercased() == "bool" {

                    } else if item.type?.lowercased() == "vector" {
                    } else if item.type?.lowercased() == "u64" {
                        let amount = getDecimalNumber(amount: NSDecimalNumber.init(string: item.value),
                                                      scale: 6,
                                                      unit: 1000000)
                        transactionAmountLabel.text = amount.stringValue
                    }
                }
            }
            if let typeArgument = model?.payload?.tyArgs, typeArgument.isEmpty == false {
                let (_, module) = ViolasManager.readTypeTags(data: Data.init(hex: typeArgument.first ?? "") ?? Data(), typeTagCount: typeArgument.count)
                let amount = transactionAmountLabel.text
                transactionAmountLabel.text = (amount ?? "---") + " " + module
            }
            let feeNumber = NSDecimalNumber.init(value: model?.maxGasAmount ?? 0).multiplying(by: NSDecimalNumber.init(value: model?.gasUnitPrice ?? 0))
            let feeString = getDecimalNumber(amount: feeNumber,
                                       scale: 6,
                                       unit: 1000000).stringValue
            minerFeesLabel.text = feeString + " " + (model?.gasCurrencyCode ?? "VLS")
        }
    }
    var libraModel: WCLibraRawTransaction? {
         didSet {
             if let args = libraModel?.payload?.args, args.count > 0 {
                 for item in args {
                     if item.type?.lowercased() == "address" {
                         transactionReceiveAddressLabel.text = item.value
                     } else if item.type?.lowercased() == "bool" {

                     } else if item.type?.lowercased() == "vector" {
                     } else if item.type?.lowercased() == "u64" {
                         let amount = getDecimalNumber(amount: NSDecimalNumber.init(string: item.value),
                                                       scale: 6,
                                                       unit: 1000000)
                         transactionAmountLabel.text = amount.stringValue + " " + (libraModel?.payload?.tyArgs?.first?.module ?? "")
                     }
                 }
             }
            let feeNumber = NSDecimalNumber.init(value: libraModel?.maxGasAmount ?? 0).multiplying(by: NSDecimalNumber.init(value: model?.gasUnitPrice ?? 0))
            let feeString = getDecimalNumber(amount: feeNumber,
                                             scale: 6,
                                             unit: 1000000).stringValue
            minerFeesLabel.text = feeString + (libraModel?.gasCurrencyCode ?? "XUS")
         }
     }
    var btcModel: WCBTCRawTransaction? {
        didSet {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(string: btcModel?.amount ?? "0"),
                                          scale: 6,
                                          unit: 100000000)
            transactionAmountLabel.text = amount.stringValue + " " + "Bitcoin"

            transactionReceiveAddressLabel.text = btcModel?.payeeAddress
            
            minerFeesLabel.text = "---"
        }
    }
}
