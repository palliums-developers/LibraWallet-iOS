//
//  WalletMainTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class WalletMainTableViewManager: NSObject {
    weak var delegate: WalletTransactionsTableViewManagerDelegate?
    /// Violas
    var violasTransactions: [ViolasDataModel]?
    deinit {
        print("VTokenTableViewManager销毁了")
    }
}
extension WalletMainTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        let data = self.dataModel![indexPath.row]
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: data.address ?? "")
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
extension WalletMainTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return violasTransactions?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WalletTransactionsTableViewCell {
            if let data = violasTransactions, data.isEmpty == false {
                cell.violasModel = data[indexPath.section]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = WalletTransactionsTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = violasTransactions, data.isEmpty == false {
                cell.violasModel = data[indexPath.section]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
