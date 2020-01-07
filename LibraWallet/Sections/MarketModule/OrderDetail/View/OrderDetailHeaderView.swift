//
//  OrderDetailHeaderView.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class OrderDetailHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(backgroundImageView)
        
        backgroundImageView.addSubview(coinTitleLabel)
        backgroundImageView.addSubview(cancelButton)
        backgroundImageView.addSubview(priceTitleLabel)
        backgroundImageView.addSubview(amountTitleLabel)
        backgroundImageView.addSubview(dateTitleLabel)
        backgroundImageView.addSubview(successAmountTitleLabel)
        backgroundImageView.addSubview(feeTitleLabel)
        
        backgroundImageView.addSubview(priceLabel)
        backgroundImageView.addSubview(amountLabel)
        backgroundImageView.addSubview(dateLabel)
        backgroundImageView.addSubview(successAmountLabel)
        backgroundImageView.addSubview(feeLabel)
        
        backgroundImageView.addSubview(checkOnlineButton)
        
        addSubview(orderTitleLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("OrderDetailHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(186)
        }
        coinTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(32)
            make.left.equalTo(backgroundImageView).offset(33)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(backgroundImageView.snp.right).offset(-27)
            make.centerY.equalTo(coinTitleLabel)
        }
        priceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundImageView).offset(33)
            make.top.equalTo(coinTitleLabel.snp.bottom).offset(19)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.left.equalTo(backgroundImageView).offset(124)
        }
        dateTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.right.equalTo(backgroundImageView.snp.right).offset(-119)
        }
        successAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceTitleLabel)
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
        }
        feeTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundImageView).offset(124)
            make.centerY.equalTo(successAmountTitleLabel)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceTitleLabel)
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(5)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundImageView).offset(124)
            make.centerY.equalTo(priceLabel)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(dateTitleLabel)
        }
        successAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(successAmountTitleLabel)
            make.top.equalTo(successAmountTitleLabel.snp.bottom).offset(5)
        }
        feeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundImageView).offset(124)
            make.centerY.equalTo(successAmountLabel)
        }
        checkOnlineButton.snp.makeConstraints { (make) in
            make.right.equalTo(backgroundImageView.snp.right).offset(-27)
            make.bottom.equalTo(backgroundImageView.snp.bottom).offset(-25)
        }
        orderTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(15)
        }
    }
    //MARK: - 懒加载对象
    private lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "order_detail_header_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    func addShadow() {
        self.layer.backgroundColor = UIColor.white.cgColor
        // 定义阴影颜色
        self.layer.shadowColor = UIColor.init(hex: "E5E5E5").cgColor
        // 阴影的模糊半径
        self.layer.shadowRadius = 10
        // 阴影的偏移量
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        self.layer.shadowOpacity = 0.3
    }
    lazy var coinTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var priceTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(white: 1.0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_price_title")
        return label
    }()
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(white: 1.0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_amount_title")
        return label
    }()
    lazy var dateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(white: 1.0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_date_title")
        return label
    }()
    lazy var successAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(white: 1.0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_fill_amount_title")
        return label
    }()
    lazy var feeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(white: 1.0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_order_detail_fee_title")
        return label
    }()
    lazy var priceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var successAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var feeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var orderTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.medium)
        label.text = localLanguage(keyString: "wallet_market_order_detail_fill_order_title")
        return label
    }()
    lazy var checkOnlineButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
//        button.setTitle(localLanguage(keyString: "浏览器查询"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "FF8C8C"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.alpha = 0
        return button
    }()
    @objc func buttonClick(button: UIButton) {
    }
    var model: MarketOrderDataModel? {
        didSet {
            let attString = NSMutableAttributedString.init(string: model?.tokenGiveSymbol ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.white])
            let attString2 = NSAttributedString.init(string: "/", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.white])
            let attString3 = NSMutableAttributedString.init(string: model?.tokenGetSymbol ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.white])
            attString.append(attString2)
            attString.append(attString3)
            coinTitleLabel.attributedText = attString
            dateLabel.text = timestampToDateString(timestamp: model?.date ?? 0, dateFormat: "MM/dd HH:mm:ss")
            priceLabel.text = "\(model?.price ?? 0)"
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(string: (model?.amountGet ?? "0")),
                                                      scale: 4,
                                                      unit: 1000000)
            
            successAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(string: (model?.amountFilled ?? "0")),
                                                             scale: 4,
                                                             unit: 1000000)
            feeLabel.text = "---"
//            order status:0=OPEN 1=FILLED 2=CANCELED 3=FILLED or CANCELED, can not specify
            var tempString = ""
            if model?.state == "OPEN" {
                tempString = localLanguage(keyString: "wallet_market_order_detail_state_processing_title")
            } else if model?.state == "FILLED" {
                tempString = localLanguage(keyString: "wallet_market_order_detail_state_done_title")
            } else if model?.state == "CANCELED" {
                tempString = localLanguage(keyString: "wallet_market_order_detail_state_canceled_title")
            }
            cancelButton.setTitle(tempString, for: UIControl.State.normal)
        }
    }
}
