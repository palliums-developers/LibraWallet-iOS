//
//  WalletMainViewFooterView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/4.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol WalletMainViewFooterViewDelegate: NSObjectProtocol {
    func walletTransfer()
    func walletReceive()
    func walletExchange()
}
class WalletMainViewFooterView: UIView {
    weak var delegate: WalletMainViewFooterViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(transferButton)
        addSubview(receiveButton)
        addSubview(exchangeButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletMainViewHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        transferButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(29)
            let width = (mainWidth - 58 - 26) / 3
            make.width.equalTo(width)
        }
        receiveButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.width.equalTo(exchangeButton)
            make.left.equalTo(transferButton.snp.right).offset(13)
        }
        exchangeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.width.equalTo(transferButton)
            make.left.equalTo(receiveButton.snp.right).offset(13)
            make.right.equalTo(self.snp.right).offset(-29)
        }
    }
    lazy var transferButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_transfer_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.cornerRadius = 3
        button.tag = 10
       return button
    }()
    lazy var receiveButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.cornerRadius = 3
        button.tag = 20
       return button
    }()
    lazy var exchangeButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_home_receive_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 1
        button.tag = 30
       return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            // 转账
            self.delegate?.walletTransfer()
        } else if button.tag == 20 {
            // 收款
            self.delegate?.walletReceive()
        } else if button.tag == 30 {
            // 闪兑
            self.delegate?.walletExchange()
        }
    }
}
