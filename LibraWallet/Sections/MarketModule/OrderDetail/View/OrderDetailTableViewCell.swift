//
//  OrderDetailTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
//        contentView.addSubview(coinTitleLabel)
        contentView.addSubview(priceTitleLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(dateTitleLabel)
        
        contentView.addSubview(priceLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(dateLabel)
                
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("OrderDetailTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
//        coinTitleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(contentView).offset(16)
//            make.left.equalTo(contentView).offset(15)
//        }
        dateTitleLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(priceTitleLabel)
//            make.right.equalTo(contentView.snp.right).offset(-119)
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(19)
        }
        priceTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(19)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(19)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(7)
            make.left.equalTo(dateTitleLabel)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceTitleLabel)
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(7)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-15)
            make.top.equalTo(amountTitleLabel.snp.bottom).offset(7)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-14)
            make.bottom.equalTo(contentView)
            make.height.equalTo(1)
        }
    }
    //MARK: - 懒加载对象
//    private lazy var addressBackgroundView: UIView = {
//        let view = UIView.init()
//        view.backgroundColor = UIColor.init(hex: "F7F7F9")
//        return view
//    }()
    lazy var coinTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var priceTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_price_title")
        return label
    }()
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_amount_title")
        return label
    }()
    lazy var dateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_date_title")
        return label
    }()
    lazy var priceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    @objc func buttonClick(button: UIButton) {
    }
    //MARK: - 设置数据
    var model: OrderDetailDataModel? {
        didSet {
            dateLabel.text = timestampToDateString(timestamp: model?.date ?? 0, dateFormat: "MM/dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(string: (model?.amount ?? "0")),
                                                      scale: 4,
                                                      unit: 1000000)
        }
    }
    var priceModel: MarketOrderDataModel? {
        didSet {
            priceLabel.text = "\(priceModel?.price ?? 0)"
        }
    }
}
