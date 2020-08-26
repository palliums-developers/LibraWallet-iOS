//
//  LoanTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LoanTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(itemTitleLabel)
        whiteBackgroundView.addSubview(itemContentLabel)
        whiteBackgroundView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.top.bottom.equalTo(contentView)
        }
        itemTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(whiteBackgroundView).offset(13)
        }
        itemContentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(13)
            make.bottom.equalTo(whiteBackgroundView.snp.bottom)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-12)
            make.height.equalTo(0.5)
        }
    }
    // MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var itemTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "Test-测试-テスト"
        return label
    }()
    lazy var itemContentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "99999999.9999"
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
