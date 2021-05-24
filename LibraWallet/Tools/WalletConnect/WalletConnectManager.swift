//
//  WalletConnectManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/5/20.
//  Copyright © 2020 palliums. All rights reserved.
//

import Foundation
import WalletConnectSwift
struct WCBTCRawTransaction: Codable {
    var from: String?
    var amount: String?
    var payeeAddress: String?
    var changeAddress: String?
    var script: String?
}
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
    var maxGasAmount: UInt64?
    var gasUnitPrice: UInt64?
    var sequenceNumber: UInt64?
    var expirationTime: UInt64?
    var gasCurrencyCode: String?
    var chainId: Int?
}
struct WCLibraArguments: Codable {
    var type: String?
    var value: String?
}
struct WCLibraTypeArguments: Codable {
    var address: String?
    var module: String?
    var name: String?
    var typeParams: [String]?
}
struct WCLibraPayload: Codable {
    var code: String?
    var tyArgs: [WCLibraTypeArguments]?
    var args: [WCLibraArguments]?
}
struct WCLibraRawTransaction: Codable {
    var from: String?
    var payload: WCLibraPayload?
    var maxGasAmount: UInt64?
    var gasUnitPrice: UInt64?
    var sequenceNumber: UInt64?
    var expirationTime: UInt64?
    var gasCurrencyCode: String?
    var chainId: Int?
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
//        do {
//            let tokens = try WalletManager.getLocalEnableTokens()
//            var address = [String]()
//            for item in tokens {
//                address.append(item.tokenAddress)
//            }
//            let walletInfo = Session.WalletInfo(approved: state,
//                                                accounts: address,
//                                                chainId: 4,
//                                                peerId: UUID().uuidString,
//                                                peerMeta: walletMeta)
//            return walletInfo
//        } catch {
//            print(error.localizedDescription)
//            let walletInfo = Session.WalletInfo(approved: state,
//                                                accounts: [""],
//                                                chainId: 4,
//                                                peerId: UUID().uuidString,
//                                                peerMeta: walletMeta)
//            return walletInfo
//        }
        let address = [Wallet.shared.violasAddress ?? "",
                       Wallet.shared.btcAddress ?? "",
                       Wallet.shared.libraAddress ?? ""]
        let walletInfo = Session.WalletInfo(approved: state,
                                            accounts: address,
                                            chainId: VIOLAS_PUBLISH_NET.chainId,
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
        ser.register(handler: SignRawTransactionHandler())
        ser.register(handler: SendLibraTransactionHandler())
        ser.register(handler: SendBTCTransactionHandler())
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
                    vc.confirm = { (result) in
                        switch result {
                        case let .success(signature):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))//
                            } catch {
                                print(error.localizedDescription)
                            }
                            print(signature)
                        case let .failure(error):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
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
                    switch model.payload?.code {
                    case ViolasUtils.getMoveCode(name: "peer_to_peer_with_metadata"):
                        print("Wallet Connect 普通交易")
                        let vc = ScanSendTransactionViewController()
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasUtils.getMoveCode(name: "add_currency_to_account"):
                        print("Wallet Connect 添加币种")
                        let vc = ScanPublishViewController()
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "MarketContracts", contract: "add_liquidity"):
                        print("Wallet Connect 市场添加流动性")
                        let vc = ScanSwapViewController()
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "MarketContracts", contract:  "remove_liquidity"):
                        print("Wallet Connect 市场移除流动性")
                        let vc = ScanSwapViewController()
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "MarketContracts", contract: "swap"):
                        print("Wallet Connect 市场兑换")
                        let vc = ScanSwapViewController()
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "lock"):
                        print("Wallet Connect 数字银行存款")
                        let vc = ScanBankDepositViewController()
                        vc.submitTransaction = true
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "borrow"):
                        print("Wallet Connect 数字银行借款")
                        let vc = ScanBankLoanViewController()
                        vc.submitTransaction = true
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "repay_borrow"):
                        print("Wallet Connect 数字银行还款")
                        let vc = ScanBankRepaymentViewController()
                        vc.submitTransaction = true
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "redeem"):
                        print("Wallet Connect 数字银行取款")
                        let vc = ScanBankWithdrawViewController()
                        vc.submitTransaction = true
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "MarketContracts", contract: "withdraw_mine_reward"):
                        print("Wallet Connect 交易所提取激励")
                        let vc = ScanViolasExcitationViewController()
                        vc.submitTransaction = true
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "claim_incentive"):
                        print("Wallet Connect 数字银行提取激励")
                        let vc = ScanViolasExcitationViewController()
                        vc.submitTransaction = true
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    default:
                        WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
                    }
                }
            }
        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}

class SendBTCTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "_bitcoin_sendTransaction"
    }
    func handle(request: Request) {
        do {
            let model = try request.parameter(of: WCBTCRawTransaction.self, at: 0)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let vc = ScanSendTransactionViewController()
                    vc.btcModel = model
                    vc.reject = {
                        WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                    }
                    vc.confirm = { (result) in
                        switch result {
                        case let .success(signature):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                            print(signature)
                        case let .failure(error):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
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
class SendLibraTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "_libra_sendTransaction"
    }
    func handle(request: Request) {
        do {
            let model = try request.parameter(of: WCLibraRawTransaction.self, at: 0)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let vc = ScanSendTransactionViewController()
                    vc.libraModel = model
                    vc.reject = {
                        WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                    }
                    vc.confirm = { (result) in
                        switch result {
                        case let .success(signature):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                            print(signature)
                        case let .failure(error):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
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
class SignTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "violas_signRawTransaction"
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
                    vc.confirm = { (result) in
                        switch result {
                        case let .success(signature):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                            print(signature)
                        case let .failure(error):
                            do {
                                WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
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
class SignRawTransactionHandler: RequestHandler {
    func canHandle(request: Request) -> Bool {
        return request.method == "violas_signTransaction"
    }
    func handle(request: Request) {
        do {
            let model = try request.parameter(of: WCRawTransaction.self, at: 0)
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    switch model.payload?.code {
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "lock"):
                        print("Wallet Connect存款")
                        let vc = ScanBankDepositViewController()
                        vc.submitTransaction = false
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "borrow"):
                        print("Wallet Connect借款")
                        let vc = ScanBankLoanViewController()
                        vc.submitTransaction = false
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "repay_borrow"):
                        print("Wallet Connect还款")
                        let vc = ScanBankRepaymentViewController()
                        vc.submitTransaction = false
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    case ViolasManager.getLocalMoveCode(bundle: "BankContracts", contract: "redeem"):
                        print("Wallet Connect取款")
                        let vc = ScanBankWithdrawViewController()
                        vc.submitTransaction = false
                        vc.model = model
                        vc.reject = {
                            WalletConnectManager.shared.walletConnectServer.send(.reject(request))
                        }
                        vc.confirm = { (result) in
                            switch result {
                            case let .success(signature):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: signature, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                                print(signature)
                            case let .failure(error):
                                do {
                                    WalletConnectManager.shared.walletConnectServer.send(try Response.init(url: request.url, errorCode: error.code, message: error.domain, id: request.id!))
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    default:
                        WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
                    }
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
                var chainId: Int?
            }
            let localWallets = try WalletManager.getLocalEnableTokens()
            var tempWallets = [tempData]()
            for wallets in localWallets {
                tempWallets.append(tempData.init(walletType: 0,
                                                 coinType: wallets.tokenType.description.lowercased(),
                                                 name: wallets.tokenName,
                                                 address: wallets.tokenAddress,
                                                 chainId: 4))
            }
            WalletConnectManager.shared.walletConnectServer.send(try Response(url: request.url, value: tempWallets, id: request.id!))//
        } catch {
            WalletConnectManager.shared.walletConnectServer.send(.invalid(request))
            return
        }
    }
}
