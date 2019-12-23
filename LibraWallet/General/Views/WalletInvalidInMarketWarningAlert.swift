//
//  WalletInvalidInMarketWarningAlert.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/20.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletInvalidInMarketWarningAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        addSubview(walletWhiteBackgroundView)

        walletWhiteBackgroundView.addSubview(indicatorImageView)
//        walletWhiteBackgroundView.addSubview(refreshBtn)
        walletWhiteBackgroundView.addSubview(descLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.right.bottom.equalTo(self)
        }
        indicatorImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(walletWhiteBackgroundView)
            make.bottom.equalTo(walletWhiteBackgroundView.snp.centerY).offset(-55)
        }
        descLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(indicatorImageView.snp.bottom).offset(7)
            make.left.equalTo(walletWhiteBackgroundView).offset(20)
            make.right.equalTo(walletWhiteBackgroundView.snp.right).offset(-20)
        }
//        refreshBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(descLabel.snp.bottom).offset(73)
//            make.left.equalTo(self).offset(68)
//            make.right.equalTo(self.snp.right).offset(-68)
//            make.height.equalTo(40)
//        }
        
    }
    internal lazy var indicatorImageView: UIImageView = {
        return UIImageView()
    }()
//    internal lazy var tipLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.init(hex: "263C4E")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
////        label.font = PingFangRegular(15)
////        label.textColor = twLightGrayColor
//        return label
//    }()
    internal lazy var descLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(hex: "3C3848").alpha(0.3)
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.numberOfLines = 0
        return label
    }()
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    var emptyImageName:String? {
        didSet{
            indicatorImageView.image = UIImage.init(named: emptyImageName ?? "")
        }
    }
//    lazy var refreshBtn: UIButton = {
//        let button = UIButton.init(type: UIButton.ButtonType.custom)
//        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
//        button.addTarget(self, action: #selector(refresh), for: UIControl.Event.touchUpInside)
//        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: UIScreen.main.bounds.size.width - 136, height: 40)), at: 0)
//        button.layer.cornerRadius = 6
//        button.layer.masksToBounds = true
//        button.tag = 10
//        return button
//    }()
//    @objc func refresh() {
//        if let callback = refreshAction {
//            callback()
//        }
//    }
//    var refreshButtonTitle: String? {
//        didSet {
//            refreshBtn.setTitle(refreshButtonTitle, for: .normal)
//        }
//    }
    var refreshAction:(() -> ())?
    var descString:String? {
        didSet{
            descLabel.text = descString
        }
    }
}
