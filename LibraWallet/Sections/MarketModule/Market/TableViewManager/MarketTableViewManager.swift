//
//  MarketTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol MarketTableViewManagerDelegate: NSObjectProtocol {
//    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath)
//    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ViolasTokenModel)
//    func selectToken(button: UIButton, leftModelName: String, rightModelName: String, header: MarketExchangeHeaderView)
//    func showOrderCenter()
//    func exchangeToken(payToken: MarketSupportCoinDataModel, receiveToken: MarketSupportCoinDataModel, amount: Double, exchangeAmount: Double)
//    func showHideOthersToMax(state: Bool)
//    func changeLeftRightTokenModel(leftModel: MarketSupportCoinDataModel, rightModel: MarketSupportCoinDataModel)
}
class MarketTableViewManager: NSObject {
    weak var delegate: MarketTableViewManagerDelegate?
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
        print("MarketTableViewManager销毁了")
    }
}
extension MarketTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModel else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension MarketTableViewManager: UITableViewDataSource {
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MarketTransactionsTableViewCell {
//            if let data = buyOrders, data.isEmpty == false {
//                cell.model = data[indexPath.row]
//            }
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = MarketTransactionsTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
//            if let data = sellOrders, data.isEmpty == false {
//                cell.model = data[indexPath.row]
//            }
            cell.selectionStyle = .none
            cell.indexPath = indexPath
            return cell
        }
    }
}
