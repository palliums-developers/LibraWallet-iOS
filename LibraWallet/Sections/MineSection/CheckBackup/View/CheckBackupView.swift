//
//  CheckBackupView.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol CheckBackupViewDelegate: NSObjectProtocol {
    func confirmBackup()
}
class CheckBackupView: UIView {
    weak var delegate: CheckBackupViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hex: "F7F7F9")
        addSubview(titleLabel)
        addSubview(checkCollectionView)
        addSubview(selectCollectionView)
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
        print("CheckBackupView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(16)
        }
        checkCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(69)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(self.collectionViewHeight ?? 238).priority(250)
        }
        selectCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(checkCollectionView.snp.bottom).offset(14)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.height.equalTo(self.collectionViewHeight ?? 238).priority(250)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(selectCollectionView.snp.bottom).offset(20)
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
        label.text = localLanguage(keyString: "wallet_backup_check_mnemonic_title")
        return label
    }()
    //
    lazy var checkCollectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: BackupMnemonicFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = false
        collectionView.register(BackupMnemonicCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "MnemonicCell")
        collectionView.register(BackupMnemonicCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CheckMnemonicCell")

        collectionView.tag = 10
        return collectionView
    }()
    lazy var selectCollectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: BackupMnemonicFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = false
        collectionView.register(BackupMnemonicCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "MnemonicCell")
        collectionView.register(BackupMnemonicCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CheckMnemonicCell")

        collectionView.tag = 20
        return collectionView
    }()
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(localLanguage(keyString: "wallet_backup_check_mnemonic_confirm_button_title"), for: UIControl.State.normal)
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
            checkCollectionView.snp.remakeConstraints { (make) in
                make.top.equalTo(self).offset(69)
                make.left.equalTo(self).offset(15)
                make.right.equalTo(self.snp.right).offset(-15)
                make.height.equalTo(self.collectionViewHeight ?? 0)
            }
            selectCollectionView.snp.remakeConstraints { (make) in
                make.top.equalTo(checkCollectionView.snp.bottom).offset(14)
                make.left.equalTo(self).offset(15)
                make.right.equalTo(self.snp.right).offset(-15)
                make.height.equalTo(self.collectionViewHeight ?? 0)
            }
        }
    }
    @objc func buttonClick(button: UIButton) {
        self.delegate?.confirmBackup()
    }
}
