//
//  AssetsPoolViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import MJRefresh
class AssetsPoolViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    lazy var viewModel: AssetsPoolViewModel = {
        let model = AssetsPoolViewModel.init()
        model.delegate = self
        return model
    }()
    /// 子View
    lazy var detailView : AssetsPoolView = {
        let view = AssetsPoolView.init()
        view.headerView.delegate = self
        return view
    }()
    
    var currentTokens: [MarketMineMainTokensDataModel]?
    
}
extension AssetsPoolViewController: AssetsPoolViewHeaderViewDelegate {
    
    func getPoolLiquidity(inputModuleName: String, outputModuleName: String) {
        self.detailView.toastView.show(tag: 99)
        self.viewModel.getPoolLiquidity(coinA: inputModuleName,
                                        coinB: outputModuleName)
    }
    func addLiquidityConfirm(amountIn: UInt64, amountOut: UInt64, inputModelName: String, outputModelName: String) {
        self.viewModel.confirmAddLiquidity(amountIn: amountIn, amountOut: amountOut, inputModelName: inputModelName, outputModelName: outputModelName)
    }
    func removeLiquidityConfirm(token: Double, amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String) {
        self.viewModel.confirmRemoveLiquidity(liquidityAmount: token, amountIn: amountIn, amountOut: amountOut, inputModelName: inputModelName, outputModelName: outputModelName)
    }
    func selectInputToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView.show(tag: 99)
            self.viewModel.requestMarketTokens(tag: 10)
        } else {
            // 转出
            self.detailView.makeToastActivity(.center)
            self.viewModel.requestMineLiquidity()
        }
    }
    func selectOutoutToken() {
        if self.detailView.headerView.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.detailView.toastView.show(tag: 99)
            self.viewModel.requestMarketTokens(tag: 20)
        }
    }
    func changeTrasferInOut() {
        
    }
}
extension AssetsPoolViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        self.detailView.headerView.tokenModel = self.currentTokens?[path.row]
        self.detailView.toastView.show(tag: 99)
        self.viewModel.getPoolLiquidity(coinA: self.currentTokens?[path.row].coin_a?.module ?? "",
                                        coinB: self.currentTokens?[path.row].coin_b?.module ?? "")
    }
}
extension AssetsPoolViewController: AssetsPoolViewModelDelegate {
    func reloadSelectTokenViewA() {
        self.detailView.toastView.hide(tag: 99)
        self.detailView.headerView.transferInInputTokenA = self.viewModel.tokenModelA
    }
    func reloadSelectTokenViewB() {
        self.detailView.toastView.hide(tag: 99)
        self.detailView.headerView.transferInInputTokenB = self.viewModel.tokenModelB
    }
    func reloadMineLiquidityView() {
        self.detailView.hideToastActivity()
        var tempDropperData = [String]()
        guard let model = self.viewModel.mineLiquidityModel, model.isEmpty == false else {
            
            self.detailView.makeToast(LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription, position: .center)
            return
        }
        for item in self.viewModel.mineLiquidityModel! {
            let tokenNameString = (item.coin_a?.show_name ?? "---") + "/" + (item.coin_b?.show_name ?? "---")
            tempDropperData.append(tokenNameString)
        }
        self.currentTokens = self.viewModel.mineLiquidityModel!
        let realHeight = CGFloat((self.viewModel.mineLiquidityModel?.count ?? 34) * 34)
        let height = realHeight > 34*6 ? 34*6:realHeight
        let dropper = Dropper.init(width: 120, height: height)
        dropper.items = tempDropperData
        dropper.cornerRadius = 8
        dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
        dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "333333")
        dropper.spacing = 12
        dropper.delegate = self
        if self.detailView.headerView.inputTokenButton.titleLabel?.text != localLanguage(keyString: "wallet_market_exchange_input_token_button_title") {
            let index = tempDropperData.firstIndex(of: self.detailView.headerView.inputTokenButton.titleLabel?.text ?? "")
            dropper.defaultSelectRow = index
        }
        dropper.show(Dropper.Alignment.center, button: (self.detailView.headerView.inputTokenButton))
    }
    func reloadLiquidityRateView() {
        self.detailView.toastView.hide(tag: 99)
        self.detailView.headerView.liquidityInfoModel = self.viewModel.modelABLiquidityInfo
    }
    func showToast(tag: Int) {
        self.detailView.toastView.show(tag: tag)
    }
    func hideToast(tag: Int) {
        self.detailView.toastView.hide(tag: tag)
    }
    func requestError(errorMessage: String) {
        self.detailView.makeToast(errorMessage, position: .center)
    }
    func successAddLiquidity() {
        self.detailView.headerView.inputAmountTextField.text = ""
        self.detailView.headerView.outputAmountTextField.text = ""
        self.detailView.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
    }
    func successRemoveLiquidity() {
        self.detailView.headerView.inputAmountTextField.text = ""
        self.detailView.headerView.outputAmountTextField.text = ""
        self.detailView.headerView.outputCoinAAmountLabel.text = "---"
        self.detailView.headerView.outputCoinBAmountLabel.text = "---"
        self.detailView.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
    }
}
