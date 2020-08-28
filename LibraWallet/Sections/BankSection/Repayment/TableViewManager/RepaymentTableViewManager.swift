//
//  RepaymentTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class RepaymentTableViewManager: NSObject {
    weak var delegate: AssetsPoolTransactionsTableViewManagerDelegate?
    var dataModels: [Int]? = [1, 2, 3]
    deinit {
        print("RepaymentTableViewManager销毁了")
    }
}
extension RepaymentTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 143
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            return header
        } else {
            let header = RepaymentTableViewHeaderView.init(reuseIdentifier: identifier)
            return header
        }
    }
}
extension RepaymentTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3//dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RepaymentTableViewCell {
            if let data = dataModels, data.isEmpty == false {
//                cell.model = data[indexPath.row]
                cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            }
//            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = RepaymentTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
//                cell.model = data[indexPath.row]
                cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
