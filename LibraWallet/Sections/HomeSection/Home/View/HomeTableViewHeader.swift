//
//  HomeTableViewHeader.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class HomeTableViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(coinNameLabel)
        contentView.addSubview(addCoinButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("HomeTableViewHeader销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        coinNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(9)
            make.left.equalTo(contentView).offset(28)
        }
        addCoinButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(9)
            make.right.equalTo(contentView.snp.right).offset(-28)
        }
    }
    //MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
//        view.layer.cornerRadius = 7
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var coinNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "7D71AA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_home_wallet_asset_title")
        return label
    }()
    private lazy var addCoinButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_add_token"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 60
        button.backgroundColor = UIColor.white
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            
        }
    }
}
