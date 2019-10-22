//
//  WalletCreateView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletCreateViewDelegate: NSObjectProtocol {
    func createWallet()
    func importWallet()
}
class WalletCreateView: UIView {
    weak var delegate: WalletCreateViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "191F3A")
        addSubview(createButton)
        addSubview(importButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoginView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        createButton.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
            make.size.equalTo(CGSize.init(width: 200, height: 44))
        }
        importButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(createButton.snp.bottom).offset(20)
            make.size.equalTo(CGSize.init(width: 200, height: 44))
        }
    }
    lazy var createButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_create_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.tag = 55
        return button
    }()
    lazy var importButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_create_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
//        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.tag = 55
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.createWallet()
    }
}
