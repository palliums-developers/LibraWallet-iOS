//
//  DepositModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
struct DepositItemDetailMainDataIntroduceModel: Codable {
    var text: String?
    var tital: String?
    /// 高度（自行添加）
    var height: CGFloat?
}
struct DepositItemDetailMainDataModel: Codable {
    /// 产品ID
    var id: String?
    /// 产品说明
    var intor: [DepositItemDetailMainDataIntroduceModel]?
    /// 产品最少借贷额度
    var minimum_amount: UInt64?
    /// 产品名称
    var name: String?
    /// 质押率
    var pledge_rate: Double?
    /// 常见问题
    var question: [DepositItemDetailMainDataIntroduceModel]?
    /// 可借额度
    var quota_limit: UInt64?
    /// 可借额度已使用
    var quota_used: UInt64?
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
    /// 余额（自行添加）
    var token_balance: UInt64?
    /// 激活状态（自行添加）
    var token_active_state: Bool?
}
struct DepositItemDetailMainModel: Codable {
    var code: Int?
    var message: String?
    var data: DepositItemDetailMainDataModel?
}
struct DepositLocalDataModel {
    var title: String
    var titleDescribe: String
    var content: String
    var contentColor: String
    var conentFont: UIFont
}
class DepositModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    private var walletTokens: [ViolasBalanceModel]?
    private var depositItemModel: DepositItemDetailMainDataModel?
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositModel销毁了")
    }
    func getLocalModel(model: DepositItemDetailMainDataModel? = nil) -> [DepositLocalDataModel] {
        
        return [DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_deposit_year_rate_title"),
                                           titleDescribe: "",
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "13B788",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_deposit_pledge_rate_title"),
                                           titleDescribe: localLanguage(keyString: "wallet_bank_deposit_pledge_rate_descript_title"),
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.pledge_rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_deposit_pay_account_title"),
                                           titleDescribe: "",
                                           content: localLanguage(keyString: "wallet_bank_deposit_pay_account_content"),
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular))]
    }
    func getDepositItemDetailModel(itemID: String, address: String) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "GetBankTokenBalanceQueue")
        queue.async {
            semaphore.wait()
            self.getDepositItemDetail(itemID: itemID, address: address, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.getViolasBalance(address: address, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.handleBankTokenBalance()
            semaphore.signal()
        }
    }
    private func getViolasBalance(address: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.GetViolasAccountInfo(address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(BalanceViolasMainModel.self)
                    if json.result == nil {
                        self?.walletTokens = [ViolasBalanceModel.init(amount: 0, currency: "LBR")]
                    } else {
                        self?.walletTokens = json.result?.balances
                    }
                    semaphore.signal()
                } catch {
                    print("GetViolasBalance_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetViolasBalance")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetViolasBalance_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetViolasBalance")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }
    private func handleBankTokenBalance() {
        self.depositItemModel?.token_active_state = false
        self.depositItemModel?.token_balance = 0
        for token in self.walletTokens! {
            if self.depositItemModel?.token_module == token.currency {
                self.depositItemModel?.token_active_state = true
                self.depositItemModel?.token_balance = NSDecimalNumber.init(value: token.amount ?? 0).uint64Value
                break
            }
        }
        DispatchQueue.main.async(execute: {
            let data = setKVOData(type: "GetBankTokens", data: self.depositItemModel)
            self.setValue(data, forKey: "dataDic")
        })
    }
}
extension DepositModel {
    private func getDepositItemDetail(itemID: String, address: String, semaphore: DispatchSemaphore) {
        let request = mainProvide.request(.loanItemDetail(itemID, address)) {[weak self](result) in
            switch  result {
            case let .success(response):
                do {
                    let json = try response.map(DepositItemDetailMainModel.self)
                    if json.code == 2000 {
                        guard let model = json.data else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataEmpty), type: "GetLoanItemDetail")
                            self?.setValue(data, forKey: "dataDic")
                            print("GetLoanItemDetail_状态异常")
                            return
                        }
                        self?.depositItemModel = model
                        semaphore.signal()
                    } else {
                        print("GetLoanItemDetail_状态异常")
                        if let message = json.message, message.isEmpty == false {
                            let data = setKVOData(error: LibraWalletError.error(message), type: "GetLoanItemDetail")
                            self?.setValue(data, forKey: "dataDic")
                        } else {
                            let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.dataCodeInvalid), type: "GetLoanItemDetail")
                            self?.setValue(data, forKey: "dataDic")
                        }
                    }
                } catch {
                    print("GetLoanItemDetail_解析异常\(error.localizedDescription)")
                    let data = setKVOData(error: LibraWalletError.WalletRequest(reason: LibraWalletError.RequestError.parseJsonError), type: "GetLoanItemDetail")
                    self?.setValue(data, forKey: "dataDic")
                }
            case let .failure(error):
                guard error.errorCode != -999 else {
                    print("GetLoanItemDetail_网络请求已取消")
                    return
                }
                let data = setKVOData(error: LibraWalletError.WalletRequest(reason: .networkInvalid), type: "GetLoanItemDetail")
                self?.setValue(data, forKey: "dataDic")
            }
        }
        self.requests.append(request)
    }

}
