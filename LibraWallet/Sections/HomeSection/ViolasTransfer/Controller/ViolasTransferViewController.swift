//
//  ViolasTransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class ViolasTransferViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化本地配置
        self.setBaseControlllerConfig()
        
        self.view.addSubview(detailView)
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
    private lazy var detailView : ViolasTransferView = {
        let view = ViolasTransferView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: ViolasTransferModel = {
        let model = ViolasTransferModel.init()
        return model
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var myContext = 0
    var wallet: LibraWalletManager?
    var sendViolasTokenState: Bool?
}
extension ViolasTransferViewController {
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
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletNotExist).localizedDescription {
                // 钱包不存在
                print(error.localizedDescription)
                let vc = WalletCreateViewController()
                let navi = UINavigationController.init(rootViewController: vc)
                self.present(navi, animated: true, completion: nil)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .walletVersionTooOld).localizedDescription {
                // 版本太久
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .parseJsonError).localizedDescription {
                // 解析失败
                print(error.localizedDescription)
            } else if error.localizedDescription == LibraWalletError.WalletRequest(reason: .dataEmpty).localizedDescription {
                print(error.localizedDescription)
                // 数据为空
            }
            self.view.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetViolasSequenceNumber" {
            if let tempData = jsonData.value(forKey: "data") as? Int {
                let menmonic = try! LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (wallet?.walletRootAddress)!)
                if sendViolasTokenState == false {
                    self.dataModel.sendViolasTransaction(sendAddress: wallet?.walletAddress ?? "",
                                                         receiveAddress: self.detailView.addressTextField.text ?? "",
                                                         amount: Double(self.detailView.amountTextField.text ?? "0")!,
                                                         mnemonic: menmonic,
                                                         sequenceNumber: tempData)
                } else {
                    self.dataModel.sendViolasTokenTransaction(sendAddress: wallet?.walletAddress ?? "",
                                                              receiveAddress: self.detailView.addressTextField.text ?? "",
                                                              amount: Double(self.detailView.amountTextField.text ?? "0")!, mnemonic: menmonic, sequenceNumber: tempData)
                }
            }
        } else if type == "SendViolasTransaction" {
            self.view.makeToast("转账成功",
                                position: .center)
            if let action = self.actionClosure {
                action()
                self.navigationController?.popViewController(animated: true)
            }
       }
        self.view.hideToastActivity()
    }
}
extension ViolasTransferViewController: ViolasTransferViewDelegate {
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chooseAddress() {
        let vc = AddressManagerViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmWithdraw() {
        self.view.makeToastActivity(.center)
        self.dataModel.getViolasSequenceNumber(address: (self.wallet?.walletAddress)!)
    }
}
