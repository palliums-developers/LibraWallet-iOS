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
            make.top.left.right.bottom.equalTo(self)
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
        nickNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(avatarImageView)
            make.top.equalTo(avatarImageView.snp.bottom).offset(14)
        }
    }
    
    //MARK: - 懒加载对象
    private lazy var headerBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mine_header_background")
        return imageView
    }()
    private lazy var avatarImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "default_avatar")
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 30
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var nickNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "---"
        return label
    }()
//    var model: WalletData? {
//        didSet {
//            let url = URL(string: model?.walletAvatarURL ?? "")
//            avatarImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "default_avatar"))
//            if let nickName = model?.walletNickName, nickName.isEmpty == false {
//                nickNameLabel.text = nickName
//            }
//            if let uid = model?.walletUID {
//                uidLabel.text = "UID: \(uid)"
//            }
//        }
//    }
}
