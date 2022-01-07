//
//  NotificationCenterView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2021/1/11.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

class NotificationCenterView: UIView {
    weak var delegate: BankViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
    }
    convenience init(controllers: [UIViewController], dotStates: [Bool]) {
        self.init(frame: CGRect.zero)
        
        self.controllers = controllers
        self.dotStates = dotStates
        
        addSubview(segmentView)
        addSubview(spaceLabel)
        addSubview(listContainerView)
        segmentView.addSubview(yieldFramingRuleButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("NotificationCenterView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.height.equalTo(40)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(0.5)
            make.bottom.equalTo(segmentView.snp.bottom)
        }
        listContainerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(spaceLabel.snp.bottom)
        }
    }
    // MARK: - 懒加载对象
    lazy var segmentView : JXSegmentedView = {
        let view = JXSegmentedView.init()
        view.backgroundColor = UIColor.white
        view.dataSource = self.segmentedDataSource
        view.contentScrollView = self.listContainerView.scrollView
        view.indicators = [indicator]
        return view
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var listContainerView: JXSegmentedListContainerView = {
        let listView = JXSegmentedListContainerView.init(dataSource: self)
        return listView
    }()
    lazy var indicator: JXSegmentedIndicatorLineView = {
        let indicator = JXSegmentedIndicatorLineView.init()
        indicator.isIndicatorWidthSameAsItemContent = true
        indicator.indicatorHeight = 1
        indicator.indicatorColor = UIColor.init(hex: "333333")
        return indicator
    }()
    lazy var segmentedDataSource : JXSegmentedDotDataSource = {
        let data = JXSegmentedDotDataSource.init()
        //配置数据源相关配置属性
        data.titles = [localLanguage(keyString: "wallet_notification_wallet_messages_title"),
                       localLanguage(keyString: "wallet_notification_system_messages_title")]
        data.isTitleColorGradientEnabled = true
        data.titleNormalColor = UIColor.init(hex: "999999")
        data.titleNormalFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        data.titleSelectedColor = UIColor.init(hex: "333333")
        data.titleSelectedFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        data.itemWidth = mainWidth / 2
        data.itemSpacing = 0
        data.dotStates = dotStates ?? [false, false]
        data.dotSize = CGSize.init(width: 6, height: 6)
        data.dotOffset = CGPoint.init(x: 4, y: 1)
        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
        data.reloadData(selectedIndex: 0)
        return data
    }()
    var controllers: [UIViewController]?
    var dotStates: [Bool]?
    lazy var yieldFramingRuleButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "yield_framing_rule_background"), for: .normal)
        button.setTitle(localLanguage(keyString: "wallet_bank_yield_framing_rules_button_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        button.setTitleColor(UIColor.init(hex: "7540FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.checkYieldFramingRules()
    }
}
extension NotificationCenterView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers?[index] as! JXSegmentedListContainerViewListDelegate
    }
}
