//
//  OrderDoneViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/17.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView
import MJRefresh
class OrderDoneViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //网络请求、数据模型
    lazy var dataModel: OrderDoneModel = {
        let model = OrderDoneModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: OrderDoneTableViewManager = {
        let manager = OrderDoneTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : OrderDoneView = {
        let view = OrderDoneView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshReceive))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreReceive))
        return view
    }()
    @objc func refreshReceive() {
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        detailView.tableView.mj_footer?.resetNoMoreData()
        dataModel.getAllDoneOrder(address: walletAddress, version: "")
    }
    @objc func getMoreReceive() {
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        if let version = self.tableViewManager.dataModel?.last?.version {
            dataModel.getAllDoneOrder(address: walletAddress, version: version)
        } else {
            detailView.tableView.mj_footer?.endRefreshing()
        }
    }
    var myContext = 0
    var firstIn: Bool = true
    var wallet: LibraWalletManager?
}
extension OrderDoneViewController: OrderDoneTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: MarketOrderDataModel) {
        let vc = OrderDetailViewController()
        vc.headerData = model
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension OrderDoneViewController {
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
            return
        }
        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
            return
        }
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletTokenExpired).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
                self.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据返回状态异常
            }
            self.detailView.hideToastActivity()
            self.detailView.tableView.mj_header?.endRefreshing()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetAllDoneOrderOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [MarketOrderDataModel] {
            //                self.detailView.tableView.reloadData()
                self.tableViewManager.dataModel = tempData
                           
                self.detailView.tableView.reloadData()
                self.detailView.tableView.mj_header?.endRefreshing()
            }
        } else {
            guard let tempData = jsonData.value(forKey: "data") as? [MarketOrderDataModel] else {
                return
            }
            if let oldData = self.tableViewManager.dataModel, oldData.isEmpty == false {
                let tempArray = NSMutableArray.init(array: oldData)
                let insertIndexPath = NSMutableArray()
                for index in 0..<tempData.count {
                    let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                    insertIndexPath.add(indexPath)
                }
                tempArray.addObjects(from: tempData)
                self.tableViewManager.dataModel = tempArray as? [MarketOrderDataModel]
                self.detailView.tableView.beginUpdates()
                self.detailView.tableView.insertRows(at: insertIndexPath as! [IndexPath], with: UITableView.RowAnimation.bottom)
                self.detailView.tableView.endUpdates()
            } else {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
            self.detailView.tableView.mj_footer?.endRefreshing()
        }
        self.detailView.hideToastActivity()
    }
}
extension OrderDoneViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.detailView
    }
    /// 可选实现，列表显示的时候调用
    func listDidAppear() {
        //防止重复加载数据
        guard firstIn == true else {
            return
        }
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        self.detailView.makeToastActivity(.center)
        dataModel.getAllDoneOrder(address: walletAddress, version: "")
        firstIn = false
    }
    /// 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
