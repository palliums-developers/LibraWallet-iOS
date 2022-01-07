//
//  WelcomeViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/8/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.init(hex: "011025")
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    //子View
    private lazy var detailView : WelcomeView = {
        let view = WelcomeView.init()
        view.delegate = self
        return view
    }()
    deinit {
        print("WelcomeViewController销毁了")
    }
}
extension WelcomeViewController: WelcomeViewDelegate {
    func confirm() {
//        setWelcomeState(show: "1")
//        if getLoginStatus() == "0" {
//            let login = LoginViewController()
//            UIApplication.shared.keyWindow?.rootViewController = login
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
//        } else {
//            let home = HomeViewController()
//            let navi = BaseNavigationController.init(rootViewController: home)
//            UIApplication.shared.keyWindow?.rootViewController = navi
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
//        }
    }
}
