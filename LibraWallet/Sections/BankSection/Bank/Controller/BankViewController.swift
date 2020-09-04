//
//  BankViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/19.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
import MJRefresh
import JXSegmentedView

class BankViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.backgroundColor = UIColor.white
        // 添加导航栏按钮
        self.addNavigationBar()
        self.view.addSubview(detailView)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("BankViewController销毁了")
    }
    /// 网络请求、数据模型
    lazy var dataModel: BankModel = {
        let model = BankModel.init()
        return model
    }()
    /// DetailView
    lazy var detailView: BankView = {
        let view = BankView.init()
        view.segmentView.delegate = self
        view.controllers = [depositController, withdrawController]
        return view
    }()
    /// 存款市场Controller
    lazy var depositController: DepositMarketViewController = {
        let con = DepositMarketViewController()
        con.initKVO()
        con.tableViewManager.delegate = self
        con.delegate = self
        return con
    }()
    /// 贷款市场Controller
    lazy var withdrawController: LoanMarketViewController = {
        let con = LoanMarketViewController()
        con.initKVO()
        con.tableViewManager.delegate = self
        con.delegate = self
        return con
    }()
    /// 全部资产价值按钮
    lazy var totalAssetsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_bank_total_deposit_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setImage(UIImage.init(named: "eyes_open_white"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 4, imageViewSize: CGSize.init(width: 14, height: 8))
        //         button.addTarget(self, action: #selector(changeWallet), for: .touchUpInside)
        return button
     }()
    /// 交易记录按钮
    lazy var transactionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.init(named: "wallet_detail_indicator"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(checkOrder(button:)), for: .touchUpInside)
        return button
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var startRefresh: Bool = false
}
extension BankViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        print(index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        //传递didClickSelectedItemAt事件给listContainerView，必须调用！！！
        self.detailView.listContainerView.didClickSelectedItem(at: index)
    }
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        //传递scrolling事件给listContainerView，必须调用！！！
        self.detailView.listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}
//MARK: - 语言切换方法
extension BankViewController {
    /// 语言切换
    @objc func setText() {
        totalAssetsButton.setTitle(localLanguage(keyString: "wallet_bank_total_deposit_title"), for: UIControl.State.normal)
        totalAssetsButton.imagePosition(at: .right, space: 4, imageViewSize: CGSize.init(width: 14, height: 8))
    }
}
//MARK: - 导航栏添加按钮
extension BankViewController {
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: totalAssetsButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
        
        let scanView = UIBarButtonItem(customView: transactionsButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightBarButtonItem.width = 15
        // 返回按钮设置成功
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, scanView]
    }
    @objc func checkOrder(button: UIButton) {
        let dropper = Dropper.init(x: 0, y: statusBarHeight - 5, width: 110, height: 90)
        dropper.items = [localLanguage(keyString: "wallet_bank_deposit_market_title"), localLanguage(keyString: "wallet_bank_loan_market_title")]
        dropper.cornerRadius = 8
        dropper.theme = .black(UIColor.init(hex: "F1EEFB"))
        dropper.cellTextFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        dropper.cellColor = UIColor.init(hex: "333333")
        dropper.spacing = 12
        dropper.delegate = self
        dropper.show(Dropper.Alignment.center, position: .top, button: self.detailView.headerView.yesterdayBenefitButton)
    }
}
extension BankViewController: DepositMarketTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, models: [BankDepositMarketDataModel]) {
        let vc = DepositViewController.init()
        vc.itemID = models[indexPath.row].id
        vc.models = models
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension BankViewController: LoanMarketTableViewManagerDelegate {
    func loanTableViewDidSelectRowAtIndexPath(indexPath: IndexPath, models: [BankDepositMarketDataModel]) {
        let vc = LoanViewController.init()
        vc.itemID = models[indexPath.row].id
        vc.models = models
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension BankViewController: LoanMarketViewControllerDelegate, DepositMarketViewControllerDelegate {
    func refreshAccount() {
        guard self.startRefresh == false else {
            return
        }
        self.dataModel.getBankAccountInfo(address: WalletManager.shared.violasAddress ?? "")
        self.startRefresh = true
    }
}
extension BankViewController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        print(contents)
        if path.row == 0 {
            let vc = DepositOrdersViewController.init()
            vc.supprotTokens = self.depositController.tableViewManager.dataModels
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = LoanOrdersViewController.init()
            vc.supprotTokens = self.depositController.tableViewManager.dataModels
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - 网络请求
extension BankViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.view?.hideToastActivity()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.view?.hideToastActivity()
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据状态异常
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 下拉刷新请求数据为空
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .noMoreData).localizedDescription {
                    // 上拉请求更多数据为空
                    print(error.localizedDescription)
                } else {
                    self?.view?.makeToast(error.localizedDescription,
                                          position: .center)
                }
                //                self?.view?.headerView.viewState = .Normal
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "GetBankAccountInfo" {
                guard let tempData = dataDic.value(forKey: "data") as? BankModelMainDataModel else {
                    return
                }
                self?.detailView.headerView.model = tempData
                self?.startRefresh = false
            }
            self?.view?.hideToastActivity()
        })
    }
}
