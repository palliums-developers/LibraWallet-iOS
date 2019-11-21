//
//  WalletManagerTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletManagerTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(itemBackgroundImageView)
        itemBackgroundImageView.addSubview(nameLabel)
        itemBackgroundImageView.addSubview(addressLabel)
        itemBackgroundImageView.addSubview(detailIndicatorImageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletManagerTableViewCell销毁了")
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
            make.top.equalTo(itemBackgroundImageView).offset(15)
            make.left.equalTo(itemBackgroundImageView).offset(14)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(itemBackgroundImageView).offset(-18)
            make.left.equalTo(itemBackgroundImageView).offset(14)
            make.right.equalTo(itemBackgroundImageView.snp.right).offset(-9)

        }
        detailIndicatorImageView.snp.makeConstraints { (make) in
            make.right.equalTo(itemBackgroundImageView).offset(-11)
            make.size.equalTo(CGSize.init(width: 17, height: 3))
            make.top.equalTo(itemBackgroundImageView).offset(15)
        }

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
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        label.text = "---"
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    private lazy var detailIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "wallet_detail_indicator")
        imageView.isUserInteractionEnabled = true
        return imageView
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
        }
    }
}
