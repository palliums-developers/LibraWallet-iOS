//
//  TransactionDetailTableViewCell.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/6/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TransactionDetailTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        if restorationIdentifier == "CellAddress" {
            contentView.addSubview(copyAddressButton)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletDetailTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(24)
            make.centerY.equalTo(contentView)
        }
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(100)
            if restorationIdentifier == "CellAddress" {
                make.right.equalTo(copyAddressButton.snp.left).offset(-5)
            } else {
                make.right.equalTo(contentView.snp.right).offset(-24)
            }
            make.centerY.equalTo(contentView)
        }
        if restorationIdentifier == "CellAddress" {
            copyAddressButton.snp.makeConstraints { (make) in
                make.left.equalTo(valueLabel.snp.right)
                make.centerY.equalTo(valueLabel)
                make.size.equalTo(CGSize.init(width: 18, height: 18))
            }
        }
    }
    //MARK: - 懒加载对象
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var valueLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var copyAddressButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_copy_address"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    //MARK: - 设置数据
    var tokenName: String?
    var model: TransactionDetailDataModel? {
        didSet {
            guard let item = model else {
                return
            }
            titleLabel.text = item.title
            valueLabel.text = item.value
            if item.type == "CellAmount" {
                valueLabel.textColor = UIColor.init(hex: "333333")
                valueLabel.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.medium)
            } else if item.type == "CellAddress" {
                contentView.addSubview(copyAddressButton)
                valueLabel.textColor = UIColor.init(hex: "999999")
                valueLabel.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
                valueLabel.lineBreakMode = .byTruncatingMiddle
            } else {
                
            }
        }
    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
          
        }
    }
}
