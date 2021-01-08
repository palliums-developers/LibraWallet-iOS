//
//  ScanBankLoanView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/9/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ScanBankLoanView: UIView {
    weak var delegate: ScanSendTransactionViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(scanLoginIndicator)
        addSubview(scanLoginTitleLabel)
        
        addSubview(topWhiteBackgroundView)
        topWhiteBackgroundView.addSubview(inputAmountTitleLabel)
        topWhiteBackgroundView.addSubview(inputAmountLabel)
        addSubview(bottomWhiteBackgroundView)
        bottomWhiteBackgroundView.addSubview(depositRateTitleLabel)
        bottomWhiteBackgroundView.addSubview(depositRateLabel)
        bottomWhiteBackgroundView.addSubview(depositWaysTitleLabel)
        bottomWhiteBackgroundView.addSubview(depositWaysLabel)
        
        addSubview(confirmButton)
        addSubview(cancelButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanBankLoanView销毁了")
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
        topWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(scanLoginIndicator.snp.bottom).offset(88)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(60)
        }
        inputAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(topWhiteBackgroundView)
            make.left.equalTo(topWhiteBackgroundView).offset(46)
        }
        inputAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(topWhiteBackgroundView)
            make.left.equalTo(inputAmountTitleLabel.snp.right).offset(31)
        }
        bottomWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(topWhiteBackgroundView.snp.bottom).offset(10)
            make.left.equalTo(self).offset(22)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(88)
        }
        depositRateTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bottomWhiteBackgroundView).offset(10)
            make.left.equalTo(bottomWhiteBackgroundView).offset(37)
            make.height.equalTo(31)
        }
        depositRateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(depositRateTitleLabel)
            make.left.equalTo(bottomWhiteBackgroundView).offset(130)
            make.right.equalTo(bottomWhiteBackgroundView.snp.right).offset(-14)
        }
        depositWaysTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(depositRateTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(bottomWhiteBackgroundView).offset(37)
            make.height.equalTo(31)
        }
        depositWaysLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(depositWaysTitleLabel)
            make.left.equalTo(bottomWhiteBackgroundView).offset(130)
            make.right.equalTo(bottomWhiteBackgroundView.snp.right).offset(-14)
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(bottomWhiteBackgroundView.snp.bottom).offset(50)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.right.equalTo(self).offset(-29)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
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
        label.text = localLanguage(keyString: "wallet_wallet_connect_bank_loan_title")
        label.numberOfLines = 0
        return label
    }()
    private lazy var topWhiteBackgroundView: UIView = {
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
    private lazy var bottomWhiteBackgroundView: UIView = {
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
    lazy var inputAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = localLanguage(keyString: "wallet_bank_loan_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 16)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var depositRateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_year_rate_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var depositRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
//        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var depositWaysTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_pay_account_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var depositWaysLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_pay_account_content")
        label.numberOfLines = 0
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_exchange_confirm_button_title"), for: UIControl.State.normal)
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
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.confirmLogin(password: "password")
        } else if button.tag == 20 {
            // 常用地址
            self.delegate?.cancelLogin()
        }
    }
    var model: WCRawTransaction? {
        didSet {
            let inputAmount = getDecimalNumber(amount: NSDecimalNumber.init(string: model?.payload?.args?[0].value ?? "0"),
                                               scale: 6,
                                               unit: 1000000)
            let (_, module) = ViolasManager.readTypeTags(data: Data.init(hex: model?.payload?.tyArgs?.first ?? "") ?? Data(), typeTagCount: 1)
            
            inputAmountLabel.text = inputAmount.stringValue + module
            
            depositRateLabel.text = ""
        }
    }
}
