//
//  MarketMineViewController.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MarketMineViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_market_assets_pool_mine_navigationbar_title")
        // 加载子View
        self.view.addSubview(detailView)
        self.initKVO()
        self.requestData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: MarketMineModel = {
        let model = MarketMineModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: MarketMineTableViewManager = {
        let manager = MarketMineTableViewManager.init()
        //        manager.delegate = self
        return manager
    }()
    /// 子View
    private lazy var detailView : MarketMineView = {
        let view = MarketMineView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    func requestData() {
        self.detailView.makeToastActivity(.center)
        self.dataModel.getMarketMineTokens(address: Wallet.shared.violasAddress ?? "")
    }
}
extension MarketMineViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.detailView.hideToastActivity()
                if self?.detailView.tableView.mj_footer?.isRefreshing == true {
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                if self?.detailView.tableView.mj_header?.isRefreshing == true {
                    self?.detailView.tableView.mj_header?.endRefreshing()
                }
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.detailView.tableView.reloadData()
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                    self?.detailView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self?.detailView.makeToast(error.localizedDescription,
                                               position: .center)
                }
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetMarketMineTokens" {
                guard let tempData = dataDic.value(forKey: "data") as? MarketMineMainDataModel else {
                    return
                }
                self?.tableViewManager.dataModels = tempData.balance
                self?.detailView.headerView.model =  tempData.total_token
                self?.detailView.tableView.reloadData()
            }
            self?.detailView.hideToastActivity()
            self?.detailView.tableView.mj_header?.endRefreshing()
        })
    }
}

