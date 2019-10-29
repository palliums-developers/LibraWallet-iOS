//
//  AboutUsTableViewHeader.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AboutUsTableViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
//        self.addShadow()
        contentView.addSubview(appIconImageView)
        contentView.addSubview(appVersion)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AboutUsTableViewHeader销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        appIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView).offset(-10)
        }
        appVersion.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(appIconImageView.snp.bottom).offset(10)
        }
    }
    //MARK: - 懒加载对象
    private lazy var appIconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "default_avatar")
        imageView.isUserInteractionEnabled = true
//        imageView.layer.cornerRadius = 30
//        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var appVersion: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.text = "Violas" + appversion
        return label
    }()
//    func addShadow() {
//        self.layer.backgroundColor = UIColor.white.cgColor
//        // 定义阴影颜色
//        self.layer.shadowColor = UIColor.init(hex: "E5E5E5").cgColor
//        // 阴影的模糊半径
//        self.layer.shadowRadius = 16
//        // 阴影的偏移量
//        self.layer.shadowOffset = CGSize(width: 0, height: 16)
//        // 阴影的透明度，默认为0，不设置则不会显示阴影****
//        self.layer.shadowOpacity = 0.3
//    }
}
