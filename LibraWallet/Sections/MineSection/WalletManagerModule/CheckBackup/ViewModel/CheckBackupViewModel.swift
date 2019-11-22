//
//  CheckBackupViewModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class CheckBackupViewModel: NSObject {
//    //网络请求、数据模型
//    lazy var dataModel: CheckBackupModel = {
//        let model = CheckBackupModel.init()
//        return model
//    }()
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
    // 原始数组
    var dataArray: [String]? {
        didSet {
            //乱序助记词
            let randomArray = shuffleArray(arr: dataArray!)
            self.collectionViewManager.dataArray = randomArray
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
    // 点选顺序数组
    lazy var dataValidArray: [String] = {
        var array = [String]()
        for _ in 0..<(dataArray?.count ?? 0) {
            array.append("")
        }
        return array
    }()
    var randomDataArray: [String]?
    
}
extension CheckBackupViewModel {
    func shuffleArray(arr:[String]) -> [String] {
        var data:[String] = arr
        for i in 1..<arr.count {
            let index:Int = Int(arc4random()) % i
            if index != i {
                data.swapAt(i, index)
            }
        }
        return data
    }
}
extension CheckBackupViewModel: CheckBackupCollectionViewManangerDelegate {
    func collectionViewDidSelectRowAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath) {
        if collectionView.tag == 10 {
            // TODO: 待完成
            // 选中Cell
            let clickCell = collectionView.cellForItem(at: indexPath) as! BackupMnemonicCollectionViewCell
            // 排除空点击
            guard clickCell.mnemonicLabel.text?.isEmpty == false else {
                return
            }
            // 删除
            if self.dataValidArray[indexPath.row].isEmpty == false {
                self.dataValidArray[indexPath.row] = ""
            }
            // 设置未选中状态
            clickCell.setNormalCell()
            // 底部选择CollectionViewCell
            let checkCell = self.detailView.selectCollectionView.cellForItem(at: clickCell.fromClickCellIndexPath!) as! BackupMnemonicCollectionViewCell
            // 恢复展示
            checkCell.alpha = 1
            // 获取焦点(当checkCollectionView点击后,计算下一次checkCollectionView初始位置)
            getFistInsetCellIndex()
        } else {
            //点击的Cell
            let clickCell = collectionView.cellForItem(at: indexPath) as! BackupMnemonicCollectionViewCell
            clickCell.alpha = 0
            //顶部展示Cell
            let checkCell = self.detailView.checkCollectionView.cellForItem(at: IndexPath.init(row: self.nextClickIndex, section: 0)) as! BackupMnemonicCollectionViewCell
            
            checkCell.checkBackupModel = clickCell.checkBackupModel
            // 添加校验数组
            if self.dataValidArray[self.nextClickIndex].isEmpty == true {
                self.dataValidArray[self.nextClickIndex] = checkCell.mnemonicLabel.text ?? ""
            }
            // 从哪里添加
            checkCell.fromClickCellIndexPath = indexPath
            // 获取焦点(当checkCollectionView点击后,计算下一次checkCollectionView初始位置)
            getFistInsetCellIndex()
//            // 检查是否全部有效
//            checkIsAllValid()
        }
    }
    func getFistInsetCellIndex() {
        for i in 0..<self.collectionViewManager.dataArray!.count {
            let clickCell = self.detailView.checkCollectionView.cellForItem(at: IndexPath.init(row: i, section: 0)) as! BackupMnemonicCollectionViewCell
            if let mnemonic = clickCell.mnemonicLabel.text, mnemonic.isEmpty == true {
                self.nextClickIndex = i
                print("FistInsetCellIndex = \(i)")
                return
            }
        }
    }
    func checkIsAllValid() throws {
        let filterEmptyArray = self.dataValidArray.filter { (result) in
            result.isEmpty == true
        }
        guard filterEmptyArray.isEmpty == true else {
            throw LibraWalletError.WalletCheckMnemonic(reason: .checkArrayNotEnough)
        }
        let realMnemonicString = self.dataArray?.joined(separator: " ")
        let checkMnemonicString = self.dataValidArray.joined(separator: " ")
        guard realMnemonicString == checkMnemonicString else {
            print("failed")
            throw LibraWalletError.WalletCheckMnemonic(reason: .orderInvalid)
        }
        print("success")
    }
}
