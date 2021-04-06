//
//  AssetsPoolViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/3.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

protocol AssetsPoolViewModelDelegate: NSObjectProtocol {
    func reloadSelectTokenViewA()
    func reloadSelectTokenViewB()
    func reloadMineLiquidityView()
    func reloadLiquidityRateView()
    func showToast(tag: Int)
    func hideToast(tag: Int)
    func requestError(errorMessage: String)
    func successAddLiquidity()
    func successRemoveLiquidity()
}
protocol AssetsPoolViewModelInterface  {
    /// 付出Token
    var tokenModelA: MarketSupportTokensDataModel? { get }
    /// 付出Token
    var tokenModelB: MarketSupportTokensDataModel? { get }
    /// 我的通证
    var mineLiquidityModel: [MarketMineMainTokensDataModel]? { get }
    /// 流动性Model
    var modelABLiquidityInfo: AssetsPoolsInfoDataModel? { get }
}
class AssetsPoolViewModel: NSObject, AssetsPoolViewModelInterface {
    weak var delegate: AssetsPoolViewModelDelegate?

    var tokenModelA: MarketSupportTokensDataModel? {
        return self.modelA
    }
    
    var tokenModelB: MarketSupportTokensDataModel? {
        return self.modelB
    }
    
    var mineLiquidityModel: [MarketMineMainTokensDataModel]? {
        return self.mineLiquidity
    }
    
    var modelABLiquidityInfo: AssetsPoolsInfoDataModel? {
        return self.modelABLiquidity
    }
    /// 网络请求、数据模型
    lazy var dataModel: AssetsPoolModel = {
        let model = AssetsPoolModel.init()
        return model
    }()
    
    private var modelA: MarketSupportTokensDataModel? {
        didSet {
            self.delegate?.reloadSelectTokenViewA()
        }
    }
    private var modelB: MarketSupportTokensDataModel? {
        didSet {
            self.delegate?.reloadSelectTokenViewB()
        }
    }
    private var mineLiquidity: [MarketMineMainTokensDataModel]? {
        didSet {
            self.delegate?.reloadMineLiquidityView()
        }
    }
    private var modelABLiquidity: AssetsPoolsInfoDataModel? {
        didSet {
            self.delegate?.reloadLiquidityRateView()
        }
    }
}
extension AssetsPoolViewModel {
    func requestMineLiquidity() {
        self.dataModel.getMarketMineTokens(address: Wallet.shared.violasAddress ?? "") { [weak self] (result) in
            switch result {
            case let .success(model):
                print("\(model)")
                self?.mineLiquidity = model.balance
            case let .failure(error):
                self?.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
    func requestMarketTokens(tag: Int) {
        self.dataModel.getMarketTokens(address: Wallet.shared.violasAddress ?? "") { [weak self] (result) in
            self?.delegate?.hideToast(tag: 99)
            switch result {
            case let .success(models):
                guard models.isEmpty == false else {
                    self?.delegate?.requestError(errorMessage: LibraWalletError.WalletMarket(reason: .marketOffline).localizedDescription)
                    return
                }
                let tempData = models.filter {
                    $0.module != (tag == 10 ? self?.modelB:self?.modelA)?.module
                }
                let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                    print(model)
                    if tag == 10 {
                        self?.modelA = model
                    } else {
                        self?.modelB = model
                    }
                }
                alert.show(tag: 199)
                alert.showAnimation()
            case let .failure(error):
                self?.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
    func getPoolLiquidity(coinA: String, coinB: String) {
        self.dataModel.getPoolLiquidity(coinA: coinA, coinB: coinB) { (result) in
            switch result {
            case let .success(model):
                self.modelABLiquidity = model
            case let .failure(error):
                self.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
    func confirmAddLiquidity(amountIn: UInt64, amountOut: UInt64, inputModelName: String, outputModelName: String) {
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                self?.delegate?.showToast(tag: 99)
                self?.dataModel.sendAddLiquidityViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "", amounta_desired: amountIn, amountb_desired: amountOut, amounta_min: UInt64(Double(amountIn) * 0.995), amountb_min: UInt64(Double(amountOut) * 0.995), fee: 0, mnemonic: mnemonic, moduleA: inputModelName, moduleB: outputModelName, feeModule: inputModelName) { [weak self] (result) in
                    self?.delegate?.hideToast(tag: 99)
                    switch result {
                    case .success(_):
                        self?.delegate?.successAddLiquidity()
                    case let .failure(error):
                        self?.delegate?.requestError(errorMessage: error.localizedDescription)
                    }
                }
            case let .failure(error):
                guard error.localizedDescription != "Cancel" else {
                    return
                }
                self?.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
    func confirmRemoveLiquidity(liquidityAmount: Double, amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String) {
        WalletManager.unlockWallet { [weak self] (result) in
            switch result {
            case let .success(mnemonic):
                self?.delegate?.showToast(tag: 99)
                self?.dataModel.sendRemoveLiquidityViolasTransaction(sendAddress: Wallet.shared.violasAddress ?? "", liquidity: liquidityAmount, amounta_min: amountIn, amountb_min: amountOut, fee: 0, mnemonic: mnemonic, moduleA: inputModelName, moduleB: outputModelName, feeModule: inputModelName) { [weak self] (result) in
                    self?.delegate?.hideToast(tag: 99)
                    switch result {
                    case .success(_):
                        self?.delegate?.successRemoveLiquidity()
                    case let .failure(error):
                        self?.delegate?.requestError(errorMessage: error.localizedDescription)
                    }
                }
            case let .failure(error):
                guard error.localizedDescription != "Cancel" else {
                    return
                }
                self?.delegate?.requestError(errorMessage: error.localizedDescription)
            }
        }
    }
}
extension AssetsPoolViewModel {

}
