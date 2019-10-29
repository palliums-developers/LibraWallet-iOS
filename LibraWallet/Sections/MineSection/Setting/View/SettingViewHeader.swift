//
//  SettingViewHeader.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SettingViewHeader: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(appIconImageView)
        addSubview(appVersion)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("SettingViewHeader销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        appIconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-10)
        }
        appVersion.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
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
        label.text = "Violas " + appversion
        return label
    }()
}
