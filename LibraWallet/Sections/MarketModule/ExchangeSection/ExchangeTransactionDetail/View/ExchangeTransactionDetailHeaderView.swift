//
//  ExchangeTransactionDetailHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ExchangeTransactionDetailHeaderView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(inputAmountLabel)
        contentView.addSubview(exchangeAmountIndicatorImageView)
        contentView.addSubview(outputAmountLabel)
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ExchangeTransactionDetailHeaderView销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        inputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.top.equalTo(contentView).offset(20)
        }
        exchangeAmountIndicatorImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(inputAmountLabel.snp.bottom).offset(12)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        outputAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.top.equalTo(exchangeAmountIndicatorImageView.snp.bottom).offset(12)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(36)
            make.right.equalTo(contentView).offset(-36)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
            make.height.equalTo(0.5)
        }
    }
    //MARK: - 懒加载对象
    lazy var inputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    private lazy var exchangeAmountIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "exchange_transaction_detail_amount_indicator")
        return view
    }()
    lazy var outputAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "E0E0E0")
        return label
    }()
    var model: ExchangeTransactionsDataModel? {
        didSet {
            // 设置输入数量
            let inputAmount = getDecimalNumber(amount: NSDecimalNumber.init(value: model?.input_amount ?? 0),
                                               scale: 6,
                                               unit: 1000000)
            let inputAmountString = NSAttributedString(string: inputAmount.stringValue,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.init(name: "DIN Alternate Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)])
            let inputUnitString = NSAttributedString(string: model?.input_name ?? "---",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.init(name: "DIN Alternate Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)])
            let tempInputAtt = NSMutableAttributedString.init(attributedString: inputAmountString)
            tempInputAtt.append(inputUnitString)
            inputAmountLabel.attributedText = tempInputAtt
            // 设置输出数量
            let outputAmount = getDecimalNumber(amount: NSDecimalNumber.init(value: model?.output_amount ?? 0),
                                                scale: 6,
                                                unit: 1000000)
            let outputAmountString = NSAttributedString(string: outputAmount.stringValue,
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.init(name: "DIN Alternate Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)])
            let outputUnitString = NSAttributedString(string: model?.output_name ?? "---",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "333333"),NSAttributedString.Key.font: UIFont.init(name: "DIN Alternate Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)])
            let tempOutputAtt = NSMutableAttributedString.init(attributedString: outputAmountString)
            tempOutputAtt.append(outputUnitString)
            outputAmountLabel.attributedText = tempOutputAtt
        }
    }
}
