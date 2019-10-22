//
//  WalletCreateViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/12.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletCreateViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置背景色
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .black
    }
    //子View
    private lazy var detailView : WalletCreateView = {
        let view = WalletCreateView.init()
        view.delegate = self
        return view
    }()
//    lazy var dataModel: LoginModel = {
//        let model = LoginModel.init()
//        return model
//    }()
    deinit {
        print("WalletCreateViewController销毁了")
    }

}
extension WalletCreateViewController: WalletCreateViewDelegate {
    func createWallet() {
//        do {
////            let mnemonic = try LibraMnemonic.generate(language: .japanese)
//            //有钱助词
////            let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
//            // 没钱助词
//            //            let mnemonic = ["legal", "winner", "thank", "year", "wave", "sausage", "worth", "useful", "legal", "winner", "thank", "year", "wave", "sausage", "worth", "useful", "legal", "will"]
//
//            let mnemonic = try LibraMnemonic.generate(language: .english)
//            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
////            let wallet = LibraWallet.init(seed: seed)
//            let wallet = try LibraWallet.init(seed: seed)
//
//            let menmonicString = mnemonic.reduce("") { (result, content) in
//                var spaceString = " "
//                if result.isEmpty == true {
//                    spaceString = ""
//                }
//                return result + spaceString + content
//            }
//
//            LibraWalletManager.shared.initWallet(walletID: 999,
//                                                 walletBalance: 0,
//                                                 walletAddress: wallet.publicKey.toAddress(),
//                                                 walletRootAddress: "Libra_" + wallet.publicKey.toAddress(),
//                                                 walletCreateTime: Int(Date().timeIntervalSince1970),
//                                                 walletName: "---",
//                                                 walletCurrentUse: true,
//                                                 walletBiometricLock: false,
//                                                 walletIdentity: 0,
//                                                 walletType: 0)
//            let result = DataBaseManager.DBManager.insertWallet(model: LibraWalletManager.shared)
//            if result == true {
//                self.dismiss(animated: true, completion: nil)
//            }
//        } catch {
//            print(error)
//        }
//        self.dismiss(animated: true, completion: nil)
        let vc = CreateWalletViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func importWallet() {
        
    }
}
