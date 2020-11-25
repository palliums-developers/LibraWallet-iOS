//
//  PhoneAreaTableViewManager.swift
//  HKWallet
//
//  Created by palliums on 2019/8/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AreaTableViewManagerDelegate: NSObjectProtocol {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: PhoneAreaDataModel)
}
class PhoneAreaTableViewManager: NSObject {
    weak var delegate: AreaTableViewManagerDelegate?
    var dataModel: NSArray? {
        didSet {
            letterArray = dataModel?.firstObject as? [String]
            dataArray = dataModel?.lastObject as? [[PhoneAreaDataModel]]
        }
    }
    private var letterArray: [String]?
    private var dataArray: [[PhoneAreaDataModel]]?
    var hideAreaCode: Bool?
    deinit {
        print("PhoneAreaTableViewManager销毁了")
    }
}
extension PhoneAreaTableViewManager: UITableViewDelegate {
    //cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let data = dataArray, data.isEmpty == false {
            let tempArray = data[indexPath.section]
            self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: tempArray[indexPath.row])
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letterArray?[section] ?? ""
    }
}
extension PhoneAreaTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?[section].count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray?.count ?? 0
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return letterArray
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var tpIndex:Int = 0
        //遍历索引值
        for character in letterArray ?? [String]() {
            //判断索引值和组名称相等，返回组坐标
            if character == title {
                return tpIndex
            }
            tpIndex += 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellNormal"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PhoneAreaTableViewCell {
            if let data = dataArray, data.isEmpty == false {
                let tempArray = data[indexPath.section]
                cell.hideAreaCode = self.hideAreaCode
                cell.model = tempArray[indexPath.row]
            }
            return cell
        } else {
            let cell = PhoneAreaTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataArray, data.isEmpty == false {
                let tempArray = data[indexPath.section]
                cell.hideAreaCode = self.hideAreaCode
                cell.model = tempArray[indexPath.row]
            }
            return cell
        }
    }
}
