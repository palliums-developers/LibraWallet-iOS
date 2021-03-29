//
//  RepaymentView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/25.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol RepaymentViewDelegate: NSObjectProtocol {
    func confirmRepayment()
}
class RepaymentView: UIView {
    weak var delegate: RepaymentViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(tableView)
        addSubview(footerBackgroundView)
        footerBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("RepaymentView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.bottom.equalTo(footerBackgroundView.snp.top)
        }
        footerBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(87)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(footerBackgroundView).offset(20)
            make.left.equalTo(footerBackgroundView).offset(69)
            make.right.equalTo(footerBackgroundView.snp.right).offset(-69)
            make.height.equalTo(40)
        }
    }
    // MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = UIColor.init(hex: "F7F7F9")
        tableView.isScrollEnabled = false
        tableView.register(RepaymentTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        tableView.register(RepaymentTableViewHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "Header")
        return tableView
    }()
    lazy var footerBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        // 定义阴影颜色
        view.layer.shadowColor = UIColor.init(hex: "333333").cgColor
        // 阴影的模糊半径
        view.layer.shadowRadius = 3
        // 阴影的偏移量
        view.layer.shadowOffset = CGSize(width: 0, height: -5)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        view.layer.shadowOpacity = 0.04
        return view
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_repayment_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        let width = UIScreen.main.bounds.width - 69 - 69
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.confirmRepayment()
    }
    lazy var toastView: ToastView = {
        let toast = ToastView.init()
        return toast
    }()
}
