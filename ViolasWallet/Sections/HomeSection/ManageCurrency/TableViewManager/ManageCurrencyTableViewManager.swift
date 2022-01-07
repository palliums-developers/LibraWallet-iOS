//
//  ManageCurrencyTableViewManager.swift
//  ViolasWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

protocol ManageCurrencyTableViewManagerDelegate: NSObjectProtocol {
    func switchButtonChange(model: AssetsModel, state: Bool, failed: @escaping (() -> Void))
}
class ManageCurrencyTableViewManager: NSObject {
    weak var delegate: ManageCurrencyTableViewManagerDelegate?
    /// 数据Model
    var dataModels: [AssetsModel]?
    deinit {
        print("ManageCurrencyTableViewManager销毁了")
    }
}
extension ManageCurrencyTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModel else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
//    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
extension ManageCurrencyTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ManageCurrencyTableViewCell {
            if let data = dataModels, data.isEmpty == false {
                cell.token = data[indexPath.section]
            }
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else {
            let cell = ManageCurrencyTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.token = data[indexPath.section]
            }
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }
}
extension ManageCurrencyTableViewManager: ManageCurrencyTableViewCellDelegate {
    func switchButtonChange(model: AssetsModel, state: Bool, failed: @escaping (() -> Void)) {
        self.delegate?.switchButtonChange(model: model, state: state, failed: failed)
    }
}
