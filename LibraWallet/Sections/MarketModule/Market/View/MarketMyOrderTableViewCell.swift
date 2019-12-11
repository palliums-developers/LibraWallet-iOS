//
//  MarketMyOrderTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MarketMyOrderTableViewCell: UITableViewCell {
//    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        
        contentView.addSubview(amountLabel)
        contentView.addSubview(priceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketMyOrderTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
//        contentBackgroundView.snp.makeConstraints { (make) in
//            make.top.equalTo(self).offset(10)
//            make.left.equalTo(contentView).offset(15)
//            make.right.equalTo(contentView.snp.right).offset(-15)
//            make.bottom.equalTo(contentView)
//        }
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(12)
            make.left.equalTo(contentView).offset(14)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(4)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(14)
            make.centerY.equalTo(contentView).offset(10)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(nameLabel)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(contentView.snp.right).offset(-16)
        }
    }
    //MARK: - 懒加载对象
//    private lazy var contentBackgroundView: UIView = {
//        let view = UIView.init()
//        view.layer.cornerRadius = 3
//        view.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
//        return view
//    }()
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "transaction_indicator")
       return imageView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "0E0051")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "BBBUSD/AAAUSD"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "01/18 12:06:23"
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "200")
        return label
    }()
    lazy var priceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "7.1")
        return label
    }()
    //MARK: - 设置数据
    var model: ViolasTokenModel? {
        didSet {
        }
    }
    var indexPath: IndexPath?
}
