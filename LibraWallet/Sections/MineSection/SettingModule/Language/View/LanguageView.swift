//
//  LanguageView.swift
//  HKWallet
//
//  Created by palliums on 2019/8/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class LanguageView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(self.tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LanguageView销毁了")
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
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = UIColor.init(hex: "F7F7F9")
        tableView.register(LanguageTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
}
