//
//  DepositModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
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
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositModel销毁了")
    }
    func getLocalModel(model: BankDepositMarketDataModel? = nil) -> [DepositLocalDataModel] {
        
        return [DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_deposit_year_rate_title"),
                                           titleDescribe: "",
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.product_rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "13B788",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_deposit_pledge_rate_title"),
                                           titleDescribe: localLanguage(keyString: "wallet_bank_deposit_pledge_rate_descript_title"),
                                           content: model != nil ? (NSDecimalNumber.init(value: model?.product_pledge_rate ?? 0).multiplying(by: NSDecimalNumber.init(value: 100)).stringValue + "%"):"---",
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)),
                DepositLocalDataModel.init(title: localLanguage(keyString: "wallet_bank_deposit_pay_account_title"),
                                           titleDescribe: "",
                                           content: localLanguage(keyString: "wallet_bank_deposit_pay_account_content"),
                                           contentColor: "333333",
                                           conentFont: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular))]
    }
    func getBankListModel(address: String, bankTokens: [BankDepositMarketDataModel]) {
        let semaphore = DispatchSemaphore.init(value: 1)
        let queue = DispatchQueue.init(label: "GetBankTokenBalanceQueue")
        queue.async {
            semaphore.wait()
            self.getViolasBalance(address: address, semaphore: semaphore)
        }
        queue.async {
            semaphore.wait()
            self.handleBankTokenBalance(bankTokens: bankTokens)
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
    private func handleBankTokenBalance(bankTokens: [BankDepositMarketDataModel]) {
        var tempBankTokens = [BankDepositMarketDataModel]()
        for bankToken in bankTokens {
            var tempBankToken = bankToken
            for token in self.walletTokens! {
                if bankToken.product_token_module == token.currency {
                    tempBankToken.token_active_state = true
                    tempBankToken.token_balance = token.amount
                    break
                }
            }
            tempBankTokens.append(tempBankToken)
        }
        DispatchQueue.main.async(execute: {
            let data = setKVOData(type: "GetBankTokens", data: tempBankTokens)
            self.setValue(data, forKey: "dataDic")
        })
    }
}
