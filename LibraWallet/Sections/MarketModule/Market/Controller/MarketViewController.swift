//
//  MarketViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import StatefulViewController
import Localize_Swift

class MarketViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.addNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        self.addFirstSubView()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        exchangeButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(titleButtonView)
            make.width.equalTo(assetsPoolButton)
        }
        assetsPoolButton.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(titleButtonView)
            make.left.equalTo(exchangeButton.snp.right)
        }
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("MarketViewController销毁了")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    func addNavigationBar() {
        titleButtonView.addSubview(exchangeButton)
        titleButtonView.addSubview(assetsPoolButton)
        self.navigationItem.titleView = self.titleButtonView
        
        let backView = UIBarButtonItem(customView: marketMineButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
        
        let mineView = UIBarButtonItem(customView: marketTransactionButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, mineView]
    }
    func addFirstSubView() {
        self.detailView.scrollView.addSubview(exchangeCon.view)
        exchangeCon.view.snp.makeConstraints { (make) in
            make.left.equalTo(self.detailView.scrollView)
            make.top.bottom.equalTo(self.detailView)
            make.width.equalTo(mainWidth)
        }
        self.detailView.scrollView.addSubview(assetsPoolCon.view)
        assetsPoolCon.view.snp.makeConstraints { (make) in
            make.left.equalTo(self.detailView.scrollView).offset(mainWidth)
            make.top.bottom.equalTo(self.detailView)
            make.width.equalTo(mainWidth)
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: MarketModel = {
        let model = MarketModel.init()
        return model
    }()
    /// 子View
    private lazy var detailView : MarketView = {
        let view = MarketView.init()
        return view
    }()
    private lazy var titleButtonView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    lazy var exchangeButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_exchange_navigation_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(changeSubViewButtonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.cornerRadius = 15
        button.tag = 10
        return button
    }()
    lazy var assetsPoolButton: UIButton = {
        let button = UIButton(type: .custom)
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_market_assets_pool_navigation_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(changeSubViewButtonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.cornerRadius = 15
        button.tag = 20
        return button
    }()
    /// 交易所个人中心
    lazy var marketMineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "market_mine"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(marketMineButtonClick), for: .touchUpInside)
        return button
    }()
    lazy var marketTransactionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "market_transaction"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(marketTransactionButtonClick), for: .touchUpInside)
        return button
    }()
    lazy var exchangeCon: ExchangeViewController = {
        let vc = ExchangeViewController()
        return vc
    }()
    lazy var assetsPoolCon: AssetsPoolViewController = {
        let vc = AssetsPoolViewController()
        vc.detailView.profitView.delegate = self
        return vc
    }()
    @objc func changeSubViewButtonClick(button: UIButton) {
        if button.tag == 10 {
            exchangeButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            exchangeButton.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
            assetsPoolButton.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
            assetsPoolButton.layer.backgroundColor = UIColor.white.cgColor
            detailView.scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        } else {
            exchangeButton.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
            exchangeButton.layer.backgroundColor = UIColor.white.cgColor
            assetsPoolButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            assetsPoolButton.layer.backgroundColor = UIColor.init(hex: "7038FD").cgColor
            detailView.scrollView.setContentOffset(CGPoint.init(x: mainWidth, y: 0), animated: true)

        }
    }
    @objc func marketMineButtonClick(button: UIButton) {
        let vc = MarketMineViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func marketTransactionButtonClick(button: UIButton) {
        if exchangeButton.layer.backgroundColor == UIColor.init(hex: "7038FD").cgColor {
            let vc = ExchangeTransactionsViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = AssetsPoolTransactionsViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    /// 语言切换
    @objc func setText() {
        exchangeButton.setTitle(localLanguage(keyString: "wallet_market_exchange_navigation_title"), for: UIControl.State.normal)
        assetsPoolButton.setTitle(localLanguage(keyString: "wallet_market_assets_pool_navigation_title"), for: UIControl.State.normal)
    }
}
extension MarketViewController : AssetsPoolProfitHeaderViewDelegate {
    func showYieldFarmingRules() {
        let vc = YieldFarmingRulesWebViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
