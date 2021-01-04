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
        addSubview(profitView)
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
        profitView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(12)
            make.left.equalTo(self).offset(26)
            make.right.equalTo(self.snp.right).offset(-26)
            make.height.equalTo(62)
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(profitView.snp.bottom)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var headerView : AssetsPoolViewHeaderView = {
        let header = AssetsPoolViewHeaderView.init()
        return header
    }()
    lazy var profitView : AssetsPoolProfitHeaderView = {
        let view = AssetsPoolProfitHeaderView.init()
        return view
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
}
