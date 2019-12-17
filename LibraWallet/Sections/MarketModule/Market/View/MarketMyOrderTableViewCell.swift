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
//        contentView.addSubview(iconImageView)
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
//        iconImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(contentView).offset(12)
//            make.left.equalTo(contentView).offset(14)
//        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(12)
            make.left.equalTo(contentView).offset(14)
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
        label.text = "---"
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
        label.text = "---"
        return label
    }()
    lazy var priceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var model: MarketOrderDataModel? {
        didSet {
            let attString = NSMutableAttributedString.init(string: model?.tokenGiveSymbol ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.init(hex: "3C3848")])
            let attString2 = NSAttributedString.init(string: "/", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(hex: "3C3848")])
            let attString3 = NSMutableAttributedString.init(string: model?.tokenGetSymbol ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.init(hex: "95969B")])
            attString.append(attString2)
            attString.append(attString3)
            nameLabel.attributedText = attString
            #warning("此处有amountGive和amountGet，不清楚用哪个")
            amountLabel.text = model?.amountGet
            #warning("此处价格待商议")
            priceLabel.text = "7.1"
//            dateLabel.text = timestampToDateString(timestamp: model?.date ?? 0, dateFormat: "MM/dd HH:mm:ss")
        }
    }
    var indexPath: IndexPath?
}
