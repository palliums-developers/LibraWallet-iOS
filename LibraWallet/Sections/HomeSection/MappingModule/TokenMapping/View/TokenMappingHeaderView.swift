//
//  TokenMappingHeaderView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/10.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit
protocol TokenMappingHeaderViewDelegate: NSObjectProtocol {
    func chooseToken()
    func confirmTransfer()
}
class TokenMappingHeaderView: UIView {
    weak var delegate: TokenMappingHeaderViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(balanceIndicatorImageView)
        whiteBackgroundView.addSubview(balanceLabel)
        whiteBackgroundView.addSubview(inputAmountTextField)
        
        whiteBackgroundView.addSubview(mappingIndicatorImageView)
        whiteBackgroundView.addSubview(outputAmountTextField)
        whiteBackgroundView.addSubview(mappingSpaceImageView)
        
        whiteBackgroundView.addSubview(mappingRateTitleLabel)
        whiteBackgroundView.addSubview(mappingRateLabel)
        whiteBackgroundView.addSubview(minerFeesTitleLabel)
        whiteBackgroundView.addSubview(minerFeesLabel)
        
        whiteBackgroundView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TokenMappingHeaderView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(436)
        }
        balanceIndicatorImageView.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(30)
            make.left.equalTo(whiteBackgroundView).offset(15)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        balanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(balanceIndicatorImageView)
            make.left.equalTo(balanceIndicatorImageView.snp.right).offset(4)
        }
        inputAmountTextField.snp.makeConstraints { (make) in
            make.top.equalTo(balanceIndicatorImageView.snp.bottom).offset(16)
            make.left.equalTo(whiteBackgroundView).offset(15)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-15)
            make.height.equalTo(48)
        }
        mappingIndicatorImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(whiteBackgroundView)
            make.top.equalTo(inputAmountTextField.snp.bottom).offset(12)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        outputAmountTextField.snp.makeConstraints { (make) in
            make.top.equalTo(mappingIndicatorImageView.snp.bottom).offset(12)
            make.left.equalTo(whiteBackgroundView).offset(15)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-15)
            make.height.equalTo(48)
        }
        mappingSpaceImageView.snp.makeConstraints { (make) in
            make.top.equalTo(outputAmountTextField.snp.bottom).offset(30)
            make.left.equalTo(whiteBackgroundView).offset(30)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-30)
            make.height.equalTo(2)
        }
        mappingRateTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mappingSpaceImageView.snp.bottom).offset(27)
            make.left.equalTo(whiteBackgroundView).offset(31)
        }
        mappingRateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(mappingRateTitleLabel)
            make.left.equalTo(whiteBackgroundView).offset(110)
        }
        minerFeesTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mappingRateTitleLabel.snp.bottom).offset(8)
            make.left.equalTo(whiteBackgroundView).offset(31)
        }
        minerFeesLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minerFeesTitleLabel)
            make.left.equalTo(whiteBackgroundView).offset(110)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(mappingSpaceImageView.snp.bottom).offset(90)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
    }
    //MARK: - 懒加载对象
    private lazy var whiteBackgroundView : UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var balanceIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mapping_balance")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var balanceLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 12)
        label.text = localLanguage(keyString: "wallet_mapping_balance_title")
        return label
    }()
    lazy var inputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 14)
        textField.attributedPlaceholder = NSAttributedString(string: localLanguage(keyString: "wallet_mapping_input_amount_textfield_placeholder"),
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "BABABA"),NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        textField.layer.borderColor = UIColor.init(hex: "D8D7DA").cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 16, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 48))
        rightView.addSubview(coinSelectButton)
        textField.rightView = rightView
        textField.rightViewMode = .always
        textField.tag = 10
        return textField
    }()
    lazy var coinSelectButton: UIButton = {
        let width = 9 + libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "wallet_transfer_token_default_title"), fontSize: 12, height: 22) + 9 + 7
        let button = UIButton.init(frame: CGRect.init(x: 120 - width - 9, y: (24 - 11), width: width, height: 22))
        // 设置字体
        button.setTitle(localLanguage(keyString: "wallet_transfer_token_default_title"), for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        button.setTitleColor(UIColor.init(hex: "7038FD"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage.init(named: "arrow_down"), for: UIControl.State.normal)
        // 调整位置
        button.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
        button.layer.borderColor = UIColor.init(hex: "7038FD").cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 11
        button.tag = 10
        return button
    }()
    lazy var mappingIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "exchange_transaction_detail_amount_indicator")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var outputAmountTextField: WYDTextField = {
        let textField = WYDTextField.init()
        textField.textAlignment = NSTextAlignment.left
        textField.textColor = UIColor.init(hex: "333333")
        textField.font = UIFont.init(name: "DIN Alternate Bold", size: 14)
        textField.text = "0"
        textField.keyboardType = .decimalPad
        textField.tintColor = DefaultGreenColor
        textField.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
        textField.layer.cornerRadius = 8
        let holderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 16, height: 48))
        textField.leftView = holderView
        textField.leftViewMode = .always
        textField.isUserInteractionEnabled = false
        let rightView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 48))
        rightView.addSubview(outputTokenUnitTitleLabel)
        textField.rightView = rightView
        textField.rightViewMode = .always
        textField.tag = 20
        return textField
    }()
    lazy var outputTokenUnitTitleLabel: UILabel = {
        let width = 16 + libraWalletTool.ga_widthForComment(content: localLanguage(keyString: "---"), fontSize: 12, height: 22) + 16

        let label = UILabel.init(frame: CGRect.init(x: 100 - width, y: 0, width: width, height: 48))
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var mappingSpaceImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "mapping_space")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var mappingRateTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_mapping_mapping_rate_title")
        return label
    }()
    lazy var mappingRateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.text = "---"
        return label
    }()
    lazy var minerFeesTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_mapping_mapping_miner_fees_title")
        return label
    }()
    lazy var minerFeesLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
//        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.font = UIFont.init(name: "DIN Alternate Bold", size: 10)
        label.text = "---"
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_mapping_confirm_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69

        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.tag = 100
        return button
    }()
    @objc func buttonClick(button: UIButton) {
        if button.tag == 10 {
            inputAmountTextField.resignFirstResponder()
            self.delegate?.chooseToken()
        } else {
            // 兑换
            self.delegate?.confirmTransfer()
        }
    }
    var inputModel: TokenMappingListDataModel? {
        didSet {
            guard let model = inputModel else {
                return
            }
            var unit = 1000000
            if model.from_coin?.coin_type == "btc" {
                unit = 100000000
            }
            let balance = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model.from_coin?.assert?.amount ?? 0),
                                                 scale: 6,
                                                 unit: unit)
            balanceLabel.text = localLanguage(keyString: "wallet_mapping_balance_title") + balance + " \(model.from_coin?.assert?.show_name ?? "")"
            coinSelectButton.setTitle(model.from_coin?.assert?.show_name, for: UIControl.State.normal)
            coinSelectButton.imagePosition(at: .right, space: 3, imageViewSize: CGSize.init(width: 9, height: 5.5))
            let oldFrame = coinSelectButton.frame
            let width = 9 + libraWalletTool.ga_widthForComment(content: model.from_coin?.assert?.show_name ?? "", fontSize: 12, height: 22) + 9 + 7
            coinSelectButton.frame = CGRect.init(x: 120 - width - 9, y: oldFrame.origin.y, width: width, height: oldFrame.size.height)
            outputTokenUnitTitleLabel.text = model.to_coin?.assert?.show_name ?? "---"
            mappingRateLabel.text = "1" + " \(model.from_coin?.assert?.show_name ?? "---")" + "=" + " \(model.mapping_rate ?? 1)" + " \(model.to_coin?.assert?.show_name ?? "---")"
        }
    }
}
