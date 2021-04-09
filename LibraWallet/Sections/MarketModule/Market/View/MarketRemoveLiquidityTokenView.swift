//
//  MarketRemoveLiquidityTokenView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/4/8.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit

class MarketRemoveLiquidityTokenView: UIView {
//    weak var delegate: MarketTokenSelectViewViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(tokenBackgroundView)
        tokenBackgroundView.addSubview(titleLabel)
        tokenBackgroundView.addSubview(outputCoinAAmountLabel)
        tokenBackgroundView.addSubview(outputCoinBAmountLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketRemoveLiquidityTokenView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView).offset(16)
            make.left.equalTo(tokenBackgroundView).offset(15)
        }
        outputCoinAAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tokenBackgroundView).offset(11)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputCoinBAmountLabel.snp.top)
            
            make.height.equalTo(24)
        }
        outputCoinBAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tokenBackgroundView).offset(11)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(tokenBackgroundView.snp.bottom).offset(-7)
            make.height.equalTo(24)
        }
    }
    private lazy var tokenBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.init(hex: "C2C2C2").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
        return label
    }()
    lazy var outputCoinAAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        label.text = "---"
        return label
    }()
    lazy var outputCoinBAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 20)
        label.text = "---"
        return label
    }()
    var transferOutModel: AssetsPoolTransferOutInfoDataModel? {
        didSet {
            guard let model = transferOutModel else {
                return
            }
            let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coin_a_value ?? 0),
                                           scale: 6,
                                           unit: 1000000)
            outputCoinAAmountLabel.text = amountA.stringValue + (model.coin_a_name ?? "---")
            
            let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coin_b_value ?? 0),
                                           scale: 6,
                                           unit: 1000000)
            outputCoinBAmountLabel.text = amountB.stringValue + (model.coin_b_name ?? "---")
        }
    }
}
extension MarketRemoveLiquidityTokenView {
    func initialView() {
        outputCoinAAmountLabel.text = "---"
        outputCoinBAmountLabel.text = "---"
        transferOutModel = nil
    }
}
