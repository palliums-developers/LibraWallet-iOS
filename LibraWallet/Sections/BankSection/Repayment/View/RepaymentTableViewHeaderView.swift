//
//  RepaymentTableViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol RepaymentTableViewHeaderViewDelegate: NSObjectProtocol {
    func selectTotalBalance(header: RepaymentTableViewHeaderView, model: RepaymentMainDataModel)
}
class RepaymentTableViewHeaderView: UITableViewHeaderFooterView {
    weak var delegate: RepaymentTableViewHeaderViewDelegate?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(repaymentTitleLabel)
        whiteBackgroundView.addSubview(repaymentTokenIndicatorImageView)
        whiteBackgroundView.addSubview(repaymentTokenSelectButton)
        whiteBackgroundView.addSubview(repaymentAmountTextField)
        whiteBackgroundView.addSubview(repaymentTextfieldSpaceLabel)
        whiteBackgroundView.addSubview(loanTokenIndicatorImageView)
        whiteBackgroundView.addSubview(loanTokenAmountTitleLabel)
        whiteBackgroundView.addSubview(loanTokenAmountLabel)
        whiteBackgroundView.addSubview(totalLoanAmountSelectButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("RepaymentTableViewHeaderView销毁了")
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
        repaymentTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(20)
            make.left.equalTo(whiteBackgroundView).offset(14)
        }
        repaymentTokenIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(repaymentTokenSelectButton)
            make.right.equalTo(repaymentTokenSelectButton.snp.left).offset(-4)
            make.size.equalTo(CGSize.init(width: 14, height: 14))
        }
        repaymentTokenSelectButton.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(20)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-10)
        }
        repaymentAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.bottom.equalTo(repaymentTextfieldSpaceLabel.snp.top)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
            make.height.equalTo(50)
        }
        repaymentTextfieldSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(86)
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
            make.height.equalTo(0.5)
        }
        loanTokenIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(repaymentTextfieldSpaceLabel.snp.bottom).offset(11)
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        loanTokenAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(loanTokenIndicatorImageView)
            make.left.equalTo(loanTokenIndicatorImageView.snp.right).offset(4)
        }
        loanTokenAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(loanTokenIndicatorImageView)
            make.left.equalTo(loanTokenAmountTitleLabel.snp.right).offset(5)
        }
        totalLoanAmountSelectButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(loanTokenIndicatorImageView)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
        }
    }
    //MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var repaymentTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_repayment_title")
        return label
    }()
    private lazy var repaymentTokenIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        imageView.image = UIImage.init(named: "wallet_icon_default")
        return imageView
    }()
    lazy var repaymentTokenSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle("---", for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "333333"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
//        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "cell_detail"), for: UIControl.State.normal)
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 12, height: 12))
        return button
    }()
    lazy var repaymentAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        textField.tag = 20
        return textField
    }()
    lazy var repaymentTextfieldSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    private lazy var loanTokenIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.image = UIImage.init(named: "wallet_bank_deposit_balance")
        return imageView
    }()
    lazy var loanTokenAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_repayment_repayment_amount_title")
        return label
    }()
    lazy var loanTokenAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.medium)
        label.text = "---"
        return label
    }()
    lazy var totalLoanAmountSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_repayment_repayment_amount_total_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.repaymentAmountTextField.resignFirstResponder()
        guard let tempModel = model else {
            return
        }
        self.delegate?.selectTotalBalance(header: self, model: tempModel)
    }
    var model: RepaymentMainDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            let amountLeast = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.balance ?? 0),
                                               scale: 4,
                                               unit: 1000000)
            loanTokenAmountLabel.text = amountLeast.stringValue + " " + (tempModel.token_show_name ?? "")
            if let iconName = tempModel.logo, iconName.isEmpty == false {
                if iconName.hasPrefix("http") {
                    let url = URL(string: iconName)
                    loanTokenIndicatorImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
                } else {
                    loanTokenIndicatorImageView.image = UIImage.init(named: iconName)
                }
            } else {
                loanTokenIndicatorImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            repaymentTokenSelectButton.setTitle(tempModel.token_show_name, for: UIControl.State.normal)
            repaymentTokenSelectButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 12, height: 12))
        }
    }
}
