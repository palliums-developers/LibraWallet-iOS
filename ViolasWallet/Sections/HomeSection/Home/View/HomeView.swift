//
//  HomeView.swift
//  ViolasWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift

protocol HomeViewDelegate: NSObjectProtocol {
    func getFreeCoin()
    func backupMenmonic()
}
class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topBackgroundImageView)
        addSubview(headerView)
        addSubview(tableView)
//        addSubview(activeButton)
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
            make.height.equalTo((232 * ratio))
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight)
            make.left.right.equalTo(self)
            let height = 202 - navigationBarHeight + 51 + 78
            make.height.equalTo(height)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
        if getIdentityWalletState() == false {
            importOrCreateView.snp.makeConstraints { (make) in
                make.left.right.equalTo(self)
                make.top.equalTo(headerView.snp.bottom).offset(-128)
                make.bottom.equalTo(self)
            }
            importOrCreateView.corner(byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], radii: 24)
        }
        if showActiveButtonState == true {
            activeButton.snp.makeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-22).priority(250)
                make.bottom.equalTo(self.snp.bottom).offset(-179)
                make.size.equalTo(CGSize.init(width: 50, height: 55))
            }
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
    lazy var activeButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "free_coin_background"), for: .normal)
        button.setTitle(localLanguage(keyString: "Free coin"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.semibold)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor.init(hex: "7540FD"), for: UIControl.State.normal)
        // 调整位置
        button.titleEdgeInsets = UIEdgeInsets(top: 19, left: 0, bottom: -19, right: 0)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.alpha = 1
        return button
    }()
    // MARK: - 懒加载对象
    lazy var tableView: UITableView = {
        let tableView = UITableView.init()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = UIColor.white
        tableView.register(HomeTableViewCell.classForCoder(), forCellReuseIdentifier: "CellNormal")
        return tableView
    }()
    lazy var importOrCreateView: HomeWithoutWalletView = {
        let view = HomeWithoutWalletView.init()
        return view
    }()
    lazy var backupWarningView: BackupWarningAlert = {
        let view = BackupWarningAlert.init()
        view.delegate = self
        return view
    }()
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
    var showActiveButtonState: Bool? {
        didSet {
            if showActiveButtonState == true {
                self.addSubview(activeButton)
            } else if showActiveButtonState == false {
                activeButton.removeFromSuperview()
            }
            self.layoutIfNeeded()
        }
    }
    private var isButtonHiding: Bool = false
    private var isBackupWarningShow: Bool = false
    @objc func buttonClick(button: UIButton) {
        self.delegate?.getFreeCoin()
    }
    func hideActiveButtonAnimation() {
        guard showActiveButtonState == true else {
            return
        }
        guard isButtonHiding == false else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.activeButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(22)
                make.bottom.equalTo(self.snp.bottom).offset(-179)
                make.size.equalTo(CGSize.init(width: 50, height: 55))
            }
        }
        self.layoutIfNeeded()
        isButtonHiding = true
    }
    func showActiveButtonAnimation() {
        guard showActiveButtonState == true else {
            return
        }
        guard isButtonHiding == true else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.activeButton.snp.remakeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-22)
                make.bottom.equalTo(self.snp.bottom).offset(-179)
                make.size.equalTo(CGSize.init(width: 50, height: 55))
            }
        }
        self.layoutIfNeeded()
        isButtonHiding = false
    }
    func showBackupWarningAlert() {
        guard isBackupWarningShow == false else {
            return
        }
        self.addSubview(backupWarningView)
        backupWarningView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(107)
        }
        self.layoutIfNeeded()
    }
    func hideBackupWarningAlert() {
        guard isBackupWarningShow == true else {
            return
        }
        self.backupWarningView.alpha = 0
        self.backupWarningView.removeFromSuperview()
        self.layoutIfNeeded()
    }
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        super.hitTest(point, with: event);
//
//        let convertedPoint = backupWarningView.convert(point, from: tableView)
//
//        // 注意点：hitTest方法内部会调用pointInside方法，询问触摸点是否在这个控件上
//        // 根据point,找到适合响应事件的这个View
//        let hitTestView = backupWarningView.hitTest(convertedPoint, with: event)
//        if hitTestView != nil {
//            return hitTestView
//        } else {
//            return tableView
//        }
//    }
}
extension HomeView: BackupWarningAlertDelegate {
    func backupMenmonic() {
        self.delegate?.backupMenmonic()
    }
}
