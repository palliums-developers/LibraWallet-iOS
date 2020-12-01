//
//  MineHeaderView.swift
//  HKWallet
//
//  Created by palliums on 2019/7/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
//import Kingfisher
class MineHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerBackground)
        headerBackground.addSubview(avatarImageView)
        headerBackground.addSubview(nickNameLabel)
        addSubview(farmingRuleButton)
        farmingRuleButton.addSubview(farmingTitleLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MineHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerBackground.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(28)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self.snp.right).offset(-18)
            make.height.equalTo(123)
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(headerBackground).offset(30)
            make.centerX.equalTo(headerBackground)
            make.size.equalTo(CGSize.init(width: 44, height: 44))
        }
        nickNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(avatarImageView)
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
        }
        farmingRuleButton.snp.makeConstraints { (make) in
            make.top.equalTo(headerBackground.snp.bottom).offset(20)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(60)
        }
        farmingTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(farmingRuleButton)
            make.right.equalTo(farmingRuleButton.snp.right).offset(-59)
        }
    }
    
    // MARK: - 懒加载对象
    private lazy var headerBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mine_header_background")
        return imageView
    }()
    private lazy var avatarImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mine_default_avatar")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var nickNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "ViolasPay"
        return label
    }()
    lazy var farmingRuleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage.init(named: "mine_farming_rule_button_background"), for: .normal)
//        button.addTarget(self, action: #selector(changeToHideMode(button:)), for: .touchUpInside)
        return button
     }()
    lazy var farmingTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.text = localLanguage(keyString: "wallet_mine_yield_farming_button_title")
        return label
    }()
}
