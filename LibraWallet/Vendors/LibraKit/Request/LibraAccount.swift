//
//  LibraAccount.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation

struct LibraAccount {
    
    private(set) var address: String?
    
    private(set) var sequenceNumber: Int64?
    
    private(set) var balance: Int64?
    
    private(set) var receiveCount: Int64?
    
    private(set) var transferCount: Int64?
    
    fileprivate let accountData: Data 
    
    init(accountData: Data) {
        self.accountData = accountData
        self.deserialize()
    }
    mutating func deserialize() {
        guard self.accountData.count != 0 else {
            return
        }
        let (countsData, lastData) = cutData(originData: self.accountData, length: 4)
        // 读取数据个数
        let dataCounts = hw_getInt(countsData.bytes)
        var resultArray = [Data]()

        for _ in 0..<dataCounts {
            // 获取Key长度
            let (keyLengthData, lastData2) = cutData(originData: lastData, length: 4)
            // 截取Key
            let (_, lastData3) = cutData(originData: lastData2, length: hw_getInt(keyLengthData.bytes))
            // 截取shen gu
            let (resultDataLength, lastData4) = cutData(originData: lastData3, length: 4)
//
            let (resultData, _) = cutData(originData: lastData4, length: hw_getInt(resultDataLength.bytes))

//            print(data.toHexString())
            resultArray.append(resultData)
        }
        for result in resultArray {
            let (addressLengthData, lastData6) = cutData(originData: result, length: 4)
            let (address, lastData7) = cutData(originData: lastData6, length: hw_getInt(addressLengthData.bytes))
//            print("address = \(address)")
            
            let (balance, lastData8) = cutData(originData: lastData7, length: 8)
//            print("balance = \(hw_getInt64(balance.bytes) / 1000000)")
            
            let (delegatedWithdrawalCapability, lastData9) = cutData(originData: lastData8, length: 1)
//            print("delegatedWithdrawalCapability = \(hw_getInt(delegatedWithdrawalCapability.bytes))")
            
            let (receivedEventsCount, lastData10) = cutData(originData: lastData9, length: 8)
//            print(hw_getInt(receivedEventsCount.bytes))
            
            let (receivedEventsLength, lastData11) = cutData(originData: lastData10, length: 4)
//            print(hw_getInt(receivedEventsLength.bytes))
            
            let (receivedEvents, lastData12) = cutData(originData: lastData11, length: hw_getInt(receivedEventsLength.bytes))
//            print(receivedEvents.toHexString())
            
            let (sentEventsCount, lastData13) = cutData(originData: lastData12, length: 8)
//            print(hw_getInt(sentEventsCount.bytes))
            
            let (sentEventsLength, lastData14) = cutData(originData: lastData13, length: 4)
//            print(hw_getInt(sentEventsLength.bytes))
            
            let (sentEvents, lastData15) = cutData(originData: lastData14, length: hw_getInt(sentEventsLength.bytes))
//            print(sentEvents.toHexString())
            
            let (sequenceNumber, _) = cutData(originData: lastData15, length: 8)
//            print(hw_getInt64(sequenceNumber.bytes))
            //            print(hw_getInt(sequenceNumber.bytes))
            self.address = address.toHexString()
            self.sequenceNumber = Int64(hw_getInt64(sequenceNumber.bytes))
            self.balance = Int64(hw_getInt64(balance.bytes) / 1000000)
            self.receiveCount = Int64(hw_getInt(receivedEventsCount.bytes))
            self.transferCount = Int64(hw_getInt(sentEventsCount.bytes))
        }
    }
    fileprivate func cutData(originData: Data, length: Int) -> (Data, Data) {
        // 截取前部数据
        let headerData = originData.subdata(in: 0..<length)
        // 留下后部数据
        let lastData = originData.subdata(in: length..<originData.count)
        return (headerData, lastData)
    }
}
