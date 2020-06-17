//
//  AddAssetTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AddAssetTableViewManagerDelegate: NSObjectProtocol {
    func switchButtonChange(model: AssetsModel, state: Bool, indexPath: IndexPath)
//    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ViolasTokenModel)
}
class AddAssetTableViewManager: NSObject {
    weak var delegate: AddAssetTableViewManagerDelegate?
    var dataModel: [AssetsModel]?
    var headerData: Token?
    deinit {
        print("AddAssetTableViewManager销毁了")
    }
}
extension AddAssetTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        guard let model = self.dataModel else {
//            return
//        }
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
//    }
}
extension AddAssetTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? AddAssetViewTableViewCell {
            if let data = dataModel, data.isEmpty == false {
                cell.token = data[indexPath.row]
            }
            cell.selectionStyle = .none
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        } else {
            let cell = AddAssetViewTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.token = data[indexPath.row]
            }
            cell.selectionStyle = .none
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
    }
}
extension AddAssetTableViewManager: AddAssetViewTableViewCellDelegate {
    func switchButtonChange(model: AssetsModel, state: Bool, indexPath: IndexPath) {
        self.delegate?.switchButtonChange(model: model, state: state, indexPath: indexPath)
    }
}
