//
//  LanguageTabViewManager.swift
//  HKWallet
//
//  Created by palliums on 2019/8/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol LanguageTabViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath)
}
class LanguageTabViewManager: NSObject {
    weak var delegate: LanguageTabViewManagerDelegate?
    var dataModel = [["Title":"简体中文",
                      "Content":"简体中文"],
                     ["Title":"English",
                      "Content":"英文"]]
    var selectRow: Int?
    deinit {
        print("LanguageTabViewManager销毁了")
    }
}
extension LanguageTabViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let oldCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: selectRow!)) as! LanguageTableViewCell
        oldCell.setCellSelected(status: false)
        
        let newCell = tableView.cellForRow(at: indexPath) as! LanguageTableViewCell
        newCell.setCellSelected(status: true)
        self.selectRow = indexPath.section
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "F8F8F8")
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
extension LanguageTabViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LanguageTableViewCell {
            cell.dataModel = dataModel[indexPath.section]
            cell.hideSpcaeLineState = true
            if indexPath.section == self.selectRow! {
                cell.setCellSelected(status: true)
            }
            return cell
        } else {
            let cell = LanguageTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell.dataModel = dataModel[indexPath.section]
            cell.hideSpcaeLineState = true
            if indexPath.section == self.selectRow! {
                cell.setCellSelected(status: true)
            }
            return cell
        }
    }
}
