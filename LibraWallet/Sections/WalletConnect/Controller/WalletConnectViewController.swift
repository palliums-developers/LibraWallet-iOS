//
//  WalletConnectViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import WalletConnectSwift
class WalletConnectViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        try! self.walletConnectServer.connect(to: WCURL.init(self.url!)!)
        
    }
    var url: String?
    lazy var walletConnectServer: Server = {
        let ser = Server.init(delegate: self)
        return ser
    }()
    func onMainThread(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}
extension WalletConnectViewController: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        print("failed")
    }
    
    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        print("shouldStart")
        let walletMeta = Session.ClientMeta(name: "Test Wallet",
                                                   description: nil,
                                                   icons: [],
                                                   url: URL(string: "https://safe.gnosis.io")!)
               let walletInfo = Session.WalletInfo(approved: true,
                                                   accounts: ["wallet.address()"],
                                                   chainId: 4,
                                                   peerId: UUID().uuidString,
                                                   peerMeta: walletMeta)
           onMainThread {
               UIAlertController.showShouldStart(from: self, clientName: session.dAppInfo.peerMeta.name, onStart: {
                   completion(walletInfo)
               }, onClose: {
                   completion(Session.WalletInfo(approved: false, accounts: [], chainId: 4, peerId: "", peerMeta: walletMeta))
//                   self.scanQRCodeButton.isEnabled = true
               })
           }
    }
    
    func server(_ server: Server, didConnect session: Session) {
        print("didConnect")
        print(session.walletInfo)
    }
    
    func server(_ server: Server, didDisconnect session: Session) {
        print("didDisconnect")
    }
    
    
}
extension UIAlertController {

    func withCloseButton(title: String = "Close", onClose: (() -> Void)? = nil ) -> UIAlertController {
        addAction(UIAlertAction(title: title, style: .cancel) { _ in onClose?() } )
        return self
    }

    static func showShouldStart(from controller: UIViewController, clientName: String, onStart: @escaping () -> Void, onClose: @escaping (() -> Void)) {
        let alert = UIAlertController(title: "Request to start a session", message: clientName, preferredStyle: .alert)
        let startAction = UIAlertAction(title: "Start", style: .default) { _ in onStart() }
        alert.addAction(startAction)
        controller.present(alert.withCloseButton(onClose: onClose), animated: true)
    }

    static func showFailedToConnect(from controller: UIViewController) {
        let alert = UIAlertController(title: "Failed to connect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }

    static func showDisconnected(from controller: UIViewController) {
        let alert = UIAlertController(title: "Did disconnect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }

    static func showShouldSign(from controller: UIViewController, title: String, message: String, onSign: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let startAction = UIAlertAction(title: "Sign", style: .default) { _ in onSign() }
        alert.addAction(startAction)
        controller.present(alert.withCloseButton(title: "Reject", onClose: onCancel), animated: true)
    }

}
