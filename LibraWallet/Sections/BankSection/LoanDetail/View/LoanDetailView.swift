//
//  LoanDetailView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

class LoanDetailView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(topBackgroundImageView)
        
        addSubview(headerView)
        headerView.addSubview(segmentView)
        addSubview(listContainerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanDetailView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo((153 * ratio))
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.right.equalTo(self)
            make.height.equalTo(146)
        }
        segmentView.snp.makeConstraints { (make) in
            make.bottom.equalTo(headerView.snp.bottom)
            make.left.equalTo(headerView).offset(15)
            make.right.equalTo(headerView.snp.right).offset(-15)
            make.height.equalTo(40)
        }
        listContainerView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.right.equalTo(self)
            make.top.equalTo(headerView.snp.bottom)
        }
        #warning("圆角待处理")
//        listContainerView.corner(byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], radii: 24)
    }
    //MARK: - 懒加载对象
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.init(hex: "F7F7F9")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var headerView: LoanDetailHeaderView = {
        let view = LoanDetailHeaderView.init()
        view.backgroundColor = UIColor.init(hex: "F7F7F9")
        return view
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
        return listView
    }()
    private lazy var segmentedDataSource : JXSegmentedTitleDataSource = {
        let data = JXSegmentedTitleDataSource.init()
        //配置数据源相关配置属性
        data.titles = [localLanguage(keyString: "wallet_bank_loan_detail_loan_detail_title"),
                       localLanguage(keyString: "wallet_bank_loan_detail_deposit_detail_title"),
                       localLanguage(keyString: "wallet_bank_loan_detail_clearing_detail_title")]
        data.isTitleColorGradientEnabled = true
        data.titleNormalColor = UIColor.init(hex: "999999")
        data.titleNormalFont = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
        data.titleSelectedColor = UIColor.init(hex: "333333")
        data.titleSelectedFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        data.itemSpacing = 20
        //reloadData(selectedIndex:)方法一定要调用，方法内部会刷新数据源数组
        data.reloadData(selectedIndex: 0)
        return data
    }()
    var controllers: [UIViewController]?
}
extension LoanDetailView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers?[index] as! JXSegmentedListContainerViewListDelegate
    }
}
