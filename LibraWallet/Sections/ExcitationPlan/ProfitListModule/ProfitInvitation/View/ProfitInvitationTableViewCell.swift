//
//  ProfitInvitationTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/2.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ProfitInvitationTableViewCell: UITableViewCell {
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
        print("ProfitInvitationTableViewCell销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        itemAddressTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(22)
            make.width.equalTo(79)
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
        label.text = "tlb1pgc28wuxspzzmvghzen74dczc8le4a35fgrxhcuqs2unfd"
        return label
    }()
    lazy var itemAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.medium)
        label.text = "10VLS"
        return label
    }()
    lazy var itemDateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "18:22 05/24"
        return label
    }()
    lazy var itemStatusLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "Done"
        return label
    }()
    // MARK: - 设置数据
    var model: LoanOrderDetailMainDataListModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            itemDateLabel.text = timestampToDateString(timestamp: (tempModel.date ?? 0), dateFormat: "HH:mm MM/dd")
            itemAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.amount ?? 0),
                                                    scale: 6,
                                                    unit: 1000000).stringValue
            //订单状态，0（已借款），1（已还款），-1（借款失败），-2（还款失败）2（已清算）
            if tempModel.status == 0 {
                itemStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_loan_status_loaned_title")
            } else if tempModel.status == 1 {
                itemStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_deposited_title")
            } else if tempModel.status == 2 {
                itemStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_status_title")
            } else if tempModel.status == -1 {
                itemStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_loan_status_failed_title")
            } else if tempModel.status == -2 {
                itemStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_failed_title")
            }
        }
    }
}
