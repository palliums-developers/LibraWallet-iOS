//
//  WalletMainModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
class WalletMainModel: NSObject {
    private var requests: [Cancellable] = []
    func updateBalance(token: Token, completion: @escaping (Result<Token, LibraWalletError>) -> Void) {
        switch token.tokenType {
        case .Libra:
            self.getDiemBalance(address: token.tokenAddress) { (result) in
                switch result {
                case .success(_):
                    let token = Wallet.shared.tokens?.filter({
                        $0.tokenType == token.tokenType && $0.tokenModule == token.tokenModule
                    })
                    completion(.success((token?.first)!))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        case .Violas:
            self.getViolasBalance(address: token.tokenAddress) { (result) in
                switch result {
                case .success(_):
                    let token = Wallet.shared.tokens?.filter({
                        $0.tokenType == token.tokenType && $0.tokenModule == token.tokenModule
                    })
                    completion(.success((token?.first)!))
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        case .BTC:
            print("")
        }
    }
    
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("WalletMainModel销毁了")
    }
}
extension WalletMainModel {
    func getViolasBalance(address: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result != nil {
                        _ = WalletManager.updateViolasTokensBalance(tokenBalances: json.result?.balances ?? [ViolasBalanceDataModel]())
                        completion(.success(true))
                    } else {
                        completion(.success(false))
                    }
                } catch {
                    print("UpdateViolasBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateViolasBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getViolasPrice(address: String, group: DispatchGroup, completion: @escaping (Result<[ModelPriceDataModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.price(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data ?? [ModelPriceDataModel]()))
                    } else {
                        print("GetViolasPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasPrice_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasPrice_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
            group.leave()
        }
        self.requests.append(request)
    }
}
// MARK: 更新Diem数量、价格
extension WalletMainModel {
    func getDiemBalance(address: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.accountInfo(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DiemAccountMainModel.self)
                    if json.result == nil {
                        _ = WalletManager.updateDiemTokensBalance(tokenBalances: json.result?.balances ?? [DiemBalanceDataModel]())
                        completion(.success(true))
                    } else {
                        completion(.success(false))
                    }
                } catch {
                    print("UpdateDiemBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("UpdateDiemBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getDiemPrice(address: String, group: DispatchGroup, completion: @escaping (Result<[ModelPriceDataModel], LibraWalletError>) -> Void) {
        let request = libraModuleProvide.request(.price(address)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ModelPriceMainModel.self)
                    if json.code == 2000 {
                        completion(.success(json.data ?? [ModelPriceDataModel]()))
                    } else {
                        print("GetLibraPrice_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetLibraPrice_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLibraPrice_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: .networkInvalid)))
            }
            group.leave()
        }
        self.requests.append(request)
    }
}
