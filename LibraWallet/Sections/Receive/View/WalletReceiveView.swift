//
//  WalletReceiveView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/6.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SnapKit
import Hue
class WalletReceiveView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
       
        addSubview(qrcodeImageView)
        addSubview(receiveAddressLabel)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletReceiveView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        qrcodeImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-30)
            make.size.equalTo(CGSize.init(width: 164, height: 164))
        }
        receiveAddressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.qrcodeImageView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.left.right.equalTo(self)
        }
    }
    lazy var qrcodeImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "default_qrcode")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var receiveAddressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    var model: LibraWallet? {
        didSet {
            qrcodeImageView.image = QRCodeGenerator.generate(from: (model?.publicKey().toAddress())!)
            receiveAddressLabel.text = model?.publicKey().toAddress()
        }
    }


}
