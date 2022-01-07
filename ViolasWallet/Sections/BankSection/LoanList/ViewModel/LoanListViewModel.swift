//
//  LoanListViewModel.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import StatefulViewController

class LoanListViewModel: NSObject {
    override init() {
        super.init()
    }
    convenience init(handleView: LoanListView) {
        self.init()
        self.view = handleView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanListViewModel销毁了")
    }
    var view: LoanListView? {
        didSet {
            view?.delegate = self
            view?.tableView.delegate = self.tableViewManager
            view?.tableView.dataSource = self.tableViewManager
            view?.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
            view?.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
            self.setEmptyView()
            self.setPlaceholderView()
            view?.tableView.mj_header?.beginRefreshing()
        }
    }
    /// 网络请求、数据模型
    private lazy var dataModel: LoanListModel = {
        let model = LoanListModel.init()
        return model
    }()
    /// tableView管理类
    private lazy var tableViewManager: LoanListTableViewManager = {
        let manager = LoanListTableViewManager.init()
        //        manager.delegate = self
        return manager
    }()
    private var dataOffset: Int = 0
    @objc func refreshData() {
        dataOffset = 0
        view?.tableView.mj_footer?.resetNoMoreData()
        transactionRequest(refresh: true)
    }
    @objc func getMoreData() {
        dataOffset += 10
        transactionRequest(refresh: false)
    }
    private var requestOrderStatus: Int = 999999
    private var requestOrderCurrency: String = ""
    private var supprotTokens = [BankDepositMarketDataModel]()
//    var controllerState: LoanControllerState = .normal {
//        didSet {
//            switch controllerState {
//            case .normal:
//                if oldValue == .headerRefresh {
//
//                } else if oldValue == .footerRefresh {
//
//                }
//                print("")
//            case .headerRefresh:
//                print("")
//            case .footerRefresh:
//                print("")
//            default:
//                print("")
//            }
//        }
//    }
//    enum LoanControllerState {
//        case normal
//        case headerRefresh
//        case footerRefresh
//    }
}
extension LoanListViewModel: StatefulViewController {
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
// MARK: - 网络请求逻辑处理
extension LoanListViewModel: LoanListViewDelegate {
    func filterOrdersWithCurrency(button: UIButton) {
        var tempTokens = [BankDepositMarketDataModel]()
        if self.supprotTokens.isEmpty == false {
            tempTokens = self.supprotTokens
            showStatusView(tokens: tempTokens)
        } else {
            self.view?.makeToastActivity(.center)
            self.dataModel.getLoanMarket(requestStatus: 0) { [weak self] (result) in
                self?.view?.hideToastActivity()
                switch result {
                case let .success(models):
                    self?.supprotTokens = models
                    tempTokens = models
                    self?.showStatusView(tokens: tempTokens)
                case let .failure(error):
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription, position: .center)
                }
            }
        }

    }
    func showStatusView(tokens: [BankDepositMarketDataModel]) {
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
                     localLanguage(keyString: "wallet_bank_loan_detail_loan_status_loaned_title"),
                     localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_deposited_title"),
                     localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_status_title"),
                     localLanguage(keyString: "wallet_bank_loan_detail_loan_status_failed_title"),
                     localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_failed_title")]
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
        if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_bank_loan_detail_loan_status_loaned_title") {
            tempStatus = 0
        } else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_deposited_title") {
            tempStatus = 1
        }  else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_status_title") {
            tempStatus = 2
        } else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_bank_loan_detail_loan_status_failed_title") {
            tempStatus = -1
        } else if self.view?.orderStateButton.titleLabel?.text == localLanguage(keyString: "wallet_bank_loan_detail_deposit_status_failed_title") {
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
        print("request=\(tempCurrency)(-)\(tempStatus)")
        self.view?.tableView.mj_header?.beginRefreshing()
    }
}
// MARK: - 网络请求
extension LoanListViewModel {
    func transactionRequest(refresh: Bool) {
        self.dataModel.getLoanList(address: Wallet.shared.violasAddress!, currency: requestOrderCurrency, status: requestOrderStatus, page: self.dataOffset, limit: 10, refresh: refresh) { [weak self] (result) in
            switch result {
            case let .success(models):
                if refresh == true {
                    guard models.isEmpty == false else {
                        self?.tableViewManager.dataModels?.removeAll()
                        self?.view?.tableView.reloadData()
                        self?.view?.tableView.mj_header?.endRefreshing()
                        self?.endLoading()
                        return
                    }
                    self?.view?.hideToastActivity()
                    // 下拉刷新
                    self?.tableViewManager.dataModels = models
                    self?.view?.tableView.reloadData()
                    self?.view?.tableView.mj_header?.endRefreshing()
                } else {
                    // 上拉刷新
                    guard models.isEmpty == false else {
                        self?.view?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        return
                    }
                    guard let oldData = self?.tableViewManager.dataModels, oldData.isEmpty == false else {
                        self?.tableViewManager.dataModels = models
                        self?.view?.tableView.reloadData()
                        return
                    }
                    var insertIndexPath = [IndexPath]()
                    for index in 0..<models.count {
                        let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                        insertIndexPath.append(indexPath)
                    }
                    self?.tableViewManager.dataModels = oldData + models
                    self?.view?.tableView.beginUpdates()
                    self?.view?.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.view?.tableView.endUpdates()
                    self?.view?.tableView.mj_footer?.endRefreshing()
                }
            case let .failure(error):
                self?.view?.hideToastActivity()
                if refresh == true {
                    if self?.view?.tableView.mj_header?.isRefreshing == true {
                        self?.view?.tableView.mj_header?.endRefreshing()
                    }
                } else {
                    if self?.view?.tableView.mj_footer?.isRefreshing == true {
                        self?.view?.tableView.mj_footer?.endRefreshing()
                    }
                }
                self?.handleError(requestType: "type", error: error)
            }
            self?.endLoading()
        }
    }
    func handleError(requestType: String, error: LibraWalletError) {
        switch error {
        case .WalletRequest(reason: .networkInvalid):
            // 网络无法访问
            print(error.localizedDescription)
        case .WalletRequest(reason: .walletVersionExpired):
            // 版本太久
            print(error.localizedDescription)
        case .WalletRequest(reason: .parseJsonError):
            // 解析失败
            print(error.localizedDescription)
        case .WalletRequest(reason: .dataCodeInvalid):
            // 数据状态异常
            print(error.localizedDescription)
        default:
            // 其他错误
            print(error.localizedDescription)
        }
        self.view?.makeToast(error.localizedDescription, position: .center)
    }
}
