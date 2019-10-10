//
//  WalletReceiveViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletReceiveViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 加载子View
        self.view.addSubview(detailView)
        self.detailView.model = LibraWalletManager.wallet
        
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
    var wallet: LibraWallet? 
    private lazy var detailView : WalletReceiveView = {
        let view = WalletReceiveView.init()
        view.delegate = self
        return view
    }()
    deinit {
        print("WalletReceiveViewController销毁了")
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil {
//            self.view.makeToast(HKWalletError.WalletSaveScreenError(reason: .saveScreenFailed).localizedDescription,
//                                position: .center)
        } else {
            self.view.makeToast(localLanguage(keyString: "wallet_receive_save_qrcode_success_title"), position: .center)
        }
    }
}
extension WalletReceiveViewController: WalletReceiveViewDelegate {
    func saveQrcode() {
        if let resultImage = screenSnapshot() {
            UIImageWriteToSavedPhotosAlbum(resultImage, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        } else {
//            self.view.makeToast(HKWalletError.WalletSaveScreenError(reason: .saveScreenFailed).localizedDescription,
//                                position: .center)
        }
    }
}
