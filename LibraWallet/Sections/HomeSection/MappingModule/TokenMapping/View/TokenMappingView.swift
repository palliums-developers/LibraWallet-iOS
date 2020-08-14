//
//  TokenMappingView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/7.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol TokenMappingViewDelegate: NSObjectProtocol {
    func scanAddressQRcode()
    func chooseAddress()
    func confirmTransfer(amount: Double, address: String, fee: Double)
}
class TokenMappingView: UIView {
    weak var delegate: TokenMappingViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerBackground)

        addSubview(scrollView)
        scrollView.addSubview(headerView)
        scrollView.addSubview(bottomView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TokenMappingView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        headerBackground.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(196)
        }
        scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(self).offset(navigationBarHeight)
        }
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo((436 * ratio))
            make.top.equalTo(scrollView).offset(30)
        }
        bottomView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo((444 * ratio))
            make.top.equalTo(headerView.snp.bottom).offset(30)
        }
        scrollView.contentSize = CGSize.init(width: mainWidth, height: bottomView.frame.maxY + 10)
    }
    //MARK: - 懒加载对象
    private lazy var headerBackground : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_top_background")
        return imageView
    }()
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        return scrollView
    }()
    
    lazy var headerView: TokenMappingHeaderView = {
        let view = TokenMappingHeaderView.init()
        return view
    }()
    lazy var bottomView: TokenMappingBottomView = {
        let view = TokenMappingBottomView.init()
        return view
    }()
    var toastView: ToastView? {
        let toast = ToastView.init()
        return toast
    }
//    var wallet: LibraWalletManager? {
//        didSet {
//            guard let model = wallet else {
//                return
//            }
//
//            let balance = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.walletBalance ?? 0)),
//                                                 scale: 4,
//                                                 unit: 1000000)
//            walletBalanceLabel.text = localLanguage(keyString: "wallet_transfer_balance_title") + balance + " vtoken"
//        }
//    }
//    var vtoken: ViolasTokenModel? {
//        didSet {
//            guard let model = vtoken else {
//                return
//            }
//            let balance = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.balance ?? 0)),
//                                                 scale: 4,
//                                                 unit: 1000000)
//            walletBalanceLabel.text = localLanguage(keyString: "wallet_transfer_balance_title") + balance + " " + (model.name ?? "")
//        }
//    }
}
extension TokenMappingView: UITextFieldDelegate {
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       guard let content = textField.text else {
           return true
       }
       let textLength = content.count + string.count - range.length
       if content.contains(".") {
           let firstContent = content.split(separator: ".").first?.description ?? "0"
           if (textLength - firstContent.count) < 6 {
               return true
           } else {
               return false
           }
       } else {
           return textLength <= ApplyTokenAmountLengthLimit
       }
   }
}
