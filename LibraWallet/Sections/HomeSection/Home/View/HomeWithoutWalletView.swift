//
//  HomeWithoutWalletView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
protocol HomeWithoutWalletViewDelegate: NSObjectProtocol {
    func createWallet()
    func importWallet()
}
class HomeWithoutWalletView: UIView {
    weak var delegate: HomeWithoutWalletViewDelegate?

    override init(frame: CGRect) {
    super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(createWalletButton)
        addSubview(importWalletButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("HomeWithoutWalletView销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        createWalletButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(33)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(64)
        }
        importWalletButton.snp.makeConstraints { (make) in
            make.top.equalTo(createWalletButton.snp.bottom).offset(20)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(64)
        }
    }
    //MARK: - 懒加载对象
    private lazy var createWalletButton : UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_create_choose_type_create_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.init(hex: "22126C"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "create_wallet"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 4)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "F7F7FA").cgColor
        button.layer.cornerRadius = 16
        button.tag = 10
        return button
    }()
    private lazy var importWalletButton : UIButton = {
        let button = UIButton.init()
        button.setTitle(localLanguage(keyString: "wallet_create_choose_type_import_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.init(hex: "22126C"), for: UIControl.State.normal)
        // 设置图片
        button.setImage(UIImage.init(named: "import_wallet"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: -4)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 4)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "F7F7FA").cgColor
        button.layer.cornerRadius = 16
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.createWallet()
        } else {
            self.delegate?.importWallet()
        }
    }
    @objc func setText(){
        importWalletButton.setTitle(localLanguage(keyString: "wallet_create_choose_type_import_button_title"), for: UIControl.State.normal)
        createWalletButton.setTitle(localLanguage(keyString: "wallet_create_choose_type_create_button_title"), for: UIControl.State.normal)
    }
}
