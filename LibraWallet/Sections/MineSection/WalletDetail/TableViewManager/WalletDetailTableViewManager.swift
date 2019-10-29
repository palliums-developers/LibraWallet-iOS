//
//  WalletDetailTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletDetailTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class WalletDetailTableViewManager: NSObject {
    weak var delegate: WalletDetailTableViewManagerDelegate?
    var dataModel: [[String: String]]?
    var selectRow: Int?
    deinit {
        print("WalletManagerTableViewManager销毁了")
    }
}
extension WalletDetailTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
                
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "F7F7F9")
        return view
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
extension WalletDetailTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
               (cell as! WalletDetailTableViewCell).model = data[indexPath.section]
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = WalletDetailTableViewCell.init(style: .default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.section]
                }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
}

