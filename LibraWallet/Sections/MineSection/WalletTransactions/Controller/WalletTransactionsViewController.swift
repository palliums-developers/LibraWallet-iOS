//
//  WalletTransactionsViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class WalletTransactionsViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_transactions_navigation_title")
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
        switch self.wallet?.walletType {
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
    var wallet: LibraWalletManager? {
        didSet {
            self.tableViewManager.transactionType = wallet?.walletType
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
    func transactionRequest(refresh: Bool) {
        let requestState = refresh == true ? 0:1
        switch self.wallet?.walletType {
        case .Libra:
            dataModel.getLibraTransactionHistory(address: (wallet?.walletAddress)!, page: dataOffset, pageSize: 10, requestStatus: requestState)
            break
        case .Violas:
            dataModel.getViolasTransactionList(address: (wallet?.walletAddress)!, page: dataOffset, pageSize: 10, contract: "", requestStatus: requestState)
            break
        case .BTC:
            dataModel.getBTCTransactionHistory(address: (wallet?.walletAddress)!, page: dataOffset + 1, pageSize: 10, requestStatus: requestState)
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
                    switch self?.wallet?.walletType {
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
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription, position: .center)
                }
                self?.detailView.hideToastActivity()
                self?.endLoading()
    //            self.endLoading(animated: false, error: error, completion: nil)
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "BTCTransactionHistoryOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [BTCTransaction] else {
                    return
                }
                self?.tableViewManager.btcTransactions = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "BTCTransactionHistoryMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [BTCTransaction] else {
                    return
                }
                if let oldData = self?.tableViewManager.btcTransactions, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()

                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: 0, section: oldData.count + index)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.btcTransactions = tempArray as? [BTCTransaction]
                    self?.detailView.tableView.beginUpdates()
                    for index in 0..<tempData.count {
                        self?.detailView.tableView.insertSections(IndexSet.init(integer: oldData.count + index), with: UITableView.RowAnimation.bottom)
                    }
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.btcTransactions = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            } else if type == "ViolasTransactionHistoryOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [ViolasDataModel] else {
                    return
                }
    //            self.tableViewManager.tokenName = "vtoken"
                self?.tableViewManager.violasTransactions = tempData
                self?.detailView.tableView.reloadData()
            } else if type == "ViolasTransactionHistoryMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [ViolasDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.violasTransactions, oldData.isEmpty == false {
                    let tempArray = NSMutableArray.init(array: oldData)
                    var insertIndexPath = [IndexPath]()

                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: 0, section: oldData.count + index)
                        insertIndexPath.append(indexPath)
                    }
                    tempArray.addObjects(from: tempData)
                    self?.tableViewManager.tokenName = "vtoken"
                    self?.tableViewManager.violasTransactions = tempArray as? [ViolasDataModel]
                    self?.detailView.tableView.beginUpdates()
                    for index in 0..<tempData.count {
                        self?.detailView.tableView.insertSections(IndexSet.init(integer: oldData.count + index), with: UITableView.RowAnimation.bottom)
                    }
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.tokenName = "vtoken"
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
    //            guard let tempData = jsonData.value(forKey: "data") as? [LibraDataModel] else {
    //                return
    //            }
    //            if let oldData = self.tableViewManager.violasTransactions, oldData.isEmpty == false {
    //                let tempArray = NSMutableArray.init(array: oldData)
    //                var insertIndexPath = [IndexPath]()
    //
    //                for index in 0..<tempData.count {
    //                    let indexPath = IndexPath.init(row: 0, section: oldData.count + index)
    //                    insertIndexPath.append(indexPath)
    //
    //                }
    //                tempArray.addObjects(from: tempData)
    //                self.tableViewManager.libraTransactions = tempArray as? [LibraDataModel]
    //                self.detailView.tableView.beginUpdates()
    //                for index in 0..<tempData.count {
    //                    self.detailView.tableView.insertSections(IndexSet.init(integer: oldData.count + index), with: UITableView.RowAnimation.bottom)
    //                }
    //                self.detailView.tableView.endUpdates()
    //            } else {
    //                self.tableViewManager.libraTransactions = tempData
    //                self.detailView.tableView.reloadData()
    //            }
    //            self.detailView.tableView.mj_footer.endRefreshing()
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
            self?.endLoading()
        })
    }
}
extension WalletTransactionsViewController: WalletTransactionsTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
        switch self.wallet?.walletType {
        case .BTC:
            print("123")
            let vc = TransactionDetailWebViewController()
            vc.requestURL = "https://live.blockcypher.com/btc-testnet/tx/\(address)"
            self.navigationController?.pushViewController(vc, animated: true)
        case .Libra:
            print("123")
            let vc = TransactionDetailWebViewController()
            vc.requestURL = address
            self.navigationController?.pushViewController(vc, animated: true)
        case .Violas:
            print("123")
        case .none:
            print("钱包类型异常")
        }
    }
}
