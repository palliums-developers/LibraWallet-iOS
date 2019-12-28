//
//  OrderDetailViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class OrderDetailViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "订单详情")
        // 加载子View
        self.view.addSubview(self.detailView)
        //设置空数据页面
        self.setEmptyView()
        // 初始化KVO
        self.initKVO()
        //设置默认页面（无数据、无网络）
        self.setPlaceholderView()
        //网络请求
        self.requestData()
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
        print("OrderDetailViewController销毁了")
    }
    //MARK: - 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "transaction_list_empty_default"
            empty.tipString = localLanguage(keyString: "wallet_transactions_empty_default_title")
        }
    }
    //MARK: - 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        
        self.detailView.makeToastActivity(.center)
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        dataModel.getOrderDetail(address: walletAddress,
                                 version: self.headerData?.version ?? "",
                                 page: dataOffset,
                                 requestStatus: 0)
    }
    override func hasContent() -> Bool {
        if let models = self.tableViewManager.dataModel, models.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    //网络请求、数据模型
    lazy var dataModel: OrderDetailModel = {
        let model = OrderDetailModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: OrderDetailTableViewManager = {
        let manager = OrderDetailTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : OrderDetailView = {
        let view = OrderDetailView.init()
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
        dataOffset = 1
        detailView.tableView.mj_footer.resetNoMoreData()
//        detailView.tableView.mj_header.beginRefreshing()
        dataModel.getOrderDetail(address: walletAddress,
                                 version: self.headerData?.version ?? "",
                                 page: dataOffset,
                                 requestStatus: 0)
    }
    @objc func getMoreReceive() {
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        dataOffset += 1
//        detailView.tableView.mj_footer.beginRefreshing()
        dataModel.getOrderDetail(address: walletAddress,
                                 version: self.headerData?.version ?? "",
                                 page: dataOffset,
                                 requestStatus: 1)
    }
    var dataOffset: Int = 1
    var myContext = 0
    var headerData: MarketOrderDataModel? {
        didSet {
            self.detailView.headerView.model = headerData
            self.tableViewManager.priceModel = headerData
        }
    }
    var wallet: LibraWalletManager?
}
extension OrderDetailViewController: OrderDetailTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
    }
}
extension OrderDetailViewController {
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
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
                self.detailView.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据返回状态异常
            }
            self.detailView.hideToastActivity()
            self.detailView.tableView.mj_header.endRefreshing()
//            self.endLoading()

            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "OrderDetailOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [OrderDetailDataModel] {
            //                self.detailView.tableView.reloadData()
                self.tableViewManager.dataModel = tempData
                           
                self.detailView.tableView.reloadData()
            }
            self.detailView.tableView.mj_header.endRefreshing()
        } else {
            guard let tempData = jsonData.value(forKey: "data") as? [OrderDetailDataModel] else {
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
                self.tableViewManager.dataModel = tempArray as? [OrderDetailDataModel]
                self.detailView.tableView.beginUpdates()
                self.detailView.tableView.insertRows(at: insertIndexPath as! [IndexPath], with: UITableView.RowAnimation.bottom)
                self.detailView.tableView.endUpdates()
            } else {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
            self.detailView.tableView.mj_footer.endRefreshing()
        }
        self.detailView.hideToastActivity()
//        self.endLoading()
    }
}
