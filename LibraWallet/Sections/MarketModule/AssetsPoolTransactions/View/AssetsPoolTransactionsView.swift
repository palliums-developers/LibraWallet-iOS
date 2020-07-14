//
//  AssetsPoolTransactionsView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/14.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class AssetsPoolTransactionsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AssetsPoolTransactionsView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
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
        return tableView
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
    func deleteRowInTableView(indexPaths: [IndexPath]) {
        
    }
    func insertRowInTableView(indexPaths: [IndexPath]) {
        
    }
    func reloadRowInTableView(indexPaths: [IndexPath]) {
        
    }
    func dealErrorToast(error: LibraWalletError) {
        
    }
}
