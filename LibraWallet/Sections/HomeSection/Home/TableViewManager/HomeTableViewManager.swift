//
//  HomeTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol HomeTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: Token)
}
class HomeTableViewManager: NSObject {
    weak var delegate: HomeTableViewManagerDelegate?
    /// 数据
    var dataModel: [Token]?
    var hideValue: Bool = false
    deinit {
        print("HomeTableViewManager销毁了")
    }
}
extension HomeTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModel else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension HomeTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HomeTableViewCell {
            cell.hideValue = self.hideValue
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.hideValue = self.hideValue
            return cell
        } else {
            let cell = HomeTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.hideValue = self.hideValue
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}
