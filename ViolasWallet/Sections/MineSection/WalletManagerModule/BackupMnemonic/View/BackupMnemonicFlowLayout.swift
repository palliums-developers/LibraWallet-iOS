//
//  BackupMnemonicFlowLayout.swift
//  ViolasWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BackupMnemonicFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        //cell的间距
        minimumLineSpacing = 16
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsets(top: 32, left: 22, bottom: 0, right: 22)
        collectionView?.alwaysBounceVertical = true
//        itemSize = CGSize(width: 84, height: 118)
    }
}
