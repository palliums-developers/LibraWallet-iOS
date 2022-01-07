//
//  WelcomePageView.swift
//  HKWallet
//
//  Created by palliums on 2019/8/14.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WelcomePageViewDelegate: NSObjectProtocol {
    func confirm()
}
class WelcomePageView: UIView {
    weak var delegate: WelcomePageViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(contentLabel)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WelcomeView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-114)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(56)
            make.centerX.equalTo(self)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom).offset(-67)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 103, height: 36))
        }
    }
    //MARK: - 懒加载对象
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "C0FFFD")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: .regular)
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_welcome_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.backgroundColor = UIColor.init(hex: "15C794").cgColor
        button.layer.cornerRadius = 7
        button.alpha = 0
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        self.delegate?.confirm()
    }
    var lastPage: Bool? {
        didSet {
            if lastPage == true {
                confirmButton.alpha = 1
            }
        }
    }
    var data: [String: String]? {
        didSet {
            imageView.image = UIImage.init(named: data?["image"] ?? "")
            contentLabel.text = data?["content"]
        }
    }
}
