//
//  SettingTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailIndicatorImageView)
        contentView.addSubview(cellSpaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("SettingTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(14)
        }
        self.detailIndicatorImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView).offset(-21)
            make.size.equalTo(CGSize.init(width: 2, height: 14))
            make.bottom.equalTo(self.contentView).offset(-17)
        }
        self.cellSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(14)
            make.right.equalTo(self.contentView).offset(-14)
            make.bottom.equalTo(self.contentView).offset(0)
            make.height.equalTo(0.5)
        }
    }
    //MARK: - 懒加载对象
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
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
        }
    }
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                cellSpaceLabel.alpha = 0
            }
        }
    }
}
