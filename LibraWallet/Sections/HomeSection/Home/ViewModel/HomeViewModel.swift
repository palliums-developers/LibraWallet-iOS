//
//  HomeViewModel.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

struct HomeViewModel {
    private var view: HomeView
    init(view: HomeView) {
        self.view = view
        initialData()
    }
    /// 网络请求、数据模型
    lazy var dataModel: HomeModel = {
        let model = HomeModel.init()
        return model
    }()
    ///
    private var firstRequestRate: Bool = true
    /// timer
    private var timer: Timer?
}
extension HomeViewModel {
    mutating func initialData() {
//        self.dataModel.getLocalTokens()
    }
}
