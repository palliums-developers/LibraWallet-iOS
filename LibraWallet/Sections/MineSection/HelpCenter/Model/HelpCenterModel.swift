//
//  HelpCenterModel.swift
//  HKWallet
//
//  Created by palliums on 2019/8/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Moya
class HelpCenterModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    func feedback(uid: String, content: String, contact: String) {
//        let request = mainProvide.request(.feedback(uid, content, contact)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(LoginOrRegisterModel.self)
//                    if let code = json.code, code == 200 {
//                        let data = setKVOData(type: "Feedback")
//                        self?.setValue(data, forKey: "dataDic")
//                    } else {
//                        print("解析失败")
//                        let data = setKVOData(error: HKWalletError.error(json.message ?? ""), type: "Feedback")
//                        self?.setValue(data, forKey: "dataDic")
//                    }
//                } catch {
//                    print("解析异常\(error.localizedDescription)")
//                    let data = setKVOData(error: HKWalletError.WalletRequestError(reason: .parseJsonError), type: "Feedback")
//                    self?.setValue(data, forKey: "dataDic")
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("网络请求已取消")
//                    return
//                }
//                print(error.localizedDescription)
//                //                let data = setKVOData(encode: NetworkLinkErrorCode, type: "SuggestInvestment", message: localLanguage(keyString: "wallet_network_invalid_error"))
//                let data = setKVOData(error: HKWalletError.WalletRequestError(reason: .networkInvalid), type: "Feedback")
//                self?.setValue(data, forKey: "dataDic")
//            }
//        }
//        self.requests.append(request)
    }
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("HelpCenterModel销毁了")
    }
}
