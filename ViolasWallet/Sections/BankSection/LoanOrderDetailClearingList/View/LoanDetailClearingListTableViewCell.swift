//
//  LoanDetailClearingListTableViewCell.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanDetailClearingListTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(itemClearingAmountTitleLabel)
        contentView.addSubview(itemClearingAmountLabel)
        contentView.addSubview(itemDeductionAmountTitleLabel)
        contentView.addSubview(itemDeductionAmountLabel)
        contentView.addSubview(itemTimeLabel)
        contentView.addSubview(itemStatusLabel)
        contentView.addSubview(spaceLabel)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("DepositMarketTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        itemClearingAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(-15)
            make.left.equalTo(contentView).offset(34)
        }
        itemClearingAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(15)
            make.left.equalTo(contentView).offset(34)
        }
        itemDeductionAmountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(-15)
            make.centerX.equalTo(contentView)
        }
        itemDeductionAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(15)
            make.left.equalTo(itemDeductionAmountTitleLabel)
        }
        itemTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(-15)
            make.right.equalTo(contentView.snp.right).offset(-34)
        }
        itemStatusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-34)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(34)
            make.bottom.equalTo(contentView.snp.bottom)
            make.right.equalTo(contentView.snp.right).offset(-34)
            make.height.equalTo(0.5)
        }
    }
    // MARK: - 懒加载对象
    lazy var itemClearingAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_clearing_amount_title")
        return label
    }()
    lazy var itemClearingAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        return label
    }()
    lazy var itemDeductionAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_deduction_amount_title")
        return label
    }()
    lazy var itemDeductionAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        return label
    }()

    lazy var itemTimeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "18:22 05/22"
        return label
    }()
    lazy var itemStatusLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_status_title")
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
            itemClearingAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.cleared ?? 0),
                                                            scale: 6,
                                                            unit: 1000000).stringValue
            itemDeductionAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.deductioned ?? 0),
                                                             scale: 6,
                                                             unit: 1000000).stringValue
        }
    }
}
