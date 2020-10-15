//
//  RepaymentTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol RepaymentTableViewManagerDelegate: NSObjectProtocol {
    func headerDelegate(header: RepaymentTableViewHeaderView)
}
class RepaymentTableViewManager: NSObject {
    weak var delegate: RepaymentTableViewManagerDelegate?
    var dataModels: [DepositLocalDataModel]?
    var model: RepaymentMainDataModel?
    deinit {
        print("RepaymentTableViewManager销毁了")
    }
}
extension RepaymentTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModels else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 143
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? RepaymentTableViewHeaderView {
            header.model = self.model
            self.delegate?.headerDelegate(header: header)
            return header
        } else {
            let header = RepaymentTableViewHeaderView.init(reuseIdentifier: identifier)
            header.model = self.model
            self.delegate?.headerDelegate(header: header)
            return header
        }
    }
}
extension RepaymentTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RepaymentTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
                cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = RepaymentTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
                cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
