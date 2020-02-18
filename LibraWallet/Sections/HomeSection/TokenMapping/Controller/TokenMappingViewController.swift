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
        self.title = localLanguage(keyString: "wallet_mapping_navigationbar_title")
        self.view.addSubview(detailView)
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
    private lazy var detailView : TokenMappingView = {
        let view = TokenMappingView.init()
        view.headerView.delegate = self
        return view
    }()
    lazy var dataModel: TokenMappingModel = {
        let model = TokenMappingModel.init()
        return model
    }()
    var wallet: LibraWalletManager?
    var observer: NSKeyValueObservation?
    typealias checkPublishClosure = (Bool) -> Void
    var actionClosure: checkPublishClosure?
    typealias publishFinishClosure = () -> Void
    var finishClosure: publishFinishClosure?
    var receiveWallet: LibraWalletManager?
}
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
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
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
                } else {
                    if type == "MappingInfo" {
                        self?.showMappingFunctionAlert()
                        return
                    }
                }
                self?.detailView.toastView?.hide()
                self?.view.makeToast(error.localizedDescription, position: .center)
                return
            }
            if type == "MappingInfo" {
                self?.detailView.toastView?.hide()
                if let tempData = dataDic.value(forKey: "data") as? TokenMappingDataModel {
                    self?.detailView.headerView.model = tempData
                }
            } else if type == "SendBTCTransaction" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "Transfer" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendVBTCTransaction" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            } else if type == "SendVLibraTransaction" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            }  else if type == "GetWalletEnableCoin" {
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
            }
        })
        self.detailView.toastView?.show()
        self.dataModel.getMappingInfo(walletType: (wallet?.walletType)!)
    }
    private func showMappingFunctionAlert() {
        let alertContr = UIAlertController(title: localLanguage(keyString: "wallet_mapping_info_alert_title"), message: LibraWalletError.WalletMapping(reason: .mappingFounctionInvalid).localizedDescription, preferredStyle: .alert)
        alertContr.addAction(UIAlertAction(title: localLanguage(keyString: "wallet_mapping_info_alert_confirm_button_title"), style: .default){ [weak self] clickHandler in
            self?.detailView.toastView?.hide()
            self?.navigationController?.popViewController(animated: true)
        })
        self.present(alertContr, animated: true, completion: nil)
    }
}
extension TokenMappingViewController: TokenMappingHeaderViewDelegate {
    func chooseAddress() {
        let vc = LocalWalletViewController()
        vc.actionClosure = { (action, wallet) in
            self.detailView.headerView.exchangeToAddressTextField.text = wallet.walletAddress
            self.receiveWallet = wallet
        }
        vc.walletType = self.wallet?.walletType
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        self.detailView.toastView?.show()
        self.dataModel.getWalletEnableToken(address: address, contract: (self.detailView.headerView.model?.module)!)
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
            let model = ViolasTokenModel.init(name: self.detailView.headerView.model?.name ?? "",
                                              description: "",
                                              address: self.detailView.headerView.model?.module ?? "",
                                              icon: "",
                                              enable: true,
                                              balance: 0,
                                              registerState: true)
            _ = DataBaseManager.DBManager.insertViolasToken(walletID: self.receiveWallet?.walletID ?? 0, model: model)

            self.showMappingWalletPasswordAlert(amount: amount, address: address, fee: fee)
        }
    }
    func chooseMapping(amount: Double, address: String, fee: Double, mnemonic: [String]) {
        switch self.wallet?.walletType {
        case .BTC:
            let wallet = BTCManager().getWallet(mnemonic: mnemonic)
            self.dataModel.makeTransaction(wallet: wallet,
                                            amount: amount,
                                            fee: fee,
                                            toAddress: self.detailView.headerView.model?.address ?? "",
                                            mappingReceiveAddress: address,
                                            mappingContract: self.detailView.headerView.model?.module ?? "")
        case .Libra:
            print("Libra")
            self.dataModel.transfer(address: address, amount: amount, mnemonic: mnemonic)
        case .Violas:
            print("Violas")
//            self.dataModel.sendVBTCTransaction(sendAddress: self.wallet?.walletAddress ?? "",
//                                               receiveAddress: address,
//                                               amount: amount,
//                                               fee: fee,
//                                               mnemonic: mnemonic,
//                                               contact: "af955c1d62a74a7543235dbb7fa46ed98948d2041dff67dfdb636a54e84f91fb")
            self.dataModel.sendVLibraTransaction(sendAddress: self.wallet?.walletAddress ?? "",
                                                 receiveAddress: address,
                                                 amount: amount,
                                                 fee: fee,
                                                 mnemonic: mnemonic,
                                                 contact: "61b578c0ebaad3852ea5e023fb0f59af61de1a5faf02b1211af0424ee5bbc410")
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
            self.detailView.toastView?.hide()
        })
        self.present(alertContr, animated: true, completion: nil)
    }
    private func showNeedPublishWalletPasswordAlert() {
        let alert = passowordAlert(rootAddress: (self.receiveWallet?.walletRootAddress)!, message: localLanguage(keyString: "wallet_type_in_watting_publish_wallet_password_content"), mnemonic: { [weak self] (mnemonic) in
            self?.dataModel.publishViolasToken(sendAddress: (self?.receiveWallet?.walletAddress)!, mnemonic: mnemonic, contact: (self?.detailView.headerView.model?.module)!)
        }) { [weak self] (errorContent) in
            guard errorContent != "Cancel" else {
                self?.detailView.toastView?.hide()
                return
            }
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
    private func showMappingWalletPasswordAlert(amount: Double, address: String, fee: Double) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.chooseMapping(amount: amount, address: address, fee: fee, mnemonic: mnemonic)
        }) { [weak self] (errorContent) in
            guard errorContent != "Cancel" else {
                self?.detailView.toastView?.hide()
                return
            }
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
