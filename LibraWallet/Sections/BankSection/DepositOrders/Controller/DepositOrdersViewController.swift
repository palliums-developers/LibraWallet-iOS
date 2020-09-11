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
        // 设置标题
        self.title = localLanguage(keyString: "wallet_bank_deposit_orders_navigationbar_title")
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
    // 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "data_empty"
            empty.tipString = localLanguage(keyString: "wallet_deposit_orders_empty_title")
        }
    }
    // 网络请求
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
    /// 网络请求、数据模型
    lazy var dataModel: DepositOrdersModel = {
        let model = DepositOrdersModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: DepositOrdersTableViewManager = {
        let manager = DepositOrdersTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : DepositOrdersView = {
        let view = DepositOrdersView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        return view
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    /// 页数
    var dataOffset: Int = 0

    /// 订单列表
    lazy var depositOrderListButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "deposit_order_list"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(checkOrder), for: .touchUpInside)
        return button
    }()

    var supprotTokens: [BankDepositMarketDataModel]?
    var withdrawClosure: ((DepositOrderWithdrawMainDataModel) -> Void)?
}

// MARK: - 导航栏添加按钮
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
        vc.supprotTokens = self.supprotTokens
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 网络请求
extension DepositOrdersViewController {
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
        self.dataModel.getDepositTransactions(address: WalletManager.shared.violasAddress!, page: self.dataOffset, limit: 10, requestStatus: requestState)
    }
}

// MARK: - TableViewManager代理
extension DepositOrdersViewController: DepositOrdersTableViewManagerDelegate {
    func cellDelegate(cell: DepositOrdersTableViewCell) {
        cell.delegate = self
    }
}

extension DepositOrdersViewController: DepositOrdersTableViewCellDelegate {
    func withdraw(indexPath: IndexPath, model: DepositOrdersMainDataModel) {
        print(indexPath.row)
        self.detailView.toastView?.show(tag: 99)
        self.dataModel.getDepositItemWithdrawDetail(address: WalletManager.shared.violasAddress!,
                                                    itemID: model.id ?? "")
        self.withdrawClosure = { model in
            let alert = RedeemAlert.init()
            alert.model = model
            alert.withdrawClosure = { [weak self] amount in
                WalletManager.unlockWallet(successful: { [weak self] (mnemonic) in
                    self?.detailView.toastView?.show(tag: 99)
                    self?.dataModel.sendWithdrawTransaction(sendAddress: WalletManager.shared.violasAddress!,
                                                        amount: amount,
                                                        fee: 10,
                                                        mnemonic: mnemonic,
                                                        module: model.token_module ?? "",
                                                        feeModule: model.token_module ?? "")
                }) { [weak self] (errorContent) in
                    guard errorContent != "Cancel" else {
                        self?.detailView.toastView?.hide(tag: 99)
                        return
                    }
                    self?.detailView.makeToast(errorContent, position: .center)
                }
            }
            alert.show(tag: 199)
        }
    }
}

// MARK: - 网络请求处理中心
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
                self?.detailView.hideToastActivity()
                self?.detailView.toastView?.hide(tag: 99)
                if self?.detailView.tableView.mj_header?.isRefreshing == true {
                    self?.detailView.tableView.mj_header?.endRefreshing()
                }
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                } else {
                    if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                        self?.detailView.tableView.mj_footer?.endRefreshing()
                    }
                    self?.detailView.makeToast(error.localizedDescription, position: .center)
                }
                self?.endLoading()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetBankDepositTransactionsOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositOrdersMainDataModel] else {
                    return
                }
                self?.tableViewManager.dataModels = tempData
                self?.detailView.tableView.reloadData()
                self?.detailView.tableView.mj_header?.endRefreshing()
                self?.detailView.hideToastActivity()
            } else if type == "GetBankDepositTransactionsMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositOrdersMainDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false {
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    self?.tableViewManager.dataModels = (oldData + tempData)
                    self?.detailView.tableView.beginUpdates()
                    self?.detailView.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
                self?.detailView.hideToastActivity()
            } else if type == "GetDepositItemWithdrawDetail" {
                self?.detailView.toastView?.hide(tag: 99)
                guard let tempData = dataDic.value(forKey: "data") as? DepositOrderWithdrawMainDataModel else {
                    return
                }
                if let action = self?.withdrawClosure {
                    action(tempData)
                }
            } else if type == "SendViolasBankWithdrawTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
            }
            self?.endLoading()
        })
    }
}
