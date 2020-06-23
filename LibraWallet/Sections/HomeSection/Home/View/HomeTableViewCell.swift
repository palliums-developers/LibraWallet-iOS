//
//  HomeTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.backgroundColor = UIColor.white
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(coinIconImageView)
        whiteBackgroundView.addSubview(coinNameLabel)
        whiteBackgroundView.addSubview(coinAmountLabel)
        whiteBackgroundView.addSubview(coinValueLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("HomeTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(6)
            make.bottom.equalTo(contentView.snp.bottom).offset(-6)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-15)
        }
        coinIconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.size.equalTo(CGSize.init(width: 42, height: 42))
            make.left.equalTo(whiteBackgroundView).offset(14)
        }
        coinNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(coinIconImageView.snp.right).offset(15)
        }
        coinAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView).offset(-10)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
        }
        coinValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView).offset(10)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
        }
    }
    //MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
//        view.layer.cornerRadius = 7
        view.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
        view.layer.cornerRadius = 14
        return view
    }()
    private lazy var coinIconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 14
        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var coinNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var coinAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "0.00"
        return label
    }()
    lazy var coinValueLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "ADADAD")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "≈$0.00"
        return label
    }()
    //MARK: - 设置数据
    var model: Token? {
        didSet {
            coinNameLabel.text = model?.tokenName
            var unit = 1000000
            if model?.tokenType == .BTC {
                unit = 100000000
            }
            coinAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model?.tokenBalance ?? 0)),
                                                          scale: 4,
                                                          unit: unit)
            if let iconName = model?.tokenIcon, iconName.isEmpty == false {
                if iconName.hasPrefix("http") {
                    let url = URL(string: iconName)
                    coinIconImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
                } else {
                    coinIconImageView.image = UIImage.init(named: iconName)
                }
            } else {
                coinIconImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            let rate = NSDecimalNumber.init(string: model?.tokenPrice ?? "0.0")
            let amount = NSDecimalNumber.init(string: coinAmountLabel.text ?? "0")
            let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
                                                           scale: 4,
                                                           raiseOnExactness: false,
                                                           raiseOnOverflow: false,
                                                           raiseOnUnderflow: false,
                                                           raiseOnDivideByZero: false)
            let value = rate.multiplying(by: amount, withBehavior: numberConfig)
            coinValueLabel.text = "≈$\(value.stringValue)"
        }
    }
}
