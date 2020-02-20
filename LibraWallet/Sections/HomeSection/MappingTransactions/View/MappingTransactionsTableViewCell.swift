//
//  MappingTransactionsTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MappingTransactionsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(dateTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(coinLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(stateLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MappingTransactionsTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        dateTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(19)
            make.top.equalTo(contentView).offset(16)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dateTitleLabel).offset(1)
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(3)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(16)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(amountTitleLabel).offset(1)
            make.top.equalTo(amountTitleLabel.snp.bottom).offset(3)
        }
        typeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-19)
            make.top.equalTo(contentView).offset(16)
        }
        coinLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-19)
            make.top.equalTo(typeLabel.snp.bottom).offset(3)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(19)
            make.right.equalTo(stateLabel.snp.left).offset(-5)
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
        stateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-19)
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
        //防止用户名字挤压
        //宽度不够时，可以被压缩
        addressLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容
        addressLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        //不可以被压缩，尽量显示完整
        stateLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    //MARK: - 懒加载对象
    lazy var dateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "808080")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_mapping_transactions_date_title")
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "808080")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_mapping_transactions_amount_title")
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var typeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_mapping_transactions_state_title")
        return label
    }()
    lazy var coinLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "808080")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.lineBreakMode = .byTruncatingMiddle
        label.text = "---"
        return label
    }()
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
//        label.textColor = UIColor.init(hex: "7A7AEE")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var tokenName: String?
    var model: MappingTransactionsMainDataModel? {
        didSet {
            dateLabel.text = timestampToDateString(timestamp: model?.date ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(string: model?.amount ?? "0"),
                                                      scale: 8,
                                                      unit: 1000000)
            addressLabel.text = model?.address
            coinLabel.text = "BTC"
            if model?.state == 0 {
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_ongoing_title")
                stateLabel.textColor = UIColor.init(hex: "5BBE75")
            } else if model?.state == 1 {
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_success_title")
                stateLabel.textColor = UIColor.init(hex: "000000")
            } else {
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_failed_title")
                stateLabel.textColor = UIColor.init(hex: "FF6464")
            }
        }
    }
}
