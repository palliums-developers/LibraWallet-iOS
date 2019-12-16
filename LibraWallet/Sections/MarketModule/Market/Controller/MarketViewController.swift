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
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
        closeSocket()
    }
    func addSocket() {
        ViolasSocketManager.shared.openSocket()
        ViolasSocketManager.shared.addMarketListening { result in
            print(result)
        }
        ViolasSocketManager.shared.getMarketData(address: "")
    }
    func closeSocket() {
        ViolasSocketManager.shared.stopSocket()
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
    typealias nextActionClosure = (MarketSupportCoinDataModel) -> Void
    var actionClosure: nextActionClosure?
    
}
extension MarketViewController: MarketTableViewManagerDelegate {
    func exchangeToken(payContract: String, receiveContract: String, amount: Double, exchangeAmount: Double) {
        let menmonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
        self.dataModel.exchangeViolasTokenTransaction(sendAddress: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89",
                                                      amount: 1,
                                                      fee: 0,
                                                      mnemonic: menmonic,
                                                      contact: payContract,
                                                      exchangeTokenContract: receiveContract,
                                                      exchangeTokenAmount: 100)
    }
    
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
//        self.dataModel.e
        
    }
    func selectToken(button: UIButton) {

//        if button.tag == 20 {
//            ViolasSocketManager.shared.openSocket()
//            ViolasSocketManager.shared.addMarketListening { (result) in
//                print(result)
//            }
//        } else {
//            ViolasSocketManager.shared.getMarketData(address: "")
//        }
        self.detailView.makeToastActivity(.center)
        self.dataModel.getMarketSupportToken(address: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89")
        self.actionClosure = { model in
            if let headerView = self.detailView.tableView.headerView(forSection: 0) as? MarketExchangeHeaderView {
                if button.tag == 20 {
                    headerView.leftTokenModel = model
                } else {
                    headerView.rightTokenModel = model
                }
            }
        }
//        self.dataModel.getCurrentOrder(baseAddress: "0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095", exchangeAddress: "0x4ce68dd6e81b400a4edf4146307b10e5030a372414fd49b1accecc0767753070")
    }
    func showOrderCenter() {
        let vc = OrderProcessingViewController()
        vc.hidesBottomBarWhenPushed = true
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
            self.detailView.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetTokenList" {
            if let tempData = jsonData.value(forKey: "data") as? [MarketSupportCoinDataModel] {
//                self.detailView.tableView.reloadData()
                let alert = TokenPickerViewAlert.init(successClosure: { (model) in
                    if let action = self.actionClosure {
                        action(model)
                    }
                }, data: tempData)
                alert.show()
                alert.showAnimation()
            }
        } else if type == "GetCurrentOrder" {
            if let tempData = jsonData.value(forKey: "data") as? MarketOrderModel {
//                self.detailView.tableView.reloadData()
                self.tableViewManager.buyOrders = tempData.buys
                self.tableViewManager.sellOrders = tempData.sells
                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
    }
}
