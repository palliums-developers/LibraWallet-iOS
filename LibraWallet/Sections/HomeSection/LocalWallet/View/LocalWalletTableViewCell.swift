//
//  LocalWalletTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/11.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LocalWalletTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(itemBackgroundImageView)
        itemBackgroundImageView.addSubview(nameLabel)
        itemBackgroundImageView.addSubview(addressLabel)
//        itemBackgroundImageView.addSubview(selectIndicatorImageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LocalWalletTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        itemBackgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.bottom.equalTo(contentView.snp.bottom).offset(-4)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(itemBackgroundImageView).offset(12)
            make.left.equalTo(itemBackgroundImageView).offset(10)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(itemBackgroundImageView).offset(-11)
            make.left.equalTo(itemBackgroundImageView).offset(10)
            make.right.equalTo(itemBackgroundImageView.snp.right).offset(-7)
        }
//        selectIndicatorImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(itemBackgroundImageView).offset(15)
//            make.right.equalTo(itemBackgroundImageView.snp.right).offset(-8)
//            make.size.equalTo(CGSize.init(width: 10, height: 10))
//        }
    }
    //MARK: - 懒加载对象
    lazy var itemBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    //MARK: - 设置数据
    var model: LibraWalletManager? {
        didSet {
            if model?.walletType == .Libra {
                itemBackgroundImageView.image = UIImage.init(named: "libra_wallet_background")
            } else if model?.walletType == .Violas {
                itemBackgroundImageView.image = UIImage.init(named: "violas_wallet_background")
            } else {
                itemBackgroundImageView.image = UIImage.init(named: "btc_wallet_background")
            }
            nameLabel.text = model?.walletName
            addressLabel.text = model?.walletAddress
//            selectIndicatorImageView.alpha = model?.walletCurrentUse == true ? 1:0
        }
    }
}
