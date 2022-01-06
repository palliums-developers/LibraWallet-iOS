//
//  AddWalletViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Toast
class AddWalletViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_create_choose_type_create_button_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    deinit {
        print("AddWalletViewController销毁了")
    }
    override func back() {
        self.dismiss(animated: true, completion: nil)
    }
    /// 子View
    private lazy var detailView : AddWalletView = {
        let view = AddWalletView.init()
        view.delegate = self
        return view
    }()
    /// 网络请求、数据模型
    lazy var dataModel: AddWalletModel = {
        let model = AddWalletModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var successCreateClosure: (()->Void)?
}
extension AddWalletViewController: AddWalletViewDelegate {
    func confirmAddWallet(password: String) {
        self.detailView.toastView.show(tag: 99)
        self.dataModel.createWallet(password: password)
    }
    func openPrivacyPolicy() {
        let vc = PrivateLegalViewController()
        vc.needDismissViewController = true
        let navi = UINavigationController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    func openServiceAgreement() {
        let vc = ServiceLegalViewController()
        vc.needDismissViewController = true
        let navi = UINavigationController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}
//MARK: - 网络请求数据处理中心
extension AddWalletViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
                self?.detailView.toastView.hide(tag: 99)
//                self?.endLoading()
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionExpired).localizedDescription {
                    // 版本太久
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                    // 解析失败
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                    print(error.localizedDescription)
                    // 数据为空
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据返回状态异常
                }
                self?.detailView.hideToastActivity()
                self?.detailView.toastView.hide(tag: 99)
                self?.detailView.makeToast(localLanguage(keyString: "wallet_create_wallet_failed_title"))
                return
            }
            self?.detailView.toastView.hide(tag: 99)
            if type == "CreateWallet" {
                // 加载本地默认钱包
                if let tempData = dataDic.value(forKey: "data") as? [String] {
                    self?.view.makeToast(localLanguage(keyString: "wallet_create_wallet_success_title"), duration: 0.5, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                        do {
                            try WalletManager.getDefaultWallet()
                            if let success = self?.successCreateClosure {
                                success()
                            }
                            DispatchQueue.main.async(execute: {
                                let vc = BackupWarningViewController()
                                vc.FirstInApp = true
                                vc.tempWallet = tempData
                                self?.navigationController?.pushViewController(vc, animated: true)
                            })
                        } catch {
                            self?.detailView.makeToast(localLanguage(keyString: "wallet_create_wallet_failed_title"))
                        }
                    })
                }
            }
        })
    }
}
