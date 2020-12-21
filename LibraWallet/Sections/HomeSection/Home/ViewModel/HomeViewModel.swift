//
//  HomeViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {
    override init() {
        super.init()
    }
    var view: HomeView? {
        didSet {
//            view?.headerView.delegate = self
//            view?.headerView.inputAmountTextField.delegate = self
//            view?.headerView.outputAmountTextField.delegate = self
        }
    }
    /// 网络请求、数据模型
    lazy var dataModel: HomeModel = {
        let model = HomeModel.init()
        return model
    }()
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    ///
    private var firstRequestRate: Bool = true
    /// timer
    private var timer: Timer?
}
extension HomeViewModel {
    
}
