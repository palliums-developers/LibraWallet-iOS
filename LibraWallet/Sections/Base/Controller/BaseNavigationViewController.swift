//
//  BaseNavigationViewController.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor:UIColor.init(hex: "263C4E"),
                                                NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)]
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
