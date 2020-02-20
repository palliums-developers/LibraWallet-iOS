//
//  HomeTableViewManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol HomeTableViewManagerDelegate: NSObjectProtocol {
        func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: ViolasTokenModel)

}
class HomeTableViewManager: NSObject {
    weak var delegate: HomeTableViewManagerDelegate?
    /// 数据
    var dataModel: [ViolasTokenModel]?
    /// 资产第一个
    var defaultModel: ViolasTokenModel?
    var selectRow: Int?
    deinit {
        print("HomeTableViewManager销毁了")
    }
}
extension HomeTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModel else {
            return
        }
        
//        let data = self.dataModel![indexPath.row]
//        guard let linkURL = data.explorerLink else {
//            return
//        }
        
        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = "Header"
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? HomeTableViewHeader {
            header.model = self.defaultModel
            return header
        } else {
            let header = HomeTableViewHeader.init(reuseIdentifier: identifier)
            header.model = self.defaultModel
            return header
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}
extension HomeTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HomeTableViewCell {
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        } else {
            let cell = HomeTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModel, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            return cell
        }
    }
}

