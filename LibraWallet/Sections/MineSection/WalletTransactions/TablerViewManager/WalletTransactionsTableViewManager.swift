//
//  WalletTransactionsTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletTransactionsTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String)
}
class WalletTransactionsTableViewManager: NSObject {
    weak var delegate: WalletTransactionsTableViewManagerDelegate?
    var dataModel: [AddressModel]?
    deinit {
        print("WalletTransactionsTableViewManager销毁了")
    }
}
extension WalletTransactionsTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let data = self.dataModel![indexPath.row]
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: data.address ?? "")
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "F7F7F9")
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
extension WalletTransactionsTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
//                (cell as! WalletTransactionsTableViewCell).dataModel = data[indexPath.row]
            }
            return cell
        } else {
            let cell = WalletTransactionsTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
//                cell.dataModel = data[indexPath.row]
            }
            return cell
        }
    }
}
