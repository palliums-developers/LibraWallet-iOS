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
    private let requestURL = "http://18.220.66.235:38181"

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
//            socket.emit("getMarket", "{\"tokenBase\":\"0xb9e3266ca9f28103ca7c9bb9e5eb6d0d8c1a9d774a11b384798a3c4784d5411e\",\"tokenQuote\":\"0x75bea7a9c432fe0d94f13c6d73543ea8758940e9b622b70dbbafec5ffbf74782\" ,\"user\":\"b45d3e7e8079eb16cd7111b676f0c32294135e4190261240e3fd7b96fe1b9b89\"}")
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
            do {
                if data.count > 0 {
                    let tempData = try JSONSerialization.data(withJSONObject: data[0], options: [])
                    response(tempData)
                }
                ack.with(["state": "success"])
            } catch {
                print("market_解析失败")
            }
        }
    }
    mutating func getMarketData(address: String, payContract: String, exchangeContract: String) {
        let socket = manager!.defaultSocket
        socket.emit("getMarket", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\" ,\"user\":\"\(address)\"}")
    }
    
    mutating func addDepthsListening(response: @escaping (Data)->Void) {
        let socket = manager!.defaultSocket
        socket.on("depths") {data, ack in
            do {
                if data.count > 0 {
                    let tempData = try JSONSerialization.data(withJSONObject: data[0], options: [])
                    response(tempData)
                }
            } catch {
                print("depths_解析失败")
            }
        }
    }
    mutating func addListeningData(payContract: String, exchangeContract: String) {
        let socket = manager!.defaultSocket
        socket.emit("subscribe", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\"}")
    }
    mutating func removeListeningData(payContract: String, exchangeContract: String) {
        let socket = manager!.defaultSocket
        socket.emit("unsubscribe", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\"}")
    }
}
