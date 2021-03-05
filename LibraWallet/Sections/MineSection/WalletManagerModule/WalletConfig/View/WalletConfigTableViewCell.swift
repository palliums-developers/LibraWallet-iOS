//
//  WalletConfigTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/28.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol WalletConfigTableViewCellDelegate: NSObjectProtocol {
    func switchButtonValueChange(button: UISwitch)
}
class WalletConfigTableViewCell: UITableViewCell {
    weak var delegate: WalletConfigTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        if reuseIdentifier == "CellNormal" {
            contentView.addSubview(detailLabel)
            contentView.addSubview(detailIndicatorImageView)
        } else {
            contentView.addSubview(switchButton)
        }
        contentView.addSubview(spaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletConfigTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(17)
            make.centerY.equalTo(contentView).offset(-10).priority(250)
        }
        if self.reuseIdentifier == "CellNormal" {
            detailLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(contentView).offset(10)
                make.left.equalTo(contentView).offset(17)
                make.right.equalTo(detailIndicatorImageView.snp.left).offset(-9)
            }
            detailIndicatorImageView.snp.makeConstraints { (make) in
                make.centerY.equalTo(contentView)
                make.right.equalTo(contentView.snp.right).offset(-16)
            }
        } else {
            switchButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(contentView)
                make.right.equalTo(contentView.snp.right).offset(-20)
            }
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView.snp.bottom)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-17)
            make.height.equalTo(0.5)
        }
//        detailLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
//        //抱紧内容
//        detailLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        detailIndicatorImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    //MARK: - 懒加载对象
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "9F9DA4")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    private lazy var detailIndicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage.init(named: "cell_detail")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var switchButton: UISwitch = {
        //#263C4E
        let button = UISwitch.init()
        button.onTintColor = DefaultGreenColor
        button.addTarget(self, action: #selector(valueChange(button:)), for: UIControl.Event.valueChanged)
        button.setOn(Wallet.shared.walletBiometricLock ?? false, animated: true)
        return button
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    //MARK: - 设置数据
    var model: [String: String]? {
        didSet {
            guard let data = model else {
                return
            }
            self.titleLabel.text =  data["Title"]
            if let content = data["Content"], content.isEmpty == false {
                self.detailLabel.text = content
            } else {
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(contentView).offset(17)
                    make.centerY.equalTo(contentView).offset(0)
                }
            }
        }
    }
    @objc func valueChange(button: UISwitch) {
        print(button.state)
        self.delegate?.switchButtonValueChange(button: button)
    }
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                spaceLabel.alpha = 0
            }
        }
    }
}
