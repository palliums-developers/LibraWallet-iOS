//
//  OrderProcessingViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView
class OrderProcessingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载子View
//        self.view.addSubview(self.detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("SupportCoinViewController销毁了")
    }
    //网络请求、数据模型
    lazy var dataModel: OrderProcessingModel = {
        let model = OrderProcessingModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: OrderProcessingTableViewManager = {
        let manager = OrderProcessingTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : OrderProcessingView = {
        let view = OrderProcessingView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        view.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction:  #selector(refreshReceive))
        view.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingTarget: self, refreshingAction:  #selector(getMoreReceive))
        return view
    }()
    @objc func refreshReceive() {
        detailView.tableView.mj_footer.resetNoMoreData()
        detailView.tableView.mj_header.beginRefreshing()
        dataModel.getAllProcessingOrder(address: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89", version: "")
    }
    @objc func getMoreReceive() {
        detailView.tableView.mj_footer.beginRefreshing()
        if let version = self.tableViewManager.dataModel?.last?.version {
            dataModel.getAllProcessingOrder(address: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89", version: version)
        } else {
            detailView.tableView.mj_footer.endRefreshing()
        }
    }
    var myContext = 0
    var firstIn: Bool = true
}
extension OrderProcessingViewController: OrderProcessingTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: MarketOrderDataModel) {
        let vc = OrderDetailViewController()
        vc.headerData = model
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func cancelOrder(indexPath: IndexPath, model: MarketOrderDataModel) {
        
//        let menmonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
//        self.dataModel.cancelTransaction(sendAddress: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89",
//                                         fee: 0,
//                                         mnemonic: menmonic,
//                                         contact: model.tokenGive ?? "",
//                                         version: model.version ?? "")
        
        let alertView = UIAlertController.init(title: localLanguage(keyString: "提示"),
                                               message: localLanguage(keyString: "您确定要取消当前未完成订单吗？"),
                                               preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_cancel_button_title"), style: .default) { okAction in
        }
        let confirmAction = UIAlertAction.init(title:localLanguage(keyString: "wallet_add_asset_alert_confirm_button_title"), style: .default) { okAction in
            self.showPasswordAlert(model: model)
        }
        alertView.addAction(cancelAction)
        alertView.addAction(confirmAction)
        self.present(alertView, animated: true, completion: nil)
    }
    func showPasswordAlert(model: MarketOrderDataModel) {
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
//                let state = try LibraWalletManager.shared.isValidPaymentPassword(walletRootAddress: (self?.model?.walletRootAddress)!, password: password)
//                guard state == true else {
//                    self?.view.makeToast(LibraWalletError.WalletCheckPassword(reason: .passwordEmptyError).localizedDescription,
//                                         position: .center)
//                    return
//                }
                self?.detailView.toastView?.show()
//                let menmonic = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (self?.model?.walletRootAddress)!)
//                self?.viewModel.dataModel.publishViolasToken(sendAddress: (self?.model?.walletAddress)!, mnemonic: menmonic, contact: model.address ?? "")
                let menmonic = ["display", "paddle", "crush", "crowd", "often", "friend", "topple", "agent", "entry", "use", "host", "begin"]
                self?.dataModel.cancelTransaction(sendAddress: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89",
                                                 fee: 0,
                                                 mnemonic: menmonic,
                                                 contact: model.tokenGive ?? "",
                                                 version: model.version ?? "")
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

}
extension OrderProcessingViewController {
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
        self.detailView.makeToastActivity(.center)
        dataModel.getAllProcessingOrder(address: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89", version: "")
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
                self.detailView.toastView?.hide()
                self.detailView.makeToast(error.localizedDescription, position: .center)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
                self.detailView.tableView.mj_footer.endRefreshingWithNoMoreData()
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                print(error.localizedDescription)
                // 数据返回状态异常
            }
            self.detailView.hideToastActivity()
            self.detailView.tableView.mj_header.endRefreshing()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetAllProcessingOrderOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [MarketOrderDataModel] {
            //                self.detailView.tableView.reloadData()
                self.tableViewManager.dataModel = tempData
                           
                self.detailView.tableView.reloadData()
                self.detailView.tableView.mj_header.endRefreshing()
            }
        } else if type == "GetAllProcessingOrderMore" {
            guard let tempData = jsonData.value(forKey: "data") as? [MarketOrderDataModel] else {
                return
            }
            if let oldData = self.tableViewManager.dataModel, oldData.isEmpty == false {
                let tempArray = NSMutableArray.init(array: oldData)
                let insertIndexPath = NSMutableArray()
                for index in 0..<tempData.count {
                    let indexPath = IndexPath.init(row: oldData.count + index, section: 0)
                    insertIndexPath.add(indexPath)
                }
                tempArray.addObjects(from: tempData)
                self.tableViewManager.dataModel = tempArray as? [MarketOrderDataModel]
                self.detailView.tableView.beginUpdates()
                self.detailView.tableView.insertRows(at: insertIndexPath as! [IndexPath], with: UITableView.RowAnimation.bottom)
                self.detailView.tableView.endUpdates()
            } else {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
            self.detailView.tableView.mj_footer.endRefreshing()
        } else {
            self.detailView.toastView?.hide()
            self.detailView.makeToast(localLanguage(keyString: "取消成功"))
        }
        self.detailView.hideToastActivity()
    }
}
extension OrderProcessingViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.detailView
    }
    /// 可选实现，列表显示的时候调用
    func listDidAppear() {
        //防止重复加载数据
        guard firstIn == true else {
            return
        }
        self.detailView.makeToastActivity(.center)
        dataModel.getAllProcessingOrder(address: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89", version: "")
        firstIn = false
    }
    /// 可选实现，列表消失的时候调用
    func listDidDisappear() {
        
    }
}
