//
//  MineTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(detailIndicatorImageView)
        contentView.addSubview(cellSpaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MineTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(14)
            make.left.equalTo(self.contentView).offset(21)
        }
        self.dateLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView).offset(-10)
            make.left.equalTo(self.contentView).offset(21)
        }

        self.detailIndicatorImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView).offset(-21)
            make.size.equalTo(CGSize.init(width: 2, height: 14))
            make.bottom.equalTo(self.contentView).offset(-17)
        }
        self.cellSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(21)
            make.right.equalTo(self.contentView).offset(-24)
            make.bottom.equalTo(self.contentView).offset(0)
            make.height.equalTo(1)
        }
    }
    //MARK: - 懒加载对象
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "7F7F7F")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var detailIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "cell_detail")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var cellSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
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
    var model: String? {
        didSet {
            self.nameLabel.text = model
        }
    }
}
