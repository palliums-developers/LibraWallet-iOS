//
//  LoanDetailDepositListTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanDetailDepositListTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(itemTimeLabel)
        contentView.addSubview(itemAmountLabel)
        contentView.addSubview(itemStatusLabel)
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanDetailDepositListTableViewCell销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        itemTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(34)
        }
        itemAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(156)
        }
        itemStatusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView.snp.right).offset(-26)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(34)
            make.bottom.equalTo(contentView.snp.bottom)
            make.right.equalTo(contentView.snp.right).offset(-26)
            make.height.equalTo(0.5)
        }
    }
    // MARK: - 懒加载对象
    lazy var itemTimeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "18:22 05/22"
        return label
    }()
    lazy var itemAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "99999999.9999"
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
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    // MARK: - 设置数据
    var model: LoanOrderDetailMainDataListModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            itemTimeLabel.text = timestampToDateString(timestamp: (tempModel.date ?? 0), dateFormat: "HH:mm MM/dd")
            itemAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.amount ?? 0),
                                                    scale: 6,
                                                    unit: 1000000).stringValue
            if tempModel.status == 1 {
                itemStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_deposited_title")
            }
        }
    }
}
