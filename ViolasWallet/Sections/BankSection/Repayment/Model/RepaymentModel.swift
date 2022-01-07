//
//  RepaymentModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct RepaymentMainDataModel: Codable {
    /// 产品ID
    var product_id: String?
    /// 待还余额
    var balance: UInt64?
    /// 借贷率
    var rate: Double?
    /// 借贷币地址
    var token_address: String?
    /// 借贷币Module
    var token_module: String?
    /// 借贷币Name
    var token_name: String?
    /// 借贷币展示名字
    var token_show_name: String?
    /// 借贷币图片
    var logo: String?
    /// 余额（自行添加）
    var token_balance: UInt64?
    /// 激活状态（自行添加）
    var token_active_state: Bool?
}
struct RepaymentMainModel: Codable {
    var code: Int?
    var message: String?
    var data: RepaymentMainDataModel?
}
class RepaymentModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var maxGasAmount: UInt64 = 600
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("RepaymentModel销毁了")
    }
    func getLocalModel(model: RepaymentMainDataModel? = nil) -> [DepositLocalDataModel] {
        
        return [DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_repayment_loan_rate_title"),
                                           titleDescribe: "",
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "333333",
                                           conentFont: UIFont.init(name: "DIN Alternate Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_repayment_miner_fees_title"),
                                           titleDescribe: "",
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "333333",
                                           conentFont: UIFont.init(name: "DIN Alternate Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_repayment_pay_account_title"),
                                           titleDescribe: "",
                                           content: localLanguage(keyString: "wallet_bank_repayment_pay_account_content"),
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular))]
    }
}
// 获取还款详情
extension RepaymentModel {
    func getLoanItemDetailModel(itemID: String, address: String, completion: @escaping (Result<RepaymentMainDataModel, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "GetBankTokenBalanceQueue")
        var accountTokens = [ViolasBalanceDataModel]()
        var repaymentItemModel: RepaymentMainDataModel?
        queue.async {
            semaphore.wait()
            self.getLoanItemDetail(address: address, itemID: itemID) { (result) in
                switch result {
                case let .success(model):
                    repaymentItemModel = model
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            self.getViolasBalance(address: address) { (result) in
                switch result {
                case let .success(models):
                    accountTokens = models
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            self.handleBankLoanData(accountTokens: accountTokens, repaymentItemModel: repaymentItemModel) { (result) in
                switch result {
                case let .success(model):
                    DispatchQueue.main.async(execute: {
                        completion(.success(model))
                    })
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
            semaphore.signal()
        }
    }
    private func getLoanItemDetail(address: String, itemID: String, completion: @escaping (Result<RepaymentMainDataModel, LibraWalletError>) -> Void) {
        let request = bankModuleProvide.request(.loanRepaymentDetail(address, itemID)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(RepaymentMainModel.self)
                    if json.code == 2000 {
                        guard let model = json.data else {
                            print("GetLoanRepaymentDetail_状态异常")
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty)))
                            return
                        }
                        completion(.success(model))
                    } else {
                        print("GetLoanRepaymentDetail_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetLoanRepaymentDetail_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLoanRepaymentDetail_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func getViolasBalance(address: String, completion: @escaping (Result<[ViolasBalanceDataModel], LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(address)) {(result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        completion(.success(json.result?.balances ?? [ViolasBalanceDataModel]()))
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasBalance_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasBalance_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func handleBankLoanData(accountTokens: [ViolasBalanceDataModel], repaymentItemModel: RepaymentMainDataModel?, completion: @escaping (Result<RepaymentMainDataModel, LibraWalletError>) -> Void) {
        var tempItem = repaymentItemModel
        tempItem?.token_active_state = false
        tempItem?.token_balance = 0
        for token in accountTokens {
            if tempItem?.token_module == token.currency {
                tempItem?.token_active_state = true
                tempItem?.token_balance = NSDecimalNumber.init(value: token.amount ?? 0).uint64Value
                break
            }
        }
        if let model = tempItem {
            completion(.success(model))
        }
    }
}
// MARK: - 还款
extension RepaymentModel {
    func sendRepaymentTransaction(sendAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], module: String, feeModule: String, productID: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        var sequenceNumber: UInt64?
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress) { (result) in
                switch result {
                case let .success(sequence):
                    sequenceNumber = sequence
                    semaphore.signal()
                case let .failure(error):
                    DispatchQueue.main.async(execute: {
                        completion(.failure(error))
                    })
                }
            }
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getBankRepaymentTransactionHex(sendAddress: sendAddress,
                                                                                 mnemonic: mnemonic,
                                                                                 feeModule: feeModule,
                                                                                 maxGasAmount: self.maxGasAmount,
                                                                                 maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                 sequenceNumber: sequenceNumber ?? 0,
                                                                                 module: module,
                                                                                 amount: amount)
                self.makeViolasTransaction(address: sendAddress, productID: productID, amount: amount, signature: signature, type: "SendViolasBankRepaymentTransaction") { (result) in
                    switch result {
                    case let .success(state):
                        DispatchQueue.main.async(execute: {
                            completion(.success(state))
                        })
                    case let .failure(error):
                        DispatchQueue.main.async(execute: {
                            completion(.failure(error))
                        })
                    }
                    
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    completion(.failure(LibraWalletError.error(error.localizedDescription)))
                })
            }
            semaphore.signal()
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, completion: @escaping (Result<UInt64, LibraWalletError>) -> Void) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
                        completion(.success(json.result?.sequence_number ?? 0))
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        if let message = json.error?.message, message.isEmpty == false {
                            completion(.failure(LibraWalletError.error(message)))
                        } else {
                            completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                        }
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
    private func makeViolasTransaction(address: String, productID: String, amount: UInt64, signature: String, type: String, completion: @escaping (Result<Bool, LibraWalletError>) -> Void) {
        let request = bankModuleProvide.request(.repaymentTransactiondSubmit(address, productID, amount, signature)) { (result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    if json.code == 2000 {
                        completion(.success(true))
                    } else {
                        print("\(type)_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.message, message.isEmpty == false {
                                completion(.failure(LibraWalletError.error(message)))
                            } else {
                                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid)))
                            }
                        })
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError)))
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                completion(.failure(LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.networkInvalid)))
            }
        }
        self.requests.append(request)
    }
}
