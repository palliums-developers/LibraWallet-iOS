//
//  WalletListCollectionViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletListCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(coinImageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletListCollectionViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        coinImageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 35, height: 35))
        }
    }
    //MARK: - 懒加载对象
    private lazy var coinImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 19
        imageView.layer.masksToBounds = true
        return imageView
    }()
    var model: String? {
        didSet {
            guard let imageName = model else {
                return
            }
            coinImageView.image = UIImage.init(named: imageName)
        }
    }
    
}
