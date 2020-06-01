//
//  VTokenMainViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class VTokenMainViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.view.addSubview(detailView)
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationWhiteMode()
        self.navigationController?.navigationBar.barStyle = .black
    }
    /// 网络请求、数据模型
    lazy var dataModel: VTokenMainModel = {
        let model = VTokenMainModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: VTokenTableViewManager = {
        let manager = VTokenTableViewManager.init()
//        manager.delegate = self
        
        return manager
    }()
    /// 子View
    lazy var detailView : VTokenMainView = {
        let view = VTokenMainView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshReceive))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreReceive))
        view.headerView.delegate = self
        return view
    }()
    /// 数据监听KVO
    private var observer: NSKeyValueObservation?
    /// 页数
    var dataOffset: Int = 0
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var wallet: LibraWalletManager? {
        didSet {
            self.detailView.headerView.walletAddressLabel.text = wallet?.walletAddress
        }
    }
    var vtokenModel: ViolasTokenModel? {
        didSet {
            self.detailView.headerView.assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (vtokenModel?.balance ?? 0)),
                                                                                          scale: 4,
                                                                                          unit: 1000000)
            self.detailView.headerView.assetUnitLabel.text = vtokenModel?.name
        }
    }
}
extension VTokenMainViewController {
    @objc func refreshReceive() {
       dataOffset = 0
       detailView.tableView.mj_footer?.resetNoMoreData()
       dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: dataOffset, pageSize: 10, contract: "\(self.vtokenModel?.id ?? 0)", requestStatus: 0, tokenName: self.vtokenModel?.name ?? "")
   }
   @objc func getMoreReceive() {
       dataOffset += 10
       dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: dataOffset, pageSize: 10, contract: "\(self.vtokenModel?.id ?? 0)", requestStatus: 1, tokenName: self.vtokenModel?.name ?? "")
   }
}
extension VTokenMainViewController: VTokenMainHeaderViewDelegate {
    func walletSend() {
        let vc = ViolasTransferViewController()
        vc.actionClosure = {
        //            self.dataModel.getLocalUserInfo()
        }
        vc.wallet = self.wallet
        vc.sendViolasTokenState = true
        vc.vtokenModel = self.vtokenModel
        vc.title = (vtokenModel?.name ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func walletReceive() {
        let vc = WalletReceiveViewController()
        // 一定要tokenname在前,否则显示有问题
        vc.tokenName = self.vtokenModel?.name
        vc.wallet = self.wallet
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension VTokenMainViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
//                self?.endLoading()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                #warning("修改好，样例")
                if self?.detailView.tableView.mj_header?.isRefreshing == true {
                    self?.detailView.tableView.mj_header?.endRefreshing()
                } else if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self?.detailView.hideToastActivity()
                }
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据返回状态异常
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 数据为空
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    print(error.localizedDescription)
                    // 没有更多
                }
                self?.detailView.makeToast(error.localizedDescription,
                                           position: .center)
                return
            }
            if type == "ViolasTransactionHistoryOrigin" {
                guard let tempData = dataDic.value(forKey: "data") as? [ViolasDataModel] else {
                    return
                }
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
                    self?.tableViewManager.violasTransactions = tempArray as? [ViolasDataModel]
                    self?.detailView.tableView.beginUpdates()
                    for index in 0..<tempData.count {
                        self?.detailView.tableView.insertSections(IndexSet.init(integer: oldData.count + index), with: UITableView.RowAnimation.bottom)
                    }
                    self?.detailView.tableView.endUpdates()
                } else {
                    self?.tableViewManager.violasTransactions = tempData
                    self?.detailView.tableView.reloadData()
                }
                self?.detailView.tableView.mj_footer?.endRefreshing()
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
        })
        self.detailView.tableView.mj_header?.beginRefreshing()
    }
}
