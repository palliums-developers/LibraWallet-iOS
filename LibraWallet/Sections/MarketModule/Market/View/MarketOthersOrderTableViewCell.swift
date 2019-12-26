//
//  MarketOthersOrderTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MarketOthersOrderTableViewCell: UITableViewCell {
//    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(iconImageView)
        contentView.addSubview(amountLabel)
        contentView.addSubview(priceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketOthersOrderTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
//        iconImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(contentView).offset(12)
//            make.left.equalTo(contentView).offset(14)
//        }
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(12)
            make.left.equalTo(contentView).offset(16)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(amountLabel)
            make.right.equalTo(contentView.snp.right).offset(-16)
        }
    }
    //MARK: - 懒加载对象
//    private lazy var iconImageView : UIImageView = {
//        let imageView = UIImageView.init()
//        imageView.layer.cornerRadius = 19
//        imageView.layer.masksToBounds = true
//       return imageView
//    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var priceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "55BA6F")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var model: MarketOrderDataModel? {
        didSet {
            amountLabel.text = "\(Double(model?.amountGet ?? "0")! / 1000000)"

            priceLabel.text = "7.1"
        }
    }
    var indexPath: IndexPath?
}
