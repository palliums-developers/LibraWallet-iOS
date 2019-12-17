//
//  ViolasSocketManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SocketIO
struct ViolasSocketManager {
    static var shared = ViolasSocketManager()
    private var manager: SocketManager?
    
//    private let requestURL = "http://18.220.66.235:38181"
    private let requestURL = "http://192.168.1.103:8181"

}
extension ViolasSocketManager {
    mutating func openSocket(response: @escaping (Bool)->Void) {
        manager = SocketManager(socketURL: URL(string: requestURL)!, config: [.log(false),
                                                                              .compress,
                                                                              .reconnectWait(60)])
        let socket = manager!.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            response(true)
            socket.emit("getMarket", "{\"tokenBase\":\"0x05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054\",\"tokenQuote\":\"0xb9e3266ca9f28103ca7c9bb9e5eb6d0d8c1a9d774a11b384798a3c4784d5411e\" ,\"user\":\"\"}")
        }
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect")
        }
        socket.on(clientEvent: .error) {data, ack in
            print("socket error")
        }
        socket.on(clientEvent: .statusChange) {data, ack in
            print("socket change")
        }
        socket.connect()
    }
    mutating func stopSocket() {
        manager?.defaultSocket.disconnect()
    }
    mutating func addMarketListening(response: @escaping (Data)->Void) {
        let socket = manager!.defaultSocket
        socket.on("market") {data, ack in
            #warning("待处理")
            let tempData = try? JSONSerialization.data(withJSONObject: data, options: [])
            
            response(tempData!)
        }
    }
    mutating func getMarketData(address: String, payContract: String, exchangeContract: String) {
        let socket = manager!.defaultSocket
        socket.emit("getMarket", "{\"tokenBase\":\(payContract),\"tokenQuote\":\(exchangeContract) ,\"user\":\(address)}")
    }
    
    mutating func addDepthsListening(response: @escaping (Data)->Void) {
        let socket = manager!.defaultSocket
        socket.on("depths") {data, ack in
            #warning("待处理")
            
            let tempData = try? JSONSerialization.data(withJSONObject: data, options: [])
            response(tempData!)
        }
    }
    mutating func addListeningData(payContract: String, exchangeContract: String) {
        let socket = manager!.defaultSocket
        socket.emit("subscribe", "{\"tokenBase\":\(payContract),\"tokenQuote\":\(exchangeContract)}")
    }
    mutating func removeListeningData(payContract: String, exchangeContract: String) {
        let socket = manager!.defaultSocket
        socket.emit("unsubscribe", "{\"tokenBase\":\(payContract),\"tokenQuote\":\(exchangeContract)}")
    }
}
