//
//  ScanLoginModel.swift
//  SSO
//
//  Created by wangyingdong on 2020/3/16.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct SubmitScanLoginMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
}
class ScanLoginModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var encryptData: String?
    func submitScanLoginData(walletAddress: String, sessionID: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let quene = DispatchQueue.init(label: "SendQueue")
//        quene.async {
//            semaphore.wait()
//            self.getAllWallet(semaphore: semaphore)
//        }
//        quene.async {
//            semaphore.wait()
//            self.submitScanLoginDataRequest(walletAddress: self.encryptData!, sessionID: sessionID)
//            semaphore.signal()
//        }
    }
    private func submitScanLoginDataRequest(walletAddress: String, sessionID: String) {
        let request = mainProvide.request(.SubmitScanLoginData(walletAddress, sessionID)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(SubmitScanLoginMainModel.self)
                    if json.code == 2000 {
                        let data = setKVOData(type: "ScanLogin")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("ScanLogin_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "ScanLogin")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .dataCodeInvalid), type: "ScanLogin")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("ScanLogin_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "ScanLogin")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("ScanLogin_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "ScanLogin")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func getAllWallet(semaphore: DispatchSemaphore) {
        let wallets = DataBaseManager.DBManager.getLocalWallets()
        let identityWallets = wallets.first!
        let othersWallets = wallets.last!
        
//        let tempData = identityWallets.reduce("") {
//            $0 + "{\"name\":\"\($1.walletName ?? "")\",\"identity\":\($1.walletIdentity ?? 0),\"type\":\"\($1.walletType!.description.lowercased())\",\"address\":\"\($1.walletAddress ?? "")\"},"
//        }
//        let tempData2 = othersWallets.reduce("") {
//            $0 + "{\"name\":\"\($1.walletName ?? "")\",\"identity\":\($1.walletIdentity ?? 0),\"type\":\"\($1.walletType!.description.lowercased())\",\"address\":\"\($1.walletAddress ?? "")\"},"
//        }
//        let range = tempData2.index(tempData2.startIndex, offsetBy: tempData2.count > 0 ? tempData2.count - 1:0)
//        // 替换指定区间数据
//        let tempData3 = tempData2.prefix(upTo: range)
//        self.encryptData = "[" + tempData + tempData3 + "]"
//        semaphore.signal()
//        let tempData = identityWallets.map {
//            ["name":"\($0.walletName ?? "")",
//             "identity":"\($0.walletIdentity ?? 0)",
//             "type":"\($0.walletType!.description.lowercased())",
//             "address":"\($0.walletAddress ?? "")"]
//        }
//        let tempData2 = othersWallets.map {
//            ["name":"\($0.walletName ?? "")",
//            "identity":"\($0.walletIdentity ?? 0)",
//            "type":"\($0.walletType!.description.lowercased())",
//            "address":"\($0.walletAddress ?? "")"] as [String : Any]
//        }
//        let tempData3 = tempData + tempData2
//        let json = try? JSONSerialization.data(withJSONObject: tempData3, options: JSONSerialization.WritingOptions.prettyPrinted)
//        self.encryptData = String.init(data: json!, encoding: String.Encoding.utf8)
//        semaphore.signal()
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ScanLoginModel销毁了")
    }
}
