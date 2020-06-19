//
//  LocalWalletTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/11.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol LocalWalletTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: Token)
}
class LocalWalletTableViewManager: NSObject {
    weak var delegate: LocalWalletTableViewManagerDelegate?
    var dataModel: [[Token]]?
    var originModel: [[Token]]?
    var originModelLocation: IndexPath?
    var dataModelLocation: IndexPath?
    let headerTitleArray = [localLanguage(keyString: "wallet_manager_identity_wallet_header_title"), localLanguage(keyString: "wallet_manager_import_or_create_wallet_header_title")]
    deinit {
        print("LocalWalletTableViewManager销毁了")
    }
}
extension LocalWalletTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
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
extension LocalWalletTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[section].count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LocalWalletTableViewCell {
            if let data = dataModel, let origin = originModel, data.isEmpty == false, origin.isEmpty == false {
                cell.model = data[indexPath.section][indexPath.row]
//                if data[indexPath.section][indexPath.row].walletCurrentUse == true {
//                    self.dataModelLocation = indexPath
//                    if data.last?.count == origin.last?.count {
//                        self.originModelLocation = indexPath
//                    }
//                }
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = LocalWalletTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, let origin = originModel, data.isEmpty == false, origin.isEmpty == false {
                cell.model = data[indexPath.section][indexPath.row]
//                if data[indexPath.section][indexPath.row].walletCurrentUse == true {
//                    self.dataModelLocation = indexPath
//                    if data.last?.count == origin.last?.count {
//                        self.originModelLocation = indexPath
//                    }
//                }
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
