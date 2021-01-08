//
//  AssetsPoolViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/3.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class AssetsPoolViewModel: NSObject {
    override init() {
        super.init()
    }
    var view: AssetsPoolView? {
        didSet {
//            view?.headerView.delegate = self
//            view?.headerView.inputAmountTextField.delegate = self
//            view?.headerView.outputAmountTextField.delegate = self
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: ExchangeModel = {
        let model = ExchangeModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
}
