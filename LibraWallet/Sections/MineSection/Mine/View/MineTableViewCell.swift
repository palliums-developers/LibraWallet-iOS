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
        contentView.addSubview(iconImageView)
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
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(13)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(39)
        }
        detailIndicatorImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-14)
            make.size.equalTo(CGSize.init(width: 15, height: 15))
            make.centerY.equalTo(contentView)
        }
        cellSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(39)
            make.right.equalTo(contentView).offset(-15)
            make.bottom.equalTo(self.contentView).offset(0)
            make.height.equalTo(1)
        }
    }
    //MARK: - 懒加载对象
    private lazy var iconImageView : UIImageView = {
       let imageView = UIImageView.init()
       return imageView
   }()
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
    var model: [String: String]? {
        didSet {
            self.nameLabel.text = model!["name"]
            iconImageView.image = UIImage.init(named: model!["icon"]!)
        }
    }
}
