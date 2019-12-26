//
//  AddAddressView.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol AddAddressViewDelegate: NSObjectProtocol {
    func confirmAddAddress(address: String, remarks: String, type: String)
    func scanAddress()
    func showTypeSelecter()
}
class AddAddressView: UIView {
    weak var delegate: AddAddressViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(remarksTitleLabel)
        addSubview(remarksTextField)
        addSubview(remarksSpaceLabel)
        
        addSubview(addressTitleLabel)
        addSubview(addressTextField)
        addSubview(scanAddressButton)
        addSubview(addressSpaceLabel)
        
        addSubview(typeTitleLabel)
        addSubview(typeButton)
            
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AddAddressView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        remarksTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(remarksTextField)
            make.left.equalTo(self)
            make.right.equalTo(remarksSpaceLabel.snp.left)
        }
        remarksTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(remarksSpaceLabel.snp.top)
            make.left.right.equalTo(self.remarksSpaceLabel)
            make.height.equalTo(50)
        }
        remarksSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(50)
            make.left.equalTo(self).offset(67)
            make.right.equalTo(self.snp.right).offset(-23)
            make.height.equalTo(1)
        }
        addressTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTextField)
            make.left.equalTo(self)
            make.right.equalTo(addressSpaceLabel.snp.left)
        }
        addressTextField.snp.makeConstraints { (make) in
            make.bottom.equalTo(addressSpaceLabel.snp.top)
            make.left.equalTo(addressSpaceLabel)
            make.right.equalTo(scanAddressButton.snp.left)
            make.height.equalTo(50)
        }
        scanAddressButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTextField)
            make.right.equalTo(self.addressSpaceLabel)
            make.size.equalTo(CGSize.init(width: 40, height: 40))
        }
        addressSpaceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(remarksSpaceLabel.snp.bottom).offset(50)
            make.left.equalTo(self).offset(67)
            make.right.equalTo(self.snp.right).offset(-23)
            make.height.equalTo(1)
        }
        typeTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(typeButton)
            make.left.equalTo(self)
            make.right.equalTo(typeButton.snp.left)
        }
        typeButton.snp.makeConstraints { (make) in
            make.top.equalTo(addressSpaceLabel.snp.bottom)
            make.left.equalTo(self).offset(67)
            make.size.equalTo(CGSize.init(width: 100, height: 50))
        }
        confirmButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(typeButton.snp.bottom).offset(40)
            make.left.equalTo(self).offset(49)
            make.right.equalTo(self.snp.right).offset(-49)
            make.height.equalTo(37)
        }
    }
    //MARK: - 懒加载对象
    
    lazy var remarksTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        label.textColor = UIColor.init(hex: "2E2E2E")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .regular)
        label.text = localLanguage(keyString: "wallet_address_add_remarks_title")
        return label
    }()
    lazy var remarksTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_address_add_remarks_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "3C3848").alpha(0.3),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.tintColor = DefaultGreenColor
        textField.delegate = self
        return textField
    }()
    lazy var remarksSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var addressTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .regular)
        label.text = localLanguage(keyString: "wallet_address_add_address_title")
        return label
    }()
    lazy var addressTextField: UITextField = {
        let textField = UITextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "3C3848")
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_address_add_address_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "3C3848").alpha(0.3),NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 16))])
        textField.tintColor = DefaultGreenColor
        return textField
    }()
    lazy var scanAddressButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "scan"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.tag = 20
        return button
    }()
    lazy var typeTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        label.textColor = UIColor.init(hex: "515151")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: .regular)
        label.text = localLanguage(keyString: "wallet_address_add_type_title")
        return label
    }()
    lazy var typeButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_address_add_type_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hex: "3C3848"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        button.tag = 30
        return button
    }()
    lazy var addressSpaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_address_add_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        let width = UIScreen.main.bounds.width - 49 - 49
        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 44)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 10
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            guard let remarks = remarksTextField.text else {
                self.makeToast(LibraWalletError.WalletAddAddress(reason: .remarksInvalidError).localizedDescription,
                               position: .center)
                return
            }
            guard remarks.isEmpty == false else {
                self.makeToast(LibraWalletError.WalletAddAddress(reason: .remarksEmptyError).localizedDescription,
                               position: .center)
                return
            }
            guard let address = addressTextField.text else {
                self.makeToast(LibraWalletError.WalletAddAddress(reason: .addressInvalidError).localizedDescription,
                               position: .center)
                return
            }
            guard address.isEmpty == false else {
                self.makeToast(LibraWalletError.WalletAddAddress(reason: .addressEmptyError).localizedDescription,
                               position: .center)
                return
            }
            guard self.typeButton.titleLabel?.text != localLanguage(keyString: "wallet_address_add_type_button_title") else {
                self.makeToast(LibraWalletError.WalletAddAddress(reason: .addressTypeInvalidError).localizedDescription,
                               position: .center)
                return
            }
            switch self.typeButton.titleLabel?.text {
            case "BTC":
                guard BTCManager.isValidBTCAddress(address: address) == true else {
                    self.makeToast(LibraWalletError.WalletAddAddress(reason: .btcAddressInvalidError).localizedDescription,
                                   position: .center)
                    return
                }
                break
            case "Violas":
                guard ViolasManager.isValidViolasAddress(address: address) == true else {
                    self.makeToast(LibraWalletError.WalletAddAddress(reason: .violasAddressInvalidError).localizedDescription,
                                   position: .center)
                    return
                }
                break
            case "Libra":
                guard LibraManager.isValidLibraAddress(address: address) == true else {
                    self.makeToast(LibraWalletError.WalletAddAddress(reason: .libraAddressInvalidError).localizedDescription,
                                   position: .center)
                    return
                }
                break
            default:
                self.makeToast(LibraWalletError.WalletAddAddress(reason: .addressTypeInvalidError).localizedDescription,
                               position: .center)
            }
            //添加地址
            self.delegate?.confirmAddAddress(address: address, remarks: remarks, type: (self.typeButton.titleLabel?.text)!)
        } else if button.tag == 20 {
            self.delegate?.scanAddress()
        } else {
            self.delegate?.showTypeSelecter()
        }
    }
    lazy var backgroundLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: mainWidth, height: mainHeight)
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
        gradientLayer.locations = [0.5,1.0]
        gradientLayer.colors = [UIColor.init(hex: "363E57").cgColor, UIColor.init(hex: "101633").cgColor]
        return gradientLayer
    }()
}
extension AddAddressView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let content = textField.text else {
            return true
        }
        let textLength = content.count + string.count - range.length
        
        return textLength <= addressRemarksLimit
    }
}
