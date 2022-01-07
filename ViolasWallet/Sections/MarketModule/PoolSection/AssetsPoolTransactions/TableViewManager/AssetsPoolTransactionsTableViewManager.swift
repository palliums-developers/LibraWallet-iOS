//
//  AssetsPoolTransactionsTableViewManager.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol AssetsPoolTransactionsTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: AssetsPoolTransactionsDataModel)
}
class AssetsPoolTransactionsTableViewManager: NSObject {
    weak var delegate: AssetsPoolTransactionsTableViewManagerDelegate?
    var dataModels: [AssetsPoolTransactionsDataModel]?
    deinit {
        print("AssetsPoolTableViewManager销毁了")
    }
}
extension AssetsPoolTransactionsTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension AssetsPoolTransactionsTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AssetsPoolTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = AssetsPoolTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            cell.indexPath = indexPath
            return cell
        }
    }
}
