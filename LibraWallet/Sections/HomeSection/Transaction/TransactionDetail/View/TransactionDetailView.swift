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
        transactionBackgroundImageView.addSubview(tableView)
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
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(200)
            make.left.equalTo(transactionBackgroundImageView).offset(24)
            make.right.equalTo(transactionBackgroundImageView.snp.right).offset(-24)
            make.bottom.equalTo(transactionBackgroundImageView.snp.bottom).offset(-30)
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
        imageView.image = UIImage.init(named: "publish_sign")
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
        tableView.backgroundColor = UIColor.init(hex: "F7F7F9")//defaultBackgroundColor
        tableView.register(LocalWalletTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
}
