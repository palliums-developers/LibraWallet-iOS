//
//  DepositListViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh

class DepositListViewModel: NSObject {
    override init() {
        super.init()
    }
    deinit {
        print("DepositListViewModel销毁了")
    }
    var view: DepositListView? {
        didSet {
            view?.delegate = self
            view?.tableView.delegate = self.tableViewManager
            view?.tableView.dataSource = self.tableViewManager
            view?.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshData))
            view?.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreData))
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: DepositListModel = {
        let model = DepositListModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: DepositListTableViewManager = {
        let manager = DepositListTableViewManager.init()
        //        manager.delegate = self
        return manager
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var dataOffset: Int = 0
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
    private var requestOrderStatus: Int = 999999
    private var requestOrderCurrency: String = ""
    var supprotTokens: [BankDepositMarketDataModel]?
}
// MARK: - 逻辑处理
extension DepositListViewModel: DepositListViewDelegate {
    func filterOrdersWithCurrency() {
        guard let tokens = self.supprotTokens else {
            return
        }
        var tempContent = tokens.map {
            $0.token_module ?? ""
        }
        tempContent.insert(localLanguage(keyString: "wallet_deposit_list_order_token_select_title"), at: 0)
        let dropper = Dropper.init(x: 0, y: 0, width: 132, height: 90)
        dropper.items = tempContent
        dropper.theme = .black(UIColor.white)
        dropper.cellTextFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "5C5C5C")
        dropper.spacing = 12
        dropper.delegate = self
        // 定义阴影颜色
        dropper.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        dropper.layer.shadowRadius = 3
        // 阴影的偏移量
        dropper.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        dropper.layer.shadowOpacity = 0.1
        dropper.tag = 10
        dropper.show(Dropper.Alignment.center, position: .bottom, button: self.view!.orderTokenSelectButton)
    }
    func filterOrdersWithStatus() {
        let dropper = Dropper.init(x: 0, y: 0, width: 132, height: 36*5)
        dropper.items = [localLanguage(keyString: "wallet_deposit_list_order_status_title"),
                         localLanguage(keyString: "wallet_deposit_list_order_status_deposit_finish_title"),
                         localLanguage(keyString: "wallet_deposit_list_order_status_withdrawal_finish_title"),
                         localLanguage(keyString: "wallet_deposit_list_order_status_deposit_failed_title"),
                         localLanguage(keyString: "wallet_deposit_list_order_status_withdrawal_failed_title")]
        dropper.theme = .black(UIColor.white)
        dropper.cellTextFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "5C5C5C")
        dropper.spacing = 12
        dropper.delegate = self
        // 定义阴影颜色
        dropper.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        dropper.layer.shadowRadius = 3
        // 阴影的偏移量
        dropper.layer.shadowOffset = CGSize(width: 0, height: 0)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        dropper.layer.shadowOpacity = 0.1
        dropper.tag = 20
        dropper.show(Dropper.Alignment.center, position: .bottom, button: self.view!.orderStateButton)
    }
}
extension DepositListViewModel: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String, tag: Int) {
        if tag == 10 {
            self.view?.orderTokenSelectButton.setTitle(contents, for: UIControl.State.normal)
            self.view?.orderTokenSelectButton.imagePosition(at: .right, space: 5, imageViewSize: CGSize.init(width: 10, height: 10))

        } else {
            self.view?.orderStateButton.setTitle(contents, for: UIControl.State.normal)
            self.view?.orderStateButton.imagePosition(at: .right, space: 5, imageViewSize: CGSize.init(width: 10, height: 10))

        }
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
            if type == "GetBankDepositListOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositListMainDataModel] else {
                    return
                }
                self?.tableViewManager.dataModels = tempData
                self?.view?.tableView.reloadData()
            } else if type == "GetBankDepositListMore" {
                guard let tempData = dataDic.value(forKey: "data") as? [DepositListMainDataModel] else {
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
                    self?.tableViewManager.dataModels = tempArray as? [DepositListMainDataModel]
                    self?.view?.tableView.beginUpdates()
                    self?.view?.tableView.insertRows(at: insertIndexPath, with: UITableView.RowAnimation.bottom)
                    self?.view?.tableView.endUpdates()
                } else {
                    self?.tableViewManager.dataModels = tempData
                    self?.view?.tableView.reloadData()
                }
                self?.view?.tableView.mj_footer?.endRefreshing()
            }
            self?.view?.tableView.mj_footer?.endRefreshing()
            self?.view?.hideToastActivity()
            self?.view?.tableView.mj_header?.endRefreshing()
        })
    }
}
