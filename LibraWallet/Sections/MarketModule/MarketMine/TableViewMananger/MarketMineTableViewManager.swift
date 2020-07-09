//
//  MarketMineTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MarketMineTableViewManager: NSObject {

}
extension MarketMineTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModel else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension MarketMineTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let identifier = "NormalCell"
        let identifier = "FailedCell"
//        if indexPath.section == 0 {
//            identifier = "";
//        } else if indexPath.section == 1 {
//            identifier = "MineCell";
//        } else {
//            identifier = "OtherCell"
//        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MarketMineTableViewCell {
//            if let data = buyOrders, data.isEmpty == false {
//                cell.model = data[indexPath.row]
//            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = MarketMineTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
//            if let data = sellOrders, data.isEmpty == false {
//                cell.model = data[indexPath.row]
//            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
