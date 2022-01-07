//
//  AboutUsTableViewManager.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AboutUsTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, content: String)
}
class AboutUsTableViewManager: NSObject {
    weak var delegate: AboutUsTableViewManagerDelegate?
    var dataModel = [["Title":localLanguage(keyString: "wallet_mine_about_us_official_address"),
                      "content":officialAddress],
                     ["Title":localLanguage(keyString: "wallet_mine_about_us_official_email"),
                      "content":officialEmail]]
    var selectRow: Int?
    deinit {
        print("AboutUsTableViewManager销毁了")
    }
}
extension AboutUsTableViewManager: UITableViewDelegate {
    //cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.dataModel[indexPath.row]["content"]!
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, content: data)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            return header
        } else {
            let header = AboutUsTableViewHeader.init(reuseIdentifier: identifier)
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 195
    }
}
extension AboutUsTableViewManager: UITableViewDataSource {
    //section下item数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            (cell as! AboutUsTableViewCell).dataModel = dataModel[indexPath.row]
            return cell
        } else {
            let cell = AboutUsTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.dataModel = dataModel[indexPath.row]
            return cell
        }
    }
}

