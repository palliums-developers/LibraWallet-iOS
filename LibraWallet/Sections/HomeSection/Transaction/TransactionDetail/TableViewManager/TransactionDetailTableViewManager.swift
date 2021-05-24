//
//  TransactionDetailTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/5.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TransactionDetailTableViewManager: NSObject {
    var models: [TransactionDetailDataModel]?
    deinit {
        print("TransactionDetailTableViewManager销毁了")
    }
}
extension TransactionDetailTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
extension TransactionDetailTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "CellNormal"
        if let data = models, data.isEmpty == false {
            identifier = data[indexPath.row].type
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TransactionDetailTableViewCell {
            if let data = models, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = TransactionDetailTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = models, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
