//
//  WithdrawMarketTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class WithdrawMarketTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(itemContentView)
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
        print("WithdrawMarketTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.top.bottom.equalTo(contentView)
        }
        itemContentView.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(15)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-15)
            make.top.equalTo(whiteBackgroundView).offset(5)
            make.bottom.equalTo(whiteBackgroundView.snp.bottom).offset(-5)
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
    lazy var itemNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "Test-テスト"
        return label
    }()
    lazy var itemDescribeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "Describe-説明する"
        return label
    }()
    lazy var itemBenefitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: UIFont.Weight.bold)
        label.text = "999.999%"
        return label
    }()
    lazy var itemBenefitTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "Benefit describe-年間収益率"
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
    //    var model: TokenMappingListDataModel? {
    //        didSet {
    //            tokenNameLabel.text = model?.from_coin?.assert?.show_name
    //            if let iconName = model?.from_coin?.assert?.icon, iconName.isEmpty == false {
    //                let url = URL(string: iconName)
    //                transactionTypeImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
    //            }
    //            var unit = 1000000
    //            if model?.from_coin?.coin_type == "btc" {
    //                unit = 100000000
    //            }
    //            amountLabel.text = localLanguage(keyString: "wallet_transfer_balance_title") + getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.from_coin?.assert?.amount ?? 0),
    //                                                                                                                  scale: 6,
    //                                                                                                                  unit: unit)
    //        }
    //    }
    var showSelectState: Bool? {
        didSet {
            //            if showSelectState == true {
            //                selectIndicatorImageView.alpha = 1
            //            } else {
            //                selectIndicatorImageView.alpha = 0
            //            }
        }
    }
}
