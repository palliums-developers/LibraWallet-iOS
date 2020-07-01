//
//  AssetsPoolTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class AssetsPoolTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        contentView.addSubview(transactionTypeImageView)
        contentView.addSubview(stateLabel)
        contentView.addSubview(tokenLabel)
        contentView.addSubview(inputAmountLabel)
        contentView.addSubview(exchangeIndicatorImageView)
        contentView.addSubview(outputAmountLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(spaceLabel)
        if reuseIdentifier == "FailedCell" {
            contentView.addSubview(retryButton)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        transactionTypeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        stateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(-15)
            make.left.equalTo(contentView).offset(8)
        }
        tokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(15)
            make.left.equalTo(contentView).offset(8)
        }
//        inputAmountLabel.snp.makeConstraints { (make) in
//            make.right.equalTo(exchangeIndicatorImageView.snp.left).offset(-33)
//            make.centerY.equalTo(outputAmountLabel)
//        }
//        exchangeIndicatorImageView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(outputAmountLabel)
//            make.right.equalTo(outputAmountLabel.snp.left).offset(-33)
//            make.size.equalTo(CGSize.init(width: 10, height: 9))
//        }
//        outputAmountLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(contentView).offset(9)
//            make.right.equalTo(exchangeIndicatorImageView.snp.right).offset(-16)
//        }
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.centerY.equalTo(tokenLabel)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.height.equalTo(0.5)
        }
        if reuseIdentifier == "FailedCell" {
            retryButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(stateLabel)
                make.left.equalTo(stateLabel.snp.right).offset(7)
            }
        }
    }
    // MARK: - 懒加载对象
    private lazy var transactionTypeImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        return view
    }()
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "兑换成功"
        return label
    }()
    lazy var tokenLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "通证：+199"
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "8888USD"
        return label
    }()
    private lazy var exchangeIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "exchange_indicator")
        return imageView
    }()
    lazy var outputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "9999USD"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "01.18 12:06"
        return label
    }()
    lazy var retryButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_confirm_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        //        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 14
        button.tag = 100
        return button
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    //MARK: - 设置数据
    //    var model: MarketOrderDataModel? {
    //        didSet {
    //            // 计算剩余
    //            let lastAmount = NSDecimalNumber.init(string: model?.amountGet ?? "0").subtracting(NSDecimalNumber.init(string: model?.amountFilled ?? "0"))
    //
    //            amountLabel.text = getDecimalNumberAmount(amount: lastAmount,
    //                                                      scale: 4,
    //                                                      unit: 1000000)
    //            priceLabel.text = "\(model?.tokenGetPrice ?? 0)"
    //        }
    //    }
    var indexPath: IndexPath?
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                spaceLabel.alpha = 0
            }
        }
    }
}
