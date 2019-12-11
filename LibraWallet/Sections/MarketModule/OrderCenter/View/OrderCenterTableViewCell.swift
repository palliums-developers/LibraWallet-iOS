//
//  OrderCenterTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class OrderCenterTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(coinTitleLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(priceTitleLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(dateTitleLabel)
        contentView.addSubview(successAmountTitleLabel)
        contentView.addSubview(feeTitleLabel)
        contentView.addSubview(detailImageView)
        
        contentView.addSubview(priceLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(successAmountLabel)
        contentView.addSubview(feeLabel)
        
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("OrderCenterTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coinTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(16)
            make.left.equalTo(contentView).offset(15)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-14)
            make.centerY.equalTo(coinTitleLabel)
        }
        priceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(coinTitleLabel.snp.bottom).offset(8)
        }
        amountTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.left.equalTo(contentView).offset(124)
        }
        dateTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.right.equalTo(contentView.snp.right).offset(-119)
        }
        successAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
        }
        feeTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(124)
            make.centerY.equalTo(successAmountTitleLabel)
        }
        detailImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-14)
            make.centerY.equalTo(contentView)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(5)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(124)
            make.centerY.equalTo(priceLabel)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(dateTitleLabel)
        }
        successAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(successAmountTitleLabel.snp.bottom).offset(5)
        }
        feeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(124)
            make.centerY.equalTo(successAmountLabel)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-14)
            make.bottom.equalTo(contentView)
            make.height.equalTo(1)
        }
        //宽度不够时，可以被压缩
//        amountTitleLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容（不可以被压缩，尽量显示完整）
//        priceTitleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容（不可以被压缩，尽量显示完整）
//        dateTitleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
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
        label.text = "BBBUSD / AAAUSD"
        return label
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "726BD9"), for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "撤销"), for: UIControl.State.normal)

        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var priceTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "价格")
        return label
    }()
    lazy var amountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "数量")
        return label
    }()
    lazy var dateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "时间"
        return label
    }()
    lazy var successAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "已成交数量")
        return label
    }()
    lazy var feeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BABABA")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "手续费"
        return label
    }()
    private lazy var detailImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "order_detail_indicator")
       return imageView
    }()
    lazy var priceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "7.1")
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "200")
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "01/18 12:06:23"
        return label
    }()
    lazy var successAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "200")
        return label
    }()
    lazy var feeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "60606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "01/18 12:06:23"
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
    var dataModel: AddressModel? {
        didSet {
//            addressLabel.text = dataModel?.address
//            nameLabel.text = dataModel?.addressName
//            addressTypeLabel.text = dataModel?.addressType
        }
    }
    
}
