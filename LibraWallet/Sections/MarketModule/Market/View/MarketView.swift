//
//  MarketView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MarketView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(scrollView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize.init(width: mainWidth * 2, height: self.frame.size.height)
        scrollView.isScrollEnabled = false
        return scrollView
    }()
}
