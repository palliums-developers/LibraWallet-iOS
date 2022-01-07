//
//  TokenMappingView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/2/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
class TokenMappingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerBackground)
        addSubview(scrollView)
        scrollView.addSubview(headerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TokenMappingView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerBackground.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(196)
        }
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(self).offset(navigationBarHeight)
        }
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo((436 * ratio))
            make.top.equalTo(scrollView).offset(30)
        }
        scrollView.contentSize = CGSize.init(width: mainWidth, height: headerView.frame.maxY + 10)
    }
    //MARK: - 懒加载对象
    private lazy var headerBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_top_background")
        return imageView
    }()
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        return scrollView
    }()
    lazy var headerView: TokenMappingHeaderView = {
        let view = TokenMappingHeaderView.init()
        return view
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
}
