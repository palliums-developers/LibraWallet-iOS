//
//  LoanListTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
//protocol LoanListTableViewManagerDelegate: NSObjectProtocol {
//    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
//}
class LoanListTableViewManager: NSObject {
//    weak var delegate: LoanListTableViewManagerDelegate?
    /// 数据
    var dataModels: [LoanListMainDataModel]?
    deinit {
        print("LoanListTableViewManager销毁了")
    }
}
extension LoanListTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModels else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
}
extension LoanListTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LoanListTableViewCell {
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            //            cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            return cell
        } else {
            let cell = LoanListTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.selectionStyle = .none;
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
