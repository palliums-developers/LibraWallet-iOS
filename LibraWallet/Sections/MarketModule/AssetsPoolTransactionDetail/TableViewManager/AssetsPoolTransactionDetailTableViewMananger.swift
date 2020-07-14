//
//  AssetsPoolTransactionDetailTableViewMananger.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class AssetsPoolTransactionDetailTableViewMananger: NSObject {
    var dataModels: [TransactionDetailCustomDataModel]?
    var model: AssetsPoolTransactionsDataModel?
}
extension AssetsPoolTransactionDetailTableViewMananger: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //        let data = self.dataModel![indexPath.row]
        //        if let data = dataModel, data.isEmpty == false {
        //            self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
        //        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? ExchangeTransactionDetailHeaderView {
            header.model = self.model
            return header
        } else {
            let header = ExchangeTransactionDetailHeaderView.init(reuseIdentifier: identifier)
            header.model = self.model
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 175
    }
}
extension AssetsPoolTransactionDetailTableViewMananger: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ExchangeTransactionDetailTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            //            cell.delegate = self
            return cell
        } else {
            let cell = ExchangeTransactionDetailTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            //            cell.delegate = self
            
            return cell
        }
    }
}
