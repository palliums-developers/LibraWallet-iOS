//
//  AddressManagerViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
class AddressManagerViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
//        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_address_navigation_title")
        // 加载子View
        self.view.addSubview(self.detailView)
        // 添加NavigationRightBar
        self.addNavigationRightBar()
        //设置空数据页面
        setEmptyView()
        // 初始化KVO
        self.initKVO()
        //设置默认页面（无数据、无网络）
        setPlaceholderView()
        //网络请求
        requestData()
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
    deinit {
        print("AddressManagerViewController销毁了")
    }
    //MARK: - 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "transactions_empty"
            empty.tipString = localLanguage(keyString: "wallet_address_manager_empty_data_title")
        }
    }
    //MARK: - 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        self.detailView.makeToastActivity(.center)
        dataModel.getWithdrawAddressHistory(type: addressType ?? "", requestStatus: 0)
    }
    override func hasContent() -> Bool {
        if let addresses = self.tableViewManager.dataModel, addresses.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    //MARK: - 属性
    typealias nextActionClosure = (String) -> Void
    var actionClosure: nextActionClosure?
    /// 网络请求、数据模型
    lazy var dataModel: AddressManagerModel = {
        let model = AddressManagerModel.init()
        return model
    }()
    /// tableView管理类
    lazy var tableViewManager: AddressManagerTableViewManager = {
        let manager = AddressManagerTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    /// 子View
    lazy var detailView : AddressManagerView = {
        let view = AddressManagerView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    lazy var addAddressButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "add"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addAddressMethod), for: .touchUpInside)
        return button
    }()
    var myContext = 0
    /// 展示地址类型
    var addressType: String?
}
extension AddressManagerViewController {
    func addNavigationRightBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: addAddressButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 5
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [barButtonItem, backView]
    }
    @objc func addAddressMethod() {
        let vc = AddAddressViewController()
        vc.actionClosure = { [weak self](action, model) in
            self?.startLoading ()
            if let oldData = self?.tableViewManager.dataModel, oldData.isEmpty == false {
                let tempArray = NSMutableArray.init(array: oldData)
                tempArray.add(model)
                self?.tableViewManager.dataModel = tempArray as? [AddressModel]
                self?.detailView.tableView.beginUpdates()
                self?.detailView.tableView.insertRows(at: [IndexPath.init(row: oldData.count, section: 0)], with: UITableView.RowAnimation.bottom)
                self?.detailView.tableView.endUpdates()
            } else {
                self?.tableViewManager.dataModel = [model]
                self?.detailView.tableView.reloadData()
            }
            self?.endLoading()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension AddressManagerViewController {
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
                // 数据状态异常
            }
            self.detailView.hideToastActivity()
            self.endLoading()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        if type == "TransferAddressOrigin" {
            if let tempData = jsonData.value(forKey: "data") as? [AddressModel] {
                self.tableViewManager.dataModel = tempData
                self.detailView.tableView.reloadData()
            }
        }
        self.detailView.hideToastActivity()
        self.endLoading()
    }
}
extension AddressManagerViewController: AddressManagerTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
        if let action = self.actionClosure {
            action(address)
            self.navigationController?.popViewController(animated: true)
        }
    }
    func tableViewDeleteRowAtIndexPath(indexPath: IndexPath, model: AddressModel) {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_alert_delete_address_title"), message: localLanguage(keyString: "wallet_alert_delete_address_content"), preferredStyle: .alert)
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_alert_delete_address_confirm_button_title"), style: .default){ [weak self] clickHandler in
            self?.deleteAddress(indexPath: indexPath, model: model)
        })
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_alert_delete_address_cancel_button_title"), style: .cancel){ clickHandler in
            NSLog("点击了取消")
        })
        self.present(alertContr, animated: true, completion: nil)
        
    }
    func deleteAddress(indexPath: IndexPath, model: AddressModel) {
        let deleteStatus = DataBaseManager.DBManager.deleteTransferAddressFromTable(model: model)
        guard deleteStatus == true else {
            self.view.makeToast(localLanguage(keyString: "wallet_transection_address_delete_error"), position: .center)
            return
        }
        self.tableViewManager.dataModel = self.tableViewManager.dataModel?.filter({
            $0.addressID != model.addressID
        })
        self.detailView.tableView.beginUpdates()
        self.detailView.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
        self.detailView.tableView.endUpdates()
        if (lastState == .Loading) {return}
        startLoading ()
        endLoading()
    }
}
