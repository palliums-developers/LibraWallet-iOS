//
//  WalletConfigView.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import BiometricAuthentication
protocol WalletConfigViewDelegate: NSObjectProtocol {
    func deleteButtonClick()
}
class WalletConfigView: UIView {
    weak var delegate: WalletConfigViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
    }
    convenience init(canDelete: Bool) {
        self.init(frame: CGRect.zero)
        addSubview(tableView)
        guard canDelete == true else {
            return
        }
        addSubview(deleteButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletDetailView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            if BioMetricAuthenticator.canAuthenticate() == true {
                make.height.equalTo((60+10) * 3)
            } else {
                make.height.equalTo((60+10) * 2)
            }
        }
        guard self.subviews.contains(deleteButton) == true else {
            return
        }
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(51)
//            make.left.equalTo(self).offset(69)
//            make.right.equalTo(self.snp.right).offset(-69)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 238, height: 40))
//            make.height.equalTo(40)
       }
    }
    //MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }
        tableView.backgroundColor = UIColor.init(hex:"F7F7F9")
        tableView.register(WalletConfigTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        tableView.register(WalletConfigTableViewCell.classForCoder(), forCellReuseIdentifier: "CellSwitch")

        return tableView
    }()
    lazy var deleteButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_manager_detail_delete_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.medium)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: UIScreen.main.bounds.size.width - 136, height: 40)), at: 0)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.deleteButtonClick()
    }
}
