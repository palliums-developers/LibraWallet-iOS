//
//  MineTableViewCell.swift
//  ViolasWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(iconImageView)
        whiteBackgroundView.addSubview(nameLabel)
        whiteBackgroundView.addSubview(detailIndicatorImageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MineTableViewCell销毁了")
    }
    // MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(whiteBackgroundView).offset(12)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(whiteBackgroundView).offset(45)
        }
        detailIndicatorImageView.snp.makeConstraints { (make) in
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
            make.centerY.equalTo(whiteBackgroundView)
        }
    }
    // MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var iconImageView: UIImageView = {
       let imageView = UIImageView.init()
       return imageView
   }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var detailIndicatorImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "cell_detail")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    // MARK: - 设置数据
    var model: [String: String]? {
        didSet {
            self.nameLabel.text = model!["name"]
            iconImageView.image = UIImage.init(named: model!["icon"]!)
        }
    }
}
