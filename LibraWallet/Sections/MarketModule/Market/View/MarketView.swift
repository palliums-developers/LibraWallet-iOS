//
//  MarketView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class MarketView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(headerBackground)
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
        headerBackground.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(196)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.right.bottom.equalTo(self)
        }
    }
    func changeHeaderViewDefault(hideLeftModel: Bool) {
        guard let headerView = tableView.headerView(forSection: 0) as? MarketExchangeHeaderView else {
            return
        }
        if hideLeftModel == true {
            headerView.leftTokenModel = nil
        }
        headerView.rightTokenModel = nil
        headerView.exchangeRateLabel.text = "---"
        headerView.leftAmountTextField.text = ""
        headerView.rightAmountTextField.text = ""
    }
    //MARK: - 懒加载对象
    private lazy var headerBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_top_background")
        return imageView
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }
        tableView.backgroundColor = UIColor.clear
        tableView.register(MarketExchangeHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "MainHeader")
        tableView.register(MarketMyOrderHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "MineHeader")
        tableView.register(MarketOthersOrderHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "OthersHeader")
        tableView.register(MarketMyOrderTableViewCell.classForCoder(), forCellReuseIdentifier: "MineCell")
        tableView.register(MarketOthersOrderTableViewCell.classForCoder(), forCellReuseIdentifier: "OtherCell")
        let header = tableView
        return tableView
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
}
