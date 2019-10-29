//
//  WalletMnemonicViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletMnemonicViewController: BaseViewController {
    override func viewDidLoad() {
       super.viewDidLoad()
       // 初始化本地配置
       self.setBaseControlllerConfig()
       // 加载子View
       self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
       detailView.snp.makeConstraints { (make) in
           if #available(iOS 11.0, *) {
               make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
           } else {
               make.top.bottom.equalTo(self.view)
           }
           make.left.right.equalTo(self.view)
       }
    }
    //子View
    private lazy var detailView : WalletMnemonicView = {
       let view = WalletMnemonicView.init()
       return view
    }()
    deinit {
       print("WalletMnemonicViewController销毁了")
    }
    var rootAddress: String? {
        didSet {
            guard let address = rootAddress else {
                return
            }
            do {
                let result = try LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: address)
                detailView.mnemonicTextView.text = result.joined(separator: " ")
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
}
