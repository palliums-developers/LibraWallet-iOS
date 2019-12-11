//
//  MarketViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SocketIO
class MarketViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    //网络请求、数据模型
    lazy var dataModel: AddAssetModel = {
        let model = AddAssetModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: MarketTableViewManager = {
        let manager = MarketTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    private lazy var detailView : MarketView = {
        let view = MarketView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    deinit {
        print("MarketViewController销毁了")
    }
    var manager: SocketManager?
//    func test() {
//        manager = SocketManager(socketURL: URL(string: "http://192.168.1.253:8181")!, config: [.log(true), .compress])
//        let socket = manager!.defaultSocket
//
//        socket.on(clientEvent: .connect) {data, ack in
//            print("socket connected")
//        }
//
//        socket.on("market") {data, ack in
//            guard let cur = data[0] as? Double else { return }
//            print(data)
////            socket.emitWithAck("getMarket", cur).timingOut(after: 0) {data in
////                socket.emit("getMarket", "{\"tokenBase\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\",\"tokenQuote\":\"0x4ce68dd6e81b400a4edf4146307b10e5030a372414fd49b1accecc0767753070\" ,\"user\":\"0x07e92f79c67fdd6b80ed9103636a49511363de8c873bc709966fffb2e3fcd095\"}")
////            }
//        }
//
//        socket.connect()
//    }
}
extension MarketViewController: MarketTableViewManagerDelegate {
    func switchButtonChange(model: ViolasTokenModel, state: Bool, indexPath: IndexPath) {
        
    }
    func selectToken(button: UIButton) {
//        let alert = TokenPickerViewAlert()
//        alert.show()
//        alert.showAnimation()
        
        if button.tag == 20 {
            ViolasSocketManager.shared.openSocket()
        } else {
            ViolasSocketManager.shared.getMarketData()
        }
    }
    func showOrderCenter() {
        let vc = OrderProcessingViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//
