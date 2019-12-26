//
//  VTokenMainView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class VTokenMainView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(topBackgroundImageView)
        addSubview(headerView)
        addSubview(tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("VTokenMainView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
//        walletTitleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(18)
//            make.left.equalTo(20)
//        }
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(navigationBarHeight)
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(topBackgroundImageView.snp.bottom)
            make.left.right.equalTo(self)
            make.height.equalTo(248)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var walletTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "2B2F43")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 30), weight: .medium)
        label.text = localLanguage(keyString: "wallet_home_title")
        return label
    }()
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_top_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var headerView: VTokenMainHeaderView = {
        let view = VTokenMainHeaderView.init()
        return view
    }()
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
        tableView.register(WalletTransactionsTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
    //
    @objc func buttonClick(button: UIButton) {
//
    }
    var clickCount: Int = 0
    var model: LibraWalletManager? {
        didSet {
//            headerView.walletModel = model
        }
    }
    @objc func setText(){
        walletTitleLabel.text = localLanguage(keyString: "wallet_home_title")
//        walletTotalAmountTitleLabel.text = localLanguage(keyString: "wallet_home_total_amount_title")
//        receiveButtonTitleLabel.text = localLanguage(keyString: "wallet_home_receive_button_title")
//        sendButtonTitleLabel.text = localLanguage(keyString: "wallet_home_send_button_title")
    }
}
