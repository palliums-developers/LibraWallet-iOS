//
//  BaseTabBarViewController.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        // Do any additional setup after loading the view.
        addAllChildViewController()
        self.selectedIndex = 0
    }
    private func addAllChildViewController(){
        let home = HomeViewController.init()
        
        let market = HomeViewController.init()
        
        let mine = MineViewController.init()
                
        addChildViewController(childViewController: home, imageName: "tabbar_wallet_normal", selectedImageName: "tabbar_wallet_highlight", title: "钱包")
        addChildViewController(childViewController: market, imageName: "tabbar_market_normal", selectedImageName: "tabbar_market_highlight", title: "市场")
        addChildViewController(childViewController: mine, imageName: "tabbar_mine_normal", selectedImageName: "tabbar_mine_highlight", title: "我的")
        
        
    }
    private func addChildViewController(childViewController:UIViewController, imageName:String, selectedImageName:String, title:String){
        childViewController.tabBarItem.title = title
        childViewController.tabBarItem.image = UIImage(named: imageName)
        childViewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        childViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hex: "3D3949"),NSAttributedString.Key.font:UIFont.systemFont(ofSize: 11)], for: UIControl.State.normal)
        childViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hex: "4421AB"),NSAttributedString.Key.font:UIFont.systemFont(ofSize: 11)], for:UIControl.State.selected)
        // 设置导航控制器
        let childNaviagation = BaseNavigationViewController(rootViewController: childViewController)
        addChild(childNaviagation)
    }

}
