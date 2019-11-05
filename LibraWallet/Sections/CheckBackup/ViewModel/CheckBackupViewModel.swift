//
//  CheckBackupViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class CheckBackupViewModel: NSObject {
    //网络请求、数据模型
    lazy var dataModel: CheckBackupModel = {
        let model = CheckBackupModel.init()
        return model
    }()
    //collectionView管理类
    lazy var collectionViewManager: CheckBackupCollectionViewMananger = {
        let manager = CheckBackupCollectionViewMananger.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : CheckBackupView = {
        let view = CheckBackupView.init(collectionViewHeight: collectionViewHeight ?? 238)
        view.selectCollectionView.delegate = self.collectionViewManager
        view.selectCollectionView.dataSource = self.collectionViewManager
        view.checkCollectionView.delegate = self.collectionViewManager
        view.checkCollectionView.dataSource = self.collectionViewManager
        return view
    }()
    private var collectionViewHeight: Int?
    var dataArray: [String]? {
        didSet {
            self.collectionViewManager.dataArray = dataArray
            collectionViewHeight = getCollectionViewHeight(itemsCount: dataArray?.count ?? 0)
            self.detailView.collectionViewHeight = collectionViewHeight
            self.detailView.selectCollectionView.reloadData()
            self.detailView.checkCollectionView.reloadData()
        }
    }
    func getCollectionViewHeight(itemsCount: Int) -> Int {
        let remainderHeight = (itemsCount % 3 > 0 ? 1:0) * (32 + 16)
        let allHeight = (itemsCount / 3) * (32 + 16)
        let result = 32 + allHeight + remainderHeight + 16
        return result
    }
    var nextClickIndex: Int = 0
}
extension CheckBackupViewModel: CheckBackupCollectionViewManangerDelegate {
    func collectionViewDidSelectRowAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        if collectionView.tag == 10 {
            
        } else {
            
        }
    }
    
}
