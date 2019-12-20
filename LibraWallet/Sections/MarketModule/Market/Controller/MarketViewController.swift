//
//  MarketViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SocketIO
class MarketViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
        self.wallet = LibraWalletManager.shared
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
        self.navigationController?.navigationBar.barStyle = .black
        addSocket()
        
        guard restartLisening == true else {
            return
        }
//        if let headerView = self.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
//            // 添加监听
//           if let payContract = headerView.leftTokenModel?.addr, let exchangeContract = headerView.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
//               print("添加监听")
//               self.dataModel.getMarketData(address: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89", payContract: payContract, exchangeContract: exchangeContract)
//               self.dataModel.addDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
//           }
//        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
//        closeSocket()
    }
    func addSocket() {
        self.dataModel.addSocket()
    }
    func closeSocket() {
        self.dataModel.removeSocket()
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
    deinit {
        print("MarketViewController销毁了")
    }
    var manager: SocketManager?
    var myContext = 0
    typealias nextActionClosure = ([MarketSupportCoinDataModel]) -> Void
    var actionClosure: nextActionClosure?
    var restartLisening: Bool?
    
    var wallet: LibraWalletManager?
}
extension MarketViewController: MarketTableViewManagerDelegate {
    func selectToken(button: UIButton, leftModelName: String, rightModelName: String) {
        guard let walletAddress = self.wallet?.walletAddress else {
            return
        }
        self.detailView.toastView?.show()
        self.dataModel.getMarketSupportToken(address: walletAddress)
        
        self.actionClosure = { dataModel in
            var tempDataModel = dataModel
            if button.tag == 20 {
                // 左边点击
                tempDataModel = dataModel.filter({ item in
                    item.enable == true
                })
                #warning("请先注册币")
                guard tempDataModel.isEmpty == false else {
                    self.detailView.makeToast(localLanguage(keyString: "请先注册稳定币"),
                                              position: .center)
                    return
                }
            } else {
                // 右边点击
                tempDataModel = dataModel.filter({ item in
                    item.name != leftModelName
                })
            }
            let alert = TokenPickerViewAlert.init(successClosure: { (model) in
                if let headerView = self.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
                    if button.tag == 20 {
                        // 移除之前监听
                        if let payContract = headerView.leftTokenModel?.addr, let exchangeContract = headerView.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                            print("移除之前监听")
                            self.dataModel.removeDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
                        } else {
                            // 之前无监听
                            print("之前无监听")
                        }
                        headerView.leftTokenModel = model
                        // 右边设置为空
                        if headerView.rightTokenModel?.name == headerView.leftTokenModel?.name {
                            headerView.rightTokenModel = nil
                        }
                    } else {
                        guard headerView.rightTokenModel?.name != model.name else {
                            return
                        }
                        // 移除之前监听
                        if let payContract = headerView.leftTokenModel?.addr, let exchangeContract = headerView.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                            print("移除之前监听")
                            self.dataModel.removeDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
                        } else {
                            // 之前无监听
                            print("之前无监听")
                        }
                        headerView.rightTokenModel = model
                    }
                    // 添加监听
                    if let payContract = headerView.leftTokenModel?.addr, let exchangeContract = headerView.rightTokenModel?.addr, payContract.isEmpty == false, exchangeContract.isEmpty == false {
                        guard let walletAddress = self.wallet?.walletAddress else {
                            return
                        }
                        print("添加监听")
                        self.dataModel.getMarketData(address: walletAddress, payContract: payContract, exchangeContract: exchangeContract)
                        self.dataModel.addDepthsLisening(payContract: payContract, exchangeContract: exchangeContract)
                        self.restartLisening = true
                    }
                }
            }, data: tempDataModel)
            alert.show()
            alert.showAnimation()
        }
    }
    func exchangeToken(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double) {
        self.showPasswordAlert(payContract: payContract,
                               receiveContract: receiveContract,
                               amount: amount,
                               exchangeAmount: exchangeAmount)
    }
    func showPasswordAlert(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double) {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: localLanguage(keyString: "wallet_type_in_password_content"), preferredStyle: .alert)
        alertContr.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = localLanguage(keyString: "wallet_type_in_password_textfield_placeholder")
            textField.tintColor = DefaultGreenColor
            textField.isSecureTextEntry = true
        }
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default) { [weak self] clickHandler in
            let passwordTextField = alertContr.textFields!.first! as UITextField
            guard let password = passwordTextField.text else {
                self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordInvalidError).localizedDescription,
                                    position: .center)
                return
            }
            guard password.isEmpty == false else {
                self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError).localizedDescription,
                                    position: .center)
                return
            }
            NSLog("Password:\(password)")
            do {
                let state = try LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: (self?.wallet?.walletRootAddress)!, password: password)
                guard state == true else {
                    self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError).localizedDescription,
                                         position: .center)
                    return
                }
                self?.detailView.toastView?.show()
                let menmonic = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (self?.wallet?.walletRootAddress)!)
                guard let walletAddress = self?.wallet?.walletAddress else {
                    #warning("缺少错误提示")
                    return
                }
                self?.dataModel.exchangeViolasTokenTransaction(sendAddress: walletAddress,
                                                               amount: amount,
                                                               fee: 0,
                                                               mnemonic: menmonic,
                                                               contact: payContract,
                                                               exchangeTokenContract: receiveContract,
                                                               exchangeTokenAmount: exchangeAmount)
            } catch {
                self?.detailView.toastView?.hide()
            }
        })
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){
            clickHandler in
            NSLog("点击了取消")
            })
        self.present(alertContr, animated: true, completion: nil)
    }

    
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
//        self.dataModel.e
        
    }
    func showOrderCenter() {
        let vc = OrderCenterViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)
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
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据返回状态异常
            }
//            self.detailView.hideToastActivity()
            self.detailView.toastView?.hide()
            self.detailView.makeToast(error.localizedDescription,
                                      position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetTokenList" {
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? [MarketSupportCoinDataModel] {
                if let action = self.actionClosure {
                    action(tempData)
                }
            }
        } else if type == "GetCurrentOrder" {
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? MarketResponseMainModel {
                self.tableViewManager.buyOrders = tempData.orders?.sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                })
                self.tableViewManager.sellOrders = tempData.depths?.buys?.sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                })
                self.detailView.tableView.reloadData()
            }
        } else if type == "OrderChange" {
            self.detailView.toastView?.hide()
            if let tempData = jsonData.value(forKey: "data") as? MarketOrderModel {
                if let data = tempData.buys, data.isEmpty == false {
                    refreshTableView(data: data)
                }
            }
        } else if type == "ExchangeDone" {
            self.detailView.toastView?.hide()
            self.detailView.makeToast(localLanguage(keyString: "挂单成功"),
                                      position: .center)
        }
//        self.detailView.hideToastActivity()
    }
    func refreshTableView(data: [MarketOrderDataModel]) {
        // 开始筛选所有我的订单
        let myOrders = data.filter({ item in
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
            if dataExist == false {
                print("匹配失败添加数据")
                self.tableViewManager.buyOrders?.append((myOrders[i]))
                self.tableViewManager.buyOrders = self.tableViewManager.buyOrders?.sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                })
                self.detailView.tableView.beginUpdates()
                if let count = self.tableViewManager.buyOrders?.count, count >= 0 {
                    // 判断数据是否已展示五条，已展示删除最后一条，未展示直接插入到列首
                    if count >= 5 {
                        self.detailView.tableView.deleteRows(at: [IndexPath.init(row: 4, section: 1)], with: UITableView.RowAnimation.left)
                    }
                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 0, section: 1)], with: UITableView.RowAnimation.bottom)
                }
                self.detailView.tableView.endUpdates()
            }
        }
        
        // 开始筛选其他人订单
        let otherOrders = data.filter({ item in
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
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.left)
                                if count >= 5 {
                                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 4, section: 2)], with: UITableView.RowAnimation.bottom)
                                }
                                self.detailView.tableView.endUpdates()
                            }
                        }
                        self.detailView.tableView.beginUpdates()
                        self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.left)
                        self.detailView.tableView.endUpdates()
                    } else if otherOrders[i].state == "CANCELED" || otherOrders[i].state == "CANCELLING" {
                        // 其他人订单已取消
//                                tempOrderDeleteIndexPath.append(IndexPath.init(row: j, section: 1))
                        self.tableViewManager.sellOrders?.remove(at: j)
                        if let count = self.tableViewManager.sellOrders?.count, count >= 0 {
                            // 判断返回数据是否在已展示的5条数据中，如果在，删除数据+刷新Tableview，不在仅删除数据
                            if j < 5 {
                                // 已在列表中展示
                                self.detailView.tableView.beginUpdates()
                                self.detailView.tableView.deleteRows(at: [IndexPath.init(row: j, section: 2)], with: UITableView.RowAnimation.left)
                                if count >= 5 {
                                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: 4, section: 2)], with: UITableView.RowAnimation.bottom)
                                }
                                self.detailView.tableView.endUpdates()
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
            if dataExist == false {
                self.tableViewManager.sellOrders?.append(otherOrders[i])
                self.tableViewManager.sellOrders = self.tableViewManager.sellOrders?.sorted(by: {
                    ($0.date ?? 0) > ($1.date ?? 0)
                })
                self.detailView.tableView.beginUpdates()
                if let count = self.tableViewManager.sellOrders?.count, count >= 0 {
                    // 判断数据是否已展示五条，已展示删除最后一条，未展示直接插入到列首
                    if count >= 5 {
                        self.detailView.tableView.deleteRows(at: [IndexPath.init(row: 4, section: 2)], with: UITableView.RowAnimation.left)
                    }
                    self.detailView.tableView.insertRows(at: [IndexPath.init(row: count - 1, section: 2)], with: UITableView.RowAnimation.bottom)
                }
                self.detailView.tableView.endUpdates()
            }
        }
    }
}
extension MarketViewController: MarketExchangeHeaderViewDelegate {
    
}
