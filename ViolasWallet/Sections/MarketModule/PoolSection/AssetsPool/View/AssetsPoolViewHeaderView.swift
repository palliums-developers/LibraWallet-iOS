//
//  AssetsPoolViewHeaderView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

protocol AssetsPoolViewHeaderViewDelegate: NSObjectProtocol {
    func addLiquidityConfirm()
    func removeLiquidityConfirm()
    func selectInputToken()
    func selectOutoutToken()
}
class AssetsPoolViewHeaderView: UIView {
    weak var delegate: AssetsPoolViewHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(changeTypeButton)
        addSubview(feeLabel)
        addSubview(tokenSelectViewA)
        addSubview(swapButton)
        addSubview(tokenSelectViewB)
        addSubview(tokenRemoveLiquidityView)
        addSubview(exchangeRateLabel)
        addSubview(confirmButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolViewHeaderView销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        changeTypeButton.snp.makeConstraints { (make) in
            make.left.equalTo(tokenSelectViewA.snp.left).offset(5).priority(250)
            make.bottom.equalTo(tokenSelectViewA.snp.top).offset(-6).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20)).priority(250)
        }
        feeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(tokenSelectViewA.snp.right).offset(-6)
            make.bottom.equalTo(tokenSelectViewA.snp.top).offset(-6)
        }
        tokenSelectViewA.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(40)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 80))
        }
        swapButton.snp.makeConstraints { (make) in
            make.top.equalTo(tokenSelectViewA.snp.bottom).offset(6)
            make.centerX.equalTo(tokenSelectViewA)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        tokenSelectViewB.snp.makeConstraints { (make) in
            make.top.equalTo(tokenSelectViewA.snp.bottom).offset(33)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 80))
        }
        tokenRemoveLiquidityView.snp.makeConstraints { (make) in
            make.top.equalTo(tokenSelectViewA.snp.bottom).offset(33)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(ratio(number: 95))
        }
        exchangeRateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenSelectViewB.snp.bottom).offset(6).priority(250)
            make.left.equalTo(tokenSelectViewB).offset(15).priority(250)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(tokenSelectViewB.snp.bottom).offset(66).priority(250)
            make.size.equalTo(CGSize.init(width: 238, height: 40)).priority(250)
            make.centerX.equalTo(self).priority(250)
        }
    }
    lazy var changeTypeButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.backgroundColor = UIColor.init(hex: "F1EEFB").cgColor
        button.layer.cornerRadius = 10
        button.tag = 10
        return button
    }()
    lazy var feeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_fee_title")
        return label
    }()
    lazy var tokenSelectViewA: MarketTokenSelectView = {
        let view = MarketTokenSelectView.init()
        view.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
        view.tag = 10
        view.inputAmountTextField.tag = 10
        view.delegate = self
        return view
    }()
    lazy var swapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("&", for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "999999"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        return button
    }()
    lazy var tokenSelectViewB: MarketTokenSelectView = {
        let view = MarketTokenSelectView.init()
        view.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
        view.tag = 20
        view.inputAmountTextField.tag = 20
        view.delegate = self
        return view
    }()
    lazy var tokenRemoveLiquidityView: MarketRemoveLiquidityTokenView = {
        let view = MarketRemoveLiquidityTokenView.init()
        view.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_output_amount_title")
        view.tag = 30
        view.alpha = 0
        return view
    }()
    lazy var exchangeRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title") + "---"
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69
        
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 100
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.changePoolType()
        } else if button.tag == 100 {
            self.tokenSelectViewA.inputAmountTextField.resignFirstResponder()
            self.tokenSelectViewB.inputAmountTextField.resignFirstResponder()
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 添加流动性
                self.delegate?.addLiquidityConfirm()
            } else {
                // 移除流动性
                self.delegate?.removeLiquidityConfirm()
            }
        }
    }
    // 设置兑换率
    var modelABLiquidityInfo: AssetsPoolsInfoDataModel? {
        didSet {
            guard let model = modelABLiquidityInfo else {
                return
            }
            let coinAAmount = NSDecimalNumber.init(value: model.coina?.value ?? 0)
            let coinBAmount = NSDecimalNumber.init(value: model.coinb?.value ?? 0)
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 6,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let rate = coinBAmount.dividing(by: coinAAmount, withBehavior: numberConfig)
            self.exchangeRateLabel.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title") + "1:\(rate.stringValue)"
        }
    }
    var addLiquidityMode: Bool = true
}
extension AssetsPoolViewHeaderView: DropperDelegate {
    func changePoolType() {
        let dropper = Dropper.init(width: self.changeTypeButton.frame.size.width, height: 68, button: self.changeTypeButton)
        dropper.items = [localLanguage(keyString: "wallet_assets_pool_transfer_in_title"),
                         localLanguage(keyString: "wallet_assets_pool_transfer_out_title")]
        dropper.cornerRadius = 8
        dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
        dropper.cellTextFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "333333")
        dropper.spacing = 12
        dropper.delegate = self
        dropper.isInvisableBackground = true
        if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            dropper.defaultSelectRow = 0
        } else {
            dropper.defaultSelectRow = 1
        }
        dropper.show(Dropper.Alignment.center, button: self.changeTypeButton)
    }
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        print(contents)
        if contents == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            self.initialAddLiquidityView()
        } else {
            // 转出
            self.initialRemoveLiquidityView()
        }
        changeTypeButton.snp.remakeConstraints { (make) in
            make.left.equalTo(tokenSelectViewA.snp.left).offset(5)
            make.bottom.equalTo(tokenSelectViewA.snp.top).offset(-6)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20))
        }
        // 调整位置
        changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
    }
    private func initialAddLiquidityView() {
        self.addLiquidityMode = true
        self.tokenSelectViewB.alpha = 1
        self.tokenRemoveLiquidityView.alpha = 0
        changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
        // 调整位置
        exchangeRateLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(tokenSelectViewB.snp.bottom).offset(6)
        }
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_confirm_button_title"), for: UIControl.State.normal)
        confirmButton.snp.remakeConstraints { (make) in
            make.top.equalTo(tokenSelectViewB.snp.bottom).offset(66)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
            make.centerX.equalTo(self)
        }
        // 重置页面
        self.tokenSelectViewA.initialView(type: "in")
        self.tokenSelectViewB.initialView(type: "in")
    }
    private func initialRemoveLiquidityView() {
        self.addLiquidityMode = false
        self.tokenSelectViewB.alpha = 0
        self.tokenRemoveLiquidityView.alpha = 1
        changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_out_title"), for: UIControl.State.normal)
        exchangeRateLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(tokenSelectViewB.snp.bottom).offset(6 + 15)
        }
        confirmButton.setTitle(localLanguage(keyString: "wallet_market_assets_pool_remove_liquidity_confirm_button_title"), for: UIControl.State.normal)
        confirmButton.snp.remakeConstraints { (make) in
            make.top.equalTo(tokenSelectViewB.snp.bottom).offset(66 + 15)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
            make.centerX.equalTo(self)
        }
        // 重置页面
        self.tokenSelectViewA.initialView(type: "out")
        self.tokenRemoveLiquidityView.initialView()
    }
}
extension AssetsPoolViewHeaderView: MarketTokenSelectViewViewDelegate {
    func selectToken(view: UIView) {
        if view.tag == 10 {
            self.delegate?.selectInputToken()
        } else if view.tag == 20 {
            self.delegate?.selectOutoutToken()
        }
    }
}
// MARK: - 语言切换
extension AssetsPoolViewHeaderView {
    @objc func setText() {
        //  刷新类型切换大小
        if addLiquidityMode == true {
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
            tokenSelectViewA.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
            tokenSelectViewB.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_input_amount_title")
        } else {
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_out_title"), for: UIControl.State.normal)
            tokenSelectViewA.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_output_token_title")
            tokenSelectViewB.titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_output_amount_title")
        }
        changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        changeTypeButton.snp.remakeConstraints { (make) in
            make.left.equalTo(tokenSelectViewA.snp.left).offset(5)
            make.bottom.equalTo(tokenSelectViewA.snp.top).offset(-6)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20))
        }

        feeLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_fee_title")
        if tokenSelectViewA.swapTokenModel == nil {
            tokenSelectViewA.tokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
            tokenSelectViewA.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            tokenSelectViewA.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenSelectViewA.snp.right).offset(-11)
                make.bottom.equalTo(tokenSelectViewA.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: tokenSelectViewA.swapTokenModel?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            tokenSelectViewA.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
        }

        if tokenSelectViewB.swapTokenModel == nil {
            self.tokenSelectViewB.tokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
            self.tokenSelectViewB.tokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            self.tokenSelectViewB.tokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(tokenSelectViewB.snp.right).offset(-11)
                make.bottom.equalTo(tokenSelectViewB.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            tokenSelectViewB.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + "---"
        } else {
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: tokenSelectViewB.swapTokenModel?.amount ?? 0),
                                          scale: 6,
                                          unit: 1000000)
            tokenSelectViewB.balanceAmountLabel.text = localLanguage(keyString: "wallet_market_assets_pool_add_liquidity_token_title") + amount.stringValue
        }
        if modelABLiquidityInfo == nil {
            exchangeRateLabel.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title") + "---"
        } else {
            let coinAAmount = NSDecimalNumber.init(value: modelABLiquidityInfo?.coina?.value ?? 0)
            let coinBAmount = NSDecimalNumber.init(value: modelABLiquidityInfo?.coinb?.value ?? 0)
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 6,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let rate = coinBAmount.dividing(by: coinAAmount, withBehavior: numberConfig)
            exchangeRateLabel.text = localLanguage(keyString: "wallet_market_assets_pool_exchange_rate_title") + "1:\(rate.stringValue)"
        }
    }
}
