//
//  AssetsPoolTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol AssetsPoolTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class AssetsPoolTableViewManager: NSObject {
    weak var delegate: AssetsPoolTableViewManagerDelegate?
    /// 当前委托
    var buyOrders: [MarketOrderDataModel]?
    /// 他人委托
    var sellOrders: [MarketOrderDataModel]?
    /// 是否展示其他人挂单至20条上线
    var showOtherSellOrdersToMax: Bool = false
    /// 付出稳定币
    var payToken: MarketSupportCoinDataModel?
    /// 兑换稳定币
    var exchangeToken: MarketSupportCoinDataModel?
    deinit {
        print("AssetsPoolTableViewManager销毁了")
    }
}
extension AssetsPoolTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //        guard let model = self.dataModel else {
        //            return
        //        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
}
extension AssetsPoolTableViewManager: UITableViewDataSource {
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AssetsPoolTableViewCell {
            //            if let data = buyOrders, data.isEmpty == false {
            //                cell.model = data[indexPath.row]
            //            }
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = AssetsPoolTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            //            if let data = sellOrders, data.isEmpty == false {
            //                cell.model = data[indexPath.row]
            //            }
            cell.selectionStyle = .none
            cell.indexPath = indexPath
            return cell
        }
    }
}
