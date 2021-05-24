//
//  ExchangeTransactionsTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol ExchangeTransactionsTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ExchangeTransactionsDataModel)
}
class ExchangeTransactionsTableViewManager: NSObject {
    weak var delegate: ExchangeTransactionsTableViewManagerDelegate?
    var dataModels: [ExchangeTransactionsDataModel]?
    deinit {
        print("ExchangeTransactionsTableViewManager销毁了")
    }
}
extension ExchangeTransactionsTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension ExchangeTransactionsTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let identifier = "NormalCell"
        var identifier = "NormalCell"
        if let data = dataModels, data.isEmpty == false {
            if data[indexPath.row].status == "Executed" {
                identifier = "NormalCell"
            } else {
                identifier = "FailedCell"
            }
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ExchangeTransactionsTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = ExchangeTransactionsTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
