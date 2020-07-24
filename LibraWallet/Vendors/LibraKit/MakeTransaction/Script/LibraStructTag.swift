//
//  StructTag.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/3/30.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
enum LibraStructTagType {
    case libraDefault
    case coin1
    case Normal(String)
}
struct LibraStructTag {
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
extension LibraStructTag {
    init(type: LibraStructTagType) {
        switch type {
        case .libraDefault:
            self.address = "00000000000000000000000000000001"
            self.module = "LBR"
            self.name = "LBR"
            self.typeParams = [String]()
        case .coin1:
            self.address = "00000000000000000000000000000001"
            self.module = "Coin1"
            self.name = "LBR"
            self.typeParams = [String]()
        case .Normal(let module):
            self.address = "00000000000000000000000000000001"
            self.module = module
            self.name = module
            self.typeParams = [String]()
        }
    }
}
