//
//  MarketOthersOrderHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol MarketOthersOrderHeaderViewDelegate: NSObjectProtocol {
    func showHideOthersToMax(button: UIButton)
}
class MarketOthersOrderHeaderView: UITableViewHeaderFooterView {
    weak var delegate: MarketOthersOrderHeaderViewDelegate?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
//        addSubview(headerTitleLabel)
        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerButton)
        contentView.addSubview(headerSpaceLabel)
        
        contentView.addSubview(transactionAmountLabel)
        contentView.addSubview(transactionPriceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketOthersOrderHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.bottom.equalTo(headerSpaceLabel.snp.top).offset(-15)
        }
        headerButton.snp.makeConstraints { (make) in
            make.left.equalTo(headerTitleLabel.snp.right).offset(5)
            make.centerY.equalTo(headerTitleLabel)
        }
        headerSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView).offset(-14)
            make.centerY.equalTo(contentView).offset(12)
            make.height.equalTo(1)
        }
        transactionAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerSpaceLabel.snp.bottom).offset(15)
            make.left.equalTo(contentView).offset(16)
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
        label.text = localLanguage(keyString: "wallet_market_other_commission_title")
        return label
    }()
    lazy var headerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "bottom_arrow"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var headerSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
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
        if button.image(for: .normal) == UIImage.init(named: "top_arrow") {
            button.setImage(UIImage.init(named: "bottom_arrow"), for: .normal)
        } else {
            button.setImage(UIImage.init(named: "top_arrow"), for: .normal)
        }
        self.delegate?.showHideOthersToMax(button: button)
    }
}
