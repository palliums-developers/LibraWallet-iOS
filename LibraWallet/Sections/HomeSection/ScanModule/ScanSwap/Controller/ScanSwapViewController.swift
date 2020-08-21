//
//  ScanSwapViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/6.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast_Swift

class ScanSwapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(detailView)
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.bottom.equalTo(self.view)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if needReject == true {
            if let rejectC = self.reject {
                rejectC()
            }
        }
    }
    deinit {
        print("ScanSwapViewController销毁了")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    private lazy var detailView : ScanSwapView = {
        let view = ScanSwapView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ScanSwapModel = {
        let model = ScanSwapModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var model: WCRawTransaction? {
        didSet {
            self.detailView.model = model
        }
    }
    var reject: (() -> Void)?
    var confirm: ((String) -> Void)?
    var needReject: Bool? = true
}
extension ScanSwapViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
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
                self?.detailView.toastView?.hide(tag: 99)
                self?.detailView.hideToastActivity()
                self?.detailView.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "SendViolasTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                var content = localLanguage(keyString: "wallet_market_exchange_submit_exchange_successful")
                if self?.model?.payload?.code == "a11ceb0b010006010002030207040902050b0d071817082f10000000010001020101000205060c030303030002090009010845786368616e67650d6164645f6c6971756964697479000000000000000000000000000000010201010001070b000a010a020a030a04380002" {
                    // 添加流动性
                    content = localLanguage(keyString: "wallet_assets_pool_add_liquidity_successful")
                } else if self?.model?.payload?.code == "a11ceb0b010006010002030207040902050b0c07171a083110000000010001020101000204060c0303030002090009010845786368616e67651072656d6f76655f6c6971756964697479000000000000000000000000000000010201010001060b000a010a020a03380002" {
                    // 移除流动性
                    content = localLanguage(keyString: "wallet_assets_pool_remove_liquidity_successful")

                } else {
                    // 交换
                }
                self?.view.makeToast(content, duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    self?.needReject = false
                    if let confirmAction = self?.confirm {
                        confirmAction("success")
                    }
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
}

extension ScanSwapViewController: ScanSendTransactionViewDelegate {
    func cancelLogin() {
        self.dismiss(animated: true, completion: {
            if let rejectC = self.reject {
                rejectC()
            }
        })
        self.needReject = false
    }
    func confirmLogin(password: String) {
        NSLog("Password:\(password)")
        if let raw = self.model {
            WalletManager.unlockWallet(controller: self, successful: { [weak self] (mnemonic) in
                self?.detailView.toastView?.show(tag: 99)
                if raw.payload?.code == "a11ceb0b010006010002030207040902050b0d071817082f10000000010001020101000205060c030303030002090009010845786368616e67650d6164645f6c6971756964697479000000000000000000000000000000010201010001070b000a010a020a030a04380002" {
                    // 添加流动性
                    self?.dataModel.sendAddLiquidityViolasTransaction(model: raw, mnemonic: mnemonic, feeModule: "LBR")
                } else if raw.payload?.code == "a11ceb0b010006010002030207040902050b0c07171a083110000000010001020101000204060c0303030002090009010845786368616e67651072656d6f76655f6c6971756964697479000000000000000000000000000000010201010001060b000a010a020a03380002" {
                    // 移除流动性
                    self?.dataModel.sendRemoveLiquidityViolasTransaction(model: raw, mnemonic: mnemonic, feeModule: "LBR")
                } else {
                    // 交换
                    self?.dataModel.sendSwapViolasTransaction(model: raw, mnemonic: mnemonic, module: "LBR")
                }
//                self?.dataModel.sendViolasTransaction(model: raw, mnemonic: mnemonic, module: "LBR")
            }) { [weak self] (error) in
                guard error != "Cancel" else {
                    self?.detailView.toastView?.hide(tag: 99)
                    return
                }
                self?.detailView.makeToast(error,
                                           position: .center)
            }
            
        } else {
            #warning("报错待处理")
        }
        self.needReject = false
    }
}
