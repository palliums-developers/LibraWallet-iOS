//
//  MarketViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SocketIO
import StatefulViewController
class MarketViewController: UIViewController {
    /*
     1.切换兑换币会GetMarket
     2.页面跳转后加载会GetMarket
     3.交换左右币后加载GetMarket
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
        // 设置空数据页面
        self.setEmptyView()
        // 初始化KVO
        self.initKVO()
        //设置默认页面（无数据、无网络）
        self.setPlaceholderView()
        addSocket()
        // 判断时候是Violas钱包
//        self.requestData()
        self.restartLisening = true
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
        self.navigationController?.navigationBar.barStyle = .black
        // 关闭后当前页面可以刷新
        stopRefreshTableView = false
        // 判断是否切换钱包
        if self.wallet?.walletRootAddress != LibraWalletManager.shared.walletRootAddress {
            self.detailView.changeHeaderViewDefault(hideLeftModel: true)
            self.tableViewManager.buyOrders?.removeAll()
            self.tableViewManager.sellOrders?.removeAll()
            self.detailView.tableView.reloadData()
        }
        // 更新钱包
        self.wallet = LibraWalletManager.shared
        // 更新数据
        guard restartLisening == true else {
            return
        }
        // 判断时候是Violas钱包
        self.requestData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
        stopRefreshTableView = true
    }
    deinit {
        print("MarketViewController销毁了")
    }
    func addSocket() {
        self.dataModel.addSocket()
        self.dataModel.addSocketListening()
    }
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading()
        guard self.wallet?.walletType == .Violas else {
            endLoading(error: NSError.init(domain: "test", code: 1, userInfo: nil))
            return
        }
        endLoading()
        if let headerView = self.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
            if let payContract = headerView.leftTokenModel?.addr, let exchangeContract = headerView.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                guard let walletAddress = self.wallet?.walletAddress else {
                    return
                }
                print("添加监听")
                self.dataModel.getMarketData(address: walletAddress, payContract: payContract, exchangeContract: exchangeContract)
//                self.dataModel.getCurrentOrder(address: walletAddress, baseAddress: payContract, exchangeAddress: exchangeContract)
            }
        }
    }
    func hasContent() -> Bool {
        guard self.wallet?.walletType == .Violas else {
            return false
        }
        return true
    }
    func setPlaceholderView() {
        if let error = errorView as? WalletInvalidInMarketWarningAlert {
            error.emptyImageName = "backup_mnemonic_icon"
            error.descString = localLanguage(keyString: "wallet_market_empty_default_describe")
        }
    }
    //网络请求、数据模型
    lazy var dataModel: MarketModel = {
        let model = MarketModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: MarketTableViewManager = {
        let manager = MarketTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    private lazy var detailView : MarketView = {
        let view = MarketView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    
    var manager: SocketManager?
    var myContext = 0
    typealias nextActionClosure = ([MarketSupportCoinDataModel]) -> Void
    var actionClosure: nextActionClosure?
    
    typealias exchangeStateClosure = (Int64) -> Void
    var checkBalanceClosure: exchangeStateClosure?
    
    typealias publishTokenForTransactionClosure = () -> Void
    var publishTokenClosure: publishTokenForTransactionClosure?
    var restartLisening: Bool?
    var wallet: LibraWalletManager?
    var stopRefreshTableView: Bool?
}
extension MarketViewController: MarketTableViewManagerDelegate {
    func changeLeftRightTokenModel(leftModel: MarketSupportCoinDataModel, rightModel: MarketSupportCoinDataModel) {
        // 获取当前钱包地址
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        self.detailView.toastView?.show()
        // 移除旧的监听
        self.dataModel.removeDepthsLisening(payContract: rightModel.addr ?? "", exchangeContract: leftModel.addr ?? "")
        // 请求交易所对应交易对数据
        self.dataModel.getMarketData(address: walletAddress, payContract: leftModel.addr ?? "", exchangeContract: rightModel.addr ?? "")
        // 添加对应交易对数据变化监听
        self.dataModel.addDepthsLisening(payContract: leftModel.addr ?? "", exchangeContract: rightModel.addr ?? "")
    }
    
    func selectToken(button: UIButton, leftModelName: String, rightModelName: String, header: MarketExchangeHeaderView) {
        // 获取当前钱包地址
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        self.detailView.toastView?.show()
        self.dataModel.getSupportToken(address: walletAddress)

        self.actionClosure = { dataModel in
            var tempDataModel = dataModel
            // 筛选左右展示数据
            var showRegisterModel: Bool = false
            if button.tag == 20 {
                // 左边点击
                tempDataModel = dataModel.filter({ item in
                    item.enable == true
                })
                showRegisterModel = true
            } else {
                // 右边点击
                tempDataModel = dataModel.filter({ item in
                    item.name != leftModelName
                }).sorted(by: {
                    ($0.enable ?? false) != ($1.enable ?? false)
                }).reversed()
                showRegisterModel = false
            }
            // 尚未注册任何稳定币
            if button.tag == 20 && tempDataModel.isEmpty == true {
                let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_market_alert_register_token_title"), message: localLanguage(keyString: "wallet_market_alert_register_token_content"), preferredStyle: .alert)
                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
                    let vc = AddAssetViewController()
                    vc.wallet = self?.wallet
                    vc.needDismissViewController = true
                    let navi = UINavigationController.init(rootViewController: vc)
                    self?.present(navi, animated: true, completion: nil)
                })
                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
                    NSLog("点击了取消")
                })
                self.present(alertContr, animated: true, completion: nil)
                return
            }
            let alert = TokenPickerViewAlert.init(successClosure: { (model) in
                if button.tag == 20 {
                    // 移除之前监听
                    if let payContract = header.leftTokenModel?.addr, let exchangeContract = header.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                        print("移除之前监听")
                        self.dataModel.removeDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
                    } else {
                        // 之前无监听
                        print("之前无监听")
                    }
                    header.leftTokenModel = model
                    // 右边设置为空
                    if header.rightTokenModel?.name == header.leftTokenModel?.name {
                        self.detailView.changeHeaderViewDefault(hideLeftModel: false)
                    }
                } else {
                    guard header.rightTokenModel?.name != model.name else {
                        return
                    }
                    // 移除之前监听
                    if let payContract = header.leftTokenModel?.addr, let exchangeContract = header.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                        print("移除之前监听")
                        self.dataModel.removeDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
                    } else {
                        // 之前无监听
                        print("之前无监听")
                    }
                    header.rightTokenModel = model
                }
                // 添加监听
                if let payContract = header.leftTokenModel?.addr, let exchangeContract = header.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                    guard let walletAddress = self.wallet?.walletAddress else {
                        return
                    }
                    print("添加监听")
                    self.dataModel.getMarketData(address: walletAddress, payContract: payContract, exchangeContract: exchangeContract)
                    self.dataModel.addDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
                }
            }, data: tempDataModel, onlyRegisterToken: showRegisterModel)
            alert.show()
            alert.showAnimation()
        }
    }
    func exchangeToken(payToken: MarketSupportCoinDataModel, receiveToken: MarketSupportCoinDataModel, amount: Double, exchangeAmount: Double) {
        self.detailView.toastView?.show()
        // 第一步，检查余额是否充足
        self.dataModel.getViolasBalance(walletID: LibraWalletManager.shared.walletID ?? 0,
                                        address: LibraWalletManager.shared.walletAddress ?? "",
                                        vtoken: payToken.addr ?? "")
        self.checkBalanceClosure = { balance in
            if balance >= Int64(amount * 1000000) {
                //第二步，余额充足，检查是否将要兑换的币已注册
                guard receiveToken.enable == true else {
                    let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: LibraWalletError.WalletMarket(reason: .exchangeTokenPublishedInvalid).localizedDescription, preferredStyle: .alert)
                    alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
                        self?.showPublishPasswordAlert(payContract: payToken.addr ?? "",
                                                      receiveContract: receiveToken.addr ?? "",
                                                      amount: amount,
                                                      exchangeAmount: exchangeAmount,
                                                      name: receiveToken.name ?? "")
                        
                    })
                    alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
                        NSLog("点击了取消")
                    })
                    self.present(alertContr, animated: true, completion: nil)
                    return
                }
                self.showPasswordAlert(payContract: payToken.addr ?? "",
                                       receiveContract: receiveToken.addr ?? "",
                                       amount: amount,
                                       exchangeAmount: exchangeAmount)
            } else {
                self.detailView.makeToast(LibraWalletError.WalletMarket(reason: .payAmountNotEnough).localizedDescription, position: .center)
            }
        }
    }
    func showPublishPasswordAlert(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double, name: String) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] mnemonic in
            guard let walletAddress = self?.wallet?.walletAddress else {
                return
            }
            self?.detailView.toastView?.show()
            self?.dataModel.publishTokenForTransaction(sendAddress: walletAddress,
                                                       mnemonic: mnemonic,
                                                       contact: receiveContract)
            self?.publishTokenClosure = {
                // 更新列表数据
                if let headerView = self?.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
                    headerView.rightTokenModel?.enable = true
                }
                // 插入本地数据库
                let violasToken = ViolasTokenModel.init(name: name,
                                                        description: "",
                                                        address: Data.init(Array<UInt8>(hex: receiveContract)).toHexString(),
                                                        icon: "",
                                                        enable: true,
                                                        balance: Int64(exchangeAmount * 1000000),
                                                        registerState: true)
                _ = DataBaseManager.DBManager.insertViolasToken(walletID: self?.wallet?.walletID ?? 0, model: violasToken)
                // 发送交易
                self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
                                                               amount: amount,
                                                               fee: 0,
                                                               mnemonic: mnemonic,
                                                               contact: payContract,
                                                               exchangeTokenContract: receiveContract,
                                                               exchangeTokenAmount: exchangeAmount)
            }
        }) { [weak self] errorContent in
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
    func showPasswordAlert(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] mnemonic in
            guard let walletAddress = self?.wallet?.walletAddress else {
                return
            }
            self?.detailView.toastView?.show()
            self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
                                                           amount: amount,
                                                           fee: 0,
                                                           mnemonic: mnemonic,
                                                           contact: payContract,
                                                           exchangeTokenContract: receiveContract,
                                                           exchangeTokenAmount: exchangeAmount)
        }) { [weak self] errorContent in
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
    func showOrderCenter() {
        let vc = OrderCenterViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showHideOthersToMax(state: Bool) {
        self.detailView.tableView.beginUpdates()
        if state == true  {
            // 展示
            if (self.tableViewManager.sellOrders?.count ?? 0) > 5 {
                // 大于5条
                var tempIndexPaths = [IndexPath]()
                let maxRow = (self.tableViewManager.sellOrders?.count ?? 0) >= 20 ? 20:(self.tableViewManager.sellOrders?.count ?? 0)
                for i in 5..<maxRow {
                    let indexPath = IndexPath.init(row: i, section: 2)
                    tempIndexPaths.append(indexPath)
                }
                self.detailView.tableView.insertRows(at: tempIndexPaths, with: UITableView.RowAnimation.bottom)
            } else {
                // 小于5条不做操作
            }
        } else {
            // 隐藏
            if (self.tableViewManager.sellOrders?.count ?? 0) > 5 {
                // 大于5条
                var tempIndexPaths = [IndexPath]()
                let maxRow = (self.tableViewManager.sellOrders?.count ?? 0) >= 20 ? 20:(self.tableViewManager.sellOrders?.count ?? 0)
                for i in 5..<maxRow {
                    let indexPath = IndexPath.init(row: i, section: 2)
                    tempIndexPaths.append(indexPath)
                }
                self.detailView.tableView.deleteRows(at: tempIndexPaths, with: UITableView.RowAnimation.bottom)
            } else {
                // 小于5条不做操作
            }
        }
        self.detailView.tableView.endUpdates()
    }
}
extension MarketViewController {
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
            self.detailView.toastView?.hide()
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据返回状态异常
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletMarket(reason: .publishedListEmpty).localizedDescription {
                print(error.localizedDescription)
                let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: localLanguage(keyString: "wallet_market_alert_register_token_content"), preferredStyle: .alert)
                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
                    let vc = AddAssetViewController()
                    vc.wallet = self?.wallet
                    vc.needDismissViewController = true
                    let navi = UINavigationController.init(rootViewController: vc)
                    self?.present(navi, animated: true, completion: nil)
                })
                alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
                    NSLog("点击了取消")
                })
                self.present(alertContr, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletMarket(reason: .marketSupportTokenEmpty).localizedDescription {
                print(error.localizedDescription)
                
            }
//            self.detailView.hideToastActivity()
            
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetTokenList" {
            // 获取交易所支持稳定币列表
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? [MarketSupportCoinDataModel] {
                if let action = self.actionClosure {
                    action(tempData)
                }
            }
        } else if type == "GetCurrentOrder" {
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? MarketResponseMainModel {
                #warning("无奈之举，望谅解")
                let headerView = self.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView
                self.tableViewManager.buyOrders = tempData.orders?.filter({
                    $0.user?.contains(self.wallet?.walletAddress ?? "") == true
                }).sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                }).map({ (item) in
                    MarketOrderDataModel.init(id: item.id, user: item.user, state: item.state, tokenGet: item.tokenGet, tokenGetSymbol: item.tokenGetSymbol, amountGet: item.amountGet, tokenGive: item.tokenGive, tokenGiveSymbol: item.tokenGiveSymbol, amountGive: item.amountGive, version: item.version, date: item.date, update_date: item.update_date, update_version: item.update_version, amountFilled: item.amountFilled, price: headerView?.rightTokenModel?.price)
                })
                #warning("无奈之举，望谅解")
                self.tableViewManager.sellOrders = tempData.depths?.buys?.filter({
                    $0.user?.contains(self.wallet?.walletAddress ?? "") == false
                }).sorted(by: {
                    ($0.date ?? 0) < ($1.date ?? 0)
                }).map({ (item) in
                    MarketOrderDataModel.init(id: item.id, user: item.user, state: item.state, tokenGet: item.tokenGet, tokenGetSymbol: item.tokenGetSymbol, amountGet: item.amountGet, tokenGive: item.tokenGive, tokenGiveSymbol: item.tokenGiveSymbol, amountGive: item.amountGive, version: item.version, date: item.date, update_date: item.update_date, update_version: item.update_version, amountFilled: item.amountFilled, price: headerView?.rightTokenModel?.price)
                })
                headerView?.rate = tempData.price ?? 0
                self.detailView.tableView.reloadData()
            }
        } else if type == "OrderChange" {
            // 订单状态变更
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? MarketOrderModel {
                if let data = tempData.buys, data.isEmpty == false {
                    refreshTableView(data: data)
                }
            }
        } else if type == "ExchangeDone" {
            // 兑换挂单成功
            self.detailView.toastView?.hide()
            self.detailView.makeToast(localLanguage(keyString: "wallet_market_alert_make_order_success_title"), position: .center)
            let headerView = self.detailView.tableView.headerView(forSection: 0) as! MarketExchangeHeaderView
            headerView.leftAmountTextField.text = ""
            headerView.rightAmountTextField.text = ""
        } else if type == "UpdateViolasBalance" {
            // 获取余额
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? BalanceLibraModel {
                if let data = tempData.modules, data.isEmpty == false, let tempModule = data.first {
                    if let action = self.checkBalanceClosure {
                        action(Int64(tempModule.balance ?? 0))
                    }
                }
            }
        } else if type == "PublishTokenForTransaction" {
            // 代币注册
            if let action = self.publishTokenClosure {
                action()
            }
        } else if type == "SocketReconnect" {
            // Socket 重连
            self.tableViewManager.buyOrders?.removeAll()
            self.tableViewManager.sellOrders?.removeAll()
            self.detailView.tableView.reloadData()
            self.requestData()
        }
    }
    func refreshTableView(data: [MarketOrderDataModel]) {
        // 开始筛选所有我的订单
        var myOrders = data.filter({ item in
            item.user?.contains(self.wallet?.walletAddress ?? "") == true
        })
        for i in 0..<(myOrders.count) {
            //依次检查新数据
            var dataExist = false
            for j in 0..<(self.tableViewManager.buyOrders?.count ?? 0) {
                //匹配旧数据
                if self.tableViewManager.buyOrders?[j].id == myOrders[i].id {
                    if myOrders[i].state == "FILLED" {
                        // 已成交
                        self.tableViewManager.buyOrders?.remove(at: j)
                        // 判断操作数据后当前数据时候大于等于0
                        if let count = self.tableViewManager.buyOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，删除数据+刷新Tableview，不在仅删除数据
                            if j < 5 {
                                guard stopRefreshTableView == false else {
                                    dataExist = true
                                    return
                                }
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 1)], with: UITableView.RowAnimation.left)
                                // 判断删除数据后已展示数据是否满足5条，不满足追加Tableview的Cell，满足不做操作
                                if count >= 5 {
                                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 4, section: 1)], with: UITableView.RowAnimation.bottom)
                                }
                                self.detailView.tableView.endUpdates()
                            }
                        }
                    } else if myOrders[i].state == "CANCELED" || myOrders[i].state == "CANCELLING" {
                        // 已取消
                        self.tableViewManager.buyOrders?.remove(at: j)
                        if let count = self.tableViewManager.buyOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，删除数据+刷新Tableview，不在仅删除数据
                            if j < 5 {
                                // 已在列表中展示
                                guard stopRefreshTableView == false else {
                                    dataExist = true
                                    return
                                }
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 1)], with: UITableView.RowAnimation.left)
                                // 判断删除数据后已展示数据是否满足5条，不满足追加Tableview的Cell，满足不做操作
                                if count >= 5 {
                                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 4, section: 1)], with: UITableView.RowAnimation.bottom)
                                }
                                self.detailView.tableView.endUpdates()
                            }
                        }
                    } else if myOrders[i].state == "OPEN" {
                        // 成交中,刷新数据
                        self.tableViewManager.buyOrders?.remove(at: j)
                        self.tableViewManager.buyOrders?.insert(myOrders[i], at: j)
                        if let count = self.tableViewManager.buyOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，刷新Tableview的Cell，不在仅刷新数据
                            if j < 5 {
                                // 已在列表中展示
                                guard stopRefreshTableView == false else {
                                    dataExist = true
                                    return
                                }
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.reloadRows(at: [IndexPath.init(row: j, section: 1)], with: UITableView.RowAnimation.fade)
                                self.detailView.tableView.endUpdates()
                            }
                        }
                    }
                    dataExist = true
                    print("匹配成功")
                    break
                }
            }
            if dataExist == false &&  myOrders[i].state == "OPEN" {
                print("匹配失败添加数据")
                let headerView = self.detailView.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainHeader") as! MarketExchangeHeaderView//headerView(forSection: 0) as! MarketExchangeHeaderView
                myOrders[i].price = headerView.rightTokenModel?.price

                self.tableViewManager.buyOrders?.append(myOrders[i])
                self.tableViewManager.buyOrders = self.tableViewManager.buyOrders?.sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                })
                guard stopRefreshTableView == false else {
                    return
                }
                self.detailView.tableView.beginUpdates()
                if let count = self.tableViewManager.buyOrders?.count, count >= 0 {
                    // 判断数据是否已展示五条，已展示删除最后一条，未展示直接插入到列首
                    if count > 5 {
                        self.detailView.tableView.deleteRows(at: [IndexPath.init(row: 4, section: 1)], with: UITableView.RowAnimation.left)
                    }
                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 0, section: 1)], with: UITableView.RowAnimation.bottom)
                }
                self.detailView.tableView.endUpdates()
            }
        }
        
        // 开始筛选其他人订单
        var otherOrders = data.filter({ item in
            item.user?.contains(self.wallet?.walletAddress ?? "") == false
        })
//                let oldOtherBuyOrders = self.tableViewManager.sellOrders
        for i in 0..<(otherOrders.count) {
            //依次检查新数据
            var dataExist = false
            for j in 0..<(self.tableViewManager.sellOrders?.count ?? 0) {
                //匹配旧数据
                if self.tableViewManager.sellOrders?[j].id == otherOrders[i].id {
                    if otherOrders[i].state == "FILLED" {
                        // 其他人订单已成交
//                                tempOrderDeleteIndexPath.append(IndexPath.init(row: j, section: 1))
                        self.tableViewManager.sellOrders?.remove(at: j)
                        if let count = self.tableViewManager.sellOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，删除数据+刷新Tableview，不在仅删除数据
                            if j < 5 {
                                // 已在列表中展示
                                guard stopRefreshTableView == false else {
                                    dataExist = true
                                    return
                                }
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.left)
                                if count >= 5 {
                                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 4, section: 2)], with: UITableView.RowAnimation.bottom)
                                }
                                self.detailView.tableView.endUpdates()
                            }
                        }
                        
                    } else if otherOrders[i].state == "CANCELED" || otherOrders[i].state == "CANCELLING" {
                        // 其他人订单已取消
//                                tempOrderDeleteIndexPath.append(IndexPath.init(row: j, section: 1))
                        self.tableViewManager.sellOrders?.remove(at: j)
                        if let count = self.tableViewManager.sellOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，删除数据+刷新Tableview，不在仅删除数据
                            if self.tableViewManager.showOtherSellOrdersToMax == false {
                                if j < 5 {
                                    // 已在列表中展示
                                    guard stopRefreshTableView == false else {
                                        dataExist = true
                                        return
                                    }
                                    self.detailView.tableView.beginUpdates()
                                    self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.left)
                                    if count >= 5 {
                                        self.detailView.tableView.insertRows(at: [IndexPath.init(row: 4, section: 2)], with: UITableView.RowAnimation.bottom)
                                    }
                                    self.detailView.tableView.endUpdates()
                                }
                            } else {
                                if j < 20 {
                                    // 已在列表中展示
                                    guard stopRefreshTableView == false else {
                                        dataExist = true
                                        return
                                    }
                                    self.detailView.tableView.beginUpdates()
                                    self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.left)
                                    if count >= 20 {
                                        self.detailView.tableView.insertRows(at: [IndexPath.init(row: 19, section: 2)], with: UITableView.RowAnimation.bottom)
                                    }
                                    self.detailView.tableView.endUpdates()
                                }
                            }
                            
                        }
                    } else if otherOrders[i].state == "OPEN" {
                        // 其他人订单成交中,刷新数据
                        self.tableViewManager.sellOrders?.remove(at: j)
                        self.tableViewManager.sellOrders?.insert(otherOrders[i], at: j)
                        if let count = self.tableViewManager.sellOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，刷新Tableview的Cell，不在仅刷新数据
                            if j < 5 {
                                // 已在列表中展示
                                guard stopRefreshTableView == false else {
                                    dataExist = true
                                    return
                                }
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.reloadRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.fade)
                                self.detailView.tableView.endUpdates()
                            }
                        }
                    }
                    dataExist = true
                    break
                }
            }
            if dataExist == false &&  otherOrders[i].state == "OPEN" {
//                let headerView = self.detailView.tableView.headerView(forSection: 0) as! MarketExchangeHeaderView
                let headerView = self.detailView.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainHeader") as! MarketExchangeHeaderView//headerView(forSection: 0) as! MarketExchangeHeaderView
                otherOrders[i].price = headerView.rightTokenModel?.price
                
                self.tableViewManager.sellOrders?.append(otherOrders[i])
                self.tableViewManager.sellOrders = self.tableViewManager.sellOrders?.sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                })
                guard stopRefreshTableView == false else {
                    return
                }
                self.detailView.tableView.beginUpdates()
                if let count = self.tableViewManager.sellOrders?.count, count >= 0 {
                    // 判断数据是否已展示五条，已展示删除最后一条，未展示直接插入到列首
                    if count > 5 {
                        self.detailView.tableView.deleteRows(at: [IndexPath.init(row: 4, section: 2)], with: UITableView.RowAnimation.left)
                    }
                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: count - 1, section: 2)], with: UITableView.RowAnimation.bottom)
                }
                self.detailView.tableView.endUpdates()
            }
        }
    }
}
extension MarketViewController: StatefulViewController {
    func setEmptyView() {
        //空数据
        errorView = WalletInvalidInMarketWarningAlert()
    }
}
