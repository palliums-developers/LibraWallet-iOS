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
    func selectToken(button: UIButton, leftModelName: String, rightModelName: String)
    func showOrderCenter()
    func exchangeToken(payToken: MarketSupportCoinDataModel, receiveToken: MarketSupportCoinDataModel, amount: Double, exchangeAmount: Double)
}
class MarketTableViewManager: NSObject {
    weak var delegate: MarketTableViewManagerDelegate?
//    var dataModel: [ViolasTokenModel]?
//    var headerData: LibraWalletManager?
    var normalLeftModel = MarketSupportCoinDataModel.init(addr: "", name: "---", price: 1, enable: true)
    
    var buyOrders: [MarketOrderDataModel]?
    var sellOrders: [MarketOrderDataModel]?
    deinit {
        print("MarketTableViewManager销毁了")
    }
}
extension MarketTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 0
        } else if indexPath.section == 1 {
            return 64
        } else {
            return 30
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModel else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var identifier = ""
        if section == 0 {
            identifier = "MainHeader";
        } else if section == 1 {
            identifier = "MineHeader";
        } else {
            identifier = "OthersHeader"
        }
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? MarketExchangeHeaderView {
            header.delegate = self
            if header.leftTokenModel == nil {
                header.leftTokenModel = self.normalLeftModel
            }
            return header
        } else if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? MarketMyOrderHeaderView {
//            (header as! AddAssetTableViewHeader).model = self.headerData
            header.delegate = self
            return header
        } else if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? MarketOthersOrderHeaderView {
//            (header as! AddAssetTableViewHeader).model = self.headerData
//            header.delegate = self
            return header
        } else {
            let view = UIView()
            return view
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 387
        } else {
            return 94
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
extension MarketTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            return buyOrders?.count ?? 0 > 5 ? 5:(buyOrders?.count ?? 0)
        } else {
            return sellOrders?.count ?? 0 > 5 ? 5:(sellOrders?.count ?? 0)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""
        if indexPath.section == 0 {
            identifier = "";
        } else if indexPath.section == 1 {
            identifier = "MineCell";
        } else {
            identifier = "OtherCell"
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MarketMyOrderTableViewCell {
            if let data = buyOrders, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MarketOthersOrderTableViewCell {
            if let data = sellOrders, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        } else {
            if indexPath.section == 0 {
                identifier = "";
                let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
                return cell
            } else if indexPath.section == 1 {
                let cell = MarketMyOrderTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                if let data = buyOrders, data.isEmpty == false {
                    cell.model = data[indexPath.row]
                }
                cell.selectionStyle = .none
                cell.indexPath = indexPath
                return cell
            } else {
                let cell = MarketOthersOrderTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                if let data = sellOrders, data.isEmpty == false {
                    cell.model = data[indexPath.row]
                }
                cell.selectionStyle = .none
                cell.indexPath = indexPath
                return cell
            }
        }
    }
}
//extension MarketTableViewManager: AddAssetViewTableViewCellDelegate {
//    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
//        self.delegate?.switchButtonChange(model: model, state: state, indexPath: indexPath)
//    }
//}
extension MarketTableViewManager: MarketExchangeHeaderViewDelegate {
    func selectToken(button: UIButton, leftModelName: String, rightModelName: String) {
        self.delegate?.selectToken(button: button, leftModelName: leftModelName, rightModelName: rightModelName)
    }
    
    func exchangeToken(payToken: MarketSupportCoinDataModel, receiveToken: MarketSupportCoinDataModel, amount: Double, exchangeAmount: Double) {
        self.delegate?.exchangeToken(payToken: payToken, receiveToken: receiveToken, amount: amount, exchangeAmount: exchangeAmount)
    }
}
extension MarketTableViewManager: MarketMyOrderHeaderViewDelegate {
    func showOrderCenter() {
        self.delegate?.showOrderCenter()
    }    
}
