//
//  ProfitPoolTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/3.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ProfitPoolTableViewManager: NSObject {
    //    weak var delegate: HomeTableViewManagerDelegate?
    /// 数据
    var dataModels: [PoolProfitDataModel]?
    deinit {
        print("ProfitPoolTableViewManager销毁了")
    }
}
extension ProfitPoolTableViewManager: UITableViewDelegate {
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
            let header = ProfitInvitationTabViewHeaderView.init(reuseIdentifier: identifier)
            return header
        }
    }
}
extension ProfitPoolTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ProfitPoolTableViewCell {
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = ProfitPoolTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
