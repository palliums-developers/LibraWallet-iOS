//
//  ExchangeTransactionDetailTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class ExchangeTransactionDetailTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
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
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(36)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(155)
        }
    }
    // MARK: - 懒加载对象
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.medium)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var model: TransactionDetailCustomDataModel? {
        didSet {
            titleLabel.text = model?.name
            contentLabel.text = model?.value
        }
    }
}
