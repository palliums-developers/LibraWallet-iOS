//
//  BackupMnemonicView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol BackupMnemonicViewDelegate: NSObjectProtocol {
    func checkBackupMnemonic()
}
class BackupMnemonicView: UIView {
    weak var delegate: BackupMnemonicViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(alertImageView)
        whiteBackgroundView.addSubview(alertLabel)
        addSubview(confirmButton)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(collectionViewHeight: Int) {
        self.init(frame: CGRect.zero)
        self.collectionViewHeight = collectionViewHeight
    }
    deinit {
        print("WalletListView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(16)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(69)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(self.collectionViewHeight ?? 238).priority(250)
        }
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(14)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(87)
        }
        alertImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(whiteBackgroundView)
            make.left.equalTo(20)
            make.size.equalTo(CGSize.init(width: 60, height: 60))
        }
        alertLabel.snp.makeConstraints { (make) in
            make.left.equalTo(alertImageView.snp.right).offset(24)
            make.top.bottom.equalTo(whiteBackgroundView)
            make.right.equalTo(whiteBackgroundView.snp.right)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView.snp.bottom).offset(72)
            make.left.equalTo(self).offset(69)
            make.right.equalTo(self).offset(-69)
            make.height.equalTo(40)
        }
        
    }
    //MARK: - 懒加载对象
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3B3847")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = localLanguage(keyString: "wallet_backup_mnemonic_title")
        return label
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: BackupMnemonicFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = false
        collectionView.register(BackupMnemonicCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "MnemonicCell")
        
        return collectionView
    }()
    private lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.backgroundColor = UIColor.white.cgColor
        return view
    }()
    lazy var alertImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "backup_alert")
        return imageView
    }()
    lazy var alertLabel: UILabel = {
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
        label.attributedText = NSAttributedString(string: localLanguage(keyString: "wallet_backup_mnemonic_alert_detail"), attributes: attributes)
        return label
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_backup_mnemonic_confirm_button_title"), for: UIControl.State.normal)
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
    var collectionViewHeight: Int? {
        didSet {
            collectionView.snp.remakeConstraints { (make) in
                make.top.equalTo(self).offset(69)
                make.left.equalTo(self).offset(15)
                make.right.equalTo(self.snp.right).offset(-15)
                make.height.equalTo(self.collectionViewHeight ?? 0)
            }
        }
    }
    @objc func buttonClick(button: UIButton) {
        self.delegate?.checkBackupMnemonic()
    }
}
