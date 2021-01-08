//
//  LoanListTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanListTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        //        contentView.addSubview(whiteBackgroundView)
        contentView.addSubview(tokenIconImageView)
        contentView.addSubview(orderTokenNameLabel)
        contentView.addSubview(orderTimeLabel)
        contentView.addSubview(orderAmountLabel)
        contentView.addSubview(orderStatusLabel)
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanListTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tokenIconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.size.equalTo(CGSize.init(width: 36, height: 36))
        }
        orderTokenNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIconImageView).offset(-11)
            make.left.equalTo(tokenIconImageView.snp.right).offset(8)
        }
        orderTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tokenIconImageView).offset(11)
            make.left.equalTo(tokenIconImageView.snp.right).offset(8)
        }
        orderAmountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.centerY.equalTo(orderTokenNameLabel)
        }
        orderStatusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(orderTimeLabel)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.height.equalTo(0.5)
        }
    }
    // MARK: - 懒加载对象
    //    private lazy var whiteBackgroundView: UIView = {
    //        let view = UIView.init()
    //        view.layer.backgroundColor = UIColor.white.cgColor
    //        view.layer.cornerRadius = 10
    //        return view
    //    }()
    private lazy var tokenIconImageView: UIImageView = {
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
    lazy var orderTimeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var orderAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: UIFont.Weight.bold)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 18)
        label.text = "---"
        return label
    }()
    lazy var orderStatusLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        
        return label
    }()
    //MARK: - 设置数据
    var indexPath: IndexPath?
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                spaceLabel.alpha = 0
            } else {
                spaceLabel.alpha = 1
            }
        }
    }
    var model: LoanListMainDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            if let iconName = model?.logo, iconName.isEmpty == false {
                if iconName.hasPrefix("http") {
                    let url = URL(string: iconName)
                    tokenIconImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
                } else {
                    tokenIconImageView.image = UIImage.init(named: iconName)
                }
            } else {
                tokenIconImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            orderTokenNameLabel.text = tempModel.currency
            orderTimeLabel.text = timestampToDateString(timestamp: tempModel.date ?? 0, dateFormat: "yyyy/MM/dd HH:mm:ss")
            orderAmountLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.value ?? 0),
                                                     scale: 6,
                                                     unit: 1000000).stringValue
            if tempModel.status == 0 {
                // 0（已借款）
                orderStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_loan_status_loaned_title")
            } else if tempModel.status == 1 {
                // 1（已还款）
                orderStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_deposited_title")
            }  else if tempModel.status == 2 {
                // 2（已清算）
                orderStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_status_title")
            }  else if tempModel.status == -1 {
                // -1（借款失败）
                orderStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_loan_status_failed_title")
            }  else if tempModel.status == -2 {
                // -2（还款失败）
                orderStatusLabel.text = localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_failed_title")
            }
        }
    }
}
