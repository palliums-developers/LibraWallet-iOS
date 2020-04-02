//
//  StructTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/3/30.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum StructTagType {
    case libraDefault
}
struct StructTag {
    fileprivate var address: String
    fileprivate var module: String
    fileprivate var name: String
    fileprivate var typeParams: [String]
    init(address: String, module: String, name: String, typeParams: [String]) {
        self.address = address
        self.module = module
        self.name = name
        self.typeParams = typeParams
    }
}
extension StructTag {
    init(type: StructTagType) {
        switch type {
        case .libraDefault:
            self.address = "00000000000000000000000000000000"
            self.module = "LBR"
            self.name = "T"
            self.typeParams = [String]()
        }
    }
}
