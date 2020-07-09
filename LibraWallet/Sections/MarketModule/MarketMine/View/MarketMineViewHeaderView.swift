//
//  MarketMineViewHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MarketMineViewHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(tokenBackgroundView)
        tokenBackgroundView.addSubview(tokenTitleLabel)
        tokenBackgroundView.addSubview(tokenAmountTextField)
        addSubview(transferInButton)
        addSubview(transferOutButton)
        addSubview(assetsTitleLabel)
        addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketMineViewHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tokenBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(16)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(87)
        }
        tokenTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView).offset(15)
            make.left.equalTo(tokenBackgroundView).offset(16)
        }
        tokenAmountTextField.snp.makeConstraints { (make) in
            make.left.equalTo(tokenBackgroundView).offset(16)
            make.right.equalTo(tokenBackgroundView.snp.right).offset(-16)
            make.top.equalTo(tokenTitleLabel.snp.bottom).offset(14)
        }
        transferInButton.snp.makeConstraints { (make) in
            make.top.equalTo(tokenBackgroundView.snp.bottom).offset(19)
            make.left.equalTo(self).offset(45)
            make.width.equalTo(transferOutButton)
            make.height.equalTo(28)
        }
        transferOutButton.snp.makeConstraints { (make) in
            make.top.equalTo(transferInButton)
            make.right.equalTo(self).offset(-45)
            make.left.equalTo(transferInButton.snp.right).offset(45)
            make.height.equalTo(transferInButton)
        }
        assetsTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(29)
            make.top.equalTo(transferOutButton.snp.bottom).offset(32)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self.snp.right).offset(-30)
            make.height.equalTo(0.5)
        }
    }
    private lazy var tokenBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 8
        view.layer.backgroundColor = UIColor.init(hex: "F8F8F8").cgColor
        return view
    }()
    lazy var tokenTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "输入"
        return label
    }()
    lazy var tokenAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "C2C2C2"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        textField.isEnabled = false
        //        textField.delegate = self
        textField.text = "10000"
        textField.tag = 10
        return textField
    }()
    lazy var transferInButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle("转入", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 14
        button.tag = 20
        return button
    }()
    lazy var transferOutButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle("转出", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        //        button.addTarget(self, action: #selector(selectExchangeToken(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 14
        button.tag = 20
        return button
    }()
    lazy var assetsTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "资产"
        return label
    }()
    lazy var spaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
}
