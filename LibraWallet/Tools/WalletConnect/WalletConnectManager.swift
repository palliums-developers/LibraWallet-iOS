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
    var from: String
    var receive: String
    var amount: Int64
    var module: String
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
    func disConnectToServer() {
        guard let sessionData = getWalletConnectSession(), sessionData.isEmpty == false else {
            return
        }
        do {
            let session = try JSONDecoder().decode(Session.self, from: sessionData)
            try self.walletConnectServer.disconnect(from: session)
        } catch {
            print(error.localizedDescription)
        }        
    }
    private func walletInfo(state: Bool) -> Session.WalletInfo {
        do {
            let tokens = try DataBaseManager.DBManager.getTokens().filter({
                $0.tokenEnable == true
            })
            var address = [String]()
            for item in tokens {
                address.append(item.tokenAddress)
            }
            let walletInfo = Session.WalletInfo(approved: state,
                                                accounts: address,
                                                chainId: 4,
                                                peerId: UUID().uuidString,
                                                peerMeta: walletMeta)
            return walletInfo
        } catch {
            print(error.localizedDescription)
            let walletInfo = Session.WalletInfo(approved: state,
                                                accounts: [""],
                                                chainId: 4,
                                                peerId: UUID().uuidString,
                                                peerMeta: walletMeta)
            return walletInfo
        }
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
    var disConnect: (() -> Void)?
    /// 连接状态
    var state: Bool?
    private var timer: Timer?
    
}
extension WalletConnectManager: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        print("failed")
        WalletConnectManager.shared.state = false
        WalletConnectManager.shared.timerInvalid()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WalletConnectFailedConnect"), object: nil)
        }
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
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WalletConnectDidConnect"), object: nil)
        }
    }
    func server(_ server: Server, didDisconnect session: Session) {
        print("didDisconnect")
        removeWalletConnectSession()
        WalletConnectManager.shared.state = false
        WalletConnectManager.shared.timerInvalid()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WalletConnectFailedConnect"), object: nil)
        }
        if WalletConnectManager.shared.disConnect != nil {
            DispatchQueue.main.async {
                self.disConnect!()
            }
        }
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
                    if model.payload?.code == "a11ceb0b010006010002030206040802050a0707111a082b100000000100010101000201060c000109000c4c696272614163636f756e740c6164645f63757272656e63790000000000000000000000000000000101010001030b00380002" {
                        let vc = ScanPublishViewController()
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    } else {
                        let vc = ScanSendTransactionViewController()
                         vc.model = model
                         vc.reject = {
                             WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                         }
                         appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    }
                }
            }
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
class GetAccountHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "_get_accounts"
    }
    func handle(request: Request) {
        do {
            struct tempData: Codable {
                var walletType: Int64?
                var coinType: String?
                var name: String?
                var address: String?
            }
            let localWallets = try DataBaseManager.DBManager.getTokens()
            var tempWallets = [tempData]()
            for wallets in localWallets {
                tempWallets.append(tempData.init(walletType: 0,
                                                 coinType: wallets.tokenType.description.lowercased(),
                                                 name: wallets.tokenName,
                                                 address: wallets.tokenAddress))
            }
            WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: tempWallets, id: request.id!))//
        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}
