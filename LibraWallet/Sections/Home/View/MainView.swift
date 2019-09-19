//
//  MainView.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/11.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
protocol MainViewDelegate: NSObjectProtocol {
    func walletSend()
    func walletReceive()
    
    func refreshBalance()
    
    func getTestCoin()
}
class MainView: UIView {
    weak var delegate: MainViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(walletTitleLabel)
        addSubview(walletBackgroundImageView)
        addSubview(walletWhiteBackgroundView)
        addSubview(walletIconButton)
        addSubview(walletTotalAmountTitleLabel)
        addSubview(walletTotalAmountUnitLabel)
        addSubview(walletTotalAmountUnitSelectButton)
        addSubview(showHideAmountButton)
        addSubview(walletTotalAmountLabel)
        addSubview(receiveButton)
        addSubview(receiveButtonTitleLabel)
        addSubview(sendButton)
        addSubview(sendButtonTitleLabel)
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("MainView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        walletTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(18)
            make.left.equalTo(20)
        }
        walletBackgroundImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-14.5)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo((221 * ratio))
        }
        walletWhiteBackgroundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.left.equalTo(self.walletBackgroundImageView).offset(22)
            make.right.equalTo(self.walletBackgroundImageView.snp.right).offset(-22)
            make.height.equalTo((221 * ratio))
            make.top.equalTo(self.walletBackgroundImageView).offset(-57)
        }
        walletIconButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 111 * ratio, height: 111 * ratio))
            make.top.equalTo(self.walletWhiteBackgroundView).offset(-50)
        }
        walletTotalAmountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.walletWhiteBackgroundView).offset(18)
            make.top.equalTo(self.walletWhiteBackgroundView).offset(58)
        }
        showHideAmountButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.walletTotalAmountTitleLabel.snp.right).offset(1)
            make.centerY.equalTo(self.walletTotalAmountTitleLabel)
            make.size.equalTo(CGSize.init(width: 25, height: 25))
        }
        walletTotalAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.walletWhiteBackgroundView).offset(14)
            make.right.equalTo(self.walletWhiteBackgroundView.snp.right).offset(-14)
            
            make.top.equalTo(self.walletTotalAmountTitleLabel.snp.bottom).offset(10)
        }
        walletTotalAmountUnitLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.walletTotalAmountUnitSelectButton.snp.left)
            make.centerY.equalTo(self.walletTotalAmountUnitSelectButton)
        }
        walletTotalAmountUnitSelectButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.walletWhiteBackgroundView.snp.right).offset(-11)
            make.centerY.equalTo(self.walletTotalAmountTitleLabel).offset(3)
            make.size.equalTo(CGSize.init(width: 17, height: 17))
        }
        sendButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.walletBackgroundImageView).offset(60)
            make.size.equalTo(CGSize.init(width: 73, height: 73))
            make.bottom.equalTo(self.walletBackgroundImageView.snp.bottom).offset(28)
        }
        sendButtonTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(sendButton)
            make.top.equalTo(sendButton.snp.bottom).offset(3)
        }
        receiveButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.walletBackgroundImageView.snp.right).offset(-60)
            make.size.equalTo(CGSize.init(width: 73, height: 73))
            make.bottom.equalTo(walletBackgroundImageView.snp.bottom).offset(28)
        }
        receiveButtonTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(receiveButton)
            make.top.equalTo(receiveButton.snp.bottom).offset(3)
        }
    }
    //MARK: - 懒加载对象
    lazy var walletTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "2B2F43")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 30), weight: .medium)
        label.text = localLanguage(keyString: "wallet_home_title")
        return label
    }()
    private lazy var walletBackgroundImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "home_wallet_background")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var walletWhiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 7
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    private lazy var walletIconButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "home_icon"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 99
        return button
    }()
    lazy var walletTotalAmountTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: .regular)
        label.text = localLanguage(keyString: "wallet_home_total_amount_title")
        return label
    }()
    lazy var showHideAmountButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "home_show_amount_icon"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 30
        return button
    }()
    lazy var walletTotalAmountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 56), weight: .bold)
        label.text = "-.----"
        return label
    }()
    lazy var walletTotalAmountUnitLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 18), weight: .regular)
        return label
    }()
    lazy var walletTotalAmountUnitSelectButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "home_select_unit_icon"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 20
        return button
    }()
    lazy var sendButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "home_send_icon"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    lazy var sendButtonTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: .regular)
        label.text = localLanguage(keyString: "wallet_home_send_button_title")
        return label
    }()
    lazy var receiveButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "home_receive_icon"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 15
        return button
    }()
    lazy var receiveButtonTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: .regular)
        label.text = localLanguage(keyString: "wallet_home_receive_button_title")
        return label
    }()
    //
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            self.delegate?.walletSend()
        } else if button.tag == 15 {
            self.delegate?.walletReceive()
        } else if button.tag == 20  {
            self.delegate?.refreshBalance()

        }  else if button.tag == 99  {
//            guard clickCount != 5 else {
//                self.delegate?.refreshBalance()
//                return
//            }
//            if clickCount == 0 {
//
//                clickCount += 1
//            } else {
//
//            }
            self.delegate?.getTestCoin()
        } else {
            
        }
    }
    var clickCount: Int = 0
    var model: LibraWalletManager? {
        didSet {
            self.walletTotalAmountLabel.text = "\(model?.walletBalance ?? 0)"
        }
    }
    @objc func setText(){
        walletTitleLabel.text = localLanguage(keyString: "wallet_home_title")
        walletTotalAmountTitleLabel.text = localLanguage(keyString: "wallet_home_total_amount_title")
        receiveButtonTitleLabel.text = localLanguage(keyString: "wallet_home_receive_button_title")
        sendButtonTitleLabel.text = localLanguage(keyString: "wallet_home_send_button_title")
    }
}
