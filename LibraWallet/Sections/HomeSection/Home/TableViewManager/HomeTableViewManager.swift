//
//  HomeTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class HomeTableViewManager: NSObject {
//    weak var delegate: TransactionsViewTableViewManagerDelegate?
    var dataModel: [String]?
    var selectRow: Int?
    deinit {
        print("HomeTableViewManager销毁了")
    }
}
extension HomeTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        let data = self.dataModel![indexPath.row]
//        guard let linkURL = data.explorerLink else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, url: linkURL)
    }
}
extension HomeTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, data.isEmpty == false {
//                (cell as! TransactionsTableViewCell).model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = HomeTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
//                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}

