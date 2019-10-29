//
//  AddressManagerTableViewManager.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AddressManagerTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String)
}
class AddressManagerTableViewManager: NSObject {
    weak var delegate: AddressManagerTableViewManagerDelegate?
    
    var dataModel: [AddressModel]?
    deinit {
        print("AddressManagerTableViewManager销毁了")
    }
}
extension AddressManagerTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let data = self.dataModel![indexPath.row]
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: data.address ?? "")
    }
}
extension AddressManagerTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
                (cell as! AddressManagerTableViewCell).dataModel = data[indexPath.row]
            }
            return cell
        } else {
            let cell = AddressManagerTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.dataModel = data[indexPath.row]
            }
            return cell
        }
    }
}
