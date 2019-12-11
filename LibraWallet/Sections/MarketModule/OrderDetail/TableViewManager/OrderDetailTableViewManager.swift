//
//  OrderDetailTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol OrderDetailTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String)
}
class OrderDetailTableViewManager: NSObject {
    weak var delegate: OrderDetailTableViewManagerDelegate?
    var dataModel: [AddressModel]?
    deinit {
        print("OrderProcessingTableViewManager销毁了")
    }
}
extension OrderDetailTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        let data = self.dataModel![indexPath.row]
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: data.address ?? "")
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? OrderDetailHeaderView {
//            (header as! OrderDetailHeaderView).model = self.headerTitleArray[section]
            return header
        } else {
            let header = OrderDetailHeaderView.init(reuseIdentifier: identifier)
//            header.model = self.headerTitleArray[section]
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 230
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
extension OrderDetailTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
                (cell as! OrderDetailTableViewCell).dataModel = data[indexPath.row]
            }
            return cell
        } else {
            let cell = OrderDetailTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.dataModel = data[indexPath.row]
            }
            return cell
        }
    }
}
