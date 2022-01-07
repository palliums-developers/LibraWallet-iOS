//
//  BankView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView
import Localize_Swift

protocol BankViewDelegate: NSObjectProtocol {
    func checkYieldFramingRules()
}
class BankView: UIView {
    weak var delegate: BankViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(topBackgroundImageView)
        addSubview(headerView)
        addSubview(segmentView)
        addSubview(listContainerView)
        segmentView.addSubview(yieldFramingRuleButton)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("BankView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(((162 + Int(navigationBarHeight)) * ratio))
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.right.equalTo(self)
            make.height.equalTo(110)
        }
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(50)
        }
        yieldFramingRuleButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(segmentView)
            make.right.equalTo(segmentView.snp.right).offset(-12)
            make.size.equalTo(CGSize.init(width: 102, height: 26))
        }
        segmentView.corner(byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], radii: 8)
        listContainerView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.top.equalTo(segmentView.snp.bottom)
        }
    }
    // MARK: - 懒加载对象
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_top_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var headerView: BankViewHeaderView = {
        let view = BankViewHeaderView.init()
        view.isUserInteractionEnabled = true
        return view
    }()
    lazy var segmentView : JXSegmentedView = {
        let view = JXSegmentedView.init()
        view.backgroundColor = UIColor.white
        view.dataSource = self.segmentedDataSource
        view.contentScrollView = self.listContainerView.scrollView
        view.contentEdgeInsetLeft = 20
        return view
    }()
    lazy var listContainerView: JXSegmentedListContainerView = {
        let listView = JXSegmentedListContainerView.init(dataSource: self)
        return listView
    }()
    private lazy var segmentedDataSource : JXSegmentedTitleDataSource = {
        let data = JXSegmentedTitleDataSource.init()
        //配置数据源相关配置属性
        data.titles = [localLanguage(keyString: "wallet_bank_deposit_market_title"),
                       localLanguage(keyString: "wallet_bank_loan_market_title")]
        data.isTitleColorGradientEnabled = true
        data.titleNormalColor = UIColor.init(hex: "999999")
        data.titleNormalFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        data.titleSelectedColor = UIColor.init(hex: "333333")
        data.titleSelectedFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
        data.reloadData(selectedIndex: 0)
        return data
    }()
    var controllers: [UIViewController]?
    lazy var yieldFramingRuleButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "yield_framing_rule_background"), for: .normal)
        button.setTitle(localLanguage(keyString: "wallet_bank_yield_framing_rules_button_title"), for: UIControl.State.normal)
        button.setImage(UIImage.init(named: "yield_farming_rule_detail"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        button.setTitleColor(UIColor.init(hex: "7540FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.imagePosition(at: .right, space: 2, imageViewSize: CGSize.init(width: 15, height: 12))
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.checkYieldFramingRules()
    }
}
extension BankView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers?[index] as! JXSegmentedListContainerViewListDelegate
    }
}
// MARK: - 语言切换方法
extension BankView {
    // 语言切换
    @objc func setText() {
        self.segmentedDataSource.titles = [localLanguage(keyString: "wallet_bank_deposit_market_title"),
                                           localLanguage(keyString: "wallet_bank_loan_market_title")]
        self.segmentView.reloadData()
    }
}
