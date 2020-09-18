//
//  ScanResultInvalidView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/19.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
class ScanResultInvalidView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(contentTextView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanResultInvalidView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        contentTextView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var contentTextView: UITextView = {
        //#263C4E
        let textView = UITextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.textColor = UIColor.init(hex: "62606B")
        textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        textView.backgroundColor = UIColor.init(hex: "F8F7FA")
        textView.isEditable = false
        return textView
    }()
}
