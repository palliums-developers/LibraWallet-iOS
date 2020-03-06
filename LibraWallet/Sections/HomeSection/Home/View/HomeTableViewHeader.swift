//
//  HomeTableViewHeader.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class HomeTableViewHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.init(hex: "F7F7F9")
        contentView.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(coinNameLabel)
        whiteBackgroundView.addSubview(coinAmountLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("HomeTableViewHeader销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView).offset(-15)

        }
        coinNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(whiteBackgroundView).offset(14)
        }
        coinAmountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-14)
        }
    }
    //MARK: - 懒加载对象
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
//        view.layer.cornerRadius = 7
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var coinNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3D3949")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var coinAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "3D3949")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var model: ViolasTokenModel? {
        didSet {
            coinNameLabel.text = model?.name
            coinAmountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model?.balance ?? 0)),
                                                          scale: 4,
                                                          unit: 1000000)
        }
    }
}
