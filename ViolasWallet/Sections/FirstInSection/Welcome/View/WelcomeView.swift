//
//  WelcomeView.swift
//  HKWallet
//
//  Created by palliums on 2019/8/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WelcomeViewDelegate: NSObjectProtocol {
    func confirm()
}
class WelcomeView: UIView {
    weak var delegate: WelcomeViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        for view in pageArray {
            scrollView.addSubview(view)
        }
        addSubview(pageControl)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WelcomeView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
        for view in pageArray {
            view.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(self)
                make.left.equalTo(scrollView).offset(mainWidth * CGFloat(view.tag))
                make.width.equalTo(mainWidth)
            }
        }
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom).offset(-142)
            make.centerX.equalTo(self)
        }
        scrollView.contentSize = CGSize.init(width: mainWidth * CGFloat(pageArray.count), height: mainHeight)
    }
    //MARK: - 懒加载对象
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    private lazy var pageArray : [WelcomePageView] = {
        var array = [WelcomePageView]()
        for i in 0..<dataArray.count {
            let page = WelcomePageView.init()
            page.tag = i
            page.data = self.dataArray[i]
            array.append(page)
            page.lastPage = i == (dataArray.count - 1) ? true:false
            page.delegate = self
        }
        return array
    }()
    private lazy var pageControl : UIPageControl = {
        let pageCon = UIPageControl.init()
        pageCon.numberOfPages = self.dataArray.count
        pageCon.pageIndicatorTintColor = UIColor.init(hex: "C0FFFD")
        pageCon.currentPageIndicatorTintColor = UIColor.init(hex: "FFD041")
        pageCon.addTarget(self, action: #selector(pageControlChange), for: UIControl.Event.valueChanged)
        return pageCon
    }()
    var dataArray: [[String: String]] {
        return [["image":"welcom_page_icon_1",
                 "content":localLanguage(keyString: "wallet_welcome_page_first_content")],
                ["image":"welcom_page_icon_2",
                 "content":localLanguage(keyString: "wallet_welcome_page_second_content")],
                ["image":"welcom_page_icon_3",
                 "content":localLanguage(keyString: "wallet_welcome_page_third_content")]]
    }
    @objc func pageControlChange() {
        print(pageControl.currentPage)
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint.init(x: mainWidth * CGFloat(self.pageControl.currentPage), y: 0)
        }
    }
}
extension WelcomeView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / self.frame.size.width
        if page != CGFloat(pageControl.currentPage) {
            pageControl.currentPage = Int(page)
        }
    }
}
extension WelcomeView: WelcomePageViewDelegate {
    func confirm() {
        self.delegate?.confirm()
    }
}
