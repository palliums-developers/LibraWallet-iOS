//
//  AddAssetModel.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
struct ViolasTokenModel: Codable {
    /// 名称
    var name: String?
    /// 描述
    var description: String?
    /// 合约地址
    var address: String?
    /// 代币图片
    var icon: String?
    /// 是否已展示
    var enable: Bool?
}
struct ViolasTokenMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
    /// 数据体
    var data: [ViolasTokenModel]?
}
class AddAssetModel: NSObject {
    private var requests: [Cancellable] = []
    
    @objc var dataDic: NSMutableDictionary = [:]
//    func getLocalViolasTokenList(walletID: Int64) {
//        do {
//            let wallet = try DataBaseManager.DBManager.getViolasTokens(walletID: walletID)
//            let data = setKVOData(type: "LoadLocalViolasToken", data: wallet)
//            self.setValue(data, forKey: "dataDic")
//
//            // 更新本地数据
////            getViolasTokenList()
//        } catch {
//
//        }
//    }
    func getViolasTokenList(walletID: Int64) {
        let request = mainProvide.request(.GetViolasTokenList) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasTokenMainModel.self)
                    guard json.code == 2000 else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "UpdateViolasTokenList")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    guard let models = json.data, models.isEmpty == false else {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "UpdateViolasTokenList")
                        self?.setValue(data, forKey: "dataDic")
                        return
                    }
                    let result = self?.dealModelWithSelect(walletID: walletID, models: models)
                    let data = setKVOData(type: "UpdateViolasTokenList", data: result)
                    self?.setValue(data, forKey: "dataDic")
                    // 刷新本地数据
                    self?.updateLocalViolasToken(models: models)
                } catch {
                    print("解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "UpdateViolasTokenList")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "UpdateViolasTokenList")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    func updateLocalViolasToken(models: [ViolasTokenModel]) {
//        for item in models {
//            guard DataBaseManager.DBManager.isExistViolasToken(walletID: <#Int64#>, address: item.address!) == false else {
//                continue
//            }
//            let result = DataBaseManager.DBManager.insertViolasToken(model: item)
//            print(result)
//        }
    }
    func dealModelWithSelect(walletID: Int64, models: [ViolasTokenModel]) -> [ViolasTokenModel] {
        let localSelectModel = try! DataBaseManager.DBManager.getViolasTokens(walletID: walletID)
        var tempDataArray = [ViolasTokenModel]()
        for model in models {
            var tempModel = model
            if localSelectModel.isEmpty == true {
                tempModel.enable = false
            } else {
                for item in localSelectModel {
                    if tempModel.address == item.address {
                        tempModel.enable = true
                    } else {
                        tempModel.enable = false
                    }
                }
            }
            tempDataArray.append(tempModel)
        }
        return tempDataArray
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("AddAssetModel销毁了")
    }
}
