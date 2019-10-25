//
//  SupportCoinTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SupportCoinTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(grayBackgroundView)
        grayBackgroundView.addSubview(iconImageView)
        grayBackgroundView.addSubview(nameLabel)
        grayBackgroundView.addSubview(detailLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("SupportCoinTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        grayBackgroundView.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView).offset(0)
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-15)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(grayBackgroundView)
            make.left.equalTo(grayBackgroundView).offset(14)
            make.size.equalTo(CGSize.init(width: 39, height: 39))
        }
        nameLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(grayBackgroundView).offset(15)
            make.centerY.equalTo(iconImageView).offset(-10)
            make.left.equalTo(iconImageView.snp.right).offset(14)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImageView).offset(10)
            make.left.equalTo(iconImageView.snp.right).offset(14)
            make.right.equalTo(grayBackgroundView.snp.right).offset(-9)
        }
    }
    //MARK: - 懒加载对象
    private lazy var grayBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 3
        view.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
        return view
    }()
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
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
    lazy var detailLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "0E0051")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    //MARK: - 设置数据
//    var model: Transaction? {
//        didSet {
//            guard let tempModel = model else {
//                return
//            }
//            var amountState = ""
//            var amountColor = DefaultGreenColor
//            if tempModel.event == "received" {
//                nameLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
//                amountState = "+"
//            } else {
//                amountState = "-"
//                amountColor = UIColor.init(hex: "FF4C4C")
//                nameLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
//
//            }
//            dateLabel.text = tempModel.date
//        }
//    }
    var model: [String: String]? {
        didSet {
            iconImageView.image = UIImage.init(named: model!["icon"]!)
            nameLabel.text = model!["name"]
            detailLabel.text = model!["detail"]
        }
    }
}
