//
//  DepositMarketTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol DepositMarketTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, models: [BankDepositMarketDataModel])
}
class DepositMarketTableViewManager: NSObject {
    weak var delegate: DepositMarketTableViewManagerDelegate?
    /// 数据
    var dataModels: [BankDepositMarketDataModel]?
    deinit {
        print("DepositMarketTableViewManager销毁了")
    }
}
extension DepositMarketTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let tempDataModels = self.dataModels else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, models: tempDataModels)
    }
}
extension DepositMarketTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DepositMarketTableViewCell {
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = DepositMarketTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
