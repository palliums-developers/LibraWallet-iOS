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
}
class HomeHeaderView: UIView {
    weak var delegate: HomeHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(whiteBackgroundView)
        addSubview(assetLabel)
        
        addSubview(walletConnectStateButton)
        
        addSubview(coinBackgroundView)
        addSubview(coinTitleLabel)
        addSubview(addCoinButton)

        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
//        whiteBackgroundView.snp.makeConstraints { (make) in
//            make.top.equalTo(self)
//            make.left.equalTo(self).offset(15)
//            make.right.equalTo(self).offset(-15)
//            make.height.equalTo(183)
//        }
        assetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(29)
            make.top.equalTo(self).offset(6)
        }
        walletConnectStateButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(coinBackgroundView.snp.top).offset(-9)
            make.right.equalTo(self.snp.right).offset(-20)
            make.size.equalTo(CGSize.init(width: 120, height: 24))
        }
        // 第三部分
        coinBackgroundView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.left.right.equalTo(self)
            make.height.equalTo(64)
        }
        coinTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(addCoinButton)
            make.left.equalTo(coinBackgroundView).offset(28)
        }
        addCoinButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(coinBackgroundView.snp.bottom).offset(-11)
            make.right.equalTo(coinBackgroundView.snp.right).offset(-28)
        }
        coinBackgroundView.corner(byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], radii: 24)
    }
//    private lazy var whiteBackgroundView: UIView = {
//        let view = UIView.init()
//        view.layer.cornerRadius = 7
//        view.layer.backgroundColor = UIColor.white.cgColor
//        return view
//    }()
    lazy var assetLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "FFFFFF")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 28), weight: .bold)
        label.text = "$ 0.00"
        return label
    }()
    lazy var walletConnectStateButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
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
        label.textColor = UIColor.init(hex: "3D3949")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .regular)
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

    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // WalletConnect
            self.delegate?.walletConnectState()
        } else if button.tag == 20 {
            // 添加资产
            self.delegate?.addAssets()
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
    var walletModel: Token? {
        didSet {
//            walletNameLabel.text = "address"
//            walletAddressLabel.text = walletModel?.walletAddress
//            // 更新本地数据
//            switch walletModel?.walletType {
//            case .Libra:
//                assetUnitLabel.text = "libra"
//                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (libraModel?.balances?[0].amount ?? 0)),
//                                                         scale: 4,
//                                                         unit: 1000000)
//                hideAddTokenButtonState = true
//                break
//            case .Violas:
//                assetUnitLabel.text = "vtoken"
//                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (walletModel?.walletBalance ?? 0)),
//                                                         scale: 4,
//                                                         unit: 1000000)
//                hideAddTokenButtonState = false
//                break
//            case .BTC:
//                assetUnitLabel.text = "BTC"
//
//                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (walletModel?.walletBalance ?? 0)),
//                                                         scale: 8,
//                                                         unit: 100000000)
//                hideAddTokenButtonState = true
//                break
//            default:
//                break
//            }
        }
    }
    var hideAddTokenButtonState: Bool? {
        didSet {
//            if hideAddTokenButtonState == true {
//                self.addCoinButton.alpha = 0
//            } else {
//                self.addCoinButton.alpha = 1
//            }
        }
    }
    @objc func setText() {
//        assetTitleLabel.text = localLanguage(keyString: "wallet_home_current_balance_title")
//        walletConnectStateButton.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
//        receiveButton.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
//        transactionTitleLabel.text = localLanguage(keyString: "wallet_home_last_transaction_date_title")
//        coinTitleLabel.text = localLanguage(keyString: "wallet_home_wallet_asset_title")
    }
}
