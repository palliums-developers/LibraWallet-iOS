//
//  WalletManagerHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/24.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletManagerHeaderView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        addSubview(headerTitleLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletManagerHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(24)
            make.top.equalTo(contentView).offset(20)
        }
    }
    //MARK: - 懒加载对象
    lazy var headerTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "292929")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_balance_balance_title")
        return label
    }()
    
    var model: String? {
        didSet {
            headerTitleLabel.text = model
        }
    }
}
