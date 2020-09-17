//
//  LoanView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/26.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import AttributedTextView
protocol LoanViewDelegate: NSObjectProtocol {
    func checkLegal()
    func loanConfirm()
}
class LoanView: UIView {
    weak var delegate: LoanViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        addSubview(footerBackgroundView)
        footerBackgroundView.addSubview(confirmButton)
        footerBackgroundView.addSubview(legalButton)
        footerBackgroundView.addSubview(legalContentTextView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("LoanView销毁了")
    }
    //MARK: - 布局
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
            make.height.equalTo(113)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(footerBackgroundView).offset(39)
            make.left.equalTo(footerBackgroundView).offset(69)
            make.right.equalTo(footerBackgroundView.snp.right).offset(-69)
            make.height.equalTo(40)
        }
        legalButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(confirmButton.snp.top).offset(-10)
            make.left.equalTo(confirmButton).offset(12)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        legalContentTextView.snp.makeConstraints { (make) in
            make.top.equalTo(legalButton).offset(-3)
            make.left.equalTo(legalButton.snp.right)
            make.right.equalTo(self.snp.right)
            make.height.equalTo(30)
        }
    }
    //MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.backgroundColor = UIColor.init(hex: "F7F7F9")
        tableView.register(LoanTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        tableView.register(LoanTableViewHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "Header")
        return tableView
    }()
    lazy var footerBackgroundView: UIView = {
        let footer = UIView.init()
        footer.backgroundColor = UIColor.white
        return footer
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_loan_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        let width = UIScreen.main.bounds.width - 69 - 69
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 100
        return button
    }()
    lazy var legalButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "unselect"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    private lazy var legalContentTextView: AttributedTextView = {
        let textView = AttributedTextView.init()
        textView.textAlignment = NSTextAlignment.left
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.attributer = localLanguage(keyString: "wallet_bank_loan_legal_button_conent")
            .color(UIColor.init(hex: "999999"))
            .font(UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular))
            .match(localLanguage(keyString: "wallet_bank_loan_legal_agreement_match_contnet")).underline.makeInteract({ [weak self] _ in
                self?.delegate?.checkLegal()
            })
        return textView
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 100 {
            self.delegate?.loanConfirm()
        } else {
            if button.imageView?.image == UIImage.init(named: "unselect") {
                button.setImage(UIImage.init(named: "selected"), for: UIControl.State.normal)
            } else {
                button.setImage(UIImage.init(named: "unselect"), for: UIControl.State.normal)
            }
        }
    }
    lazy var toastView: ToastView? = {
        let toast = ToastView.init()
        return toast
    }()
}
