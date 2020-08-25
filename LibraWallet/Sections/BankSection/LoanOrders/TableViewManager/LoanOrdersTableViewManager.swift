//
//  LoanOrdersTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol LoanOrdersTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class LoanOrdersTableViewManager: NSObject {
    weak var delegate: LoanOrdersTableViewManagerDelegate?
    /// 数据
    var dataModels: [Token]?
    deinit {
        print("WithdrawMarketTableViewManager销毁了")
    }
}
extension LoanOrdersTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModels else {
//            return
//        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            return header
        } else {
            let header = LoanOrdersTableViewHeaderView.init(reuseIdentifier: identifier)
            return header
        }
    }
}
extension LoanOrdersTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10//dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LoanOrdersTableViewCell {
            cell.selectionStyle = .none;
            //            if let data = dataModel, data.isEmpty == false {
            //                cell.model = data[indexPath.row]
            //            }
            return cell
        } else {
            let cell = LoanOrdersTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.selectionStyle = .none;
            //            if let data = dataModel, data.isEmpty == false {
            //                cell.model = data[indexPath.row]
            //            }
            return cell
        }
    }
}
