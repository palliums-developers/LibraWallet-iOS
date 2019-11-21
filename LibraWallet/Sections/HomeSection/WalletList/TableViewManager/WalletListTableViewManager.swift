//
//  WalletListTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletListTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: LibraWalletManager)
}
class WalletListTableViewManager: NSObject {
    weak var delegate: WalletListTableViewManagerDelegate?
    var dataModel: [[LibraWalletManager]]?
    var originModel: [[LibraWalletManager]]?
    var originModelLocation: IndexPath?
    var dataModelLocation: IndexPath?
    let headerTitleArray = [localLanguage(keyString: "wallet_manager_identity_wallet_header_title"), localLanguage(keyString: "wallet_manager_import_or_create_wallet_header_title")]
    deinit {
        print("WalletListTableViewManager销毁了")
    }
}
extension WalletListTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let data = dataModel else {
            return
        }
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: data[indexPath.section][indexPath.row])
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            (header as! WalletManagerHeaderView).model = self.headerTitleArray[section]
            return header
        } else {
            let header = WalletManagerHeaderView.init(reuseIdentifier: identifier)
            header.model = self.headerTitleArray[section]
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }
}
extension WalletListTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[section].count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            if let data = dataModel, let origin = originModel, data.isEmpty == false, origin.isEmpty == false {
                (cell as! WalletListTableViewCell).model = data[indexPath.section][indexPath.row]
                if data[indexPath.section][indexPath.row].walletCurrentUse == true {
                    self.dataModelLocation = indexPath
                    if data.last?.count == origin.last?.count {
                        self.originModelLocation = indexPath
                    }
                }
                
                
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = WalletListTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, let origin = originModel, data.isEmpty == false, origin.isEmpty == false {
                cell.model = data[indexPath.section][indexPath.row]
                if data[indexPath.section][indexPath.row].walletCurrentUse == true {
                    self.dataModelLocation = indexPath
                    if data.last?.count == origin.last?.count {
                        self.originModelLocation = indexPath
                    }
                }
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
