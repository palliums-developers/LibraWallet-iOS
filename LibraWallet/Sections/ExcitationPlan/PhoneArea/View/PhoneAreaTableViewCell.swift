//
//  PhoneAreaTableViewCell.swift
//  HKWallet
//
//  Created by palliums on 2019/8/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

class PhoneAreaTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(areaIndicatorImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(cellSpaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("PhoneAreaTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        areaIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(20)
            make.size.equalTo(CGSize.init(width: 0, height: 0))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(areaIndicatorImageView.snp.right).offset(10)
            make.right.equalTo(detailLabel.snp.left).offset(-5)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-20)
        }
        cellSpaceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(21)
            make.right.equalTo(self.contentView).offset(-24)
            make.bottom.equalTo(self.contentView).offset(0)
            make.height.equalTo(1)
        }
        //宽度不够时，可以被压缩
        nameLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容
        detailLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        areaIndicatorImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)

        //不可以被压缩，尽量显示完整
        detailLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        areaIndicatorImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)

    }
    //MARK: - 懒加载对象
    private lazy var areaIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "63606D")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_recharge_history_amount_title")
        label.numberOfLines = 0
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        return label
    }()
    
    lazy var cellSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    var hideAreaCode: Bool?
    //MARK: - 设置数据
    var model: PhoneAreaDataModel? {
        didSet {
            guard let result = model else {
                return
            }
//            areaIndicatorImageView.image = UIImage(named: "Countries.bundle/Images/\(result.code!.uppercased())", in: Bundle.main, compatibleWith: nil)
            nameLabel.text = result.name
            guard hideAreaCode == false else {
                return
            }
            detailLabel.text = result.dial_code
        }
    }
}
