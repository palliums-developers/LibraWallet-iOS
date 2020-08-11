//
//  HomeView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class HomeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topBackgroundImageView)
        addSubview(headerView)
        addSubview(tableView)
        if getIdentityWalletState() == false {
            addSubview(importOrCreateView)
        }
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteWallet), name: NSNotification.Name("PalliumsWalletDelete"), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PalliumsWalletDelete"), object: nil)
        print("HomeView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        topBackgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo((196 * ratio))
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.right.equalTo(self)
//            make.height.equalTo(356)
            let height = 163 - navigationBarHeight + 63
            make.height.equalTo(height)
        }
//        topBackgroundImageView.snp.makeConstraints { (make) in
//            make.top.left.right.equalTo(self)
//            make.height.equalTo((232 * ratio))
//        }
//        headerView.snp.makeConstraints { (make) in
//            make.top.equalTo(self).offset(navigationBarHeight)
//            make.left.right.equalTo(self)
//            let height = 202 - navigationBarHeight + 51
//            make.height.equalTo(height)
//        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
        if getIdentityWalletState() == false {
            importOrCreateView.snp.makeConstraints { (make) in
                make.left.right.equalTo(self)
                make.top.equalTo(headerView.snp.bottom).offset(-64)
                make.bottom.equalTo(self)
            }
            importOrCreateView.corner(byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], radii: 24)
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
    lazy var headerView: HomeHeaderView = {
        let view = HomeHeaderView.init()
        return view
    }()
    //MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.backgroundColor = UIColor.white
        tableView.register(HomeTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
//        tableView.register(HomeTableViewHeader.classForCoder(), forHeaderFooterViewReuseIdentifier: "Header")
        return tableView
    }()
    lazy var importOrCreateView: HomeWithoutWalletView = {
        let view = HomeWithoutWalletView.init()
        return view
    }()
    var model: Token?
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
    @objc func setText(){
        walletTitleLabel.text = localLanguage(keyString: "wallet_home_title")
    }
    @objc func deleteWallet() {
        addSubview(importOrCreateView)
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
}
extension UIView {

    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
