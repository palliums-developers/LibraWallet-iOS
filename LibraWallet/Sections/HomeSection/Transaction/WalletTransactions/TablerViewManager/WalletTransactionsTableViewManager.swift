//
//  WalletTransactionsTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletTransactionsTableViewManagerDelegate: NSObjectProtocol {
//    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String)
    func tableViewDidSelectRowAtIndexPath<T>(indexPath: IndexPath, model: T)
}
class WalletTransactionsTableViewManager: NSObject {
    weak var delegate: WalletTransactionsTableViewManagerDelegate?
    /// BTC
    var btcTransactions: [TrezorBTCTransactionDataModel]?
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
        return 64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch transactionType {
        case .Libra:
            if let data = libraTransactions, data.isEmpty == false {
                self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: data[indexPath.row])
            }
        case .Violas:
            if let data = violasTransactions, data.isEmpty == false {
                self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: data[indexPath.row])
            }
        case .BTC:
            if let data = btcTransactions, data.isEmpty == false {
                self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: data[indexPath.row])
            }
        default:
            break
        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, address: content)
    }
}
extension WalletTransactionsTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WalletTransactionsTableViewCell {
            switch transactionType {
            case .Libra:
                if let data = libraTransactions, data.isEmpty == false {
                    cell.libraModel = data[indexPath.row]
                }
            case .Violas:
                if let data = violasTransactions, data.isEmpty == false {
                    cell.violasModel = data[indexPath.row]
                }
            case .BTC:
                if let data = btcTransactions, data.isEmpty == false {
                    cell.btcModel = data[indexPath.row]
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
                    cell.libraModel = data[indexPath.row]
                }
            case .Violas:
                if let data = violasTransactions, data.isEmpty == false {
                    cell.violasModel = data[indexPath.row]
                    
                }
            case .BTC:
                if let data = btcTransactions, data.isEmpty == false {
                    cell.btcModel = data[indexPath.row]
                }
            default:
                break
            }
            return cell
        }
    }
}
