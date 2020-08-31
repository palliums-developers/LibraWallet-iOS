//
//  LoanMarketTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol LoanMarketTableViewManagerDelegate: NSObjectProtocol {
    func loanTableViewDidSelectRowAtIndexPath(indexPath: IndexPath, models: [BankDepositMarketDataModel])
}
class LoanMarketTableViewManager: NSObject {
    weak var delegate: LoanMarketTableViewManagerDelegate?
    /// 数据
    var dataModels: [BankDepositMarketDataModel]?
    deinit {
        print("LoanMarketTableViewManager销毁了")
    }
}
extension LoanMarketTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        self.delegate?.loanTableViewDidSelectRowAtIndexPath(indexPath: indexPath, models: model)
    }
}
extension LoanMarketTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LoanMarketTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = LoanMarketTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
