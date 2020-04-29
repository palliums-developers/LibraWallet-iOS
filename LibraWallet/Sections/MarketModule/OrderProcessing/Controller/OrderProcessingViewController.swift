//
//  OrderProcessingViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView
class OrderProcessingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("SupportCoinViewController销毁了")
    }
    //网络请求、数据模型
    lazy var dataModel: OrderProcessingModel = {
        let model = OrderProcessingModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: OrderProcessingTableViewManager = {
        let manager = OrderProcessingTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : OrderProcessingView = {
        let view = OrderProcessingView.init()
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
//        detailView.tableView.mj_header.beginRefreshing()
        dataModel.getAllProcessingOrders(address: walletAddress, version: "")
    }
    @objc func getMoreReceive() {
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
//        detailView.tableView.mj_footer.beginRefreshing()
        if let version = self.tableViewManager.dataModel?.last?.version {
            dataModel.getAllProcessingOrders(address: walletAddress, version: version)
        } else {
            detailView.tableView.mj_footer?.endRefreshing()
        }
    }
    var myContext = 0
    var firstIn: Bool = true
    var wallet: LibraWalletManager?
    var cancelIndexPath: IndexPath?
}
extension OrderProcessingViewController: OrderProcessingTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: MarketOrderDataModel) {
        let vc = OrderDetailViewController()
        vc.headerData = model
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func cancelOrder(indexPath: IndexPath, model: MarketOrderDataModel) {
        let alertView = UIAlertController.init(title: localLanguage(keyString: "wallet_market_order_center_cancel_order_alert_title"),
                                               message: localLanguage(keyString: "wallet_market_order_center_cancel_order_alert_content"),
                                               preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_cancel_button_title"), style: .default) { okAction in
        }
        let confirmAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_confirm_button_title"), style: .default) { okAction in
            self.cancelIndexPath = indexPath
            self.showPasswordAlert(model: model)
        }
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        self.present(alertView, animated: true, completion: nil)
    }
    func showPasswordAlert(model: MarketOrderDataModel) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show()
            guard let walletAddress = self?.wallet?.walletAddress else {
                #warning("缺少错误提示")
                return
            }
            self?.dataModel.cancelTransaction(sendAddress: walletAddress,
                                             fee: 0,
                                             mnemonic: mnemonic,
                                             contact: ViolasMainContract,
                                             version: model.version ?? "",
                                             tokenIndex: model.tokenGive ?? "")
        }) { [weak self] (errorContent) in
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }

}
extension OrderProcessingViewController {
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
                self.detailView.toastView?.hide()
                self.detailView.makeToast(error.localizedDescription, position: .center)
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
            self.detailView.makeToast(error.localizedDescription, position: .center)

            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetAllProcessingOrderOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [MarketOrderDataModel] {
            //                self.detailView.tableView.reloadData()
                self.tableViewManager.dataModel = tempData
                           
                self.detailView.tableView.reloadData()
                self.detailView.tableView.mj_header?.endRefreshing()
            }
        } else if type == "GetAllProcessingOrderMore" {
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
        } else {
            self.detailView.toastView?.hide()
            if let indexPath = self.cancelIndexPath {
                self.tableViewManager.dataModel?.remove(at: indexPath.row)
                self.detailView.tableView.beginUpdates()
                self.detailView.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.detailView.tableView.endUpdates()
            } else {
                self.refreshReceive()
            }
            self.detailView.makeToast(localLanguage(keyString: "wallet_market_alert_cancel_order_success_title"), position: .center)
        }
        self.detailView.hideToastActivity()
    }
}
extension OrderProcessingViewController: JXSegmentedListContainerViewListDelegate {
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
        dataModel.getAllProcessingOrders(address: walletAddress, version: "")
        firstIn = false
    }
    /// 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
