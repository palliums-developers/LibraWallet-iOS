//
//  WalletMessagesTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/11.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
protocol WalletMessagesTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: WalletMessagesDataModel)
}
class WalletMessagesTableViewManager: NSObject {
    /// Delegate
    weak var delegate: WalletMessagesTableViewManagerDelegate?
    /// 数据
    var dataModels: [WalletMessagesDataModel]?
    deinit {
        print("WalletMessagesTableViewManager销毁了")
    }
}
extension WalletMessagesTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension WalletMessagesTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WalletMessagesCellTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = WalletMessagesCellTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
