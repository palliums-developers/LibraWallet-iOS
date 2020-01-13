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
    private let requestURL = "https://dex.violas.io"
}
extension ViolasSocketManager {

    mutating func configSocket(response: @escaping ()->Void) {
        manager = SocketManager(socketURL: URL(string: requestURL)!, config: [.log(true),
                                                                              .compress,
                                                                              .reconnectWait(30)])
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            response()
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
        socket.on(clientEvent: .reconnect) { (data, ack) in
            print("socket reconnect")
        }
        socket.connect()
    }
    mutating func stopSocket() {
        manager?.defaultSocket.disconnect()
    }
    mutating func addMarketListening(response: @escaping (Data)->Void) {
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
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
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
        socket.emit("getMarket", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\" ,\"user\":\"\(address)\"}")
    }
    
    mutating func addDepthsListening(response: @escaping (Data)->Void) {
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
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
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
        if socket.status == .connected {
            // 已连接
            socket.emit("subscribe", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\"}")
        } else if socket.status == .connecting {
            // 连接中
        } else {
            // 未连接
            socket.connect()
        }
    }
    mutating func removeListeningData(payContract: String, exchangeContract: String) {
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
        if socket.status == .connected {
            // 已连接
            socket.emit("unsubscribe", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\"}")
        } else if socket.status == .connecting {
            // 连接中
        } else {
            // 未连接
            socket.connect()
        }
    }
}
