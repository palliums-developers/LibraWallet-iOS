//
//  ScanLoginModel.swift
//  SSO
//
//  Created by wangyingdong on 2020/3/16.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Moya

struct SubmitScanLoginMainModel: Codable {
    /// 错误代码
    var code: Int?
    /// 错误信息
    var message: String?
}
class ScanLoginModel: NSObject {
    private var requests: [Cancellable] = []
    @objc dynamic var dataDic: NSMutableDictionary = [:]
    deinit {
        requests.forEach { cancellable in
            cancellable.cancel()
        }
        requests.removeAll()
        print("ScanLoginModel销毁了")
    }
}
