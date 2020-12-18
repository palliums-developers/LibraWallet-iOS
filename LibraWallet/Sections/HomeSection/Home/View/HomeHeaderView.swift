//
//  HomeHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
protocol HomeHeaderViewDelegate: NSObjectProtocol {
    func walletConnectState()
    func addAssets()
    func transfer()
    func receive()
    func mapping()
    func yieldFarmingRules()
}
class HomeHeaderView: UIView {
    weak var delegate: HomeHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(assetLabel)
        addSubview(walletConnectStateButton)
        addSubview(coinBackgroundView)
        addSubview(coinTitleLabel)
        addSubview(addCoinButton)
        
        addSubview(transferButton)
        addSubview(spaceLabelOne)
        addSubview(receiveButton)
        addSubview(spaceLabelTwo)
        addSubview(exchangeButton)
        
        addSubview(farmingRuleButton)
        farmingRuleButton.addSubview(farmingTitleLabel)
        
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addConnect), name: NSNotification.Name("WalletConnectDidConnect"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeConnect), name: NSNotification.Name("WalletConnectFailedConnect"), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("WalletConnectDidConnect"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("WalletConnectFailedConnect"), object: nil)
        print("HomeHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        assetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(25)
            make.top.equalTo(self).offset(2)
        }
        walletConnectStateButton.snp.makeConstraints { (make) in
//            make.bottom.equalTo(coinBackgroundView.snp.top).offset(-9)
            make.bottom.equalTo(coinBackgroundView.snp.top).offset(-49)
            make.right.equalTo(self.snp.right).offset(-20)
            let width = 14 + 10 + 4 + libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_wallet_connect_state_title"), fontSize: 12, height: 24) + 8
            make.size.equalTo(CGSize.init(width: width, height: 24))
        }
        
        transferButton.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.width.equalTo(receiveButton)
            make.bottom.equalTo(coinBackgroundView.snp.top).offset(-10)
            make.height.equalTo(40)
        }
        spaceLabelOne.snp.makeConstraints { (make) in
            make.left.equalTo(transferButton.snp.right)
            make.centerY.equalTo(transferButton)
            make.size.equalTo(CGSize.init(width: 0.5, height: 12))
        }
        receiveButton.snp.makeConstraints { (make) in
            make.left.equalTo(spaceLabelOne.snp.right)
            make.width.equalTo(exchangeButton)
            make.bottom.equalTo(coinBackgroundView.snp.top).offset(-10)
            make.height.equalTo(40)
        }
        spaceLabelTwo.snp.makeConstraints { (make) in
            make.left.equalTo(receiveButton.snp.right)
            make.centerY.equalTo(receiveButton)
            make.size.equalTo(CGSize.init(width: 0.5, height: 12))
        }
        exchangeButton.snp.makeConstraints { (make) in
            make.left.equalTo(spaceLabelTwo.snp.right)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(coinBackgroundView.snp.top).offset(-10)
            make.height.equalTo(40)
            make.width.equalTo(transferButton)
        }
        // 第三部分
        coinBackgroundView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.left.right.equalTo(self)
            make.height.equalTo(128)
        }
        coinTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(addCoinButton)
            make.left.equalTo(coinBackgroundView).offset(25)
        }
        addCoinButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(coinBackgroundView.snp.bottom).offset(-11)
            make.right.equalTo(coinBackgroundView.snp.right).offset(-28)
            make.size.equalTo(CGSize.init(width: 22, height: 22))
        }
        farmingRuleButton.snp.makeConstraints { (make) in
            make.top.equalTo(coinBackgroundView).offset(18)
            make.left.equalTo(coinBackgroundView).offset(15)
            make.right.equalTo(coinBackgroundView.snp.right).offset(-15)
            make.height.equalTo(60)
        }
        farmingTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(farmingRuleButton)
            make.right.equalTo(farmingRuleButton.snp.right).offset(-59)
        }
        coinBackgroundView.corner(byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], radii: 24)
    }
    lazy var assetLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "FFFFFF")
        label.font = UIFont.init(name: "Helvetica", size: 28)
        label.text = "$ 0.00"
        return label
    }()
    lazy var walletConnectStateButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_wallet_connect_state_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "FB8F0B"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "wallet_connect_state"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        button.layer.backgroundColor = UIColor.init(hex: "463288").cgColor
        button.layer.cornerRadius = 12
        button.alpha = 0
        return button
    }()
    private lazy var coinBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var coinTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3B3B3B")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: .regular)
        label.text = localLanguage(keyString: "wallet_home_wallet_asset_title")
        return label
    }()
    private lazy var addCoinButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_add_token"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        button.backgroundColor = UIColor.white
        return button
    }()
    private lazy var transferButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "wallet_transfer"), for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        button.imagePosition(at: .left, space: 8, imageViewSize: CGSize.init(width: 16, height: 16))
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    lazy var spaceLabelOne: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.white
        return label
    }()
    private lazy var receiveButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "wallet_receive"), for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        button.imagePosition(at: .left, space: 8, imageViewSize: CGSize.init(width: 16, height: 16))

        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 40
        return button
    }()
    lazy var spaceLabelTwo: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.white
        return label
    }()
    private lazy var exchangeButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "wallet_mapping"), for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "wallet_home_mapping_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        button.imagePosition(at: .left, space: 8, imageViewSize: CGSize.init(width: 16, height: 16))
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 50
        return button
    }()
    lazy var farmingRuleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage.init(named: "home_farming_rule_button_background"), for: .normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        button.tag = 60
        return button
    }()
    lazy var farmingTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.text = localLanguage(keyString: "wallet_mine_yield_farming_button_title")
        return label
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // WalletConnect
            self.delegate?.walletConnectState()
        } else if button.tag == 20 {
            // 添加资产
            self.delegate?.addAssets()
        } else if button.tag == 30 {
            // 转账
            self.delegate?.transfer()
        } else if button.tag == 40 {
            // 收款
            self.delegate?.receive()
        } else if button.tag == 50 {
            // 映射
            self.delegate?.mapping()
        } else if button.tag == 60 {
            self.delegate?.yieldFarmingRules()
        }
    }
    var assetsModel: String? {
        didSet {
            if assetsModel == "0" {
                self.assetLabel.text = "$ 0.00"
            } else {
                self.assetLabel.text = "$ \(assetsModel ?? "0.00")"
            }
        }
    }
    func showAssets() {
        self.assetLabel.text = "$ \(assetsModel!)"
    }
    @objc func setText() {
        coinTitleLabel.text = localLanguage(keyString: "wallet_home_wallet_asset_title")
        transferButton.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
        receiveButton.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
        exchangeButton.setTitle(localLanguage(keyString: "wallet_home_mapping_button_title"), for: UIControl.State.normal)
    }
    @objc func addConnect() {
        self.walletConnectStateButton.alpha = 1
    }
    @objc func removeConnect() {
        self.walletConnectStateButton.alpha = 0
    }
}
