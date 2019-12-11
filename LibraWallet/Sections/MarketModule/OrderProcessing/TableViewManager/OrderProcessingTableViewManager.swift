//
//  OrderProcessingTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol OrderProcessingTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String)
}
class OrderProcessingTableViewManager: NSObject {
    weak var delegate: OrderProcessingTableViewManagerDelegate?
    var dataModel: [AddressModel]?
    deinit {
        print("OrderProcessingTableViewManager销毁了")
    }
}
extension OrderProcessingTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 141
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        let data = self.dataModel![indexPath.row]
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: "")
    }
}
extension OrderProcessingTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
                (cell as! OrderCenterTableViewCell).dataModel = data[indexPath.row]
            }
            return cell
        } else {
            let cell = OrderCenterTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.dataModel = data[indexPath.row]
            }
            return cell
        }
    }
}
