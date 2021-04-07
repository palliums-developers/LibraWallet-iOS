//
//  AssetsPoolProfitHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

protocol AssetsPoolProfitHeaderViewDelegate: NSObjectProtocol {
    func showYieldFarmingRules()
}
class AssetsPoolProfitHeaderView: UIView {
    weak var delegate: AssetsPoolProfitHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        //        addSubview(headerBackground)
        addSubview(backgroundImageView)
        backgroundImageView.addSubview(titleLabel)
        backgroundImageView.addSubview(describeLabel)
        backgroundImageView.addSubview(detailImageView)
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("AssetsPoolProfitHeaderView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundImageView).offset(13)
            make.left.equalTo(backgroundImageView).offset(54)
        }
        describeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundImageView).offset(54)
            make.right.equalTo(backgroundImageView.snp.right).offset(-20)
            make.bottom.equalTo(backgroundImageView.snp.bottom).offset(-9)
        }
        detailImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(backgroundImageView.snp.right).offset(-22)
        }
    }
    // MARK: - 懒加载对象
    lazy var backgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "pool_yield_farming_background")
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "FB8F0B")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_yield_farming_title")
        return label
    }()
    lazy var describeLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_market_assets_pool_yield_farming_describe") + "---"
        return label
    }()
    private lazy var detailImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "pool_yield_farming_detail")
        return view
    }()
    private lazy var tap: UIGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }()
    @objc private func tapRecognized(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.delegate?.showYieldFarmingRules()
        }
    }
    /// 语言切换
    @objc func setText() {
        titleLabel.text = localLanguage(keyString: "wallet_market_assets_pool_yield_farming_title")
        describeLabel.text = localLanguage(keyString: "wallet_market_assets_pool_yield_farming_describe") + "---"

    }
}
