//
//  AddressManagerViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
class AddressManagerViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_address_navigation_title")
        // 加载子View
        self.view.addSubview(self.viewModel.detailView)
        // 添加NavigationRightBar
        self.addNavigationRightBar()
        //设置空数据页面
//        setEmptyView()
        // 初始化KVO
        self.viewModel.initKVO()
        //设置默认页面（无数据、无网络）
        setPlaceholderView()
        //网络请求
        requestData()
    }
    func addNavigationRightBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: addAddressButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 5
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [barButtonItem, backView]
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    
    lazy var addAddressButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "add"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(rechargeHistory), for: .touchUpInside)
        return button
    }()
  
    @objc func rechargeHistory() {
        let vc = AddAddressViewController()
//        vc.actionClosure = { [weak self](action, model) in
//            self?.startLoading ()
//            if let oldData = self?.tableViewManager.dataModel, oldData.isEmpty == false {
//                let tempArray = NSMutableArray.init(array: oldData)
//                tempArray.add(model)
//                self?.tableViewManager.dataModel = tempArray as? [AddressManagerModelAddress]
//                self?.detailView.tableView.beginUpdates()
//                self?.detailView.tableView.insertRows(at: [IndexPath.init(row: oldData.count, section: 0)], with: UITableView.RowAnimation.bottom)
//                self?.detailView.tableView.endUpdates()
//            } else {
//                self?.tableViewManager.dataModel = [model]
//                self?.detailView.tableView.reloadData()
//            }
//            self?.endLoading()
//        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - 默认页面
    func setPlaceholderView() {
        if let empty = emptyView as? EmptyDataPlaceholderView {
            empty.emptyImageName = "withdraw_address_list_empty_icon"
            empty.tipString = localLanguage(keyString: "wallet_withdraw_address_list_empty_view_content")
        }
    }
    //MARK: - 网络请求
    func requestData() {
        if (lastState == .Loading) {return}
        startLoading ()
        self.viewModel.detailView.makeToastActivity(.center)
        viewModel.dataModel.getWithdrawAddressHistory(type: "", requestStatus: 0)
    }
    override func hasContent() -> Bool {
        if let addresses = self.viewModel.tableViewManager.dataModel, addresses.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    typealias nextActionClosure = (String) -> Void
    var actionClosure: nextActionClosure?
    deinit {
        print("AddressManagerViewController销毁了")
    }
    lazy var viewModel: AddressManagerViewModel = {
        let viewModel = AddressManagerViewModel.init()
        viewModel.tableViewManager.delegate = self
        return viewModel
    }()
}
extension AddressManagerViewController: AddressManagerTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, address: String) {
        if let action = self.actionClosure {
            action(address)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
