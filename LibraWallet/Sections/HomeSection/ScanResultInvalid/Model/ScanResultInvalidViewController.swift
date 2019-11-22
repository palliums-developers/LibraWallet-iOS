//
//  ScanResultInvalidViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/19.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ScanResultInvalidViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
    private lazy var detailView : ScanResultInvalidView = {
        let view = ScanResultInvalidView.init()
        return view
    }()
    var content: String? {
        didSet {
            self.detailView.contentTextView.text = content
        }
    }
    deinit {
        print("ScanResultInvalidViewController销毁了")
    }
}
