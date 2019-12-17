//
//  OrderDetailView.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class OrderDetailView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerView)
        addSubview(tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("OrderDetailView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(230)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    lazy var headerView: OrderDetailHeaderView = {
        let view = OrderDetailHeaderView.init()
        return view
    }()
    //MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = UIColor.white
        tableView.register(OrderDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
//        tableView.register(OrderDetailHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "Header")
        return tableView
    }()
}
