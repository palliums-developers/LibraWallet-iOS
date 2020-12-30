//
//  RepaymentModel.swift
//  LibraWallet
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
    private var sequenceNumber: UInt64?
    private var maxGasAmount: UInt64 = 600
    private var walletTokens: [ViolasBalanceDataModel]?
    private var repymentItemModel: RepaymentMainDataModel?
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
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_repayment_miner_fees_title"),
                                           titleDescribe: "",
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_repayment_pay_account_title"),
                                           titleDescribe: "",
                                           content: localLanguage(keyString: "wallet_bank_repayment_pay_account_content"),
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular))]
    }
}
// 获取还款详情
extension RepaymentModel {
    func getLoanItemDetailModel(itemID: String, address: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "GetBankTokenBalanceQueue")
        queue.async {
            semaphore.wait()
            self.getLoanItemDetail(address: address, itemID: itemID, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.getViolasBalance(address: address, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.handleBankLoanData()
            semaphore.signal()
        }
    }
    private func getLoanItemDetail(address: String, itemID: String, semaphore: DispatchSemaphore) {
        let request = bankModuleProvide.request(.loanRepaymentDetail(address, itemID)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(RepaymentMainModel.self)
                    if json.code == 2000 {
                        guard let model = json.data else {
                            print("GetLoanRepaymentDetail_状态异常")
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetLoanRepaymentDetail")
                                self?.setValue(data, forKey: "dataDic")
                            })
                            return
                        }
                        //                        let data = setKVOData(type: "GetLoanItemDetail", data: model)
                        //                        self?.setValue(data, forKey: "dataDic")
                        self?.repymentItemModel = model
                        semaphore.signal()
                    } else {
                        print("GetLoanRepaymentDetail_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetLoanRepaymentDetail")
                                self?.setValue(data, forKey: "dataDic")
                            })
                        } else {
                            DispatchQueue.main.async(execute: {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetLoanRepaymentDetail")
                                self?.setValue(data, forKey: "dataDic")
                            })
                        }
                    }
                } catch {
                    print("GetLoanRepaymentDetail_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLoanRepaymentDetail")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLoanRepaymentDetail_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLoanRepaymentDetail")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    private func getViolasBalance(address: String, semaphore: DispatchSemaphore) {
        let request = violasModuleProvide.request(.accountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.result == nil {
                        self?.walletTokens = [ViolasBalanceDataModel.init(amount: 0, currency: "LBR")]
                    } else {
                        self?.walletTokens = json.result?.balances
                    }
                    semaphore.signal()
                } catch {
                    print("GetViolasBalance_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasBalance")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasBalance_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasBalance")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
    private func handleBankLoanData() {
        self.repymentItemModel?.token_active_state = false
        self.repymentItemModel?.token_balance = 0
        for token in self.walletTokens! {
            if self.repymentItemModel?.token_module == token.currency {
                self.repymentItemModel?.token_active_state = true
                self.repymentItemModel?.token_balance = NSDecimalNumber.init(value: token.amount ?? 0).uint64Value
                break
            }
        }
        DispatchQueue.main.async(execute: {
            let data = setKVOData(type: "GetLoanRepaymentDetail", data: self.repymentItemModel)
            self.setValue(data, forKey: "dataDic")
        })
    }
}
// MARK: - 还款
extension RepaymentModel {
    func sendRepaymentTransaction(sendAddress: String, amount: UInt64, fee: UInt64, mnemonic: [String], module: String, feeModule: String, productID: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "SendQueue")
        queue.async {
            semaphore.wait()
            self.getViolasSequenceNumber(sendAddress: sendAddress, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            do {
                let signature = try ViolasManager.getBankRepaymentTransactionHex(sendAddress: sendAddress,
                                                                                 mnemonic: mnemonic,
                                                                                 feeModule: feeModule,
                                                                                 maxGasAmount: self.maxGasAmount,
                                                                                 maxGasUnitPrice: ViolasManager.handleMaxGasUnitPrice(maxGasAmount: self.maxGasAmount),
                                                                                 sequenceNumber: self.sequenceNumber ?? 0,
                                                                                 module: module,
                                                                                 amount: amount)
                self.makeViolasTransaction(address: sendAddress, productID: productID, amount: amount, signature: signature, type: "SendViolasBankRepaymentTransaction")
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.error(error.localizedDescription), type: "SendViolasBankRepaymentTransaction")
                    self.setValue(data, forKey: "dataDic")
                })
            }
            semaphore.signal()
        }
    }
    private func getViolasSequenceNumber(sendAddress: String, semaphore: DispatchSemaphore) {
        let request = violasModuleProvide.request(.accountInfo(sendAddress)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolasAccountMainModel.self)
                    if json.error == nil {
                        self?.sequenceNumber = json.result?.sequence_number ?? 0
                        self?.maxGasAmount = ViolasManager.handleMaxGasAmount(balances: json.result?.balances ?? [ViolasBalanceDataModel.init(amount: 0, currency: "VLS")])
                        semaphore.signal()
                    } else {
                        print("GetViolasSequenceNumber_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.error?.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: "GetViolasSequenceNumber")
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "SendLibraTransaction")
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("GetViolasSequenceNumber_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasSequenceNumber")
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasSequenceNumber_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasSequenceNumber")
                    self?.setValue(data, forKey: "dataDic")
                })
            }
        }
        self.requests.append(request)
    }
//    private func makeViolasTransaction(signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
//        let request = mainProvide.request(.SendViolasTransaction(signature)) {[weak self](result) in
//            switch  result {
//            case let .success(response):
//                do {
//                    let json = try response.map(LibraTransferMainModel.self)
//                    if json.result == nil {
//                        DispatchQueue.main.async(execute: {
//                            if let sema = semaphore {
//                                sema.signal()
//                            } else {
//                                let data = setKVOData(type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                        })
//                    } else {
//                        print("\(type)_状态异常")
//                        DispatchQueue.main.async(execute: {
//                            if let message = json.error?.message, message.isEmpty == false {
//                                let data = setKVOData(error: LibraWalletError.error(message), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            } else {
//                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
//                                self?.setValue(data, forKey: "dataDic")
//                            }
//                        })
//                    }
//                } catch {
//                    print("\(type)_解析异常\(error.localizedDescription)")
//                    DispatchQueue.main.async(execute: {
//                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
//                        self?.setValue(data, forKey: "dataDic")
//                    })
//                }
//            case let .failure(error):
//                guard error.errorCode != -999 else {
//                    print("\(type)_网络请求已取消")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
//                    self?.setValue(data, forKey: "dataDic")
//                })
//
//            }
//        }
//        self.requests.append(request)
//    }
    private func makeViolasTransaction(address: String, productID: String, amount: UInt64, signature: String, type: String, semaphore: DispatchSemaphore? = nil) {
        let request = bankModuleProvide.request(.repaymentTransactiondSubmit(address, productID, amount, signature)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(ViolaSendTransactionMainModel.self)
                    if json.code == 2000 {
                        DispatchQueue.main.async(execute: {
                            if let sema = semaphore {
                                sema.signal()
                            } else {
                                let data = setKVOData(type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    } else {
                        print("\(type)_状态异常")
                        DispatchQueue.main.async(execute: {
                            if let message = json.message, message.isEmpty == false {
                                let data = setKVOData(error: LibraWalletError.error(message), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            } else {
                                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: type)
                                self?.setValue(data, forKey: "dataDic")
                            }
                        })
                    }
                } catch {
                    print("\(type)_解析异常\(error.localizedDescription)")
                    DispatchQueue.main.async(execute: {
                        let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: type)
                        self?.setValue(data, forKey: "dataDic")
                    })
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("\(type)_网络请求已取消")
                    return
                }
                DispatchQueue.main.async(execute: {
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: type)
                    self?.setValue(data, forKey: "dataDic")
                })
                
            }
        }
        self.requests.append(request)
    }
}
