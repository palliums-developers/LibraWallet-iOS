//
//  DepositOrdersTableViewManager.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol DepositOrdersTableViewManagerDelegate: NSObjectProtocol {
    func cellDelegate(cell: DepositOrdersTableViewCell)
}
class DepositOrdersTableViewManager: NSObject {
    weak var delegate: DepositOrdersTableViewManagerDelegate?
    /// 数据
    var dataModels: [DepositOrdersMainDataModel]?
    deinit {
        print("DepositOrdersTableViewManager销毁了")
    }
}
extension DepositOrdersTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            return header
        } else {
            let header = DepositOrdersTableViewHeaderView.init(reuseIdentifier: identifier)
            return header
        }
    }
}
extension DepositOrdersTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DepositOrdersTableViewCell {
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.indexPath = indexPath
            self.delegate?.cellDelegate(cell: cell)
            return cell
        } else {
            let cell = DepositOrdersTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.indexPath = indexPath
            self.delegate?.cellDelegate(cell: cell)
            return cell
        }
    }
}
