//
//  DepositTableViewManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol DepositTableViewManagerDelegate: NSObjectProtocol {
    func headerDelegate(header: DepositTableViewHeaderView)
}
class DepositTableViewManager: NSObject {
    weak var delegate: DepositTableViewManagerDelegate?
    var model: BankDepositMarketDataModel?
    var dataModels: [DepositLocalDataModel]?
    deinit {
        print("DepositTableViewManager销毁了")
    }
}
extension DepositTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        //        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 162
        } else {
            return 10
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let identifier = "Header"
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? DepositTableViewHeaderView {
                header.productModel = self.model
                self.delegate?.headerDelegate(header: header)
                return header
            } else {
                let header = DepositTableViewHeaderView.init(reuseIdentifier: identifier)
                header.productModel = self.model
                self.delegate?.headerDelegate(header: header)
                return header
            }
        } else {
            let view = UIView.init()
            view.backgroundColor = UIColor.init(hex: "F7F7F9")
            return view
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hex: "F7F7F9")
        return view
    }
}
extension DepositTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataModels?.count ?? 0
        } else {
            return 1
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier = "NormalCell"
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DepositTableViewCell {
                if let data = dataModels, data.isEmpty == false {
                    cell.model = data[indexPath.row]
                    cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
                }
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = DepositTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                if let data = dataModels, data.isEmpty == false {
                    cell.model = data[indexPath.row]
                    cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
                }
                cell.selectionStyle = .none
                return cell
            }
        } else if indexPath.section == 1 {
            let identifier = "DescribeCell"
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DepositDescribeTableViewCell {
                if let data = dataModels, data.isEmpty == false {
                    //                cell.model = data[indexPath.row]
                }
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = DepositDescribeTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                if let data = dataModels, data.isEmpty == false {
                    //                cell.model = data[indexPath.row]
                }
                cell.selectionStyle = .none
                return cell
            }
        } else {
            let identifier = "QuestionCell"
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DepositQuestionTableViewCell {
                if let data = dataModels, data.isEmpty == false {
                    //                cell.model = data[indexPath.row]
                }
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = DepositQuestionTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                if let data = dataModels, data.isEmpty == false {
                    //                cell.model = data[indexPath.row]
                }
                cell.selectionStyle = .none
                return cell
            }
        }
        
    }
}
