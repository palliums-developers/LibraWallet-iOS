//
//  ToastView.swift
//  HKWallet
//
//  Created by palliums on 2019/8/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ToastView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(invisableBackgroundView)
        self.makeToastActivity(.center)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(successClosure: @escaping successClosure) {
        self.init(frame: CGRect.zero)
        self.actionClosure = successClosure
    }
    deinit {
        print("ToastView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        invisableBackgroundView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    //懒加载子View
    private lazy var invisableBackgroundView: UIView = {
        let view = UIView.init()
        view.alpha = 0
        return view
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    
}
extension ToastView: actionViewProtocol {
    
}
