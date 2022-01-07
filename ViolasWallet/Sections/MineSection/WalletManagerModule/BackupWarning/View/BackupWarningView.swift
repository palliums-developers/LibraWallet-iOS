//
//  BackupWarningView.swift
//  ViolasWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol BackupWarningViewDelegate: NSObjectProtocol {
    func checkBackupMnemonic()
}
class BackupWarningView: UIView {
    weak var delegate: BackupWarningViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(alertTitleLabel)
        scrollView.addSubview(alertTitleDetailLabel)
        scrollView.addSubview(alertImageView)
        scrollView.addSubview(alertItemOneIndicatorLabel)
        scrollView.addSubview(alertItemOneTitleLabel)
        scrollView.addSubview(alertItemOneContentLabel)
        scrollView.addSubview(alertItemTwoIndicatorLabel)
        scrollView.addSubview(alertItemTwoTitleLabel)
        scrollView.addSubview(alertItemTwoContentLabel)
        scrollView.addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(collectionViewHeight: Int) {
        self.init(frame: CGRect.zero)
        self.collectionViewHeight = collectionViewHeight
    }
    deinit {
        print("BackupWarningView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        alertTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(32)
        }
        alertTitleDetailLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(alertTitleLabel.snp.bottom).offset(2)
        }
        alertImageView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView).offset(128)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize.init(width: 236, height: 171))
        }
        alertItemOneIndicatorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(51)
            make.top.equalTo(alertImageView.snp.bottom).offset(14)
            make.size.equalTo(CGSize.init(width: 6, height: 6))
        }
        alertItemOneTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(alertItemOneIndicatorLabel)
            make.left.equalTo(alertItemOneIndicatorLabel.snp.right).offset(8)
        }
        alertItemOneContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(alertItemOneTitleLabel.snp.bottom).offset(8)
            make.left.equalTo(alertItemOneTitleLabel)
            make.right.equalTo(self.snp.right).offset(-50)
        }
        alertItemTwoIndicatorLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(51)
            make.top.equalTo(alertItemOneIndicatorLabel.snp.bottom).offset(114)
            make.size.equalTo(CGSize.init(width: 6, height: 6))
        }
        alertItemTwoTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(alertItemTwoIndicatorLabel)
            make.left.equalTo(alertItemTwoIndicatorLabel.snp.right).offset(8)
        }
        alertItemTwoContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(alertItemTwoTitleLabel.snp.bottom).offset(8)
            make.left.equalTo(alertItemTwoTitleLabel)
            make.right.equalTo(self.snp.right).offset(-50)
        }
        confirmButton.snp.makeConstraints { (make) in
//            make.bottom.equalTo(self.snp.bottom).offset(-10)
            make.top.equalTo(alertImageView.snp.bottom).offset(271)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        scrollView.contentSize = CGSize.init(width: mainWidth, height: confirmButton.frame.maxY + 20)
    }
    //MARK: - 懒加载对象
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    lazy var alertTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3B3847")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 20), weight: UIFont.Weight.semibold)
        label.text = localLanguage(keyString: "wallet_backup_mnemonic_warning_title")
        return label
    }()
    lazy var alertTitleDetailLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3B3847")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_backup_mnemonic_warning_title_detail")
        return label
    }()
    lazy var alertImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "backup_mnemonic_icon")
        return imageView
    }()
    lazy var alertItemOneIndicatorLabel: UILabel = {
        let label = UILabel.init()
        label.layer.backgroundColor = UIColor.init(hex: "3B3847").cgColor
        label.layer.cornerRadius = 3
        return label
    }()
    lazy var alertItemOneTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3B3847")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_backup_mnemonic_warning_item_one_title")
        return label
    }()
    lazy var alertItemOneContentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3B3847")
        label.numberOfLines = 3
        let paraph = NSMutableParagraphStyle()
        // 将行间距设置为10
        paraph.lineSpacing = 10
        // 样式属性集合
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular),
                          NSAttributedString.Key.paragraphStyle: paraph]
        label.attributedText = NSAttributedString(string: localLanguage(keyString: "wallet_backup_mnemonic_warning_item_one_detail"), attributes: attributes)
        return label
    }()
    lazy var alertItemTwoIndicatorLabel: UILabel = {
        let label = UILabel.init()
        label.layer.backgroundColor = UIColor.init(hex: "3B3847").cgColor
        label.layer.cornerRadius = 3
        return label
    }()
    lazy var alertItemTwoTitleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3B3847")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 16), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_backup_mnemonic_warning_item_two_title")
        return label
    }()
    lazy var alertItemTwoContentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3B3847")
        label.numberOfLines = 3
        let paraph = NSMutableParagraphStyle()
        // 将行间距设置为10
        paraph.lineSpacing = 10
        // 样式属性集合
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular),
                          NSAttributedString.Key.paragraphStyle: paraph]
        label.attributedText = NSAttributedString(string: localLanguage(keyString: "wallet_backup_mnemonic_warning_item_two_detail"), attributes: attributes)
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_backup_mnemonic_warning_confirm_button_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.init(hex: "15C794")
        let width = UIScreen.main.bounds.width - 69 - 69

        button.layer.insertSublayer(colorGradualChange(size: CGSize.init(width: width, height: 40)), at: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    var collectionViewHeight: Int?
    @objc func buttonClick(button: UIButton) {
        self.delegate?.checkBackupMnemonic()
    }
}
