//
//  MarketMyOrderHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol MarketMyOrderHeaderViewDelegate: NSObjectProtocol {
    func showOrderCenter()
}
class MarketMyOrderHeaderView: UITableViewHeaderFooterView {
    weak var delegate: MarketMyOrderHeaderViewDelegate?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
//        addSubview(headerTitleLabel)
        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerButton)
        contentView.addSubview(headerSpaceLabel)
        
        contentView.addSubview(transactionTitleLabel)
        contentView.addSubview(transactionAmountLabel)
        contentView.addSubview(transactionPriceLabel)
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
            make.left.equalTo(contentView).offset(16)
            make.bottom.equalTo(headerSpaceLabel.snp.top).offset(-15)
        }
        headerButton.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.bottom.equalTo(headerSpaceLabel.snp.top).offset(-15)
        }
        headerSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView).offset(-14)
            make.centerY.equalTo(contentView).offset(12)
            make.height.equalTo(1)
        }
        transactionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerSpaceLabel.snp.bottom).offset(15)
            make.left.equalTo(contentView).offset(16)
        }
        transactionAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerSpaceLabel.snp.bottom).offset(15)
            make.centerX.equalTo(contentView)
        }
        transactionPriceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerSpaceLabel.snp.bottom).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-16)
        }
    }
    lazy var headerTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_market_mine_commission_title")
        return label
    }()
    lazy var headerButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_order_center_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "60606D"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var headerSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var transactionTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "95969B")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_trade_name_title")
        return label
    }()
    lazy var transactionAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "95969B")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_trade_amount_title")
        return label
    }()
    lazy var transactionPriceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "95969B")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_trade_price_title")
        return label
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.showOrderCenter()
    }
}
