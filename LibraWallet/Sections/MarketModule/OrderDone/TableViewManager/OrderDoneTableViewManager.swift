//
//  OrderDoneTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol OrderDoneTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: MarketOrderDataModel)
}
class OrderDoneTableViewManager: NSObject {
    weak var delegate: OrderDoneTableViewManagerDelegate?
    var dataModel: [MarketOrderDataModel]?
    deinit {
        print("OrderDoneTableViewManager销毁了")
    }
}
extension OrderDoneTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 141
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        let data = self.dataModel![indexPath.row]
        if let data = dataModel, data.isEmpty == false {
            self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: data[indexPath.row])
        }
    }
}
extension OrderDoneTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "OrderDoneCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? OrderCenterTableViewCell {
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = OrderCenterTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
