//
//  BTCTransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BTCTransferViewController: BaseViewController {
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
    //子View
    private lazy var detailView : BTCTransferView = {
        let view = BTCTransferView.init()
        view.delegate = self
        return view
    }()
    lazy var dataModel: BTCTransferModel = {
        let model = BTCTransferModel.init()
        return model
    }()
    typealias successClosure = () -> Void
    var actionClosure: successClosure?
    var myContext = 0
    var wallet: LibraWalletManager?
}
extension BTCTransferViewController {
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
                // 数据状态异常
            }
            self.view.hideToastActivity()
            return
        }
        let type = jsonData.value(forKey: "type") as! String
        
        if type == "GetUnspentUTXO" {
            if let tempData = jsonData.value(forKey: "data") as? [BTCUnspentUTXOListModel] {
                // 转账成功
                print("Success,\(tempData.count)")
                let menmonic = try! LibraWalletManager.shared.getMnemonicFromKeychain(walletRootAddress: (wallet?.walletRootAddress)!)
                let walletttt = BTCManager().getWallet(mnemonic: menmonic)
                self.dataModel.selectUTXOMakeSignature(utxos: tempData, wallet: walletttt, balance: UInt64((wallet?.walletBalance)!), amount: 0.001, fee: 0.0001, toAddress: "2NGZrVvZG92qGYqzTLjCAewvPZ7JE8S8VxE")
            }
        } else if type == "SendBTCTransaction" {
            print("SendBTCsuccess")
        }
        self.view.hideToastActivity()
    }
}
extension BTCTransferViewController: BTCTransferViewDelegate {
    func scanAddressQRcode() {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            self.detailView.addressTextField.text = address
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chooseAddress() {
        let vc = AddressManagerViewController()
        vc.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmWithdraw() {
        self.view.makeToastActivity(.center)
//        self.dataModel.transfer(address: self.detailView.addressTextField.text!,
//                                amount: Double(self.detailView.amountTextField.text!)!,
//                                rootAddress: (self.wallet?.walletRootAddress)!)
//        self.dataModel.getViolasSequenceNumber(address: (self.wallet?.walletAddress)!)
        self.dataModel.getUnspentUTXO(address: (wallet?.walletAddress)!)
    }
}
