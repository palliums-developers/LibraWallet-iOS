//
//  AddAssetViewTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class AddAssetViewTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(iconImageView)
        contentBackgroundView.addSubview(nameLabel)
        contentBackgroundView.addSubview(detailLabel)
        contentBackgroundView.addSubview(switchButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("AddAssetViewTableViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        contentBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.bottom.equalTo(contentView)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView)
            make.left.equalTo(contentBackgroundView).offset(14)
            make.size.equalTo(CGSize.init(width: 38, height: 38))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView).offset(-10)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalTo(contentBackgroundView).offset(10)
        }
        switchButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView)
            make.right.equalTo(contentBackgroundView).offset(-15)
        }
    }
    //MARK: - 懒加载对象
    private lazy var contentBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 3
        view.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
        return view
    }()
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 19
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.red
       return imageView
   }()
    lazy var nameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "0E0051")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.semibold)
        label.text = "---"
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "0E0051")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var switchButton: UISwitch = {
        //#263C4E
        let button = UISwitch.init()
        button.onTintColor = UIColor.init(hex: "4730A7")
        
//        if WalletData.wallet.walletBiometricLock == true {
//            button.setOn(true, animated: true)
//        } else {
//            button.setOn(false, animated: true)
//        }
        button.addTarget(self, action: #selector(valueChange(button:)), for: UIControl.Event.valueChanged)
        return button
    }()
    @objc func valueChange(button: UISwitch) {
            print(button.state)
//            var str = localLanguage(keyString: "wallet_biometric_alert_face_id_describe")
//            if BioMetricAuthenticator.shared.touchIDAvailable() {
//                str = localLanguage(keyString: "wallet_biometric_alert_fingerprint_describe")
//            }
//            BioMetricAuthenticator.authenticateWithBioMetrics(reason: str) { (result) in
//                switch result {
//                case .success( _):
//    //                button.setOn(button.isOn, animated: true)
//    //                let str = button.isOn == true ? "1":"0"
//    //                setBiometricCheckState(state: str)
//                    let result = DataBaseManager.BDManager.updateWalletBiometricLockState(uid: WalletData.wallet.walletUID!, state: button.isOn)
//
//                    guard result == true else {
//                        button.setOn(!button.isOn, animated: true)
//                        return
//                    }
//                    WalletData.wallet.changeWalletBiometricLock(state: button.isOn)
//                    print("success")
//                case .failure(let error):
//                    //还原状态
//                    button.setOn(!button.isOn, animated: true)
//
//    //                let str = button.isOn == true ? "1":"0"
//    //                setBiometricCheckState(state: str)
//                    switch error {
//
//                    // device does not support biometric (face id or touch id) authentication
//                    case .biometryNotAvailable:
//                        print("biometryNotAvailable")
//                    // No biometry enrolled in this device, ask user to register fingerprint or face
//                    case .biometryNotEnrolled:
//                        //                    self.showGotoSettingsAlert(message: error.message())
//                        print("biometryNotEnrolled")
//
//                    // show alternatives on fallback button clicked
//                    case .fallback:
//                        //                    self.txtUsername.becomeFirstResponder() // enter username password manually
//                        print("fallback")
//                        // Biometry is locked out now, because there were too many failed attempts.
//                    // Need to enter device passcode to unlock.
//                    case .biometryLockedout:
//                        //                    self.showPasscodeAuthentication(message: error.message())
//                        print("biometryLockedout")
//                    // do nothing on canceled by system or user
//                    case .canceledBySystem, .canceledByUser:
//                        print("cancel")
//                        break
//
//                    // show error for any other reason
//                    default:
//                        print(error.localizedDescription)
//                    }
//                }
//
//            }
        }
    //MARK: - 设置数据
//    var model: Transaction? {
//        didSet {
//            guard let tempModel = model else {
//                return
//            }
//            var amountState = ""
//            var amountColor = DefaultGreenColor
//            if tempModel.event == "received" {
//                nameLabel.text = localLanguage(keyString: "wallet_transactions_receive_title")
//                amountState = "+"
//            } else {
//                amountState = "-"
//                amountColor = UIColor.init(hex: "FF4C4C")
//                nameLabel.text = localLanguage(keyString: "wallet_transactions_transfer_title")
//
//            }
//            dateLabel.text = tempModel.date
//        }
//    }
    var model: [String: String]? {
        didSet {
            self.nameLabel.text = model!["name"]
            iconImageView.image = UIImage.init(named: model!["icon"]!)
        }
    }
}
