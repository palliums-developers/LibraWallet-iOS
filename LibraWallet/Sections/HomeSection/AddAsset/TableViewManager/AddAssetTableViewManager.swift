//
//  AddAssetTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAssetTableViewManager: NSObject {
    weak var delegate: MineTableViewManagerDelegate?
    var dataModel: [[String: String]]?
    var selectRow: Int?
    deinit {
        print("AddAssetTableViewManager销毁了")
    }
}
extension AddAssetTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
                
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
//            (header as! AddAssetTableViewHeader).model = self.headerTitleArray[section]
            return header
        } else {
            let header = AddAssetTableViewHeader.init(reuseIdentifier: identifier)
//            header.model = self.headerTitleArray[section]
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}
extension AddAssetTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
//                (cell as! AddAssetViewTableViewCell).model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = AddAssetViewTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
//                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
