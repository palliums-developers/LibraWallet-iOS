//
//  WalletMnemonicView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
class WalletMnemonicView: UIView {
    weak var delegate: ImportWalletViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mnemonicTextView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletMnemonicView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        mnemonicTextView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.height.equalTo(200)
        }
    }
    //MARK: - 懒加载对象
    lazy var mnemonicTextView: RSKPlaceholderTextView = {
        //#263C4E
        let textView = RSKPlaceholderTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.textColor = UIColor.init(hex: "62606B")
        textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        textView.backgroundColor = UIColor.init(hex: "F8F7FA")
        textView.tintColor = DefaultGreenColor
        textView.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_import_mnemonic_textview_placeholder"),
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C5C8DB"),
                                                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        return textView
    }()
}
