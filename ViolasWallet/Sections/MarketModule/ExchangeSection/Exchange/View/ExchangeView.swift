//
//  ExchangeView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ExchangeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(headerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ExchangeView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    /// View上半部分
    lazy var headerView: ExchangeViewHeaderView = {
        let header = ExchangeViewHeaderView.init()
        return header
    }()
    /// Toast
    lazy var toastView: ToastView = {
        let toast = ToastView.init()
        return toast
    }()
}
