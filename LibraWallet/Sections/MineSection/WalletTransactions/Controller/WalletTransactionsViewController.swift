//
//  WalletTransactionsViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletTransactionsViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setNavigationWithoutShadowImage()
        // 设置标题
//        self.title = localLanguage(keyString: "wallet_withdraw_address_list_navigationbar_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        //设置空数据页面
        setEmptyView()
        // 初始化KVO
        self.viewModel.initKVO()
        //设置默认页面（无数据、无网络）
        setPlaceholderView()
        //网络请求
        requestData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    //MARK: - 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "withdraw_address_list_empty_icon"
            empty.tipString = localLanguage(keyString: "wallet_withdraw_address_list_empty_view_content")
        }
    }
    //MARK: - 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        self.viewModel.detailView.makeToastActivity(.center)
        switch transactionType {
        case .Libra:
            viewModel.dataModel.getLibraTransactionHistory(address: (wallet?.walletAddress)!, page: 0, pageSize: 10, requestStatus: 0)
        case .Violas:
            viewModel.dataModel.getViolasTransactionHistory(address: (wallet?.walletAddress)!, page: 0, pageSize: 10, requestStatus: 0)
        case .BTC:
            viewModel.dataModel.getBTCTransactionHistory(address: (wallet?.walletAddress)!, page: 1, pageSize: 10, requestStatus: 0)
        default:
            break
        }
        
    }
    override func hasContent() -> Bool {
        switch transactionType {
        case .Libra:
            if let addresses = self.viewModel.tableViewManager.libraTransactions, addresses.isEmpty == false {
                return true
            } else {
                return false
            }
        case .Violas:
            if let addresses = self.viewModel.tableViewManager.violasTransactions, addresses.isEmpty == false {
                return true
            } else {
                return false
            }
        case .BTC:
            if let addresses = self.viewModel.tableViewManager.btcTransactions, addresses.isEmpty == false {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    typealias nextActionClosure = (String) -> Void
    var actionClosure: nextActionClosure?
    deinit {
        print("AddressManagerViewController销毁了")
    }
    lazy var viewModel: WalletTransactionsViewModel = {
        let viewModel = WalletTransactionsViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
    var transactionType: WalletType? {
        didSet {
            self.viewModel.tableViewManager.transactionType = transactionType
        }
    }
    var wallet: LibraWalletManager? {
        didSet {
            self.viewModel.wallet = wallet
        }
    }
}
extension WalletTransactionsViewController: WalletTransactionsTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
        if let action = self.actionClosure {
            action(address)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
