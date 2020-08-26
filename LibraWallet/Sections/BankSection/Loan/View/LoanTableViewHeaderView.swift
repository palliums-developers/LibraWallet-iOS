//
//  LoanTableViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanTableViewHeaderView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(depositTitleLabel)
        whiteBackgroundView.addSubview(depositTokenIndicatorImageView)
        whiteBackgroundView.addSubview(depositTokenSelectButton)
        whiteBackgroundView.addSubview(depositAmountTextField)
        whiteBackgroundView.addSubview(depositTextfieldSpaceLabel)
        whiteBackgroundView.addSubview(depositBalanceIndicatorImageView)
        whiteBackgroundView.addSubview(depositAmountTitleLabel)
        whiteBackgroundView.addSubview(depositAmountLabel)
        whiteBackgroundView.addSubview(totalLoanAmountSelectButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanTableViewHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.bottom.equalTo(contentView).offset(-10)
        }
        depositTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(20)
            make.left.equalTo(whiteBackgroundView).offset(14)
        }
        depositTokenIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(depositTokenSelectButton)
            make.right.equalTo(depositTokenSelectButton.snp.left).offset(-4)
            make.size.equalTo(CGSize.init(width: 14, height: 14))
        }
        depositTokenSelectButton.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(20)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-10)
        }
        depositAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.bottom.equalTo(depositTextfieldSpaceLabel.snp.top)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
            make.height.equalTo(50)
        }
        depositTextfieldSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(86)
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
            make.height.equalTo(0.5)
        }
        depositBalanceIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(depositTextfieldSpaceLabel.snp.bottom).offset(11)
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        depositAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(depositBalanceIndicatorImageView)
            make.left.equalTo(depositBalanceIndicatorImageView.snp.right).offset(4)
        }
        depositAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(depositBalanceIndicatorImageView)
            make.left.equalTo(depositAmountTitleLabel.snp.right).offset(5)
        }
        totalLoanAmountSelectButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(depositBalanceIndicatorImageView)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
        }
    }
    //MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var depositTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_title")
        return label
    }()
    private lazy var depositTokenIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.red
        return imageView
    }()
    lazy var depositTokenSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle("Test", for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "333333"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        //        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        //
        button.setImage(UIImage.init(named: "cell_detail"), for: UIControl.State.normal)
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 12, height: 12))
        
        return button
    }()
    lazy var depositAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        //        textField.delegate = self
        textField.tag = 20
        return textField
    }()
    lazy var depositTextfieldSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    private lazy var depositBalanceIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.image = UIImage.init(named: "wallet_bank_deposit_balance")
        return imageView
    }()
    lazy var depositAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_balance_title")
        return label
    }()
    lazy var depositAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.medium)
        label.text = "999999"
        return label
    }()
    private lazy var totalLoanAmountSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_repayment_repayment_amount_total_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        //        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
}
// = "我要还";
//wallet_bank_repayment_textfield_placeholder_a = "起";
//wallet_bank_repayment_textfield_placeholder_b = "每";
//wallet_bank_repayment_textfield_placeholder_c = "递增";
// = "待还金额";
// = "全部";
//
//wallet_bank_deposit_title = "我要存";
//wallet_bank_deposit_amount_title = "可用余额";
//wallet_bank_deposit_limit_amount_title = "每日限额";
//wallet_bank_deposit_year_rate_title = "存款年利率";
//wallet_bank_deposit_pledge_rate_title = "质押率";
//wallet_bank_deposit_pledge_rate_descript_title = "质押率=借贷数量/存款数量";
//wallet_bank_deposit_pay_account_title = "支付方式";
//wallet_bank_deposit_pay_account_content = "钱包余额";
//wallet_bank_deposit_describe_title = "产品说明";
//wallet_bank_deposit_question_title = "常见问题";
//wallet_bank_loan_button_title = "立即借款";
//wallet_bank_loan_year_rate_title = "借款利率";
//wallet_bank_loan_pledge_rate_title = "质押率";
//wallet_bank_loan_pledge_rate_descript_title = "质押率=借贷数量/存款数量";
//wallet_bank_loan_pay_account_title = "质押账户";
//wallet_bank_loan_pay_account_content = "银行余额";
