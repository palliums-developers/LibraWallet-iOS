//
//  CheckBackupCollectionViewMananger.swift
//  ViolasWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol CheckBackupCollectionViewManangerDelegate: NSObjectProtocol {
    func collectionViewDidSelectRowAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath)
}
class CheckBackupCollectionViewMananger: NSObject {
    var dataArray: [String]?
    var checkDataArray: [String]?
    weak var delegate: CheckBackupCollectionViewManangerDelegate?
}
extension CheckBackupCollectionViewMananger: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.collectionViewDidSelectRowAtIndexPath(collectionView: collectionView, indexPath: indexPath)
    }
}
extension CheckBackupCollectionViewMananger: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return dataArray?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 10 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheckMnemonicCell", for: indexPath) as! BackupMnemonicCollectionViewCell
            if let data = checkDataArray, data.isEmpty == false {
                cell.checkBackupModel = data[indexPath.row]
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicCell", for: indexPath) as! BackupMnemonicCollectionViewCell
            if let data = dataArray, data.isEmpty == false {
                cell.checkBackupModel = data[indexPath.row]
            }
            return cell
        }
        
    }
}
extension CheckBackupCollectionViewMananger: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 90, height: 32)
    }
}
