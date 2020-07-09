//
//  MarketMineModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/7/9.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya
class MarketMineModel: NSObject {
    private var requests: [Cancellable] = []
    @objc var dataDic: NSMutableDictionary = [:]
}
