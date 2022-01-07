//
//  DepositListView.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2020/8/21.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

protocol DepositListViewDelegate: NSObjectProtocol {
    func filterOrdersWithCurrency(button: UIButton)
    func filterOrdersWithStatus(button: UIButton)
}
class DepositListView: UIView {
    weak var delegate: DepositListViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 背景色（space间隔）
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(orderTokenSelectButton)
        addSubview(orderStateButton)
        addSubview(tableView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("DepositListView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        orderTokenSelectButton.snp.makeConstraints { (make) in
            make.top.left.equalTo(self)
            make.width.equalTo(orderStateButton)
            make.height.equalTo(orderStateButton)
        }
        orderStateButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(self)
            make.left.equalTo(orderTokenSelectButton.snp.right)
            make.height.equalTo(24)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(orderTokenSelectButton.snp.bottom).offset(5)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    // MARK: - 懒加载对象
    lazy var orderTokenSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_deposit_list_order_token_select_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "5C5C5C"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setImage(UIImage.init(named: "bank_deposit_list_select"), for: UIControl.State.normal)
        button.imagePosition(at: .right, space: 5, imageViewSize: CGSize.init(width: 10, height: 10))
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.white
        button.tag = 10
        return button
    }()
    lazy var orderStateButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_deposit_list_order_status_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "5C5C5C"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setImage(UIImage.init(named: "bank_deposit_list_select"), for: UIControl.State.normal)
        button.imagePosition(at: .right, space: 5, imageViewSize: CGSize.init(width: 10, height: 10))
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.white
        button.tag = 20
        return button
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = UIColor.white
        tableView.register(DepositListTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
//    var toastView: ToastView? {
//        let toast = ToastView.init()
//        return toast
//    }
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.filterOrdersWithCurrency(button: button)
        } else {
            self.delegate?.filterOrdersWithStatus(button: button)
        }
    }
}
