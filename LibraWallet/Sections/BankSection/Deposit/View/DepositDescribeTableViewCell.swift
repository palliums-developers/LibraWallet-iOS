//
//  DepositDescribeTableViewCell.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class DepositDescribeTableViewCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(itemTitleLabel)
        whiteBackgroundView.addSubview(itemContentLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("DepositDescribeTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
             make.left.equalTo(contentView).offset(15)
             make.right.equalTo(contentView.snp.right).offset(-15)
             make.top.bottom.equalTo(contentView)
         }
         itemTitleLabel.snp.makeConstraints { (make) in
             make.top.equalTo(whiteBackgroundView).offset(15)
             make.left.equalTo(whiteBackgroundView).offset(13)
             make.right.equalTo(whiteBackgroundView.snp.right).offset(-13)
         }
         itemContentLabel.snp.makeConstraints { (make) in
             make.top.equalTo(itemTitleLabel.snp.bottom).offset(10)
             make.left.equalTo(whiteBackgroundView).offset(13)
             make.right.equalTo(whiteBackgroundView.snp.right).offset(-13)
         }
    }
    // MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var itemTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.medium)
        label.text = ""
        return label
    }()
    lazy var itemContentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "---"
        label.numberOfLines = 0
        return label
    }()
    //MARK: - 设置数据
    var model: DepositItemDetailMainDataIntroduceModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
//            itemTitleLabel.text = tempModel.title
            itemContentLabel.text = (tempModel.title ?? "") + " " + (tempModel.text ?? "")
        }
    }
}
