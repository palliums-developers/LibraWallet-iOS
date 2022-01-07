//
//  MappingTransactionsTableViewCell.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/2/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MappingTransactionsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stateLabel)
        contentView.addSubview(inputAmountLabel)
        contentView.addSubview(exchangeIndicatorImageView)
        contentView.addSubview(outputAmountLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(minerFeesLabel)
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MappingTransactionsTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        stateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(10)
            make.left.equalTo(contentView).offset(14)
        }
        inputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(stateLabel.snp.bottom).offset(8)
        }
        exchangeIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(inputAmountLabel)
            make.left.equalTo(inputAmountLabel.snp.right).offset(8)
            make.size.equalTo(CGSize.init(width: 10, height: 9))
        }
        outputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(exchangeIndicatorImageView.snp.right).offset(8)
            make.centerY.equalTo(inputAmountLabel)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.centerY.equalTo(stateLabel)
        }
        minerFeesLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(inputAmountLabel.snp.bottom).offset(8)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.height.equalTo(0.5)
        }
    }
    // MARK: - 懒加载对象
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "13B788")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        return label
    }()
    private lazy var exchangeIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mapping_transaction_indicator")
        return imageView
    }()
    lazy var outputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = "---"
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
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
    lazy var minerFeesLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
//        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.text = localLanguage(keyString: "wallet_mapping_transactions_fees_title") + "---"
        label.numberOfLines = 0
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    //MARK: - 设置数据
    var model: MappingTransactionsDataModel? {
        didSet {
            //计算剩余
            guard let tempModel = model else {
                return
            }
            var toAmountUnit = 1000000
            if tempModel.out_token?.lowercased() == "btc" {
                toAmountUnit = 100000000
            }
            var fromAmountUnit = 1000000
            if tempModel.in_token?.lowercased() == "btc" {
                fromAmountUnit = 100000000
            }
            inputAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.in_amount ?? 0),
                                                           scale: fromAmountUnit == 1000000 ? 6:8,
                                                           unit: fromAmountUnit) + (model?.in_show_name ?? "")
            outputAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.out_amount ?? 0),
                                                            scale: toAmountUnit == 1000000 ? 6:8,
                                                            unit: toAmountUnit) + (model?.out_show_name ?? "")
            dateLabel.text = timestampToDateString(timestamp: Int(model?.expiration_time ?? 0),
                                                               dateFormat: "HH:mm MM/dd")
            if model?.state == "end" {
                // 已完成
                stateLabel.textColor = UIColor.init(hex: "13B788")
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_success_title")
            } else if model?.state == "start" {
                // 兑换中
                stateLabel.textColor = UIColor.init(hex: "FB8F0B")
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_processing_title")
            } else if model?.state == "cancel" {
                // 已取消
                stateLabel.textColor = UIColor.init(hex: "E54040")
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_canceled_title")
            } else {
                // 兑换失败
                stateLabel.textColor = UIColor.init(hex: "E54040")
                stateLabel.text = localLanguage(keyString: "wallet_mapping_transactions_state_failed_title")
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
