//
//  AssetsPoolViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol AssetsPoolViewHeaderViewDelegate: NSObjectProtocol {
    func addLiquidityConfirm(amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String)
    func removeLiquidityConfirm(token: Double, amountIn: Double, amountOut: Double, inputModelName: String, outputModelName: String)
    func selectInputToken()
    func selectOutoutToken()
//    func swapInputOutputToken()
    func changeTrasferInOut()
    func dealTransferOutAmount(amount: Int64, coinAModule: String, coinBModule: String)
}
enum AssetsPoolViewHeaderViewState {
    case Normal
    case ExchangeTransferInSwap

    case AssetsPoolTransferInSelectAToken
    case AssetsPoolTransferInSelectBToken
    case AssetsPoolTransferInRequestRate
    case AssetsPoolTransferOutSelectToken
    case AssetsPoolTransferOutRequestLiquidityRate
    case AssetsPoolTransferOutAddLiquidity
    case AssetsPoolTransferOutRemoveLiquidity
}
class AssetsPoolViewHeaderView: UIView {
    weak var delegate: AssetsPoolViewHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(changeTypeButton)
        addSubview(feeLabel)
        addSubview(inputTokenBackgroundView)
        inputTokenBackgroundView.addSubview(inputTitleLabel)
        inputTokenBackgroundView.addSubview(inputTokenAssetsImageView)
        inputTokenBackgroundView.addSubview(inputTokenAssetsLabel)
        inputTokenBackgroundView.addSubview(inputAmountTextField)
        addSubview(inputTokenButton)
        addSubview(swapButton)
        addSubview(outputTokenBackgroundView)
        outputTokenBackgroundView.addSubview(outputTitleLabel)
        outputTokenBackgroundView.addSubview(outputAmountTextField)
        outputTokenBackgroundView.addSubview(outputTokenAssetsImageView)
        outputTokenBackgroundView.addSubview(outputTokenAssetsLabel)
        outputTokenBackgroundView.addSubview(outputCoinAAmountLabel)
        outputTokenBackgroundView.addSubview(outputCoinBAmountLabel)
        addSubview(outputTokenButton)
        addSubview(exchangeRateLabel)
        addSubview(minerFeeLabel)
        addSubview(confirmButton)
//        addSubview(exchangeTransactionsTitleLabel)
//        addSubview(titleIndicatorLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolViewHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        changeTypeButton.snp.makeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView.snp.left).offset(5).priority(250)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20)).priority(250)
        }
        feeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-6)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6)
        }
        inputTokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(30)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(80)
        }
        inputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView).offset(16)
            make.left.equalTo(inputTokenBackgroundView).offset(15)
        }
        inputTokenAssetsImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(inputTokenAssetsLabel)
            make.right.equalTo(inputTokenAssetsLabel.snp.left).offset(-2)
            make.size.equalTo(CGSize.init(width: 12, height: 13))
        }
        inputTokenAssetsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView).offset(16)
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
        }
        inputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView).offset(15)
            make.bottom.equalTo(inputTokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-88)
        }
        inputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11).priority(250)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11).priority(250)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22)).priority(250)
        }
        swapButton.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(6)
            make.centerX.equalTo(inputTokenBackgroundView)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        outputTokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33).priority(250)
            make.left.equalTo(self).offset(30).priority(500)
            make.right.equalTo(self.snp.right).offset(-30).priority(500)
            make.height.equalTo(80).priority(250)
        }
        outputTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView).offset(16)
            make.left.equalTo(outputTokenBackgroundView).offset(15)
        }
        outputTokenAssetsImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(outputTokenAssetsLabel)
            make.right.equalTo(outputTokenAssetsLabel.snp.left).offset(-2)
            make.size.equalTo(CGSize.init(width: 12, height: 13))
        }
        outputTokenAssetsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView).offset(16)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
        }
        outputAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.bottom.equalTo(outputTokenBackgroundView).offset(0)
            make.height.equalTo(44)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-88)
        }
        outputTokenButton.snp.makeConstraints { (make) in
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        exchangeRateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.top.equalTo(outputTokenBackgroundView.snp.bottom).offset(6)
        }
        minerFeeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(15)
            make.top.equalTo(exchangeRateLabel.snp.bottom).offset(6)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(outputTokenBackgroundView.snp.bottom).offset(66)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
            make.centerX.equalTo(self)
        }
        outputCoinAAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(11)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputCoinBAmountLabel.snp.top)

            make.height.equalTo(24)
        }
        outputCoinBAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(outputTokenBackgroundView).offset(11)
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-7)
            make.height.equalTo(24)
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
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_fee_title") + "---"
        return label
    }()
    private lazy var inputTokenBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.init(hex: "C2C2C2").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var inputTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_input_amount_title")
        return label
    }()
    private lazy var inputTokenAssetsImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "assets_pool_token")
        return imageView
    }()
    lazy var inputTokenAssetsLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + "---"
        return label
    }()
    lazy var inputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.tag = 10
        return textField
    }()
    lazy var inputTokenButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 11
        button.tag = 20
        return button
    }()
    lazy var swapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "swap_indicator"), for: UIControl.State.normal)
        //        button.addTarget(self, action: #selector(selectExchangeToken(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    private lazy var outputTokenBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.init(hex: "C2C2C2").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    lazy var outputTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_output_amount_title")
        return label
    }()
    private lazy var outputTokenAssetsImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "assets_pool_token")
        return imageView
    }()
    lazy var outputTokenAssetsLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + "---"
        return label
    }()
    lazy var outputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.tag = 20
        return textField
    }()
    lazy var outputCoinAAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.text = "---"
        label.alpha = 0
        return label
    }()
    lazy var outputCoinBAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.bold)
        label.text = "---"
        label.alpha = 0
        return label
    }()
    lazy var outputTokenButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 11
        button.tag = 30
        return button
    }()
    lazy var exchangeRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_rate_title") + "---"
        return label
    }()
    lazy var minerFeeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_exchange_miner_fee_title") + "---"
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_confirm_title"), for: UIControl.State.normal)
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
//    lazy var exchangeTransactionsTitleLabel: UILabel = {
//        let label = UILabel.init()
//        label.textAlignment = NSTextAlignment.left
//        label.textColor = UIColor.init(hex: "3D3949")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
//        label.text = "资金池记录"
//        return label
//    }()
//    lazy var titleIndicatorLabel: UILabel = {
//        let label = UILabel.init()
//        label.layer.backgroundColor = UIColor.init(hex: "#7038FD").cgColor
//        label.layer.cornerRadius = 3
//        return label
//    }()
    var viewState: AssetsPoolViewHeaderViewState = .Normal
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.changeTrasferInOut()
            let dropper = Dropper.init(width: button.frame.size.width, height: 68)
            dropper.items = [localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), localLanguage(keyString: "wallet_assets_pool_transfer_out_title")]
            dropper.cornerRadius = 8
            dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
            dropper.cellTextFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
            dropper.cellColor = UIColor.init(hex: "333333")
            dropper.spacing = 12
            dropper.show(Dropper.Alignment.center, button: button)
            dropper.delegate = self
        } else if button.tag == 20 {
            selectAToken = true
            self.delegate?.selectInputToken()
        } else if button.tag == 30 {
            selectAToken = false
            self.delegate?.selectOutoutToken()
        } else if button.tag == 100 {
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 转入
                self.delegate?.addLiquidityConfirm(amountIn: NSDecimalNumber.init(string: inputAmountTextField.text ?? "0").doubleValue,
                                                   amountOut: NSDecimalNumber.init(string: outputAmountTextField.text ?? "0").doubleValue,
                                                   inputModelName: transferInInputTokenA?.module ?? "",
                                                   outputModelName: transferInInputTokenB?.module ?? "")
            } else {
                let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: transferOutModel?.coin_a_value ?? 0),
                                               scale: 4,
                                               unit: 1000000)
                let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: transferOutModel?.coin_b_value ?? 0),
                                               scale: 4,
                                               unit: 1000000)
                // 转出
                self.delegate?.removeLiquidityConfirm(token: NSDecimalNumber.init(string: inputAmountTextField.text ?? "0").doubleValue,
                                                      amountIn: amountA.doubleValue,
                                                      amountOut: amountB.doubleValue,
                                                      inputModelName: tokenModel?.coin_a_name ?? "",
                                                      outputModelName: tokenModel?.coin_b_name ?? "")
            }
        }
    }
    /// 通证Model
    var tokenModel: MarketMineMainTokensDataModel? {
        didSet {
            guard let model = tokenModel else {
                return
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.token ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + amount.stringValue
            let content = (tokenModel?.coin_a_name ?? "---") + "/" + (tokenModel?.coin_b_name ?? "---")
            inputTokenButton.setTitle(content, for: UIControl.State.normal)
            // 调整位置
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: content, fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
        }
    }
    /// 资金池转出Model
    var transferOutModel: AssetsPoolTransferOutInfoDataModel? {
        didSet {
            guard let model = transferOutModel else {
                return
            }
            let amountA = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coin_a_value ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            outputCoinAAmountLabel.text = amountA.stringValue + (model.coin_a_name ?? "---")
            
            let amountB = getDecimalNumber(amount: NSDecimalNumber.init(value: model.coin_b_value ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            outputCoinBAmountLabel.text = amountB.stringValue + (model.coin_b_name ?? "---")
        }
    }
    /// 资金池转入ModelA
    var transferInInputTokenA: MarketSupportTokensDataModel? {
        didSet {
            guard let model = transferInInputTokenA else {
                return
            }
            inputTokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            inputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + amount.stringValue
        }
    }
    /// 资金池转入ModelB
    var transferInInputTokenB: MarketSupportTokensDataModel? {
        didSet {
            guard let model = transferInInputTokenB else {
                return
            }
            outputTokenButton.setTitle(model.show_name, for: UIControl.State.normal)
            // 调整位置
            outputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            outputTokenButton.snp.remakeConstraints { (make) in
                make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
                make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
                let width = libraWalletTool.ga_widthForComment(content: model.show_name ?? "---", fontSize: 12, height: 22) + 8 + 19
                make.size.equalTo(CGSize.init(width: width, height: 22))
            }
            let amount = getDecimalNumber(amount: NSDecimalNumber.init(value: model.amount ?? 0),
                                          scale: 4,
                                          unit: 1000000)
            outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + amount.stringValue
        }
    }
    var selectAToken: Bool?
}
extension AssetsPoolViewHeaderView: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        print(contents)
        if contents == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
            // 转入
            outputTokenButton.alpha = 1
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_in_title"), for: UIControl.State.normal)
            // 调整位置
            changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            outputAmountTextField.alpha = 1
            outputCoinAAmountLabel.alpha = 0
            outputCoinBAmountLabel.alpha = 0
            outputTokenBackgroundView.snp.remakeConstraints { (make) in
                make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
                make.left.equalTo(self).offset(30)
                make.right.equalTo(self.snp.right).offset(-30)
                make.height.equalTo(80)
            }
            outputTokenAssetsImageView.alpha = 1
            outputTokenAssetsLabel.alpha = 1
            
            resetAssetsPoolTransferInView()
        } else {
            // 转出
            outputTokenButton.alpha = 0
            changeTypeButton.setTitle(localLanguage(keyString: "wallet_assets_pool_transfer_out_title"), for: UIControl.State.normal)
            outputAmountTextField.alpha = 0
            outputCoinAAmountLabel.alpha = 1
            outputCoinBAmountLabel.alpha = 1
            outputTokenBackgroundView.snp.remakeConstraints { (make) in
                make.top.equalTo(inputTokenBackgroundView.snp.bottom).offset(33)
                make.left.equalTo(self).offset(30)
                make.right.equalTo(self.snp.right).offset(-30)
                make.height.equalTo(95)
            }
            outputTokenAssetsImageView.alpha = 0
            outputTokenAssetsLabel.alpha = 0
            
            resetAssetsPoolTransferOutView()
        }
        changeTypeButton.snp.remakeConstraints { (make) in
            make.left.equalTo(inputTokenBackgroundView.snp.left).offset(5)
            make.bottom.equalTo(inputTokenBackgroundView.snp.top).offset(-6)
            let width = libraWalletTool.ga_widthForComment(content: changeTypeButton.titleLabel?.text ?? "", fontSize: 12, height: 20) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 20))
        }
        // 调整位置
        changeTypeButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        
        transferInInputTokenA = nil
        transferInInputTokenB = nil
        transferOutModel = nil
        tokenModel = nil
    }
    func resetAssetsPoolTransferInView() {
        // 重置输入TokenA按钮
        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        inputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + "---"
        // 重置数量
        inputAmountTextField.text = ""
        // 重置输入TokenB按钮
        outputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), for: UIControl.State.normal)
        outputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(outputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(outputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_output_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        // 调整位置
        outputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        outputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + "---"
        // 重置数量
        outputAmountTextField.text = ""
    }
    func resetAssetsPoolTransferOutView() {
        // 重置输入TokenA按钮
        inputTokenButton.setTitle(localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), for: UIControl.State.normal)
        inputTokenButton.snp.remakeConstraints { (make) in
            make.right.equalTo(inputTokenBackgroundView.snp.right).offset(-11)
            make.bottom.equalTo(inputTokenBackgroundView.snp.bottom).offset(-11)
            let width = libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_market_exchange_input_token_button_title"), fontSize: 12, height: 22) + 8 + 19
            make.size.equalTo(CGSize.init(width: width, height: 22))
        }
        inputTokenButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        // 重置通证余额
        inputTokenAssetsLabel.text = localLanguage(keyString: "wallet_market_assets_pool_token_title") + "---"
        // 重置试算数量
        outputCoinAAmountLabel.text = "---"
        outputCoinBAmountLabel.text = "---"
        // 重置数量
        inputAmountTextField.text = ""
    }
}
extension AssetsPoolViewHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        if textField.tag == 10 {
            if textLength == 0 {
                inputAmountTextField.text = ""
            }
        } else {
            if textLength == 0 {
                outputAmountTextField.text = ""
            }
        }
        if content.contains(".") {
            let firstContent = content.split(separator: ".").first?.description ?? "0"
            if (textLength - firstContent.count) < 6 {
                return true
            } else {
                return false
            }
        } else {
            return textLength <= ApplyTokenAmountLengthLimit
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            print("123")
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 转入
                self.delegate?.dealTransferOutAmount(amount: NSDecimalNumber.init(string: textField.text).int64Value,
                                                     coinAModule: transferInInputTokenA?.name ?? "",
                                                     coinBModule: transferInInputTokenB?.name ?? "")
            } else {
                // 转出
                self.delegate?.dealTransferOutAmount(amount: NSDecimalNumber.init(string: textField.text).int64Value,
                                                     coinAModule: tokenModel?.coin_a_name ?? "",
                                                     coinBModule: tokenModel?.coin_b_name ?? "")
            }

        } else if textField.tag == 20 {
            if self.changeTypeButton.titleLabel?.text == localLanguage(keyString: localLanguage(keyString: "wallet_assets_pool_transfer_in_title")) {
                // 转入
                self.delegate?.dealTransferOutAmount(amount: NSDecimalNumber.init(string: textField.text).int64Value,
                                                     coinAModule: transferInInputTokenA?.name ?? "",
                                                     coinBModule: transferInInputTokenB?.name ?? "")
            } 
        }
    }
}
//wallet_assets_pool_transfer_in_title = "Transfer-In"
//wallet_assets_pool_transfer_out_title = "Transfer-Out"
