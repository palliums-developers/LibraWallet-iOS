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
        // 设置标题
        self.title = localLanguage(keyString: "wallet_mapping_navigationbar_title")
        // 添加导航栏按钮
        self.addRightNavigationBar()
        // 加载子View
        self.view.addSubview(detailView)
        // 初始化KVO
        self.initKVO()
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
    /// 子View
    private lazy var detailView : TokenMappingView = {
        let view = TokenMappingView.init()
        view.headerView.delegate = self
        return view
    }()
    /// 网络请求、数据模型
    lazy var dataModel: TokenMappingModel = {
        let model = TokenMappingModel.init()
        return model
    }()
    /// 映射钱包
    var wallet: Token? {
        didSet {
            self.detailView.headerView.walletType = wallet?.tokenType
        }
    }
    /// 导航栏交易记录按钮
    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        // 给按钮设置返回箭头图片
        button.setTitle(localLanguage(keyString: "wallet_mapping_transactions_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        // 设置frame
        button.frame = CGRect(x: 200, y: 13, width: 22, height: 44)
        button.addTarget(self, action: #selector(addMethod), for: .touchUpInside)
        return button
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    /// 接收映射钱包
    var receiveWallet: Token?
    typealias checkPublishClosure = (Bool) -> Void
    var actionClosure: checkPublishClosure?
    typealias publishFinishClosure = () -> Void
    var finishClosure: publishFinishClosure?
    
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
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - 网络请求数据处理中心
extension TokenMappingViewController {
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
                    if type == "MappingTokenList" {
                        self?.showMappingDataEmptyFunctionAlert()
                        return
                    }
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataCodeInvalid).localizedDescription {
                    print(error.localizedDescription)
                    // 数据返回状态异常
                } else {
                    if type == "MappingInfo" {
                        self?.showMappingFunctionAlert()
                        return
                    }
                }
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "MappingInfo" {
                self?.detailView.toastView?.hide(tag: 99)
                if let tempData = dataDic.value(forKey: "data") as? TokenMappingDataModel {
                    self?.detailView.headerView.model = tempData
                }
            } else if type == "SendBTCTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendLibraTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendVBTCTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendVLibraTransaction" {
                self?.detailView.toastView?.hide(tag: 99)
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "GetWalletEnableCoin" {
                if let tempData = dataDic.value(forKey: "data") as? Bool {
                    print(tempData)
                    if let action = self?.actionClosure {
                        action(tempData)
                    }
                }
            } else if type == "SendPublishTransaction" {
                if let action = self?.finishClosure {
                    action()
                }
            } else if type == "MappingTokenList" {
                if let tempData = dataDic.value(forKey: "data") as? [TokenMappingListDataModel] {
                    print(tempData)
                    self?.detailView.toastView?.hide(tag: 99)
                    let alert = MappingTokenListAlert.init(data: tempData) { (model) in
                        print(model)
                        self?.detailView.headerView.reverseModel = model
                    }
                    alert.show(tag: 99)
                    alert.showAnimation()
                }
            }
        })
        if wallet?.tokenType == .BTC || wallet?.tokenType == .Libra {
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.getMappingInfo(walletType: (wallet?.tokenType)!)
        } else {
//            // 获取当前钱包已映射稳定币列表
//            self.dataModel.getMappingTokenList(walletAddress: "b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89")
        }
    }
    private func showMappingFunctionAlert() {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_mapping_info_alert_title"), message: LibraWalletError.WalletMapping(reason: .mappingFounctionInvalid).localizedDescription, preferredStyle: .alert)
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_mapping_info_alert_confirm_button_title"), style: .default){ [weak self] clickHandler in
            self?.detailView.toastView?.hide(tag: 99)
            self?.navigationController?.popViewController(animated: true)
        })
        self.present(alertContr, animated: true, completion: nil)
    }
    private func showMappingDataEmptyFunctionAlert() {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_mapping_info_alert_title"), message: LibraWalletError.WalletMapping(reason: .mappingCoinDataEmpty).localizedDescription, preferredStyle: .alert)
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_mapping_info_alert_confirm_button_title"), style: .default){ [weak self] clickHandler in
            self?.detailView.toastView?.hide(tag: 99)
            self?.navigationController?.popViewController(animated: true)
        })
        self.present(alertContr, animated: true, completion: nil)
    }
}
//MARK: - 映射子View Header代理方法
extension TokenMappingViewController: TokenMappingHeaderViewDelegate {
    func showMappingTokenList() {
        self.detailView.toastView?.show(tag: 99)
        // 获取当前钱包已映射稳定币列表
        self.dataModel.getMappingTokenList(walletAddress: self.wallet?.tokenAddress ?? "")
    }
    func chooseAddress() {
//        let vc = LocalWalletViewController()
//        vc.actionClosure = { (action, wallet) in
//            self.detailView.headerView.exchangeToAddressTextField.text = wallet.tokenAddress
//            self.receiveWallet = wallet
//        }
//        if self.wallet?.tokenType == .BTC || self.wallet?.tokenType == .Libra {
//            vc.walletType = .Violas
//        } else {
//            if self.detailView.headerView.rightCoinButton.titleLabel?.text?.lowercased() == "btc" {
//                vc.walletType = .BTC
//            } else {
//                vc.walletType = .Libra
//            }
//        }
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        
        if wallet?.tokenType == .Libra || wallet?.tokenType == .BTC {
            self.detailView.toastView?.show(tag: 99)
            self.dataModel.getWalletEnableToken(address: address, contract: ViolasMainContract)
            self.actionClosure = { (result) in
                if result == false {
                    // 接收映射钱包未注册映射币
                    self.showUnpublishAlert()
                } else {
                    // 接收钱包已注册映射币
                    self.showMappingWalletPasswordAlert(amount: amount, address: address, fee: fee)
                }
            }
            self.finishClosure = {
                // 接收映射钱包注册成功映射币
//                let model = ViolasTokenModel.init(name: self.detailView.headerView.model?.name ?? "",
//                                                  description: "",
//                                                  address: self.detailView.headerView.model?.module ?? "",
//                                                  icon: "",
//                                                  enable: true,
//                                                  balance: 0,
//                                                  registerState: true)
//                _ = DataBaseManager.DBManager.insertViolasToken(tokenID: self.receiveWallet?.tokenID ?? 0, model: model)

//                self.showMappingWalletPasswordAlert(amount: amount, address: address, fee: fee)
            }
        } else {
//            if self.detailView.headerView.rightCoinButton.titleLabel?.text?.lowercased() == "btc" {
//                // btc
//                self.showMappingWalletPasswordAlert(amount: amount, address: address, fee: fee)
//            } else if self.detailView.headerView.rightCoinButton.titleLabel?.text?.lowercased() == "libra" {
//                // libra
//                self.showMappingWalletPasswordAlert(amount: amount, address: address, fee: fee)
//            } else {
//                //异常
//            }
            self.showMappingWalletPasswordAlert(amount: amount, address: address, fee: fee)
        }
    }
    func chooseMapping(amount: Double, address: String, fee: Double, mnemonic: [String]) {
        switch self.wallet?.tokenType {
        case .BTC:
            let wallet = try! BTCManager().getWallet(mnemonic: mnemonic)
            self.dataModel.makeTransaction(wallet: wallet,
                                            amount: amount,
                                            fee: fee,
                                            toAddress: "2N2YasTUdLbXsafHHmyoKUYcRRicRPgUyNB",
                                            mappingReceiveAddress: "e92e6c91e33f0ec5fc70425c99c5df5cfa279f2615270daed6061313a48360f7",
                                            mappingContract: "00000000000000000000000000000000e1be1ab8360a35a0259f1c93e3eac736")
        case .Libra:
            print("Libra")
//            self.dataModel.transfer(address: address, amount: amount, mnemonic: mnemonic)
            self.dataModel.sendLibraTransaction(sendAddress: self.wallet?.tokenAddress ?? "",
                                                receiveAddress: self.receiveWallet?.tokenAuthenticationKey ?? "",
                                                amount: amount,
                                                fee: 0,
                                                mnemonic: mnemonic)
        case .Violas:
            print("Violas")
            self.detailView.toastView?.show(tag: 99)
            if self.detailView.headerView.rightCoinButton.titleLabel?.text?.lowercased() == "btc" {
                // btc
                self.dataModel.sendVBTCTransaction(sendAddress: self.wallet?.tokenAddress ?? "",
                                                   receiveAddress: address,
                                                   amount: amount,
                                                   fee: fee,
                                                   mnemonic: mnemonic,
                                                   contact: self.detailView.headerView.reverseModel?.module ?? "",
                                                   module: self.wallet?.tokenModule ?? "")
            } else if self.detailView.headerView.rightCoinButton.titleLabel?.text?.lowercased() == "libra" {
                // libra
                self.dataModel.sendVLibraTransaction(sendAddress: self.wallet?.tokenAddress ?? "",
                                                     receiveAddress: self.receiveWallet?.tokenAuthenticationKey ?? "",
                                                     amount: amount,
                                                     fee: fee,
                                                     mnemonic: mnemonic,
                                                     contact: self.detailView.headerView.reverseModel?.module ?? "",
                                                     module: self.wallet?.tokenModule ?? "")
            } else {
                //异常
            }
        case .none:
            break
        }
    }
    private func showUnpublishAlert() {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_type_in_password_title"), message: LibraWalletError.WalletMapping(reason: .mappingTokenPublishedInvalid).localizedDescription, preferredStyle: .alert)
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_confirm_button_title"), style: .default){ [weak self] clickHandler in
            //显示选中钱包publish密码
            self?.showNeedPublishWalletPasswordAlert()
        })
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_type_in_password_cancel_button_title"), style: .cancel){ clickHandler in
            NSLog("点击了取消")
            self.detailView.toastView?.hide(tag: 99)
        })
        self.present(alertContr, animated: true, completion: nil)
    }
    private func showNeedPublishWalletPasswordAlert() {
//        if LibraWalletManager.shared.walletBiometricLock == true {
//            KeychainManager().getPasswordWithBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "") { [weak self](result, error) in
//                if result.isEmpty == false {
//                    do {
//                        let mnemonic = try LibraWalletManager.shared.getMnemonicFromKeychain(password: result, walletRootAddress: LibraWalletManager.shared.walletRootAddress ?? "")
//                        self?.dataModel.publishViolasToken(sendAddress: (self?.receiveWallet?.walletAddress)!, mnemonic: mnemonic, contact: (self?.detailView.headerView.model?.module)!)
//                    } catch {
//                        self?.detailView.makeToast(error.localizedDescription, position: .center)
//                    }
//                } else {
//                    self?.detailView.makeToast(error, position: .center)
//                }
//            }
//        } else {
//            let alert = passowordAlert(rootAddress: (self.receiveWallet?.walletRootAddress)!, message: localLanguage(keyString: "wallet_type_in_watting_publish_wallet_password_content"), mnemonic: { [weak self] (mnemonic) in
//                self?.dataModel.publishViolasToken(sendAddress: (self?.receiveWallet?.walletAddress)!, mnemonic: mnemonic, contact: (self?.detailView.headerView.model?.module)!)
//            }) { [weak self] (errorContent) in
//                guard errorContent != "Cancel" else {
//                    self?.detailView.toastView?.hide()
//                    return
//                }
//                self?.view.makeToast(errorContent, position: .center)
//            }
//            self.present(alert, animated: true, completion: nil)
//        }
        
    }
    private func showMappingWalletPasswordAlert(amount: Double, address: String, fee: Double) {
//        if LibraWalletManager.shared.walletBiometricLock == true {
//            KeychainManager().getPasswordWithBiometric(walletAddress: LibraWalletManager.shared.walletRootAddress ?? "") { [weak self](result, error) in
//                if result.isEmpty == false {
//                    do {
//                        let mnemonic = try LibraWalletManager.shared.getMnemonicFromKeychain(password: result, walletRootAddress: LibraWalletManager.shared.walletRootAddress ?? "")
//                        self?.chooseMapping(amount: amount, address: address, fee: fee, mnemonic: mnemonic)
//                    } catch {
//                        self?.detailView.makeToast(error.localizedDescription, position: .center)
//                    }
//                } else {
//                    self?.detailView.makeToast(error, position: .center)
//                }
//            }
//        } else {
//            let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
//                self?.chooseMapping(amount: amount, address: address, fee: fee, mnemonic: mnemonic)
//            }) { [weak self] (errorContent) in
//                guard errorContent != "Cancel" else {
//                    self?.detailView.toastView?.hide()
//                    return
//                }
//                self?.view.makeToast(errorContent, position: .center)
//            }
//            self.present(alert, animated: true, completion: nil)
//        }
    }
}
