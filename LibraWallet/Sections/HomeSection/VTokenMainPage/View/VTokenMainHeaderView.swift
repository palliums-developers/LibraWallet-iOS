//
//  VTokenMainHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol VTokenMainHeaderViewDelegate: NSObjectProtocol {
    func walletSend()
    func walletReceive()
}
class VTokenMainHeaderView: UIView {
    weak var delegate: VTokenMainHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(assetLabel)
        whiteBackgroundView.addSubview(assetUnitLabel)
        whiteBackgroundView.addSubview(walletAddressLabel)
        whiteBackgroundView.addSubview(copyAddressButton)
        
        whiteBackgroundView.addSubview(transferButton)
        whiteBackgroundView.addSubview(buttonSpaceLabel)
        whiteBackgroundView.addSubview(receiveButton)
        
        addSubview(transactionTitleLabel)
        addSubview(transactionIndicatorLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("VTokenMainHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(183)
        }
        assetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(whiteBackgroundView).offset(14)
            make.top.equalTo(whiteBackgroundView).offset(26)
        }
        assetUnitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(assetLabel.snp.right).offset(5)
            make.centerY.equalTo(assetLabel).offset(4)
        }
        walletAddressLabel.snp.makeConstraints { (make) in
            make.right.equalTo(copyAddressButton.snp.left).offset(-4)
            make.left.equalTo(whiteBackgroundView).offset(14)

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
        transactionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView.snp.bottom).offset(17)
            make.left.equalTo(self).offset(19)
        }
        transactionIndicatorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.bottom.equalTo(self)
            make.size.equalTo(CGSize.init(width: 12, height: 3))
        }
    }
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 4
        view.layer.backgroundColor = UIColor.init(hex: "F2F2F9").cgColor
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "22126C"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "home_transfer"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "F2F2F9")
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "22126C"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "home_receive"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 40
        button.backgroundColor = UIColor.init(hex: "F2F2F9")
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
   
    lazy var transactionIndicatorLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "3D3949")
        return label
    }()

    @objc func buttonClick(button: UIButton) {
        if button.tag == 20 {
            // 拷贝地址
            UIPasteboard.general.string = walletAddressLabel.text
            self.makeToast(localLanguage(keyString: "wallet_address_copy_success_title"),
                           position: .center)
        } else if button.tag == 30 {
            // 转账
            self.delegate?.walletSend()
        } else if button.tag == 40 {
            // 收款
            self.delegate?.walletReceive()
        }
    }
}
