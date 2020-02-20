//
//  TransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SwiftGRPC
import SwiftProtobuf
class TransferViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (self.wallet?.walletType?.description ?? "") + localLanguage(keyString: "wallet_transfer_navigation_title")
        
        self.view.addSubview(detailView)
        self.detailView.wallet = self.wallet
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    //子View
    private lazy var detailView : TransferView = {
        let view = TransferView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: TransferModel = {
        let model = TransferModel.init()
        return model
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var myContext = 0
    var wallet: LibraWalletManager?
    
    var address: String? {
        didSet {
           self.detailView.addressTextField.text = address
        }
    }
}
extension TransferViewController {
    //MARK: - KVO
    func initKVO() {
        dataModel.addObserver(self, forKeyPath: "dataDic", options: NSKeyValueObservingOptions.new, context: &myContext)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)  {
        
        guard context == &myContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard (change?[NSKeyValueChangeKey.newKey]) != nil else {
            return
        }
        guard let jsonData = (object! as AnyObject).value(forKey: "dataDic") as? NSDictionary else {
            return
        }
        if let error = jsonData.value(forKey: "error") as? LibraWalletError {
            if error.localizedDescription == LibraWalletError.WalletRequest(reason: .networkInvalid).localizedDescription {
                // 网络无法访问
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletTokenExpired).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
//                let vc = WalletCreateViewController()
//                let navi = UINavigationController.init(rootViewController: vc)
//                self.present(navi, animated: true, completion: nil)
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
            self.detailView.toastView?.hide()
            self.view.makeToast(error.localizedDescription, position: .center)
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "Transfer" {
            self.detailView.toastView?.hide()
            // 转账成功
            self.view.makeToast(localLanguage(keyString: "wallet_transfer_success_alert"),
                                position: .center)
            if let action = self.actionClosure {
                action()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}
extension TransferViewController: TransferViewDelegate {    
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
//            if address.hasPrefix("libra:") {
//                let tempAddress = address.replacingOccurrences(of: "libra:", with: "")
//
//                guard LibraManager.isValidLibraAddress(address: tempAddress) else {
//                    self.view.makeToast("不是有效的Libra地址", position: .center)
//                    return
//                }
//                self.detailView.addressTextField.text = tempAddress
//            } else {
//                self.view.makeToast("不是有效的Libra地址", position: .center)
//            }
            do {
                let tempAddressModel = try handleScanContent(content: address)
                self.detailView.addressTextField.text = tempAddressModel.address
            } catch {
                self.detailView.makeToast(error.localizedDescription, position: .center)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chooseAddress() {
        let vc = AddressManagerViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        vc.addressType = "Libra"
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func confirmTransfer(amount: Double, address: String, fee: Double) {
        let alert = passowordAlert(rootAddress: (self.wallet?.walletRootAddress)!, mnemonic: { [weak self] (mnemonic) in
            self?.detailView.toastView?.show()
            self?.dataModel.transfer(address: address,
                                    amount: amount,
                                    mnemonic: mnemonic)
        }) { [weak self] (errorContent) in
            self?.view.makeToast(errorContent, position: .center)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
