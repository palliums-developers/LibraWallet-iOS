//
//  DepositView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol DepositViewDelegate: NSObjectProtocol {
    func confirmDeposit()
}
class DepositView: UIView {
    weak var delegate: DepositViewDelegate?
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
        print("DepositView销毁了")
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
            make.bottom.equalTo(self)
            make.height.equalTo(90)
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
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = UIColor.init(hex: "F7F7F9")
        tableView.register(RepaymentTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        tableView.register(DepositTableViewHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "Header")
        return tableView
    }()
    lazy var footerBackgroundView: UIView = {
        let footer = UIView.init()
        footer.backgroundColor = UIColor.white
        return footer
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_deposit_button_title"), for: UIControl.State.normal)
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
        self.delegate?.confirmDeposit()
    }
    lazy var toastView: ToastView? = {
        let toast = ToastView.init()
        return toast
    }()
}
