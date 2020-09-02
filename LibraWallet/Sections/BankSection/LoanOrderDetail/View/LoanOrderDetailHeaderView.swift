//
//  LoanOrderDetailHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanOrderDetailHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(assetTitleLabel)
        addSubview(assetLabel)
        addSubview(assetUnitLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanOrderDetailHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        assetTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(30)
            make.left.equalTo(self).offset(34)
        }
        assetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(assetTitleLabel.snp.bottom).offset(12)
            make.left.equalTo(self).offset(34)
        }
        assetUnitLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(assetLabel).offset(3)
            make.left.equalTo(assetLabel.snp.right).offset(8)
        }
    }
    lazy var assetTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: .regular)
        label.text = localLanguage(keyString: "wallet_bank_loan_detail_remaining_payment_amount_title")
        return label
    }()
    lazy var assetLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "7038FD")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 24), weight: .bold)
        label.text = "---"
        return label
    }()
    lazy var assetUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: .regular)
        label.text = "---"
        return label
    }()
    var model: LoanOrderDetailMainDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            assetLabel.text = getDecimalNumber(amount: NSDecimalNumber.init(value: tempModel.balance ?? 0),
                                               scale: 6,
                                               unit: 1000000).stringValue
            assetUnitLabel.text = tempModel.token_show_name
        }
    }
}
