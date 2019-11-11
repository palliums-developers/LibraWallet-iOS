//
//  BackupMnemonicCollectionViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BackupMnemonicCollectionViewManager: NSObject {
    var dataArray: [String]?
//    weak var delegate: WalletListCollectionViewCellDelegate?
}
extension BackupMnemonicCollectionViewManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.delegate?.collectionViewDidSelectRowAtIndexPath(collectionView: collectionView, indexPath: indexPath)
    }
}
extension BackupMnemonicCollectionViewManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = dataArray, data.count > 0 {
            return data.count
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicCell", for: indexPath) as! BackupMnemonicCollectionViewCell
        if let data = dataArray, data.isEmpty == false {
            cell.model = data[indexPath.row]
        }
        return cell
    }
}
extension BackupMnemonicCollectionViewManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 90, height: 32)
    }
}
