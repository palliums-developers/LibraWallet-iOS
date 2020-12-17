//
//  ProfitPoolTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/3.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ProfitPoolTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(itemAddressTitleLabel)
        contentView.addSubview(itemAmountLabel)
        contentView.addSubview(itemDateLabel)
        contentView.addSubview(itemStatusLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ProfitPoolTableViewCell销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        itemAddressTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(22)
        }
        itemAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(124)
        }
        itemDateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView.snp.right).offset(-82)
        }
        itemStatusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView.snp.right).offset(-22)
        }
    }
    // MARK: - 懒加载对象
    lazy var itemAddressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.lineBreakMode = .byTruncatingMiddle
        label.text = localLanguage(keyString: "wallet_profit_pool_type_withdraw_title")
        return label
    }()
    lazy var itemAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.medium)
        label.text = "---"
        return label
    }()
    lazy var itemDateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var itemStatusLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    // MARK: - 设置数据
    var model: PoolProfitDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            itemDateLabel.text = timestampToDateString(timestamp: (tempModel.date ?? 0), dateFormat: "HH:mm MM/dd")
            itemAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.amount ?? 0),
                                                    scale: 6,
                                                    unit: 1000000).stringValue + "VLS"
            //订单状态：0：未到帐；1： 已到帐
            if tempModel.status == 0 {
                itemStatusLabel.textColor = UIColor.init(hex: "FB8F0B")
                itemStatusLabel.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .medium)
                itemStatusLabel.text = localLanguage(keyString: "wallet_profit_invitation_status_processing_title")
            } else if tempModel.status == 1 {
                itemStatusLabel.textColor = UIColor.init(hex: "333333")
                itemStatusLabel.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
                itemStatusLabel.text = localLanguage(keyString: "wallet_profit_invitation_status_success_title")
            } else {
                itemStatusLabel.text = localLanguage(keyString: "wallet_profit_invitation_status_unknown_title")
            }
        }
    }
}
//wallet_profit_pool_type_withdraw_title = "提取";
//wallet_profit_pool_type_loan_title = "借款";
//wallet_profit_pool_type_deposit_title = "存款";
