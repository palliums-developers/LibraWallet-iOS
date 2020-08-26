//
//  DepositModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

class DepositModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("DepositModel销毁了")
    }
    //    wallet_bank_repayment_loan_rate_title = "Loan Rate";
    //    wallet_bank_repayment_miner_fees_title = "Miner Fees";
    //    wallet_bank_repayment_pay_account_title = "Repayment Account";
    //    wallet_bank_repayment_pay_account_content = "Account Balance";
}
