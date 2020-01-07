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
    
    func checkWalletDetail()
    
    func walletSend()
    
    func walletReceive()
    
    func checkWalletTransactionList()
    
    func addCoinToWallet()
}
class HomeHeaderView: UIView {
    weak var delegate: HomeHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(whiteBackgroundView)
        addSubview(assetTitleLabel)
        addSubview(assetLabel)
        addSubview(assetUnitLabel)
        addSubview(walletDetailButton)
        addSubview(walletNameLabel)
        addSubview(walletAddressLabel)
        addSubview(copyAddressButton)
        
        addSubview(lastTransactionBackgroundButton)
        addSubview(transferButton)
        addSubview(receiveButton)
        addSubview(buttonSpaceLabel)
        
        addSubview(coinBackgroundView)
        addSubview(coinTitleLabel)
        addSubview(addCoinButton)
        
        lastTransactionBackgroundButton.addSubview(transactionTitleLabel)
//        lastTransactionBackgroundButton.addSubview(lastTransactionDateLabel)
        lastTransactionBackgroundButton.addSubview(lastTransactionDetailImageView)

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
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(183)
        }
        assetTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.centerY.equalTo(walletDetailButton)
        }
        assetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.top.equalTo(assetTitleLabel.snp.bottom).offset(5)
        }
        assetUnitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(assetLabel.snp.right).offset(5)
            make.centerY.equalTo(assetLabel).offset(4)
        }
        walletDetailButton.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(12)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-5)
            make.size.equalTo(CGSize.init(width: 36, height: 27))
        }
        
        walletNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.right.equalTo(walletAddressLabel.snp.left).offset(-10)
            make.top.equalTo(walletAddressLabel)
            make.height.equalTo(42)
            make.width.equalTo(42)
        }
        walletAddressLabel.snp.makeConstraints { (make) in
            make.right.equalTo(copyAddressButton.snp.left).offset(-4)
            make.height.equalTo(42)
            make.centerY.equalTo(copyAddressButton)
        }
        copyAddressButton.snp.makeConstraints { (make) in
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
            make.bottom.equalTo(receiveButton.snp.top).offset(-22)
            make.size.equalTo(CGSize.init(width: 19, height: 19))
        }
        
        transferButton.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(whiteBackgroundView)
            make.size.equalTo(receiveButton)
            
            make.right.equalTo(receiveButton.snp.left)
        }
        buttonSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transferButton.snp.right).offset(-1)
            make.centerY.equalTo(transferButton)
            make.size.equalTo(CGSize.init(width: 2, height: 15))
        }
        receiveButton.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(whiteBackgroundView)
            make.height.equalTo(54)
        }
        
        lastTransactionBackgroundButton.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView.snp.bottom).offset(13)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(42)
        }
        transactionTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(lastTransactionBackgroundButton)
            make.left.equalTo(lastTransactionBackgroundButton).offset(14)
        }
//        lastTransactionDateLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(lastTransactionBackgroundButton)
//            make.right.equalTo(lastTransactionDetailImageView.snp.left).offset(-4)
//        }
        lastTransactionDetailImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(lastTransactionBackgroundButton)
            make.right.equalTo(lastTransactionBackgroundButton.snp.right).offset(-15)
        }
        // 第三部分
        coinBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(lastTransactionBackgroundButton.snp.bottom).offset(13)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(50)
        }
        coinTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinBackgroundView)
            make.left.equalTo(coinBackgroundView).offset(14)
        }
        addCoinButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinBackgroundView)
            make.right.equalTo(coinBackgroundView.snp.right).offset(-14)
        }
    }
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 7
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var assetTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "9D9CA3")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
        label.text = localLanguage(keyString: "wallet_home_current_balance_title")
        return label
    }()
    lazy var assetLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 27), weight: .semibold)
        label.text = "0.00"
        return label
    }()
    lazy var assetUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "9D9CA3")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .regular)
        label.text = "---"
        return label
    }()
    lazy var walletNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "9D9CA3")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
        label.text = "---"
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 2
        return label
    }()
    lazy var walletAddressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: .semibold)
        label.text = "---"
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 2
        return label
    }()
    private lazy var copyAddressButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_copy_address"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    private lazy var walletDetailButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_wallet_detail"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        button.backgroundColor = UIColor.white
        
        return button
    }()
    
    lazy var transferButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "22126C"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "home_transfer"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.white
        button.tag = 30
        // 定义阴影颜色
        button.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 2
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: -2)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.02
       return button
    }()
    lazy var buttonSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "22126C")
        return label
    }()
    lazy var receiveButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "22126C"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "home_receive"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 40
        button.backgroundColor = UIColor.white
        // 定义阴影颜色
        button.layer.shadowColor = UIColor.init(hex: "3D3949").cgColor
        // 阴影的模糊半径
        button.layer.shadowRadius = 2
        // 阴影的偏移量
        button.layer.shadowOffset = CGSize(width: 0, height: -2)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        button.layer.shadowOpacity = 0.02
       return button
    }()
    private lazy var lastTransactionBackgroundButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_icon"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 50
        button.backgroundColor = UIColor.white
        return button
    }()
    lazy var transactionTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3D3949")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .regular)
        label.text = localLanguage(keyString: "wallet_home_last_transaction_date_title")
        return label
    }()
    lazy var lastTransactionDateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "9D9CA3")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: .regular)
//        label.text = localLanguage(keyString: "2019-10-30")
        return label
    }()
    private lazy var lastTransactionDetailImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "cell_detail")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var coinBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
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
        button.setImage(UIImage.init(named: "home_add_asset"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 60
        button.backgroundColor = UIColor.white
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // 查看钱包详情
            self.delegate?.checkWalletDetail()
        } else if button.tag == 20 {
            // 拷贝地址
            UIPasteboard.general.string = walletAddressLabel.text
            self.makeToast(localLanguage(keyString: "wallet_copy_address_success_title"),
                           position: .center)
        } else if button.tag == 30 {
            // 转账
            self.delegate?.walletSend()
        } else if button.tag == 40 {
            // 收款
            self.delegate?.walletReceive()
        } else if button.tag == 50 {
            // 查看交易记录
            self.delegate?.checkWalletTransactionList()
        } else if button.tag == 60 {
            // 添加资产
            self.delegate?.addCoinToWallet()
        }
    }
    var walletModel: LibraWalletManager? {
        didSet {
            walletNameLabel.text = "address"
            walletAddressLabel.text = walletModel?.walletAddress
            // 更新本地数据
            switch walletModel?.walletType {
            case .Libra:
                assetUnitLabel.text = "libra"
                assetLabel.text = "\(walletModel?.walletBalance ?? 0)"
                hideAddTokenButtonState = true
                break
            case .Violas:
                assetUnitLabel.text = "vtoken"
                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (walletModel?.walletBalance ?? 0)),
                                                         scale: 4,
                                                         unit: 1000000)
                hideAddTokenButtonState = false
                break
            case .BTC:
                assetUnitLabel.text = "BTC"

                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (walletModel?.walletBalance ?? 0)),
                                                         scale: 8,
                                                         unit: 100000000)
                hideAddTokenButtonState = true
                break
            default:
                break
            }
        }
    }
    var libraModel: BalanceLibraModel? {
        didSet {
            if libraModel?.address == self.walletAddressLabel.text {
                assetLabel.text = "\(libraModel?.balance ?? 0)"
                self.walletModel?.changeWalletBalance(banlance: libraModel?.balance ?? 0)
                assetUnitLabel.text = "libra"
            }
        }
    }
    var violasModel: BalanceLibraModel? {
        didSet {
            if violasModel?.address == self.walletAddressLabel.text {
                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (violasModel?.balance ?? 0)),
                                                         scale: 4,
                                                         unit: 1000000)
                self.walletModel?.changeWalletBalance(banlance: violasModel?.balance ?? 0)
                assetUnitLabel.text = "vtoken"
            }
        }
    }
    var btcModel: BalanceBTCModel? {
        didSet {
            if btcModel?.address == self.walletAddressLabel.text {
                assetLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (btcModel?.balance ?? 0)),
                                                         scale: 8,
                                                         unit: 100000000)
                self.walletModel?.changeWalletBalance(banlance: btcModel?.balance ?? 0)
                assetUnitLabel.text = "BTC"
            }
        }
    }
    var hideAddTokenButtonState: Bool? {
        didSet {
            if hideAddTokenButtonState == true {
                self.addCoinButton.alpha = 0
            } else {
                self.addCoinButton.alpha = 1
            }
        }
    }
    @objc func setText() {
        assetTitleLabel.text = localLanguage(keyString: "wallet_home_current_balance_title")
        transferButton.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
        receiveButton.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
        transactionTitleLabel.text = localLanguage(keyString: "wallet_home_last_transaction_date_title")
        coinTitleLabel.text = localLanguage(keyString: "wallet_home_wallet_asset_title")
    }
}
