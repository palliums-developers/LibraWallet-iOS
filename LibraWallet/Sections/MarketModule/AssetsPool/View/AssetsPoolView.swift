//
//  AssetsPoolView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/1.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class AssetsPoolView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        //        addSubview(headerBackground)
        addSubview(headerView)
        addSubview(tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MarketView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(404)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    private lazy var headerView : AssetsPoolViewHeaderView = {
        let header = AssetsPoolViewHeaderView.init()
        return header
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }
        tableView.backgroundColor = UIColor.clear
        tableView.register(AssetsPoolTableViewCell.classForCoder(), forCellReuseIdentifier: "NormalCell")
        tableView.register(AssetsPoolTableViewCell.classForCoder(), forCellReuseIdentifier: "FailedCell")
        return tableView
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
}
