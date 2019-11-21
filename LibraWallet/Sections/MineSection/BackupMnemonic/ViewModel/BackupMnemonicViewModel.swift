//
//  BackupMnemonicViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BackupMnemonicViewModel: NSObject {
    //网络请求、数据模型
    lazy var dataModel: BackupMnemonicModel = {
        let model = BackupMnemonicModel.init()
        return model
    }()
    //collectionView管理类
    lazy var collectionViewManager: BackupMnemonicCollectionViewManager = {
        let manager = BackupMnemonicCollectionViewManager.init()
        return manager
    }()
    //子View
    lazy var detailView : BackupMnemonicView = {
        let view = BackupMnemonicView.init(collectionViewHeight: collectionViewHeight ?? 238)
        view.collectionView.delegate = self.collectionViewManager
        view.collectionView.dataSource = self.collectionViewManager
        return view
    }()
    private var collectionViewHeight: Int?
    var dataArray: [String]? {
        didSet {
            self.collectionViewManager.dataArray = dataArray
            collectionViewHeight = getCollectionViewHeight(itemsCount: dataArray?.count ?? 0)
            self.detailView.collectionViewHeight = collectionViewHeight
            self.detailView.collectionView.reloadData()
        }
    }
    func getCollectionViewHeight(itemsCount: Int) -> Int {
        let remainderHeight = (itemsCount % 3 > 0 ? 1:0) * (32 + 16)
        let allHeight = (itemsCount / 3) * (32 + 16)
        let result = 32 + allHeight + remainderHeight + 16
        return result
    }
    deinit {
        print("BackupMnemonicViewModel销毁了")
    }
}
