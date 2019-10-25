//
//  AboutUsView.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AboutUsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topBackgroundImageView)
        
        self.addSubview(self.tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AboutUsView销毁了")
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
        tableView.backgroundColor = UIColor.white
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        return tableView
    }()
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "navigation_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
}
