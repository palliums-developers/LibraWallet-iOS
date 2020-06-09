//
//  WalletConnectManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import Foundation
import WalletConnectSwift
struct WCSignTransactionModel: Codable {
    var address: String?
    var message: String?
}
struct WCSendRawTransaction: Codable {
    var tx: String?
}
struct WCArguments: Codable {
    var type: String?
    var value: String?
}
struct WCPayload: Codable {
    var code: String?
    var tyArgs: [String]?
    var args: [WCArguments]?
}
struct WCRawTransaction: Codable {
    var from: String?
    var payload: WCPayload?
    var maxGasAmount: Int64?
    var gasUnitPrice: Int64?
    var sequenceNumber: Int64?
    var expirationTime: Int64?
}
struct WCDataModel {
    var from: String?
    var receive: String?
    var amount: Int64?
}
class WalletConnectManager: NSObject {
    static var shared = WalletConnectManager()
    
    func connectToServer(url: String) {
        do {
            guard let wcURL = WCURL.init(url) else {
                return
            }
            try self.walletConnectServer.connect(to: wcURL)
            self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(connectTimeInvalid), userInfo: nil, repeats: false)
            RunLoop.current.add(self.timer!, forMode: .common)
        } catch {
            print(error.localizedDescription)
        }
    }
    func reconnectToServer(sessionData: Data) {
        do {
            let session = try JSONDecoder().decode(Session.self, from: sessionData)
            try self.walletConnectServer.reconnect(to: session)
        } catch {
            print(error.localizedDescription)
        }
    }
    private func walletInfo(state: Bool) -> Session.WalletInfo {
        let wallets = DataBaseManager.DBManager.getWalletWithType(walletType: WalletType.Violas)
        var address = [String]()
        for item in wallets {
            address.append(item.walletAddress ?? "")
        }
        let walletInfo = Session.WalletInfo(approved: state,
                                            accounts: address,
                                            chainId: 4,
                                            peerId: UUID().uuidString,
                                            peerMeta: walletMeta)
        return walletInfo
    }
    @objc func connectTimeInvalid() {
        if let timeInvalid = WalletConnectManager.shared.connectInvalid {
            timeInvalid()
        }
    }
    func timerInvalid() {
        self.timer?.invalidate()
        self.timer = nil
    }
    private lazy var walletMeta: Session.ClientMeta = {
        let meta = Session.ClientMeta(name: "ViolasPay",
                                      description: nil,
                                      icons: [],
                                      url: URL(string: "https://www.violas.io")!)
        return meta
    }()
    lazy var walletConnectServer: Server = {
        let ser = Server.init(delegate: self)
        ser.register(handler: SendRawTransactionHandler())
        ser.register(handler: SendTransactionHandler())
        ser.register(handler: GetAccountHandler())
        ser.register(handler: SignTransactionHandler())
        return ser
    }()

    var didConnectClosure: (() -> Void)?
    var connect: ((Bool) -> Void)?
    var allowConnect: (() -> Void)?
    var connectInvalid: (() -> Void)?
    /// 连接状态
    var state: Bool?
    private var timer: Timer?
    
}
extension WalletConnectManager: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        print("failed")
        WalletConnectManager.shared.state = false
        WalletConnectManager.shared.timerInvalid()
    }
    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        print("shouldStart")
        self.connect = { state in
            DispatchQueue.main.async {
                completion(self.walletInfo(state: state))
            }
        }
        if let allow = WalletConnectManager.shared.allowConnect {
            DispatchQueue.main.async {
                allow()
            }
        }
        WalletConnectManager.shared.timerInvalid()
    }
    func server(_ server: Server, didConnect session: Session) {
        print("didConnect")
        if WalletConnectManager.shared.didConnectClosure != nil {
            DispatchQueue.main.async {
                self.didConnectClosure!()
            }
        }
        let sessionData = try! JSONEncoder().encode(session)
        setWalletConnectSession(session: sessionData)
        WalletConnectManager.shared.state = true
        WalletConnectManager.shared.timerInvalid()
    }
    func server(_ server: Server, didDisconnect session: Session) {
        print("didDisconnect")
        removeWalletConnectSession()
        WalletConnectManager.shared.state = false
        WalletConnectManager.shared.timerInvalid()
    }
}
class SendRawTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "violas_sendRawTransaction"
    }
    func handle(request: Request) {
        do {
            let messageBytes = try request.parameter(of: WCSendRawTransaction.self, at: 0)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let vc = ScanSendRawTransactionViewController()
                    vc.transactionHex = messageBytes.tx
                    vc.reject = {
                        WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                    }
                    appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
            }
        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}
class SendTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "violas_sendTransaction"
    }
    func handle(request: Request) {
        do {
            let model = try request.parameter(of: WCRawTransaction.self, at: 0)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let vc = ScanSendTransactionViewController()
                    vc.model = model
                    vc.reject = {
                        WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                    }
                    appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
            }
        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}
class GetAccountHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "_get_accounts"
    }
    func handle(request: Request) {
        do {
            struct tempData: Codable {
                var walletType: Int?
                var coinType: String?
                var name: String?
                var address: String?
            }
            let localWallets = DataBaseManager.DBManager.getLocalWallets()
            var tempWallets = [tempData]()
            for wallets in localWallets {
                tempWallets.append(tempData.init(walletType: wallets.walletCreateType,
                                                 coinType: wallets.walletType?.description.lowercased(),
                                                 name: wallets.walletName,
                                                 address: wallets.walletAddress))
            }
            let resultData = try? JSONEncoder().encode(tempWallets)
            let strJson = String.init(data: resultData!, encoding: .utf8)
            WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: strJson, id: request.id!))//

        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}
class SignTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "violas_signTransaction"
    }
    func handle(request: Request) {
        do {
            let model = try request.parameter(of: WCSignTransactionModel.self, at: 0)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let vc = ScanSignTransactionViewController()
                    vc.model = model
                    vc.reject = {
                        WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                    }
                    vc.confirm = { (signature) in
                        do {
                            WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))//
                        } catch {
                            print(error.localizedDescription)
                        }
                        print(signature)
                    }
                    appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
            }
        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}
