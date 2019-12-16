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
    mutating func openSocket() {
        manager = SocketManager(socketURL: URL(string: requestURL)!, config: [.log(false),
                                                                              .compress,
                                                                              .reconnectWait(60)])
        let socket = manager!.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            socket.emit("subscribe", "{\"tokenBase\":\"0x05599ef248e215849cc599f563b4883fc8aff31f1e43dff1e3ebe4de1370e054\",\"tokenQuote\":\"0xb9e3266ca9f28103ca7c9bb9e5eb6d0d8c1a9d774a11b384798a3c4784d5411e\"}")
            
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
        socket.on("depths") { (data, ack) in
                print(data)
        }
        socket.connect()
    }
    mutating func stopSocket() {
        manager?.defaultSocket.disconnect()
    }
    mutating func addMarketListening(response: @escaping (Data)->Void) {
        let socket = manager!.defaultSocket
        socket.on("market") {data, ack in
            let tempData = try? JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
            response(tempData!)
//            guard let cur = data[0] as? Double else { return }
//            print(data)
            
//            socket.emitWithAck("getMarket", cur).timingOut(after: 0) {data in
//                socket.emit("getMarket", "{\"tokenBase\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\",\"tokenQuote\":\"0x4ce68dd6e81b400a4edf4146307b10e5030a372414fd49b1accecc0767753070\" ,\"user\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\"}")
//            }
        }
        
    }
    mutating func getMarketData(address: String) {
        let socket = manager!.defaultSocket
        
        socket.emit("getMarket", "{\"tokenBase\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\",\"tokenQuote\":\"0x4ce68dd6e81b400a4edf4146307b10e5030a372414fd49b1accecc0767753070\" ,\"user\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\"}")
    }
}
