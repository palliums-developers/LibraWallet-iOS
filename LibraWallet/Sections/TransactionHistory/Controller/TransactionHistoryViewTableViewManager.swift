//
//  TransactionHistoryViewTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol TransactionHistoryViewTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, url: String)
}
class TransactionHistoryViewTableViewManager: NSObject {
    weak var delegate: TransactionHistoryViewTableViewManagerDelegate?
    var dataModel: [Transaction]?
    var selectRow: Int?
    deinit {
        print("TransactionHistoryViewTableViewManager销毁了")
    }
}
extension TransactionHistoryViewTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let data = self.dataModel![indexPath.row]
        guard let linkURL = data.explorerLink else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, url: linkURL)
    }
}
extension TransactionHistoryViewTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
                (cell as! TransactionHistoryTableViewCell).model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = TransactionHistoryTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
