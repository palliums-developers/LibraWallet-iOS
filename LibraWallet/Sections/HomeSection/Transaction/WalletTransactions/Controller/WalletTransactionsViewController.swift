//
//  WalletTransactionsViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView
class WalletTransactionsViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_transactions_navigation_title")
        //设置空数据页面
        self.setEmptyView()
        //设置默认页面（无数据、无网络）
        self.setPlaceholderView()
    }
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        detailView.snp.makeConstraints { (make) in
//            if #available(iOS 11.0, *) {
//                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
//            } else {
//                make.top.bottom.equalTo(self.view)
//            }
//            make.left.right.equalTo(self.view)
//        }
//    }
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
//        self.detailView.makeToastActivity(.center)
        
        transactionRequest(refresh: true)
    }
    override func hasContent() -> Bool {
        switch self.wallet?.tokenType {
        case .Libra:
            if let addresses = self.tableViewManager.libraTransactions, addresses.isEmpty == false {
                return true
            } else {
                return false
            }
        case .Violas:
            if let addresses = self.tableViewManager.violasTransactions, addresses.isEmpty == false {
                return true
            } else {
                return false
            }
        case .BTC:
            if let addresses = self.tableViewManager.btcTransactions, addresses.isEmpty == false {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    deinit {
        print("WalletTransactionsViewController销毁了")
    }
    // 网络请求、数据模型
    lazy var dataModel: WalletTransactionsModel = {
        let model = WalletTransactionsModel.init()
        return model
    }()
    // tableView管理类
    lazy var tableViewManager: WalletTransactionsTableViewManager = {
        let manager = WalletTransactionsTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    // 子View
    lazy var detailView : WalletTransactionsView = {
        let view = WalletTransactionsView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    var observer: NSKeyValueObservation?
    var wallet: Token? {
        didSet {
            self.tableViewManager.transactionType = wallet?.tokenType
        }
    }
    
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
    func transactionRequest(refresh: Bool) {
        let requestState = refresh == true ? 0:1
        switch self.wallet?.tokenType {
        case .Libra:
            dataModel.getLibraTransactionHistory(address: (wallet?.tokenAddress)!, module: wallet?.tokenModule ?? "", requestType: requestType ?? "", page: dataOffset, pageSize: 10, requestStatus: requestState)
            break
        case .Violas:
            dataModel.getViolasTransactions(address: (wallet?.tokenAddress)!, module: wallet?.tokenModule ?? "", requestType: requestType ?? "", page: dataOffset, pageSize: 10, requestStatus: requestState)
            break
        case .BTC:
            dataModel.getBTCTransactionHistory(address: (wallet?.tokenAddress)!, page: dataOffset + 1, pageSize: 10, requestStatus: requestState)
        default:
            break
        }
    }
}
extension WalletTransactionsViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.detailView.makeToast("版本太旧,请及时更新版本", position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 数据为空
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription, position: .center)
                    // 数据为空
                    if self?.detailView.tableView.mj_header?.isRefreshing == true {
                        self?.detailView.tableView.mj_header?.endRefreshing()
                    } else {
                        self?.detailView.hideToastActivity()
                    }
                    switch self?.wallet?.tokenType {
                    case .BTC:
                        self?.tableViewManager.btcTransactions?.removeAll()
                    case .Libra:
                        self?.tableViewManager.libraTransactions?.removeAll()
                    case .Violas:
                        self?.tableViewManager.violasTransactions?.removeAll()
                    case .none:
                        print("钱包类型异常")
                    }
                    self?.detailView.tableView.reloadData()
                    self?.endLoading()
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription, position: .center)
                }
                self?.detailView.hideToastActivity()
                if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                if self?.detailView.tableView.mj_header?.isRefreshing == true {
                    self?.detailView.tableView.mj_header?.endRefreshing()
                }
//                self?.endLoading(animated: true, error: nil, completion: nil)
                self?.endLoading(animated: false, error: error, completion: nil)
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "BTCTransactionHistoryOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [TrezorBTCTransactionDataModel] else {
                    return
                }
                self?.tableViewManager.btcTransactions = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "BTCTransactionHistoryMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [TrezorBTCTransactionDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.btcTransactions, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.btcTransactions = tempArray as? [TrezorBTCTransactionDataModel]
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.btcTransactions = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            } else if type == "ViolasTransactionsOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [ViolasDataModel] else {
                    return
                }
                self?.tableViewManager.violasTransactions = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "ViolasTransactionsMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [ViolasDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.violasTransactions, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.violasTransactions = tempArray as? [ViolasDataModel]
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.violasTransactions = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            } else if type == "LibraTransactionHistoryOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [LibraDataModel] else {
                   return
                }
                self?.tableViewManager.libraTransactions = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "LibraTransactionHistoryMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [LibraDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.libraTransactions, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.libraTransactions = tempArray as? [LibraDataModel]
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.libraTransactions = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
            self?.endLoading()
        })
    }
}
extension WalletTransactionsViewController: WalletTransactionsTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
        switch self.wallet?.tokenType {
        case .BTC:
            print("BTC")
            let vc = TransactionDetailWebViewController()
            vc.requestURL = "https://live.blockcypher.com/btc-testnet/tx/\(address)"
            self.navigationController?.pushViewController(vc, animated: true)
        case .Libra:
            print("Libra")
            let vc = TransactionDetailWebViewController()
            vc.requestURL = address
            self.navigationController?.pushViewController(vc, animated: true)
        case .Violas:
            print("Violas")
            let vc = TransactionDetailViewController()
//            vc.requestURL = address
            self.navigationController?.pushViewController(vc, animated: true)
        case .none:
            print("钱包类型异常")
        }
    }
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, violasTransaction: ViolasDataModel) {
        let vc = TransactionDetailViewController()
        //            vc.requestURL = address
        vc.violasTransaction = violasTransaction
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension WalletTransactionsViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.detailView
    }
    /// 可选实现，列表显示的时候调用
    func listDidAppear() {
        //防止重复加载数据
        guard firstIn == true else {
            return
        }
        if (lastState == .Loading) {return}
        startLoading ()
//        self.detailView.makeToastActivity(.center)
//        transactionRequest(refresh: true)
        self.detailView.tableView.mj_header?.beginRefreshing()
        firstIn = false
    }
    /// 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
