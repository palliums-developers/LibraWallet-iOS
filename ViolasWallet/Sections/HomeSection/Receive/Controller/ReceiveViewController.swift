//
//  ReceiveViewController.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ReceiveViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 页面标题
        self.title = localLanguage(keyString: "wallet_receive_navigation_title")
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    var wallet: Token? {
        didSet {
            self.detailView.token = wallet
        }
    }
    private lazy var detailView : ReceiveView = {
        let view = ReceiveView.init()
        view.delegate = self
        return view
    }()
    var tokens: [Token]?
    deinit {
        print("ReceiveViewController销毁了")
    }
}
extension ReceiveViewController: ReceiveViewDelegate {
    func chooseCoin() {
        guard let tempTokens = self.tokens, tempTokens.isEmpty == false else {
            return
        }
        let alert = TransferTokensAlert.init(data: tempTokens) { (model) in
            print(model)
            self.detailView.token = model
        }
        if self.detailView.coinSelectButton.titleLabel?.text != localLanguage(keyString: "wallet_transfer_token_default_title") {
            let index = tempTokens.firstIndex {
                $0.tokenName == (self.detailView.coinSelectButton.titleLabel?.text ?? "")
            }
            alert.pickerRow = index
        }
        alert.show(tag: 199)
        alert.showAnimation()
    }
}
