//
//  TokenMappingViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TokenMappingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 设置标题
        self.title = localLanguage(keyString: "wallet_mapping_navigationbar_title")
        // 添加导航栏按钮
        self.addRightNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.viewModel.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationWhiteMode()
        self.navigationController?.navigationBar.barStyle = .black
    }
    deinit {
        print("TokenMappingViewController销毁了")
    }
    /// 子View
    private lazy var detailView : TokenMappingView = {
        let view = TokenMappingView.init()
        return view
    }()
    /// 导航栏交易记录按钮
    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "mapping_transactions"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addMethod), for: .touchUpInside)
        return button
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    /// 接收映射钱包
    var tokens: [Token]?
    /// ViewModel
    lazy var viewModel: TokenMappingViewModel = {
        let viewModel = TokenMappingViewModel.init()
        viewModel.view = self.detailView
        return viewModel
    }()
}
//MARK: - 导航栏添加按钮
extension TokenMappingViewController {
    func addRightNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let addView = UIBarButtonItem(customView: addButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [addView, barButtonItem]
    }
    @objc func addMethod() {
        let vc = MappingTransactionsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
