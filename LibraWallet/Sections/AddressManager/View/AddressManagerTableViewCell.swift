//
//  AddressManagerTableViewCell.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddressManagerTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F8F8F8")
        contentView.addSubview(walletWhiteBackgroundView)
        walletWhiteBackgroundView.addSubview(nameLabel)
        walletWhiteBackgroundView.addSubview(addressLabel)
        walletWhiteBackgroundView.addSubview(addressTypeLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AddressManagerTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        self.walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(self)
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletWhiteBackgroundView).offset(11)
            make.left.equalTo(self.walletWhiteBackgroundView).offset(15)
        }
        self.addressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.walletWhiteBackgroundView.snp.bottom).offset(-10)
            make.left.equalTo(self.walletWhiteBackgroundView).offset(15)
        }
        self.addressTypeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.walletWhiteBackgroundView).offset(10)
            make.right.equalTo(self.walletWhiteBackgroundView.snp.right).offset(-10)
            make.size.equalTo(CGSize.init(width: 55, height: 23))
        }
    }
    //MARK: - 懒加载对象
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "7F7F7F")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var addressTypeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "AEAEAE")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "BTC"
        label.layer.backgroundColor = UIColor.init(hex: "F5F4F4").cgColor
        label.layer.cornerRadius = 7
        return label
    }()
    //MARK: - 设置数据
    var dataModel: AddressModel? {
        didSet {
            self.addressLabel.text = dataModel?.address
            self.nameLabel.text = dataModel?.addressName
        }
    }
}
