//
//  ViolasStructTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/4/13.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

enum ViolasStructTagType {
    case ViolasDefault
    case Publish
}
struct ViolasStructTag {
    var address: String
    var module: String
    var name: String
    var typeParams: [String]
    init(address: String, module: String, name: String, typeParams: [String]) {
        self.address = address
        self.module = module
        self.name = name
        self.typeParams = typeParams
    }
}
extension ViolasStructTag {
    init(type: ViolasStructTagType) {
        switch type {
        case .ViolasDefault:
            self.address = "00000000000000000000000000000000"
            self.module = "LBR"
            self.name = "T"
            self.typeParams = [String]()
        case .Publish:
            self.address = ""
            self.module = ""
            self.name = "publish"
            self.typeParams = [String]()
        }

    }
}
