//
//  WalletListCollectionViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletListCollectionViewCellDelegate: NSObjectProtocol {
    func collectionViewDidSelectRowAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath)
}
class WalletListCollectionViewManager: NSObject {
    var dataArray: [String]?
    weak var delegate: WalletListCollectionViewCellDelegate?
}
extension WalletListCollectionViewManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.collectionViewDidSelectRowAtIndexPath(collectionView: collectionView, indexPath: indexPath)
    }
}
extension WalletListCollectionViewManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = dataArray, data.count > 0 {
            return data.count
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! WalletListCollectionViewCell
        if let data = dataArray, data.isEmpty == false {
            cell.model = data[indexPath.row]
        }
        return cell
    }
}
extension WalletListCollectionViewManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 78, height: 57)
    }
}
