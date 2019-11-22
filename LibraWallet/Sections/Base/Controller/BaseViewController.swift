//
//  BaseViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/18.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import StatefulViewController
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置默认背景色
        self.view.backgroundColor = defaultBackgroundColor
        self.setChildControllerConfig()
        self.setNavigationBarTitleColorDefault()
//        self.navigationController?.navigationBar.barStyle = .black
    }
    func setBaseControlllerConfig() {
        self.setNavigationWithoutShadowImage()
    }
    func setChildControllerConfig() {
        // 自定义NavigationBar返回按钮
        self.addNavigationBar()
        // 添加分割条
//        self.setNavigationWithShadowImage()
        // 删除分割条
        self.setNavigationWithoutShadowImage()
        // 自定义NavigationBar返回按钮后，添加滑动返回手势
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: backButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = -5
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
    }
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    lazy var backButton: UIButton = {
        
        let backButton = UIButton(type: .custom)
        // 给按钮设置返回箭头图片
        backButton.setImage(UIImage.init(named: "navigation_back"), for: UIControl.State.normal)
        // 设置frame
        backButton.frame = CGRect(x: 200, y: 13, width: 22, height: 44)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        return backButton
    }()
    func setNavigationWithShadowImage() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage().imageWithColor(color: UIColor.white), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage().imageWithColor(color: UIColor.init(hex: "F3F6FB"))
    }
    func setNavigationWithoutShadowImage() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    func setNavigationBarTitleColorDefault() {
        self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor:UIColor.init(hex: "3C3848"),
                                                                      NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)]
    }
    func setNavigationBarTitleColorWhite() {
        self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor:UIColor.white,
                                                                  NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)]
    }
    func navigationWhiteMode() {
        backButton.setImage(UIImage.init(named: "navigation_back_white"), for: UIControl.State.normal)
        setNavigationBarTitleColorWhite()
    }
    func hasContent() -> Bool {
        return true
    }
    func showAlert(view: UIView, content: String) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        view.hideToastActivity()
        view.makeToast(content, position: .center)
    }
}
extension BaseViewController: UIGestureRecognizerDelegate {
    
}
extension BaseViewController: StatefulViewController {
    func setEmptyView() {
        //空数据
        emptyView = EmptyDataPlaceholderView.init()
        //        emptyView = EmptyDataPlaceholderView.init(frame: CGRect.init(x: 0, y: navigationBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - navigationBarHeight))
        
    }
}
