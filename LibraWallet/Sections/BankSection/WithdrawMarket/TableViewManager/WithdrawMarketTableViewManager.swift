//
//  WithdrawMarketTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol WithdrawMarketTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class WithdrawMarketTableViewManager: NSObject {
    weak var delegate: WithdrawMarketTableViewManagerDelegate?
    /// 数据
    var dataModels: [Token]?
    deinit {
        print("WithdrawMarketTableViewManager销毁了")
    }
}
extension WithdrawMarketTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModels else {
//            return
//        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
}
extension WithdrawMarketTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10//dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WithdrawMarketTableViewCell {
//            if let data = dataModel, data.isEmpty == false {
//                cell.model = data[indexPath.row]
//            }
            return cell
        } else {
            let cell = WithdrawMarketTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
//            if let data = dataModel, data.isEmpty == false {
//                cell.model = data[indexPath.row]
//            }
            return cell
        }
    }
}
