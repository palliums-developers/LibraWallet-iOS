//
//  EnrollPhoneModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct SecureCodeMainModel: Codable {
    var code: Int?
    var message: String?
}
class EnrollPhoneModel: NSObject {
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var requests: [Cancellable] = []
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("EnrollPhoneModel销毁了")
    }
}
extension EnrollPhoneModel {
    func getSecureCode(address: String, phoneArea: String, phoneNumber: String) {
        let request = ActiveModuleProvide.request(.secureCode(address, phoneArea, phoneNumber)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(SecureCodeMainModel.self)
                    if json.code == 2000 {
                        let data = setKVOData(type: "GetSecureCode")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetVerifyMobilePhone_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetVerifyMobilePhone")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetSecureCode")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetSecureCode_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetSecureCode")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetSecureCode_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetSecureCode")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    func sendVerifyPhone(address: String, phoneArea: String, phoneNumber: String, secureCode: String, invitedAddress: String) {
        let request = ActiveModuleProvide.request(.verifyMobilePhone(address, phoneArea, phoneNumber, secureCode, invitedAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(SecureCodeMainModel.self)
                    if json.code == 2000 {
                        do {
                            WalletManager.shared.changeWalletIsNewState(state: false)
                            try WalletManager.updateIsNewWallet()
                        } catch {
                            print(error.localizedDescription)
                        }
                        let data = setKVOData(type: "GetVerifyMobilePhone")
                        self?.setValue(data, forKey: "dataDic")
                    } else {
                        print("GetVerifyMobilePhone_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetVerifyMobilePhone")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetVerifyMobilePhone")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetVerifyMobilePhone_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetVerifyMobilePhone")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetVerifyMobilePhone_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetVerifyMobilePhone")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
}
