//
//  LoanOrderDetailView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import JXSegmentedView

protocol LoanOrderDetailViewDelegate: NSObjectProtocol {
    func confirmRepayment()
}
class LoanOrderDetailView: UIView {
    weak var delegate: LoanOrderDetailViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(topBackgroundImageView)
        
        addSubview(headerView)
        headerView.addSubview(segmentView)
        addSubview(listContainerView)
        addSubview(footerBackgroundView)
        footerBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanOrderDetailView销毁了")
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
            make.bottom.equalTo(self.footerBackgroundView.snp.top)
            make.left.right.equalTo(self)
            make.top.equalTo(headerView.snp.bottom)
        }
        footerBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(72)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(footerBackgroundView).offset(20)
            make.left.equalTo(footerBackgroundView).offset(69)
            make.right.equalTo(footerBackgroundView.snp.right).offset(-69)
            make.height.equalTo(40)
        }
    }
    // MARK: - 懒加载对象
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.init(hex: "F7F7F9")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var headerView: LoanOrderDetailHeaderView = {
        let view = LoanOrderDetailHeaderView.init()
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
        listView.backgroundColor = UIColor.init(hex: "F7F7F9")
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
    lazy var footerBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        // 定义阴影颜色
        view.layer.shadowColor = UIColor.init(hex: "333333").cgColor
        // 阴影的模糊半径
        view.layer.shadowRadius = 3
        // 阴影的偏移量
        view.layer.shadowOffset = CGSize(width: 0, height: -5)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        view.layer.shadowOpacity = 0.04
        return view
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_loan_detail_repayment_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        let width = UIScreen.main.bounds.width - 69 - 69
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
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
extension LoanOrderDetailView: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return self.segmentedDataSource.titles.count
    }
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return controllers?[index] as! JXSegmentedListContainerViewListDelegate
    }
}
