//
//  SupportCoinTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol SupportCoinTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class SupportCoinTableViewManager: NSObject {
    weak var delegate: SupportCoinTableViewManagerDelegate?
    var dataModel: [[String: String]]?
    var selectRow: Int?
    deinit {
        print("WalletManagerTableViewManager销毁了")
    }
}
extension SupportCoinTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
                
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
}
extension SupportCoinTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[section].count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
               (cell as! SupportCoinTableViewCell).model = data[indexPath.row]
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = SupportCoinTableViewCell.init(style: .default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
                }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
}
