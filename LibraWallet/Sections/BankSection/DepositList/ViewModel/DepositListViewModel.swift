//
//  DepositListViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import StatefulViewController
import DropDownMenuKit

enum ViewRequestAnimation {
    case showToast
    case hideToast
    case startHeaderRefresh
    case endHeaderRefresh
    case startFooterRefresh
    case endFooterRefresh
    case endFooterWithoutData
    case startToast(tag: Int)
    case endToast(tag: Int)
    case reloadTableView
    case insertRowsInTableView(indexPaths: [IndexPath])
    case reloadCell(indexPath: IndexPath)
}
protocol DepositListViewModelDelegate: NSObjectProtocol {
    func requestAnimation(type: ViewRequestAnimation)
}
class DepositListViewModel: NSObject {
    weak var delegate: DepositListViewModelDelegate?
    override init() {
        super.init()
    }
    convenience init(handleView: DepositListView) {
        self.init()
        self.view = handleView
        handleView.delegate = self
        handleView.tableView.delegate = self.tableViewManager
        handleView.tableView.dataSource = self.tableViewManager
        handleView.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
        handleView.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        self.setEmptyView()
        self.setPlaceholderView()
    }
    deinit {
        print("DepositListViewModel销毁了")
    }
    /// 管理view
    var view: DepositListView?
    /// 网络请求、数据模型
    lazy var dataModel: DepositListModel = {
        let model = DepositListModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: DepositListTableViewManager = {
        let manager = DepositListTableViewManager.init()
        return manager
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    /// 页数
    private var dataOffset: Int = 0
    /// 请求状态
    private var requestOrderStatus: Int = 999999
    /// 请求币种
    private var requestOrderCurrency: String = ""
    var supprotTokens: [BankDepositMarketDataModel]?
    lazy var dropMenu: DropDownMenu = {
        let menu = DropDownMenu(frame: self.view!.bounds)
        menu.delegate = self
        menu.container = view
        return menu
    }()
}
extension DepositListViewModel: DropDownMenuDelegate {
    func didTapInDropDownMenuBackground(_ menu: DropDownMenu) {
        dropMenu.hide()
    }
}
extension DepositListViewModel: StatefulViewController {
    var backingView: UIView {
        get {
            return self.view!
        }
    }
    func setEmptyView() {
        //空数据
        emptyView = EmptyDataPlaceholderView.init()
    }
    // 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "data_empty"
            empty.tipString = localLanguage(keyString: "wallet_deposit_orders_empty_title")
            empty.edge = UIEdgeInsets.init(top: 29, left: 0, bottom: 0, right: 0)
        }
    }
    // 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        self.view?.makeToastActivity(.center)
        
        self.transactionRequest(refresh: true)
    }
    func hasContent() -> Bool {
        if let models = self.tableViewManager.dataModels, models.isEmpty == false {
            return true
        } else {
            return false
        }
    }
}
// MARK: - 网络请求
extension DepositListViewModel {
    @objc func refreshData() {
        dataOffset = 0
        view?.tableView.mj_footer?.resetNoMoreData()
        transactionRequest(refresh: true)
    }
    @objc func getMoreData() {
        dataOffset += 10
        transactionRequest(refresh: false)
    }
    func transactionRequest(refresh: Bool) {
        let requestState = refresh == true ? 0:1
        self.dataModel.getDepositList(address: WalletManager.shared.violasAddress!,
                                      currency: requestOrderCurrency,
                                      status: requestOrderStatus,
                                      page: self.dataOffset,
                                      limit: 10,
                                      requestStatus: requestState)
    }
}
// MARK: - 逻辑处理
extension DepositListViewModel: DepositListViewDelegate {
    func filterOrdersWithCurrency(button: UIButton) {
        guard let tokens = self.supprotTokens else {
            return
        }
        var tempContent = tokens.map {
            $0.token_module ?? ""
        }
        tempContent.insert(localLanguage(keyString: "wallet_deposit_list_order_token_select_title"), at: 0)
        let view = BankStatusSelectView.init(data: tempContent, showLeft: true) { [weak self] item in
            self?.view?.orderTokenSelectButton.setTitle(item, for: UIControl.State.normal)
            self?.view?.orderTokenSelectButton.imagePosition(at: .right, space: 5, imageViewSize: CGSize.init(width: 10, height: 10))
            self?.refreshView()
        }
        view.show()
    }
    func filterOrdersWithStatus(button: UIButton) {
        let datas = [localLanguage(keyString: "wallet_deposit_list_order_status_title"),
                     localLanguage(keyString: "wallet_deposit_list_order_status_deposit_finish_title"),
                     localLanguage(keyString: "wallet_deposit_list_order_status_withdrawal_finish_title"),
                     localLanguage(keyString: "wallet_deposit_list_order_status_deposit_failed_title"),
                     localLanguage(keyString: "wallet_deposit_list_order_status_withdrawal_failed_title")]
        let view = BankStatusSelectView.init(data: datas, showLeft: false) { [weak self] item in
            self?.view?.orderStateButton.setTitle(item, for: UIControl.State.normal)
            self?.view?.orderStateButton.imagePosition(at: .right, space: 5, imageViewSize: CGSize.init(width: 10, height: 10))
            self?.refreshView()
        }
        view.show()
    }
    func refreshView() {
        //999999: 默认 0（已存款），1（已提取），-1（提取失败），-2（存款失败）
        var tempStatus = 999999
        if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_deposit_list_order_status_deposit_finish_title") {
            tempStatus = 0
        } else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_deposit_list_order_status_withdrawal_finish_title") {
            tempStatus = 1
        } else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_deposit_list_order_status_withdrawal_failed_title") {
            tempStatus = -1
        } else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_deposit_list_order_status_deposit_failed_title") {
            tempStatus = -2
        }
        var tempCurrency = ""
        if self.view?.orderTokenSelectButton.titleLabel?.text == localLanguage(keyString: "wallet_deposit_list_order_token_select_title") {
            tempCurrency = ""
        } else {
            tempCurrency = self.view?.orderTokenSelectButton.titleLabel?.text ?? ""
        }
        self.requestOrderStatus = tempStatus
        self.requestOrderCurrency = tempCurrency
        print("request=\(tempCurrency)-\(tempStatus)")
        self.view?.tableView.mj_header?.beginRefreshing()
    }
}
// MARK: - 网络请求
extension DepositListViewModel {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.view?.hideToastActivity()
                //                self?.view?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.view?.hideToastActivity()
                if self?.view?.tableView.mj_header?.isRefreshing == true {
                    self?.view?.tableView.mj_header?.endRefreshing()
                }
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshing()
                    }
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshing()
                    }
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshing()
                    }
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshing()
                    }
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.tableViewManager.dataModels?.removeAll()
                    self?.view?.tableView.reloadData()
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                } else {
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshing()
                    }
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                }
                self?.endLoading()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetBankDepositListOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositListMainDataModel] else {
                    return
                }
                self?.tableViewManager.dataModels = tempData
                self?.view?.tableView.reloadData()
                self?.view?.tableView.mj_header?.endRefreshing()
            } else if type == "GetBankDepositListMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositListMainDataModel] else {
                    return
                }
                if let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false {
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<tempData.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    self?.tableViewManager.dataModels = (oldData + tempData)
                    self?.view?.tableView.beginUpdates()
                    self?.view?.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.view?.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData
                    self?.view?.tableView.reloadData()
                }
                self?.view?.tableView.mj_footer?.endRefreshing()
            }
            self?.view?.hideToastActivity()
            self?.endLoading()
        })
    }
}
