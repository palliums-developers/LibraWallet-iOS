//
//  SettingView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class SettingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topBackgroundImageView)
        
        self.addSubview(self.tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TransactionsView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(202)
        }
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
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
        tableView.backgroundColor = defaultBackgroundColor
        return tableView
    }()
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "navigation_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
}
