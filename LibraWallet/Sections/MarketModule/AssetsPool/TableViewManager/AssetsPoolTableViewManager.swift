//
//  AssetsPoolTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol AssetsPoolTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class AssetsPoolTableViewManager: NSObject {
    weak var delegate: AssetsPoolTableViewManagerDelegate?
    var dataModels: [AssetsPoolTransactionsDataModel]?
    deinit {
        print("AssetsPoolTableViewManager销毁了")
    }
}
extension AssetsPoolTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //        guard let model = self.dataModel else {
        //            return
        //        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
}
extension AssetsPoolTableViewManager: UITableViewDataSource {
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
