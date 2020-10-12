//
//  DepositMarketTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class DepositMarketTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        contentView.addSubview(itemContentView)
        itemContentView.addSubview(itemIconImageView)
        itemContentView.addSubview(itemNameLabel)
        itemContentView.addSubview(itemDescribeLabel)
        itemContentView.addSubview(itemBenefitLabel)
        itemContentView.addSubview(itemBenefitTitleLabel)
        // 添加语言变换通知
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("DepositMarketTableViewCell销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.top.bottom.equalTo(contentView)
        }
        itemContentView.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(15)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-15)
            make.top.equalTo(whiteBackgroundView)
            make.bottom.equalTo(whiteBackgroundView.snp.bottom).offset(-10)
        }
        itemIconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(itemContentView).offset(12)
            make.centerY.equalTo(itemContentView)
            make.size.equalTo(CGSize.init(width: 36, height: 36))
        }
        itemNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(itemContentView).offset(-11)
            make.left.equalTo(itemIconImageView.snp.right).offset(8)
        }
        itemDescribeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(itemIconImageView.snp.right).offset(8)
            make.centerY.equalTo(itemContentView).offset(12)
        }
        itemBenefitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(itemNameLabel)
            make.right.equalTo(itemContentView.snp.right).offset(-12)
        }
        itemBenefitTitleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(itemContentView.snp.right).offset(-12)
            make.centerY.equalTo(itemDescribeLabel)
        }
    }
    // MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    private lazy var itemContentView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        return view
    }()
    private lazy var itemIconImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        view.layer.cornerRadius = 18
        view.layer.borderColor = UIColor.init(hex: "E0E0E0").cgColor
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var itemNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var itemDescribeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var itemBenefitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: UIFont.Weight.bold)
        label.text = "---"
        return label
    }()
    private lazy var itemBenefitTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    // MARK: - 设置数据
    var model: BankDepositMarketDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            if let iconName = tempModel.logo, iconName.isEmpty == false {
                if iconName.hasPrefix("http") {
                    let url = URL(string: iconName)
                    itemIconImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
                } else {
                    itemIconImageView.image = UIImage.init(named: iconName)
                }
            } else {
                itemIconImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            itemNameLabel.text = tempModel.name
            itemDescribeLabel.text = tempModel.desc
            itemBenefitLabel.text = NSDecimalNumber.init(value: tempModel.rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"
            itemBenefitTitleLabel.text = tempModel.rate_desc
        }
    }
}
