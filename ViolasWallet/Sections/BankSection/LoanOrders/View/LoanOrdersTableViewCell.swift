//
//  LoanOrdersTableViewCell.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanOrdersTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(orderTokenIconImageView)
        whiteBackgroundView.addSubview(orderTokenNameLabel)
        whiteBackgroundView.addSubview(orderTotalAmountTitleLabel)
        whiteBackgroundView.addSubview(orderTotalAmountLabel)
        whiteBackgroundView.addSubview(orderDetailImageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanOrdersTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(5)
            make.left.equalTo(contentView).offset(15)
            make.bottom.equalTo(contentView).offset(-5)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        orderTokenIconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(whiteBackgroundView).offset(12)
            make.size.equalTo(CGSize.init(width: 36, height: 36))
        }
        orderTokenNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(orderTokenIconImageView)
            make.left.equalTo(orderTokenIconImageView.snp.right).offset(8)
        }
        orderTotalAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView).offset(-11)
            make.right.equalTo(orderDetailImageView.snp.left).offset(-11)
        }
        orderTotalAmountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(orderDetailImageView.snp.left).offset(-11)
            make.centerY.equalTo(whiteBackgroundView).offset(11)
        }
        orderDetailImageView.snp.makeConstraints { (make) in
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
            make.centerY.equalTo(whiteBackgroundView)
            make.size.equalTo(CGSize.init(width: 7, height: 10))
        }
    }
    // MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    private lazy var orderTokenIconImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        view.layer.cornerRadius = 18
        view.layer.borderColor = UIColor.init(hex: "E0E0E0").cgColor
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        return view
    }()
    lazy var orderTokenNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var orderTotalAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_order_amount_title")
        return label
    }()
    lazy var orderTotalAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        label.text = "---"
        return label
    }()
    private lazy var orderDetailImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "cell_detail")
        return view
    }()
    //MARK: - 设置数据
    var model: LoanOrdersMainDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            if let iconName = model?.logo, iconName.isEmpty == false {
                if iconName.hasPrefix("http") {
                    let url = URL(string: iconName)
                    orderTokenIconImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
                } else {
                    orderTokenIconImageView.image = UIImage.init(named: iconName)
                }
            } else {
                orderTokenIconImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            orderTokenNameLabel.text = tempModel.name
            orderTotalAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.amount ?? 0),
                                                          scale: 6,
                                                          unit: 1000000).stringValue
        }
    }
}
