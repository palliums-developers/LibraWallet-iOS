//
//  BaseTabBarViewController.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
class BaseTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        // 修复iOS 13 tabBar切换后会变蓝色（默认tintColor的值为nil，这表示它将会运用父视图层次的颜色来进行着色。如果父视图中没有设置tintColor，那么默认系统就会使用蓝色。）
        if #available(iOS 13.0, *) {
            self.tabBar.tintColor = UIColor.init(hex: "4421AB")
            let appearance = UITabBarAppearance()
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "4421AB")]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "5C5C5C")]
            tabBar.standardAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        // 添加Child
        addAllChildViewController()
        // 设置默认位置
        self.selectedIndex = 0
        // 添加语言切换监听
        addLanguageListen()
        // 自定义TabBar样式
        customTabBar()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("BaseTabBarViewController销毁了")
    }
    private func addAllChildViewController(){
        let home = HomeViewController.init()
        
        let market = MarketViewController.init()

        let bank = BankViewController.init()
        
        let mine = MineViewController.init()
        
        addChildViewController(childViewController: home, imageName: "tabbar_wallet_normal", selectedImageName: "tabbar_wallet_highlight", title: localLanguage(keyString: "wallet_tabbar_wallet_title"))
        addChildViewController(childViewController: market, imageName: "tabbar_market_normal", selectedImageName: "tabbar_market_highlight", title: localLanguage(keyString: "wallet_tabbar_market_title"))
        addChildViewController(childViewController: bank, imageName: "tabbar_bank_normal", selectedImageName: "tabbar_bank_highlight", title: localLanguage(keyString: "wallet_tabbar_bank_title"))
        addChildViewController(childViewController: mine, imageName: "tabbar_mine_normal", selectedImageName: "tabbar_mine_highlight", title: localLanguage(keyString: "wallet_tabbar_mine_title"))
    }
    private func addChildViewController(childViewController:UIViewController, imageName:String, selectedImageName:String, title:String){
        childViewController.tabBarItem.title = title
        childViewController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        childViewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //UIColor.init(hex: "5C5C5C")
        childViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red,
                                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)], for: UIControl.State.normal)
        childViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hex: "4421AB"),
                                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)], for: UIControl.State.selected)
        
        // 设置导航控制器
        let childNaviagation = BaseNavigationViewController(rootViewController: childViewController)
        addChild(childNaviagation)
        subViewControllers.append(childViewController)
    }
    private func addLanguageListen() {
        // 添加语言变换通知
         NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    private func customTabBar() {
        // 移除顶部线条
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        // 添加阴影
        self.tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.tabBar.layer.shadowOffset = CGSize.init(width: 0, height: -3)
        self.tabBar.layer.shadowOpacity = 0.1
    }
    lazy var subViewControllers: [UIViewController] = {
        let con = [UIViewController]()
        return con
    }()
    @objc func setText() {
        for item in subViewControllers {
            if item.isKind(of: HomeViewController.classForCoder()) {
                item.tabBarItem.title = localLanguage(keyString: "wallet_tabbar_wallet_title")
            }
            if item.isKind(of: MarketViewController.classForCoder()) {
                item.tabBarItem.title = localLanguage(keyString: "wallet_tabbar_market_title")
            }
            if item.isKind(of: MineViewController.classForCoder()) {
                item.tabBarItem.title = localLanguage(keyString: "wallet_tabbar_mine_title")
            }
        }
    }
}
