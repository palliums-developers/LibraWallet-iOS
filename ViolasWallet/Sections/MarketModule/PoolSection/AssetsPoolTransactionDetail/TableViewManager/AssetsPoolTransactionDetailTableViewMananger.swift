//
//  AssetsPoolTransactionDetailTableViewMananger.swift
//  ViolasWallet
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? AssetsPoolTransactionDetailHeaderView {
            header.model = self.model
            return header
        } else {
            let header = AssetsPoolTransactionDetailHeaderView.init(reuseIdentifier: identifier)
            header.model = self.model
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let identifier = "Footer"
        if let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? AssetsPoolTransactionDetailFooterView {
            footer.model = self.model
            return footer
        } else {
            let footer = AssetsPoolTransactionDetailFooterView.init(reuseIdentifier: identifier)
            footer.model = self.model
            return footer
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 180
    }
}
extension AssetsPoolTransactionDetailTableViewMananger: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AssetsPoolTransactionDetailTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = AssetsPoolTransactionDetailTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
