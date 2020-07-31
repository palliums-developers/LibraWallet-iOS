//
//  ExchangeTransactionDetailFooterView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/31.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ExchangeTransactionDetailFooterView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        contentView.addSubview(submitIndicatorImageView)
        contentView.addSubview(submitTitleLabel)
        contentView.addSubview(submitSpaceLabel)
        
        contentView.addSubview(exchangeIndicatorImageView)
        contentView.addSubview(exchangeTitleLabel)
        contentView.addSubview(exchangeSpaceLabel)
        
        contentView.addSubview(finalIndicatorImageView)
        contentView.addSubview(finalTitleLabel)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ExchangeTransactionDetailFooterView销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        submitIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(29)
            make.left.equalTo(contentView).offset(36)
            make.right.equalTo(submitTitleLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        submitTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(submitIndicatorImageView)
            make.left.equalTo(submitIndicatorImageView.snp.right).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-36)
        }
        submitSpaceLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(submitIndicatorImageView)
            make.top.equalTo(submitIndicatorImageView.snp.bottom).offset(4)
            make.size.equalTo(CGSize.init(width: 0.5, height: 38))
        }
        exchangeIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(submitSpaceLabel.snp.bottom).offset(4)
            make.left.equalTo(contentView).offset(36)
            make.right.equalTo(submitTitleLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        exchangeTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(exchangeIndicatorImageView)
            make.left.equalTo(exchangeIndicatorImageView.snp.right).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-36)
        }
        exchangeSpaceLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(exchangeIndicatorImageView)
            make.top.equalTo(exchangeIndicatorImageView.snp.bottom).offset(4)
            make.size.equalTo(CGSize.init(width: 0.5, height: 38))
        }
        finalIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeSpaceLabel.snp.bottom).offset(4)
            make.left.equalTo(contentView).offset(36)
            make.right.equalTo(submitTitleLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
        }
        finalTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(finalIndicatorImageView)
            make.left.equalTo(finalIndicatorImageView.snp.right).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-36)
        }
    }
    //MARK: - 懒加载对象
    private lazy var submitIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "transaction_detail_finish")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var submitTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_transaction_status_submitted_title")
        return label
    }()
    lazy var submitSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "333333")
        return label
    }()
    private lazy var exchangeIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "transaction_detail_uncheck")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var exchangeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "333333")
        label.text = localLanguage(keyString: "---")
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        return label
    }()
    lazy var exchangeSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "333333")
        return label
    }()
    private lazy var finalIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "transaction_detail_failed")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var finalTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.numberOfLines = 2
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
        button.layer.cornerRadius = 9
        button.tag = 100
        button.alpha = 0
        return button
    }()
    var model: ExchangeTransactionsDataModel? {
        didSet {
            exchangeTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_exchanging_title")
            
            if model?.status == 4001 {
                retryButton.alpha = 0
                finalTitleLabel.textColor = UIColor.init(hex: "13B788")
                finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_finish")
                finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_exchange_fsuccessful_title")
            } else {
                retryButton.alpha = 1
                finalIndicatorImageView.image = UIImage.init(named: "transaction_detail_failed")
                finalTitleLabel.text = localLanguage(keyString: "wallet_market_transaction_status_exchange_failed_title")
            }
        }
    }
}
