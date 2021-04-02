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
    func reloadLiquidityView()
    func showToast(tag: Int)
    func hideToast(tag: Int)
    func requestError(errorMessage: String)
}
protocol AssetsPoolViewModelInterface  {
    /// 付出Token
    var tokenModelA: MarketSupportTokensDataModel? { get }
    /// 付出Token
    var tokenModelB: MarketSupportTokensDataModel? { get }
    /// 流动性Model
    var liquidityModel: [MarketMineMainTokensDataModel]? { get }
}
class AssetsPoolViewModel: NSObject, AssetsPoolViewModelInterface {
    weak var delegate: AssetsPoolViewModelDelegate?

    var tokenModelA: MarketSupportTokensDataModel? {
        return self.modelA
    }
    
    var tokenModelB: MarketSupportTokensDataModel? {
        return self.modelB
    }
    
    var liquidityModel: [MarketMineMainTokensDataModel]? {
        return self.liquidity
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
    private var liquidity: [MarketMineMainTokensDataModel]? {
        didSet {
            self.delegate?.reloadLiquidityView()
        }
    }
}
extension AssetsPoolViewModel {
    func requestMineLiquidity() {
        self.dataModel.getMarketMineTokens(address: Wallet.shared.violasAddress ?? "") { [weak self] (result) in
            switch result {
            case let .success(model):
                print("\(model)")
                self?.liquidity = model.balance
            case let .failure(error):
                print(error.localizedDescription)
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
                print(error.localizedDescription)
            }
        }
    }
}
extension AssetsPoolViewModel {

}
