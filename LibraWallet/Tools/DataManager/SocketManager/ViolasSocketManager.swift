//
//  ViolasSocketManager.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/10.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SocketIO
enum SocketManagerState {
    /// 等待请求
    case WaitingRequest
    /// 请求中
    case Requesting
    /// 等待响应
    case WaitingResponse
    /// 空闲
    case Empty
}
struct SocketManagerRequest {
    /// 任务状态
    private(set) var state: SocketManagerState?
    /// 任务请求数据
    private(set) var requestData: String?
    /// 信号量防止同时操作数据
    private let semaphore = DispatchSemaphore.init(value: 1)
}
extension SocketManagerRequest {
    mutating func changeState(state: SocketManagerState) {
        self.semaphore.wait()
        self.state = state
        self.semaphore.signal()
    }
    mutating func changeTaskData(data: String) {
        self.semaphore.wait()
        self.requestData = data
        self.semaphore.signal()
    }
}
struct ViolasSocketManager {
    static var shared = ViolasSocketManager()
    private var manager: SocketManager?
//    private let requestURL = "http://18.220.66.235:38181"
    private let requestURL = VIOLAS_PUBLISH_NET == .premainnet ? "https://dex.violas.io":"http://18.220.66.235:38181"
    /// 请求超时时间
    private var timeout = 30
    /// 设置Socket任务状态
    private var socketTask: SocketManagerRequest?
    
    private var timer: Timer?
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
            ViolasSocketManager.shared.timer?.invalidate()
            ViolasSocketManager.shared.timer = nil
            ViolasSocketManager.shared.socketTask?.changeState(state: .Empty)
            ViolasSocketManager.shared.socketTask?.changeTaskData(data: "")
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
    mutating func getMarketData(address: String, payContract: String, exchangeContract: String, failed: @escaping (()->Void)) {
        guard let socket = manager?.defaultSocket else {
            print("获取默认Socket失败")
            return
        }
        if socket.status == .connected {
            // 已连接
            // 判断是否有正在进行的任务
            guard self.socketTask?.state == .Empty || self.socketTask == nil else {
                print("有任务正在请求")
                return
            }
            self.socketTask = SocketManagerRequest.init(state: .Requesting, requestData: "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\" ,\"user\":\"\(address)\"}")
            socket.emit("getMarket", "{\"tokenBase\":\"\(payContract)\",\"tokenQuote\":\"\(exchangeContract)\" ,\"user\":\"\(address)\"}")
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.timeout), repeats: false, block: { (Timer) in
                print("超时")
                ViolasSocketManager.shared.socketTask?.changeState(state: .Empty)
                ViolasSocketManager.shared.socketTask?.changeTaskData(data: "")
                failed()
            })
        } else if socket.status == .connecting {
            // 连接中
            failed()
        } else {
            // 未连接
            socket.connect()
            failed()
        }
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
