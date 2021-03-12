//
//  ManageCurrencyView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ManageCurrencyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(self.tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ManageCurrencyView销毁了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        tableView.backgroundColor = defaultBackgroundColor
        tableView.register(ManageCurrencyTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
    lazy var toastView: ToastView = {
        let toast = ToastView.init()
        return toast
    }()
}
