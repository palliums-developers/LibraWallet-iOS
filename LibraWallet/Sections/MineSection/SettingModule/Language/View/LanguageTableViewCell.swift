//
//  LanguageTableViewCell.swift
//  HKWallet
//
//  Created by palliums on 2019/8/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        contentView.addSubview(IndicatorImageView)
        contentView.addSubview(cellSpaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LanguageTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.centerY.equalTo(contentView)
        }
        IndicatorImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.centerY.equalTo(contentView)
        }
        cellSpaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom)
            make.left.equalTo(self).offset(14)
            make.right.equalTo(self.snp.right).offset(-14)
            make.height.equalTo(1)
        }
    }
    //MARK: - 懒加载对象

    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "Test"
        return label
    }()
    lazy var IndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "language_deselect")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var cellSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
//language_select
    //MARK: - 设置数据
    var dataModel: [String: String]? {
        didSet {
            guard let data = dataModel else {
                return
            }
            self.titleLabel.text =  data["Title"]
        }
    }
    func setCellSelected(status: Bool) {
        if status == true {
            IndicatorImageView.image = UIImage.init(named: "language_select")
        } else {
            IndicatorImageView.image = UIImage.init(named: "language_deselect")
        }
    }
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                cellSpaceLabel.alpha = 0
            }
        }
    }
}
