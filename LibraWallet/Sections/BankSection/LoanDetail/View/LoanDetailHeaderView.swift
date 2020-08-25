//
//  LoanDetailHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanDetailHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(assetTitleLabel)
        addSubview(assetLabel)
        addSubview(assetUnitLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanDetailHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        assetTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(30)
            make.left.equalTo(self).offset(34)
        }
        assetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(assetTitleLabel.snp.bottom).offset(12)
            make.left.equalTo(self).offset(34)
        }
        assetUnitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(assetLabel).offset(3)
            make.left.equalTo(assetLabel.snp.right).offset(8)
        }
    }
    lazy var assetTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_detail_remaining_payment_amount_title")
        return label
    }()
    lazy var assetLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "7038FD")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 24), weight: .bold)
        label.text = "99999999.9999"
        return label
    }()
    lazy var assetUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: .regular)
        label.text = "VLS"
        return label
    }()
    //    var model: Token? {
    //        didSet {
    //
    //            self.walletAddressLabel.text = model?.tokenAddress
    //            var unit = 1000000
    //            switch model?.tokenType {
    //            case .BTC:
    //                self.walletTypeLabel.text = "BTC"
    //                self.walletIndicatorImageView.image = UIImage.init(named: "btc_icon")
    //                unit = 100000000
    //            case .Libra:
    //                self.walletTypeLabel.text = model?.tokenName
    //                self.walletIndicatorImageView.image = UIImage.init(named: "libra_icon")
    //            case .Violas:
    //                self.walletTypeLabel.text = model?.tokenName
    //                self.walletIndicatorImageView.image = UIImage.init(named: "violas_icon")
    //            default:
    //                self.walletIndicatorImageView.image = UIImage.init(named: "wallet_icon_default")
    //            }
    //            self.amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model?.tokenBalance ?? 0)),
    //                                                           scale: 4,
    //                                                           unit: unit)
    //            let rate = NSDecimalNumber.init(string: model?.tokenPrice ?? "0.0")
    //            let amount = NSDecimalNumber.init(string: amountLabel.text ?? "0.0")
    //            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
    //                                                           scale: 4,
    //                                                           raiseOnExactness: false,
    //                                                           raiseOnOverflow: false,
    //                                                           raiseOnUnderflow: false,
    //                                                           raiseOnDivideByZero: false)
    //            let value = rate.multiplying(by: amount, withBehavior: numberConfig)
    //            amountValueLabel.text = "≈$\(value.stringValue)"
    //        }
    //    }
}
