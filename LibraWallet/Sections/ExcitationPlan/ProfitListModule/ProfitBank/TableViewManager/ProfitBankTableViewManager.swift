//
//  ProfitBankTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/3.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ProfitBankTableViewManager: NSObject {
    //    weak var delegate: HomeTableViewManagerDelegate?
    /// 数据
    var dataModels: [LoanOrderDetailMainDataListModel]?
    deinit {
        print("ProfitBankTableViewManager销毁了")
    }
}
extension ProfitBankTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            return header
        } else {
            let header = ProfitBankTableViewHeaderView.init(reuseIdentifier: identifier)
            return header
        }
    }
}
extension ProfitBankTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10//dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ProfitBankTableViewCell {
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = ProfitBankTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
