//
//  WalletListFlowLayout.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletListFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 0       //cell的间距
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
//        itemSize = CGSize(width: 84, height: 118)
    }
}
