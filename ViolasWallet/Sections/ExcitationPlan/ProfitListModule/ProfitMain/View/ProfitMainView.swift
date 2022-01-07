//
//  ProfitMainView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/12/2.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

protocol ProfitMainViewDelegate: NSObjectProtocol {
    func confirmRepayment()
}
class ProfitMainView: UIView {
    
    weak var delegate: ProfitMainViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(topBackgroundImageView)
        
        addSubview(segmentView)
        addSubview(listContainerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ProfitMainView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo((153 * ratio))
        }
        segmentView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight + 17)
            make.left.equalTo(self)
            make.right.equalTo(self.snp.right).offset(-22)
            make.height.equalTo(56)
        }
        listContainerView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.left.right.equalTo(self)
            make.top.equalTo(segmentView.snp.bottom)
        }
    }
    // MARK: - 懒加载对象
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.init(hex: "F7F7F9")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var segmentView : JXSegmentedView = {
        let view = JXSegmentedView.init()
        view.dataSource = self.segmentedDataSource
        view.contentScrollView = self.listContainerView.scrollView
        view.contentEdgeInsetLeft = 34
        view.backgroundColor = UIColor.init(hex: "F7F7F9")
        return view
    }()
    lazy var listContainerView: JXSegmentedListContainerView = {
        let listView = JXSegmentedListContainerView.init(dataSource: self)
        listView.backgroundColor = UIColor.init(hex: "F7F7F9")
        return listView
    }()
    private lazy var segmentedDataSource : JXSegmentedTitleDataSource = {
        let data = JXSegmentedTitleDataSource.init()
        //配置数据源相关配置属性
        data.titles = [localLanguage(keyString: "wallet_profit_invitation_title"),
                       localLanguage(keyString: "wallet_profit_pool_title"),
                       localLanguage(keyString: "wallet_profit_bank_title")]
        data.isTitleColorGradientEnabled = true
        data.titleNormalColor = UIColor.init(hex: "999999")
        data.titleNormalFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
        data.titleSelectedColor = UIColor.init(hex: "333333")
        data.titleSelectedFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        data.itemSpacing = 32
        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
        data.reloadData(selectedIndex: 0)
        return data
    }()
    lazy var toastView: ToastView? = {
        let toast = ToastView.init()
        return toast
    }()
    var controllers: [UIViewController]?
    @objc func buttonClick(button: UIButton) {
        self.delegate?.confirmRepayment()
    }
}
extension ProfitMainView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers?[index] as! JXSegmentedListContainerViewListDelegate
    }
}
