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
    private let requestURL = "http://192.168.1.253:8181"
}
extension ViolasSocketManager {
    mutating func openSocket() {
        manager = SocketManager(socketURL: URL(string: requestURL)!, config: [.log(false),
                                                                              .compress,
                                                                              .reconnectWait(60)])
        let socket = manager!.defaultSocket

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect")
        }
        socket.on(clientEvent: .error) {data, ack in
            print("socket error")
        }
        
        socket.connect()
    }
    mutating func stopSocket() {
        manager?.defaultSocket.disconnect()
    }
    mutating func getMarketData() {
        let socket = manager!.defaultSocket
        socket.on("market") {data, ack in
            guard let cur = data[0] as? Double else { return }
            print(data)
//            socket.emitWithAck("getMarket", cur).timingOut(after: 0) {data in
//                socket.emit("getMarket", "{\"tokenBase\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\",\"tokenQuote\":\"0x4ce68dd6e81b400a4edf4146307b10e5030a372414fd49b1accecc0767753070\" ,\"user\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\"}")
//            }
        }
        socket.emit("getMarket", "{\"tokenBase\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\",\"tokenQuote\":\"0x4ce68dd6e81b400a4edf4146307b10e5030a372414fd49b1accecc0767753070\" ,\"user\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\"}")
    }
}
