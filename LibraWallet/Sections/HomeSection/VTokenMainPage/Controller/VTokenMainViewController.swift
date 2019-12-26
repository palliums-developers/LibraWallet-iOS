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
        self.view.addSubview(viewModel.detailView)
//        self.detailView.wallet = self.wallet
        self.viewModel.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.detailView.snp.makeConstraints { (make) in
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
    lazy var viewModel: VTokenViewModel = {
        let viewModel = VTokenViewModel.init()
        viewModel.detailView.headerView.delegate = self
        return viewModel
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var myContext = 0
    var wallet: LibraWalletManager? {
        didSet {
            self.viewModel.detailView.headerView.walletAddressLabel.text = wallet?.walletAddress
            self.viewModel.wallet = wallet
        }
    }
    var vtokenModel: ViolasTokenModel? {
        didSet {
            self.viewModel.detailView.headerView.assetLabel.text = "\(Double(vtokenModel?.balance ?? 0) / 1000000.0)"
            self.viewModel.detailView.headerView.assetUnitLabel.text = vtokenModel?.name
            self.viewModel.vtokenModel = vtokenModel
        }
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
