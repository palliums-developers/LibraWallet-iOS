//
//  ExchangeTransactionDetailTableViewMananger.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
class ExchangeTransactionDetailTableViewMananger: NSObject {
    var dataModels: [TransactionDetailCustomDataModel]?
    var model: ExchangeTransactionsDataModel?
}
extension ExchangeTransactionDetailTableViewMananger: UITableViewDelegate {
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
        return 150
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let identifier = "Footer"
        if let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? ExchangeTransactionDetailFooterView {
            footer.model = self.model
            return footer
        } else {
            let footer = ExchangeTransactionDetailFooterView.init(reuseIdentifier: identifier)
            footer.model = self.model
            return footer
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 180
    }
}
extension ExchangeTransactionDetailTableViewMananger: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5//dataModel?.count ?? 0
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
