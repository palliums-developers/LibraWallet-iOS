//
//  ActiveAccountViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/22.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ActiveAccountViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 页面标题
        self.title = localLanguage(keyString: "Active Account")
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
    var authKey: String? {
        didSet {
            self.detailView.authKey = authKey
        }
    }
    private lazy var detailView : ActiveAccountView = {
        let view = ActiveAccountView.init()
        return view
    }()
    deinit {
        print("WalletReceiveViewController销毁了")
    }


}
