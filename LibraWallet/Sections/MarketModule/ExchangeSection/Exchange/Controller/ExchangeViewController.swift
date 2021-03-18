//
//  ExchangeViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
class ExchangeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(detailView)
        self.viewModel.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("ExchangeViewController销毁了")
    }
    /// 子View
    lazy var detailView : ExchangeView = {
        let view = ExchangeView.init()
        view.headerView.delegate = self
        return view
    }()
    /// ViewModel
    lazy var viewModel: ExchangeViewModel = {
        let viewModel = ExchangeViewModel.init()
        viewModel.delegate = self
        return viewModel
    }()
}
extension ExchangeViewController: ExchangeViewModelDelegate {
    func reloadSelectTokenViewA() {
        self.detailView.headerView.tokenSelectViewA.swapTokenModel = self.viewModel.tokenModelA
        self.detailView.toastView.hide(tag: 99)
    }
    func reloadSelectTokenViewB() {
        self.detailView.headerView.tokenSelectViewB.swapTokenModel = self.viewModel.tokenModelB
        self.detailView.toastView.hide(tag: 99)
    }
    func reloadView() {
        self.detailView.headerView.exchangeModel = self.viewModel.swapInfoModel
    }
}
extension ExchangeViewController: ExchangeViewHeaderViewDelegate {
    func selectInputToken() {
        self.detailView.toastView.show(tag: 99)
        self.viewModel.requestSupportTokens(tag: 10)
    }
    
    func selectOutoutToken() {
        self.detailView.toastView.show(tag: 99)
        self.viewModel.requestSupportTokens(tag: 20)
    }
    
    func swapInputOutputToken() {
        print("swapInputOutputToken")
//        self.viewModel.swapInputOutputToken()
    }
    
    func exchangeConfirm() {
        self.viewModel.exchangeConfirm()
    }
    func filterBestOutput(amount: Int64) {
        self.viewModel.fliterBestOutputAmount(inputAmount: amount)
    }
    
    func filterBestIntput(amount: Int64) {
        self.viewModel.fliterBestInputAmount(outputAmount: amount)
    }
}
