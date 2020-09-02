//
//  DepositOrdersViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import StatefulViewController

class DepositOrdersViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        self.view.addSubview(self.detailView)
        // 添加导航栏按钮
        self.addNavigationRightBar()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_transactions_navigation_title")
        self.initKVO()
        //设置空数据页面
        self.setEmptyView()
        //设置默认页面（无数据、无网络）
        self.setPlaceholderView()
        
        
        self.requestData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
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
        
        transactionRequest(refresh: true)
    }
    override func hasContent() -> Bool {
        if let models = self.tableViewManager.dataModels, models.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    deinit {
        print("DepositOrdersViewController销毁了")
    }
    // 网络请求、数据模型
    lazy var dataModel: DepositOrdersModel = {
        let model = DepositOrdersModel.init()
        return model
    }()
    // tableView管理类
    lazy var tableViewManager: DepositOrdersTableViewManager = {
        let manager = DepositOrdersTableViewManager.init()
        return manager
    }()
    // 子View
    lazy var detailView : DepositOrdersView = {
        let view = DepositOrdersView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    var observer: NSKeyValueObservation?
    var dataOffset: Int = 0
    @objc func refreshData() {
        dataOffset = 0
        detailView.tableView.mj_footer?.resetNoMoreData()
        transactionRequest(refresh: true)
    }
    @objc func getMoreData() {
        dataOffset += 10
        transactionRequest(refresh: false)
    }
    var firstIn: Bool = true
    var requestType: String?
    /// 二维码扫描按钮
    lazy var depositOrderListButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "deposit_order_list"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(checkOrder), for: .touchUpInside)
        return button
    }()
    func transactionRequest(refresh: Bool) {
        let requestState = refresh == true ? 0:1
        self.dataModel.getDepositTransactions(address: WalletManager.shared.violasAddress!, page: self.dataOffset, limit: 10, requestStatus: requestState)
    }
}
//MARK: - 导航栏添加按钮
extension DepositOrdersViewController {
    func addNavigationRightBar() {
        let scanView = UIBarButtonItem(customView: depositOrderListButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    @objc func checkOrder() {
        let vc = DepositListViewController.init()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension DepositOrdersViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.view?.hideToastActivity()
                //                self?.view?.toastView?.hide(tag: 99)
                //                self?.view?.toastView?.hide(tag: 299)
                //                self?.view?.toastView?.hide(tag: 399)
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                } else {
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                }
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetBankDepositTransactionsOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositOrdersMainDataModel] else {
                    return
                }
                self?.tableViewManager.dataModels = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "GetBankDepositTransactionsMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositOrdersMainDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.dataModels = tempArray as? [DepositOrdersMainDataModel]
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            }
            self?.detailView.tableView.mj_footer?.endRefreshing()
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
            self?.endLoading()
        })
    }
}
//extension DepositOrdersViewController: WalletTransactionsTableViewManagerDelegate {
//    func tableViewDidSelectRowAtIndexPath<T>(indexPath: IndexPath, model: T) {
//        let vc = TransactionDetailViewController()
//        //            vc.requestURL = address
//        vc.tokenAddress = self.wallet?.tokenAddress
//        switch self.wallet?.tokenType {
//        case .BTC:
//            print("BTC")
//            vc.btcTransaction = model as? TrezorBTCTransactionDataModel
//        case .Libra:
//            print("Libra")
//            vc.libraTransaction = model as? LibraDataModel
//
//        case .Violas:
//            print("Violas")
//            vc.violasTransaction = model as? ViolasDataModel
//        case .none:
//            print("钱包类型异常")
//        }
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    //    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
//    //        switch self.wallet?.tokenType {
//    //        case .BTC:
//    //            print("BTC")
//    //            let vc = TransactionDetailWebViewController()
//    //            vc.requestURL = "https://live.blockcypher.com/btc-testnet/tx/\(address)"
//    //            self.navigationController?.pushViewController(vc, animated: true)
//    //        case .Libra:
//    //            print("Libra")
//    //            let vc = TransactionDetailWebViewController()
//    //            vc.requestURL = address
//    //            self.navigationController?.pushViewController(vc, animated: true)
//    //        case .Violas:
//    //            print("Violas")
//    //            let vc = TransactionDetailViewController()
//    ////            vc.requestURL = address
//    //            self.navigationController?.pushViewController(vc, animated: true)
//    //        case .none:
//    //            print("钱包类型异常")
//    //        }
//    //    }
//    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, violasTransaction: ViolasDataModel) {
//
//    }
//}
