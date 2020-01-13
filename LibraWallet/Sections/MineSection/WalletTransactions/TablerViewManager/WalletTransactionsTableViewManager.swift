//
//  WalletTransactionsTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletTransactionsTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String)
}
class WalletTransactionsTableViewManager: NSObject {
    weak var delegate: WalletTransactionsTableViewManagerDelegate?
    /// BTC
    var btcTransactions: [BTCTransaction]?
    /// Violas
    var violasTransactions: [ViolasDataModel]?
    /// Libra
    var libraTransactions: [LibraDataModel]?
    var transactionType: WalletType?
    var tokenName: String?
    deinit {
        print("WalletTransactionsTableViewManager销毁了")
    }
}
extension WalletTransactionsTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var content = ""
        switch transactionType {
        case .Libra:
            if let data = libraTransactions, data.isEmpty == false {
                content = data[indexPath.row].explorerLink ?? ""
            }
        case .Violas:
            if let data = violasTransactions, data.isEmpty == false {
                content = "\(data[indexPath.row].version ?? 0)"
            }
        case .BTC:
            if let data = btcTransactions, data.isEmpty == false {
                content = data[indexPath.row].hash ?? ""
            }
        default:
            break
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: content)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "F7F7F9")
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
extension WalletTransactionsTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch transactionType {
        case .Libra:
            return libraTransactions?.count ?? 0
        case .Violas:
            return violasTransactions?.count ?? 0
        case .BTC:
            return btcTransactions?.count ?? 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            switch transactionType {
            case .Libra:
                if let data = libraTransactions, data.isEmpty == false {
                    (cell as! WalletTransactionsTableViewCell).libraModel = data[indexPath.section]
                }
            case .Violas:
                if let data = violasTransactions, data.isEmpty == false {
                    (cell as! WalletTransactionsTableViewCell).violasModel = data[indexPath.section]
                }
            case .BTC:
                if let data = btcTransactions, data.isEmpty == false {
                    (cell as! WalletTransactionsTableViewCell).btcModel = data[indexPath.section]
                }
            default:
                break
            }
            return cell
        } else {
            let cell = WalletTransactionsTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            switch transactionType {
            case .Libra:
                if let data = libraTransactions, data.isEmpty == false {
                    cell.libraModel = data[indexPath.section]
                }
            case .Violas:
                if let data = violasTransactions, data.isEmpty == false {
                    cell.violasModel = data[indexPath.section]
                    
                }
            case .BTC:
                if let data = btcTransactions, data.isEmpty == false {
                    cell.btcModel = data[indexPath.section]
                }
            default:
                break
            }
            return cell
        }
    }
}
