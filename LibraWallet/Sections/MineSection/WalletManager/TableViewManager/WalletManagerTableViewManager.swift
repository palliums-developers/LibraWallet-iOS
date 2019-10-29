//
//  WalletManagerTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletManagerTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: LibraWalletManager)
}
class WalletManagerTableViewManager: NSObject {
    weak var delegate: WalletManagerTableViewManagerDelegate?
    var dataModel: [[LibraWalletManager]]?
    var selectRow: Int?
    let headerTitleArray = ["身份钱包","创建/导入"]
    deinit {
        print("WalletManagerTableViewManager销毁了")
    }
}
extension WalletManagerTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let data = dataModel else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: data[indexPath.section][indexPath.row])
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            (header as! WalletManagerHeaderView).model = self.headerTitleArray[section]
            return header
        } else {
            let header = WalletManagerHeaderView.init(reuseIdentifier: identifier)
            header.model = self.headerTitleArray[section]
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }
}
extension WalletManagerTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[section].count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
               (cell as! WalletManagerTableViewCell).model = data[indexPath.section][indexPath.row]
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = WalletManagerTableViewCell.init(style: .default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.section][indexPath.row]
                }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
}
