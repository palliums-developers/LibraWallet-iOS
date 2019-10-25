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
        contentView.backgroundColor = defaultBackgroundColor
        contentView.addSubview(walletWhiteBackgroundView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
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
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.centerY.equalTo(walletWhiteBackgroundView).offset(-10)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(walletWhiteBackgroundView).offset(10)
            make.left.equalTo(contentView).offset(15)
        }
    }
    //MARK: - 懒加载对象
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "Test"
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        return label
    }()
    //MARK: - 设置数据
    var dataModel: [String: String]? {
        didSet {
            guard let data = dataModel else {
                return
            }
            self.titleLabel.text =  data["Title"]
            self.detailLabel.text = data["Content"]
        }
    }
    func setCellSelected(status: Bool) {
        if status == true {
            titleLabel.textColor = UIColor.init(hex: "15C794")
            detailLabel.textColor = UIColor.init(hex: "15C794")
        } else {
            titleLabel.textColor = UIColor.init(hex: "333333")
            detailLabel.textColor = UIColor.init(hex: "333333")
        }
    }
}
