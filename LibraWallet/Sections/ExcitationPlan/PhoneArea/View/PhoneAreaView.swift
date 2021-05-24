//
//  PhoneAreaView.swift
//  HKWallet
//
//  Created by palliums on 2019/8/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class PhoneAreaView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(self.tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("PhoneAreaView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(0)
            make.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = defaultBackgroundColor
        tableView.sectionIndexColor = UIColor.init(hex: "7F7F7F")
        tableView.register(PhoneAreaTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
}
