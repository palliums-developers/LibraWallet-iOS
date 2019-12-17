//
//  TokenPickerViewAlert.swift
//  LibraWallet
//
//  Created by palliums on 2019/12/9.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class TokenPickerViewAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(alertTitleLabel)
        whiteBackgroundView.addSubview(pickerView)
        
        whiteBackgroundView.addSubview(cancelButton)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(successClosure: @escaping successClosure, data: [MarketSupportCoinDataModel]) {
        self.init(frame: CGRect.zero)
        self.actionClosure = successClosure
        self.models = data
//        guard let phone = SSOWalletManager.shared.walletBindingPhone else {
//            return
//        }
////        let range = phone.index(phone.startIndex, offsetBy: 6)..<phone.index(phone.startIndex, offsetBy: 10)
////        self.phoneTitleLabel.text = phone.replacingCharacters(in: range, with: "****")
//        self.phoneTitleLabel.text = phone
//
//        guard let email = SSOWalletManager.shared.walletBindingEmail else {
//            return
//        }
////        let range2 = email.index(email.startIndex, offsetBy: 6)..<email.index(email.startIndex, offsetBy: 10)
////        self.emailTitleLabel.text = email.replacingCharacters(in: range2, with: "****")
//        self.emailTitleLabel.text = email
    }
    deinit {
        print("TokenPickerViewAlert销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(358)
            make.bottom.equalTo(self).offset(358).priority(250)
        }
        alertTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(5)
            make.left.equalTo(whiteBackgroundView).offset(22)
            make.height.equalTo(30)
        }
        pickerView.snp.makeConstraints { (make) in
            make.right.left.equalTo(whiteBackgroundView)
            make.top.equalTo(alertTitleLabel.snp.bottom).offset(5)
            make.bottom.equalTo(whiteBackgroundView)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(alertTitleLabel)
            make.right.equalTo(whiteBackgroundView)
            make.size.equalTo(CGSize.init(width: 76, height: 30))
        }
    }
    //MARK: - 懒加载对象
    //懒加载子View
    lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        return view
    }()
    lazy var alertTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hex: "000000")
        label.textAlignment = NSTextAlignment.left
        label.text = localLanguage(keyString: "选择Token")
        label.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold)
        return label
    }()
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7C7C7C"), for: UIControl.State.normal)
        button.setTitle(localLanguage(keyString: "确定"), for: UIControl.State.normal)

        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.tag = 10
        return button
    }()
    typealias successClosure = (MarketSupportCoinDataModel) -> Void
    var actionClosure: successClosure?
    @objc func buttonClick(button: UIButton) {
        guard let model = models?[pickerRow] else {
            return
        }
        if let action = self.actionClosure {
            action(model)
        }
        self.hideAnimation()
    }
    var models: [MarketSupportCoinDataModel]?
    var pickerRow: Int = 0
}
extension TokenPickerViewAlert: actionViewProtocol {
    
}
extension TokenPickerViewAlert: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return models?.count ?? 0
    }
    // MARK: Picker Delegate 实现代理方法
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //返回多少列
        return 1
    }
}
extension TokenPickerViewAlert: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
       //每行多高
       return 40
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
       // 每列多宽
       return mainWidth
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //赋值
        if let model = models?[row] {
            return (model.name ?? "") + (model.enable == true ? localLanguage(keyString: "（已开启）"):"")
        }
        return "test"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //选中所执行的方法
        
        self.pickerRow = row
        print(row)
    }
}
extension TokenPickerViewAlert: actionViewAnimationProtocol {

}
