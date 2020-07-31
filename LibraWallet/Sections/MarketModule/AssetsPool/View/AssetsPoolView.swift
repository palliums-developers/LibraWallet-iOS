//
//  AssetsPoolView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class AssetsPoolView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        //        addSubview(headerBackground)
        addSubview(headerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var headerView : AssetsPoolViewHeaderView = {
        let header = AssetsPoolViewHeaderView.init()
        return header
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
}
