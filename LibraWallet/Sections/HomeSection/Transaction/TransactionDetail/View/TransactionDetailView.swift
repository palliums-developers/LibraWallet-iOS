//
//  TransactionDetailView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/6/5.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TransactionDetailView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(topBackgroundImageView)
        addSubview(transactionBackgroundImageView)
        transactionBackgroundImageView.addSubview(transactionStateImageView)
        transactionBackgroundImageView.addSubview(transactionStateLabel)
        transactionBackgroundImageView.addSubview(transactionDateLabel)
        transactionBackgroundImageView.addSubview(spaceLabel)
        transactionBackgroundImageView.addSubview(tableView)
        addSubview(bottomBackgroundImageView)
        addSubview(checkOnlineButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TransactionDetailView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo((153 * ratio))
        }
        transactionBackgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.equalTo(38)
            make.right.equalTo(self.snp.right).offset(-38)
            make.height.equalTo(404)
        }
        transactionStateImageView.snp.makeConstraints { (make) in
            make.top.equalTo(transactionBackgroundImageView).offset(40)
            make.size.equalTo(CGSize.init(width: 38, height: 38))
            make.centerX.equalTo(transactionBackgroundImageView)
        }
        transactionStateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(transactionStateImageView.snp.bottom).offset(14)
            make.centerX.equalTo(transactionBackgroundImageView)
            make.left.equalTo(transactionBackgroundImageView).offset(10)
            make.right.equalTo(transactionBackgroundImageView.snp.right).offset(-10)
        }
        transactionDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(transactionStateLabel.snp.bottom).offset(18)
            make.centerX.equalTo(transactionBackgroundImageView)
            make.left.equalTo(transactionBackgroundImageView).offset(10)
            make.right.equalTo(transactionBackgroundImageView.snp.right).offset(-10)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(transactionBackgroundImageView).offset(180)
            make.left.equalTo(transactionBackgroundImageView).offset(24)
            make.right.equalTo(transactionBackgroundImageView.snp.right).offset(-24)
            make.height.equalTo(1)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(spaceLabel.snp.bottom).offset(20)
            make.left.right.equalTo(transactionBackgroundImageView)
            make.bottom.equalTo(transactionBackgroundImageView.snp.bottom)
        }
        bottomBackgroundImageView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self)
        }
        checkOnlineButton.snp.makeConstraints { (make) in
            make.left.right.centerX.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    private lazy var topBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "transaction_detail_navigationbar_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var transactionBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "transaction_detail_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var transactionStateImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "wallet_icon_default")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var transactionStateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "00D1AF")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var transactionDateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "2020-06-05 17:52:04"
        return label
    }()
    lazy var borderLayer: CAShapeLayer = {
        let border = CAShapeLayer.init()
        //虚线的颜色
        border.strokeColor = UIColor.init(hex: "3C3848").alpha(0.5).cgColor
        //填充的颜色
        border.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: mainWidth - 64, height: 36), cornerRadius: 2)
        //设置路径
        border.path = path.cgPath
        border.frame = CGRect.init(x: 0, y: 0, width: mainWidth - 64, height: 36)
        //虚线的宽度
        border.lineWidth = 1
        //虚线的间隔
        border.lineDashPattern = [3,1.5]
        return border
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
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
        tableView.backgroundColor = UIColor.white//defaultBackgroundColor
        tableView.isScrollEnabled = false
        tableView.register(TransactionDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "AmountCell")
        tableView.register(TransactionDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "AddressCell")
        tableView.register(TransactionDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "NormalCell")
        return tableView
    }()
    private lazy var bottomBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "transaction_detail_bottom_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var checkOnlineButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_transaction_detail_explorer_check_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
//        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    var violasTransaction: ViolasDataModel? {
        didSet {
            guard let model = violasTransaction else {
                return
            }
            switch model.type {
            case 0:
                print("123")
            case 1:
                // 平台币转账
                if model.transaction_type == 0 {
                    // 转账
                    transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_transfer_success_title")
                } else {
                    transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_receive_success_title")
                }
                transactionStateImageView.image = UIImage.init(named: "transaction_detail_finish")
            case 2:
                // 稳定币激活
                transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_publish_success_title")
                transactionStateImageView.image = UIImage.init(named: "transaction_detail_finish")
            case 3:
                // 铸币授权
                transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_mint_authority_success_title")
                transactionStateImageView.image = UIImage.init(named: "transaction_detail_finish")
            case 4:
                // 钱包激活
                transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_active_success_title")
                transactionStateImageView.image = UIImage.init(named: "transaction_detail_finish")
            case 5:
                // 交易中
                transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_uncheck_title")
                transactionStateLabel.textColor = UIColor.init(hex: "FAA030")
                transactionStateImageView.image = UIImage.init(named: "transaction_detail_uncheck")
            case 6:
                transactionStateLabel.text = localLanguage(keyString: "wallet_transaction_detail_transaction_failed_title")
                transactionStateLabel.textColor = UIColor.init(hex: "F55753")
                transactionStateImageView.image = UIImage.init(named: "transaction_detail_failed")
            default:
                print("123")
            }
        }
    }
}

