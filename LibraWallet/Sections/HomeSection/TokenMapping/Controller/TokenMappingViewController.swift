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
}
extension TokenMappingViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.hideToastActivity()
//                self?.endLoading()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                    // 网络无法访问
                    print(error.localizedDescription)
                } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                    // 钱包不存在
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
                }
                self?.detailView.toastView?.hide()
                self?.view.makeToast(error.localizedDescription, position: .center)
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            if type == "MappingInfo" {
                self?.detailView.toastView?.hide()
                if let tempData = dataDic.value(forKey: "data") as? TokenMappingDataModel {
                    self?.detailView.headerView.model = tempData
                }
            } else if type == "SendBTCTransaction" {
                self?.detailView.toastView?.hide()
                self?.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"), position: .center)
            }
        })
        self.dataModel.getMappingInfo(walletType: (wallet?.walletType)!)
    }
}
extension TokenMappingViewController: TokenMappingHeaderViewDelegate {
    func chooseAddress() {
        let vc = LocalWalletViewController()
        vc.actionClosure = { (action, wallet) in
            self.detailView.headerView.exchangeToAddressTextField.text = wallet.walletAddress
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show()
            let wallet = BTCManager().getWallet(mnemonic: mnemonic)
            self?.dataModel.makeTransaction(wallet: wallet,
                                            amount: amount,
                                            fee: fee,
                                            toAddress: self?.detailView.headerView.model?.exchange_receive_address ?? "",
                                            mappingReceiveAddress: address,
                                            mappingContract: self?.detailView.headerView.model?.exchange_contract ?? "")
        }) { [weak self] (errorContent) in
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
        
    }
}
