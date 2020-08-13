//
//  TransferViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/8/12.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class TransferViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localLanguage(keyString: "wallet_transfer_navigation_title")
        self.view.backgroundColor = UIColor.init(hex: "F7F7F9")
        
        self.view.addSubview(detailView)
        self.viewModel.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalTo(self.view)
            }
            make.left.right.equalTo(self.view)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .default
    }
    deinit {
        print("TransferViewController销毁了")
    }
    /// 子View
    private lazy var detailView : TransferView = {
        let view = TransferView.init()
        return view
    }()
    /// viewModel
    lazy var viewModel: TransferViewModel = {
        let viewModel = TransferViewModel.init()
        viewModel.view = self.detailView
        viewModel.delegate = self
        return viewModel
    }()    
    var address: String? {
        didSet {
            self.detailView.addressTextField.text = address
        }
    }
    var amount: Int64? {
        didSet {
            guard let tempAmount = amount else {
                return
            }
            let amountContent = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: tempAmount),
                                                       scale: 6,
                                                       unit: 1000000)
            self.detailView.amountTextField.text = "\(amountContent)"
        }
    }
    /// 钱包币列表
    var tokens: [Token]? {
        didSet {
            self.viewModel.tokens = tokens
        }
    }
}
extension TransferViewController: TransferViewModelDelegate {
    func getController() {
        if let action = viewModel.controllerClosure {
            action(self)
        }
    }
}
