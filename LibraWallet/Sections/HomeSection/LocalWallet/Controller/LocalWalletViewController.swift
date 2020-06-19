//
//  LocalWalletViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/11.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class LocalWalletViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 页面标题
        self.title = localLanguage(keyString: "wallet_mapping_receive_wallet_navigationbar_title")
        // 加载子View
        self.view.addSubview(self.detailView)
        // 加载数据
        self.initKVO()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
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
        print("WalletListController销毁了")
    }
    typealias nextActionClosure = (ControllerAction, Token) -> Void
    var actionClosure: nextActionClosure?
    //网络请求、数据模型
    lazy var dataModel: LocalWalletModel = {
        let model = LocalWalletModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: LocalWalletTableViewManager = {
        let manager = LocalWalletTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : LocalWalletView = {
        let view = LocalWalletView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    var observer: NSKeyValueObservation?
    var walletType: WalletType?
}
extension LocalWalletViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
//                self?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletTokenExpired).localizedDescription {
                    // 钱包不存在
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 数据为空
                }
//                self.detailView.hideToastActivity()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "LoadLocalWallets" {
                if let tempData = dataDic.value(forKey: "data") as? [[Token]] {
                    self?.tableViewManager.originModel = tempData
                    self?.tableViewManager.dataModel = tempData

                    self?.detailView.tableView.reloadData()
                }
            }
//            self.detailView.hideToastActivity()
        })
//        switch self.walletType {
//        case .BTC:
//            self.dataModel.loadLocalWallet(walletType: .Violas)
//        case .Violas:
//            #warning("待处理")
////            self.dataModel.loadLocalWallet(walletType: .BTC)
//            self.dataModel.loadLocalWallet(walletType: .Libra)
//        case .Libra:
//            self.dataModel.loadLocalWallet(walletType: .Violas)
//        default:
//            print("异常")
//        }
        self.dataModel.loadLocalWallet(walletType: self.walletType!)
    }

}
extension LocalWalletViewController: LocalWalletTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, model: Token) {
        print(indexPath.row)
        if let action = self.actionClosure {
//            LibraWalletManager.shared.changeDefaultWallet(wallet: model)
            action(.update, model)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
