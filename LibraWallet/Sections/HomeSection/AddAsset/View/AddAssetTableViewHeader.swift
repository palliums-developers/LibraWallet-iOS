//
//  AddAssetTableViewHeader.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAssetTableViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(iconImageView)
        contentBackgroundView.addSubview(nameLabel)
        contentBackgroundView.addSubview(detailLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AddAssetTableViewHeader销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        contentBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.bottom.equalTo(contentView)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView)
            make.left.equalTo(contentBackgroundView).offset(14)
            make.size.equalTo(CGSize.init(width: 38, height: 38))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView).offset(-10)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalTo(contentBackgroundView).offset(10)
        }
    }
    //MARK: - 懒加载对象
    private lazy var contentBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 3
        view.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
        return view
    }()
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 19
        imageView.layer.masksToBounds = true
        imageView.layer.backgroundColor = UIColor.red.cgColor
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
        return label
    }()
    var model: Token? {
        didSet {
            nameLabel.text = "vtoken"
            detailLabel.text = model?.tokenType.description
            let url = URL(string: "")
            iconImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "violas_icon"))
        }
    }
}
