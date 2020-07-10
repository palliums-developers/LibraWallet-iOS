//
//  ExchangeTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ExchangeTableViewManager: NSObject {
    var dataModels: [ExchangeTransactionsDataModel]?
    deinit {
        print("ExchangeTableViewManager销毁了")
    }
}
extension ExchangeTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //        guard let model = self.dataModel else {
        //            return
        //        }
        //        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension ExchangeTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let identifier = "NormalCell"
        var identifier = "NormalCell"
        if let data = dataModels, data.isEmpty == false {
            if data[indexPath.row].status == 4001 {
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
