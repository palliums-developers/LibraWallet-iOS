//
//  MarketManager.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/30.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct MarketManager {
//    var shortPath = [[PoolLiquidityDataModel]]()
//    var tempArray = [PoolLiquidityDataModel]()
//    private var timer: Timer?
////    func startAutoRefreshExchangeRate(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel) {
////        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(connectTimeInvalid), userInfo: nil, repeats: false)
////        RunLoop.current.add(self.timer!, forMode: .common)
////    }
//    mutating func stopAutoRefreshExchangeRate() {
//        self.timer?.invalidate()
//        self.timer = nil
//    }
//    mutating func handleLiquidity(inputCoinA: MarketSupportTokensDataModel, outputCoinB: MarketSupportTokensDataModel, data: [PoolLiquidityDataModel]) {
//        let date1 = Date().timeIntervalSince1970
//        let tempData = data
//        let fliterPrifix0Data = tempData.filter {
//            $0.coina?.index == inputCoinA.index || $0.coinb?.index == inputCoinA.index
//        }
//        let fliterWithout0Data = tempData.filter {
//            $0.coina?.index != inputCoinA.index && $0.coinb?.index != inputCoinA.index
//        }
//        for item in fliterPrifix0Data {
//            print("\(item)")
//            // 初始符合
//            tempArray.removeAll()
//            tempArray.append(item)
//            // 判断路径结束是否符合
//            if item.coinb?.index == outputCoinB.index {
//                // 结束符合
//                shortPath.append(tempArray)
//                tempArray.removeAll()
//            } else {
//                // 结束不符合,进入路径搜索
//                fliterPath(inputCoinA: (item.coinb?.index)!, outputCoinB: outputCoinB.index!, data: fliterWithout0Data, originData: fliterWithout0Data)
//            }
//        }
//        let date2 = Date().timeIntervalSince1970
//        print("time\(Int((date2 - date1) * 1000))ms")
//        print("\(shortPath)")
//        self.fliterBestPrice(inputAAmount: 1000000, inputCoinA: 1, paths: shortPath)
//    }
//    mutating func fliterPath(inputCoinA: UInt8, outputCoinB: UInt8, data: [PoolLiquidityDataModel], originData: [PoolLiquidityDataModel]) {
//        let tempData = data
//        if data.count == 0 {
//            print(shortPath)
//            return
//        } else {
//            for item in tempData {
//                // 判断当前路径是否符合要求的起始路径
//                if (item.coina?.index == inputCoinA || item.coinb?.index == inputCoinA) {
//                    // 初始符合
//                    tempArray.append(item)
//                    // 判断路径是否符合要求的结束路径
//                    if item.coinb?.index == outputCoinB || item.coina?.index == outputCoinB {
//                        // 查询结束
//                        shortPath.append(tempArray)
//                        if tempArray.count == 3 {
//                            tempArray.removeLast(2)
//                            return
//                        } else {
//                            tempArray.removeLast()
//                            continue
//                        }
//                    } else {
//                        guard tempArray.count < 3 else {
//                            tempArray.removeLast()
//                            continue
//                        }
//                        // 初始不符合
//                        // 删除本身
//                        let lastArray = originData.filter {
//                            $0.coina?.value != item.coina?.value && $0.coinb?.value != item.coinb?.value
//                        }
//                        // 筛选接下来初始Index
//                        let index = item.coina?.index == inputCoinA ? (item.coinb?.index):(item.coina?.index)
//                        let tempppp = lastArray.filter {
//                            $0.coina?.index == index || $0.coinb?.index == index
//                        }
//                        fliterPath(inputCoinA: index!, outputCoinB: outputCoinB, data: tempppp, originData: originData)
//                    }
//                }
//            }
//        }
//    }
//    mutating func fliterBestPrice(inputAAmount: Int64, inputCoinA: UInt8, paths: [[PoolLiquidityDataModel]]) {
//        struct model {
//            var input: Int64
//            var output: Int64
//            var path: [Int]
//            var outputWithoutFee: Int64
//            var fee: Int64
//        }
//        let numberConfig = NSDecimalNumberHandler.init(roundingMode: .down,
//                                                       scale: 6,
//                                                       raiseOnExactness: false,
//                                                       raiseOnOverflow: false,
//                                                       raiseOnUnderflow: false,
//                                                       raiseOnDivideByZero: false)
//        var tempArray = [model]()
//        for path in paths {
//            var output: Int64 = inputAAmount
//            var outputWithoutFee: Int64 = inputAAmount
//            var nextIndex = inputCoinA
//            var pathArray: [UInt8] = [0]
//            var fee: Int64 = 0
//            for item in path {
//                if item.coina?.index == nextIndex {
//                    let amountInWithFee = NSDecimalNumber.init(value: output).multiplying(by: NSDecimalNumber.init(value: 997))
//                    let numerator = amountInWithFee.multiplying(by: NSDecimalNumber.init(value: item.coinb?.value ?? 0))
//                    let denominator = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).adding(amountInWithFee)
//                    output = numerator.dividing(by: denominator, withBehavior: numberConfig).int64Value
//                    // fee
//                    nextIndex = (item.coinb?.index)!
//                    let amountInWithoutFee = NSDecimalNumber.init(value: outputWithoutFee).multiplying(by: NSDecimalNumber.init(value: 1000))
//                    let numeratorWithoutFee = amountInWithoutFee.multiplying(by: NSDecimalNumber.init(value: item.coinb?.value ?? 0))
//                    let denominatorWithoutFee = (NSDecimalNumber.init(value: item.coina?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).adding(amountInWithoutFee)
//                    outputWithoutFee = numeratorWithoutFee.dividing(by: denominatorWithoutFee, withBehavior: numberConfig).int64Value
//                } else {
//                    let amountInWithFee = NSDecimalNumber.init(value: output).multiplying(by: NSDecimalNumber.init(value: 997))
//                    let numerator = amountInWithFee.multiplying(by: NSDecimalNumber.init(value: item.coina?.value ?? 0))
//                    let denominator = NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000)).adding(amountInWithFee)
//                    output = numerator.dividing(by: denominator, withBehavior: numberConfig).int64Value
//                    nextIndex = (item.coina?.index)!
//                    // fee
//                    let amountInWithoutFee = NSDecimalNumber.init(value: outputWithoutFee).multiplying(by: NSDecimalNumber.init(value: 1000))
//                    let numeratorWithoutFee = amountInWithoutFee.multiplying(by: NSDecimalNumber.init(value: item.coina?.value ?? 0))
//                    let denominatorWithoutFee = (NSDecimalNumber.init(value: item.coinb?.value ?? 0).multiplying(by: NSDecimalNumber.init(value: 1000))).adding(amountInWithoutFee)
//                    outputWithoutFee = numeratorWithoutFee.dividing(by: denominatorWithoutFee, withBehavior: numberConfig).int64Value
//                }
//                pathArray.append(nextIndex)
//            }
//            fee = outputWithoutFee - output
//            let tempModel = model.init(input: inputAAmount, output: output, path: pathArray, outputWithoutFee: outputWithoutFee, fee: fee)
//            tempArray.append(tempModel)
//        }
//        
//        let tempaaa = tempArray.sorted { (item1, item2) in
//            item1.output > item2.output
//        }
//        print(tempaaa)
//    }
}
