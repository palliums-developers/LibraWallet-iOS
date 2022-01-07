//
//  ExchangeTransactionsTableViewCell.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class ExchangeTransactionsTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stateLabel)
        contentView.addSubview(inputAmountLabel)
        contentView.addSubview(exchangeIndicatorImageView)
        contentView.addSubview(outputAmountLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ExchangeTransactionsTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        stateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(14)
        }
        inputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(14)
            make.bottom.equalTo(contentView).offset(-11)
        }
        exchangeIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(inputAmountLabel)
            make.left.equalTo(inputAmountLabel.snp.right).offset(33)
            make.size.equalTo(CGSize.init(width: 10, height: 9))
        }
        outputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(exchangeIndicatorImageView.snp.right).offset(37)
            make.centerY.equalTo(inputAmountLabel)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.top.equalTo(contentView.snp.top).offset(13)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.height.equalTo(0.5)
        }
//        if reuseIdentifier == "FailedCell" {
//            retryButton.snp.makeConstraints { (make) in
//                make.centerY.equalTo(stateLabel)
//                make.left.equalTo(stateLabel.snp.right).offset(7)
//                make.size.equalTo(CGSize.init(width: 42, height: 18))
//            }
//        }
    }
    // MARK: - 懒加载对象
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 14)
        label.text = "---"
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
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 14)
        label.text = "---"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var retryButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_transaction_retry_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        //        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 9
        button.tag = 20
        return button
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    //MARK: - 设置数据
    var model: ExchangeTransactionsDataModel? {
        didSet {
            // 计算剩余
            inputAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.input_amount ?? 0),
                                                           scale: 6,
                                                           unit: 1000000) + (model?.input_name ?? "")
            outputAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.output_amount ?? 0),
                                                            scale: 6,
                                                            unit: 1000000) + (model?.output_name ?? "")
            dateLabel.text = timestampToDateString(timestamp: model?.date ?? 0,
                                                   dateFormat: "MM.dd HH:mm")
            if model?.status == "Executed" {
                // 已完成
                stateLabel.textColor = UIColor.init(hex: "13B788")
                stateLabel.text = localLanguage(keyString: "wallet_market_exchange_transaction_status_success_title")
            } else if model?.status == "4002" {
                // 兑换中
                stateLabel.textColor = UIColor.init(hex: "FB8F0B")
                stateLabel.text = localLanguage(keyString: "wallet_market_exchange_transaction_status_processing_title")
            } else if model?.status == "4004" {
                // 已取消
                stateLabel.textColor = UIColor.init(hex: "E54040")
                stateLabel.text = localLanguage(keyString: "wallet_market_exchange_transaction_status_cancel_title")
            } else {
                // 兑换失败
                stateLabel.textColor = UIColor.init(hex: "E54040")
                stateLabel.text = localLanguage(keyString: "wallet_market_exchange_transaction_status_failed_title")
            }
        }
    }
    var indexPath: IndexPath?
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                spaceLabel.alpha = 0
            }
        }
    }
}
