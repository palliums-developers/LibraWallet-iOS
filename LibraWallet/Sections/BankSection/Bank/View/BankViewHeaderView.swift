//
//  BankViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

class BankViewHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(assetLabel)
        addSubview(withdrawAmountIndicatorImageView)
        addSubview(loanLimitAmountTitleLabel)
        addSubview(loanLimitAmountLabel)
        addSubview(benefitIndicatorImageView)
        addSubview(benefitTitleLabel)
        addSubview(benefitLabel)
        addSubview(yesterdayBenefitButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("BankViewHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        assetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(35)
        }
        withdrawAmountIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(assetLabel.snp.bottom).offset(20)
            make.left.equalTo(self).offset(35)
            make.size.equalTo(CGSize.init(width: 10, height: 10))
        }
        loanLimitAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(withdrawAmountIndicatorImageView)
            make.left.equalTo(withdrawAmountIndicatorImageView.snp.right).offset(8)
        }
        loanLimitAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(withdrawAmountIndicatorImageView)
            make.left.equalTo(withdrawAmountIndicatorImageView.snp.right).offset(140)
        }
        benefitIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(withdrawAmountIndicatorImageView.snp.bottom).offset(14)
            make.left.equalTo(self).offset(35)
            make.size.equalTo(CGSize.init(width: 10, height: 10))
        }
        benefitTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(benefitIndicatorImageView)
            make.left.equalTo(benefitIndicatorImageView.snp.right).offset(8)
        }
        benefitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(benefitIndicatorImageView)
            make.left.equalTo(benefitIndicatorImageView.snp.right).offset(140)
        }
        yesterdayBenefitButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(benefitIndicatorImageView).priority(250)
            make.right.equalTo(self.snp.right).offset(-30).priority(250)
            let width = 6 + 10 + 4 + libraWalletTool.ga_widthForComment(content: (localLanguage(keyString: "wallet_bank_yesterday_earnings_button_title") + " 0.00$"), fontSize: 10, height: 16) + 4
            make.size.equalTo(CGSize.init(width: width, height: 16)).priority(250)
        }
    }
    lazy var assetLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "FFFFFF")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: .medium)
        label.text = "≈$ 0.00"
        return label
    }()
    private lazy var withdrawAmountIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "bank_withdraw_indicator")
        view.isUserInteractionEnabled = true
        return view
    }()
    lazy var loanLimitAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_deposit_amount_title")
        return label
    }()
    lazy var loanLimitAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: .regular)
        label.text = "≈9999.9999"
        return label
    }()
    private lazy var benefitIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "bank_benefit_indicator")
        view.isUserInteractionEnabled = true
        return view
    }()
    lazy var benefitTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_total_benefit_title")
        return label
    }()
    lazy var benefitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: .regular)
        label.text = "≈0.00"
        return label
    }()
    lazy var yesterdayBenefitButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "bank_yesterday_benefit_indicator"), for: UIControl.State.normal)
        button.setTitle((localLanguage(keyString: "wallet_bank_yesterday_earnings_button_title") + " 0.00$"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "FB8F0B"), for: UIControl.State.normal)
//        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.imagePosition(at: .left, space: 4, imageViewSize: CGSize.init(width: 10, height: 6))
        button.backgroundColor = UIColor.init(hex: "#FB8F0B").alpha(0.1)
        button.tag = 20
        return button
    }()
    var model: BankModelMainDataModel? {
        didSet {
            assetLabel.text = "≈$\(model?.amount ?? 0.00)"
            loanLimitAmountLabel.text = "≈\(model?.borrow ?? 0.00)"
            benefitLabel.text = "≈\(model?.total ?? 0.00)"
            yesterdayBenefitButton.setTitle((localLanguage(keyString: "wallet_bank_yesterday_earnings_button_title") + "\(model?.yesterday ?? 0.00)$"), for: UIControl.State.normal)
            yesterdayBenefitButton.imagePosition(at: .left, space: 4, imageViewSize: CGSize.init(width: 10, height: 6))
        }
    }
}
//MARK: - 语言切换方法
extension BankViewHeaderView {
    /// 语言切换
    @objc func setText() {
        loanLimitAmountTitleLabel.text = localLanguage(keyString: "wallet_bank_deposit_amount_title")
        benefitTitleLabel.text = localLanguage(keyString: "wallet_bank_total_benefit_title")
        yesterdayBenefitButton.setTitle((localLanguage(keyString: "wallet_bank_yesterday_earnings_button_title") + "\(model?.yesterday ?? 0.00)$"), for: UIControl.State.normal)
        yesterdayBenefitButton.snp.remakeConstraints { (make) in
            make.centerY.equalTo(benefitIndicatorImageView)
            make.right.equalTo(self.snp.right).offset(-30)
            let width = 6 + 10 + 4 + libraWalletTool.ga_widthForComment(content: (localLanguage(keyString: "wallet_bank_yesterday_earnings_button_title") + "\(model?.yesterday ?? 0.00)$"), fontSize: 10, height: 16) + 4
            make.size.equalTo(CGSize.init(width: width, height: 16))
        }
    }
}
