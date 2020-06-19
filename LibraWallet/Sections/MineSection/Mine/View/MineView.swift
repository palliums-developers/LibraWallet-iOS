//
//  MineView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mineHeaderView)
        self.addSubview(self.tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MineView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        mineHeaderView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(208)
        }
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(mineHeaderView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }
        tableView.backgroundColor = UIColor.init(hex: "F7F7F9")//defaultBackgroundColor
        tableView.register(MineTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
    private lazy var mineHeaderView : MineHeaderView = {
        let view = MineHeaderView.init()
//        view.model = WalletData.wallet
        return view
    }()
}
