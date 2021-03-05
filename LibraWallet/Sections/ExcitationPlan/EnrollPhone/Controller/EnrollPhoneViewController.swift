//
//  EnrollPhoneViewController.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/24.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
import Toast_Swift

class EnrollPhoneViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 页面标题
        self.title = localLanguage(keyString: "wallet_phone_verify_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
        // 添加数据监听
        self.initKVO()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    deinit {
        print("EnrollPhoneViewController销毁了")
    }
    override func back() {
        super.back()
        self.dismiss(animated: true, completion: nil)
    }
    private lazy var detailView : EnrollPhoneView = {
        let view = EnrollPhoneView.init()
        view.delegate = self
        return view
    }()
    /// 网络请求、数据模型
    lazy var dataModel: EnrollPhoneModel = {
        let model = EnrollPhoneModel.init()
        return model
    }()
    var tokens: [Token]?
    /// 数据监听KVO
    var observer: NSKeyValueObservation?
    var successClosure: (()->Void)?
}
extension EnrollPhoneViewController: EnrollPhoneViewDelegate {
    func selectPhoneArea() {
        let vc = PhoneAreaViewController()
        vc.hideAreaCode = false
        vc.actionClosure = { [weak self](action, model) in
            self?.detailView.phoneAreaButton.setTitle(model.dial_code, for: UIControl.State.normal)
        }
        let navi = BaseNavigationViewController.init(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    func getSecureCode() {
        do {
            let (phoneArea, phoneNumber) = try handleSendSecureCode()
            self.detailView.phoneNumberTextField.resignFirstResponder()
            self.detailView.invitedAddressTextField.resignFirstResponder()
            self.detailView.secureCodeTextField.becomeFirstResponder()
            self.detailView.toastView.show(tag: 99)
            self.dataModel.getSecureCode(address: Wallet.shared.violasAddress ?? "",
                                         phoneArea: phoneArea,
                                         phoneNumber: phoneNumber)
            print(phoneArea, phoneNumber)
        } catch {
            self.detailView.makeToast(error.localizedDescription, position: .center)
        }
    }
    private func handleSendSecureCode() throws -> (String, String) {
        guard let phoneArea = self.detailView.phoneAreaButton.titleLabel?.text, phoneArea != "+ 00" else {
            throw LibraWalletError.WalletVerifyMobile(reason: .phoneAreaUnselect)
        }
        guard let phoneNumber = self.detailView.phoneNumberTextField.text, phoneNumber.isEmpty == false else {
            throw LibraWalletError.WalletVerifyMobile(reason: .phoneNumberEmpty)
        }
        return (phoneArea, phoneNumber)
    }
    func confirmVerifyMobilePhone() {
        do {
            let (phoneArea, phoneNumber) = try handleSendSecureCode()
            let (secureCode, invitedAddress) = try handleConfirmVerifyMobilePhone()
            self.detailView.phoneNumberTextField.resignFirstResponder()
            self.detailView.secureCodeTextField.resignFirstResponder()
            self.detailView.invitedAddressTextField.resignFirstResponder()
            self.detailView.toastView.show(tag: 99)
            self.dataModel.sendVerifyPhone(address: Wallet.shared.violasAddress ?? "",
                                           phoneArea: phoneArea,
                                           phoneNumber: phoneNumber,
                                           secureCode: secureCode,
                                           invitedAddress: invitedAddress)
        } catch {
            self.detailView.makeToast(error.localizedDescription, position: .center)
        }
    }
    private func handleConfirmVerifyMobilePhone() throws -> (String, String) {
        guard let secureCode = self.detailView.secureCodeTextField.text, secureCode.isEmpty == false else {
            // 验证码为空
            throw LibraWalletError.WalletVerifyMobile(reason: .secureCodeEmpty)
        }
        if let address = self.detailView.invitedAddressTextField.text, address.isEmpty == false {
            return (secureCode, address)
        }
        return (secureCode, "")
    }
    
}
extension EnrollPhoneViewController {
    func initKVO() {
        self.observer = dataModel.observe(\.dataDic, options: [.new], changeHandler: { [weak self](model, change) in
            guard let dataDic = change.newValue, dataDic.count != 0 else {
                self?.detailView.toastView.hide(tag: 99)
                self?.detailView.hideToastActivity()
                return
            }
            if let error = dataDic.value(forKey: "error") as? LibraWalletError {
                // 隐藏请求指示
                self?.detailView.toastView.hide(tag: 99)
                self?.detailView.hideToastActivity()
                switch error {
                case .WalletRequest(reason: .networkInvalid):
                    break
                case .WalletRequest(reason: .walletVersionExpired):
                    break
                case .WalletRequest(reason: .parseJsonError):
                    break
                case .WalletRequest(reason: .dataCodeInvalid):
                    break
                default:
                    print(error)
                }
                self?.detailView.makeToast(error.localizedDescription, position: .center)
                return
            }
            let type = dataDic.value(forKey: "type") as! String
            self?.detailView.hideToastActivity()
            self?.detailView.toastView.hide(tag: 99)
            if type == "GetSecureCode" {
                self?.detailView.secureCodeButton.countdown = true
            } else if type == "GetVerifyMobilePhone" {
                self?.detailView.makeToast(localLanguage(keyString: "wallet_verify_mobile_phone_successful"), duration: toastDuration, position: .center, title: nil, image: nil, style: ToastManager.shared.style, completion: { (bool) in
                    if let action = self?.successClosure {
                        action()
                    }
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
}
