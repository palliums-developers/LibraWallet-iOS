//
//  BackupMnemonicCollectionViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/4.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class BackupMnemonicCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mnemonicLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("BackupMnemonicCollectionViewCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        mnemonicLabel.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
    }
    //MARK: - 懒加载对象
    lazy var mnemonicLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 15), weight: UIFont.Weight.regular)
        label.text = ""
        label.layer.cornerRadius = 3
        label.layer.borderWidth = 0.5
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.init(hex: "9B9DA2").cgColor
        return label
    }()
    var model: String? {
        didSet {
            mnemonicLabel.text = model
        }
    }
    var checkBackupModel: String? {
        didSet {
            if reuseIdentifier == "CheckMnemonicCell" {
                mnemonicLabel.layer.borderColor = UIColor.white.cgColor
                mnemonicLabel.textColor = UIColor.white
                mnemonicLabel.backgroundColor = UIColor.init(hex: "504ACB")
                mnemonicLabel.text = checkBackupModel
            } else {
                mnemonicLabel.text = checkBackupModel
            }
        }
    }
    func setNormalCell() {
        mnemonicLabel.text = ""
        mnemonicLabel.backgroundColor = UIColor.clear
        mnemonicLabel.layer.borderColor = UIColor.init(hex: "9B9DA2").cgColor
    }
    var fromClickCellIndexPath: IndexPath?
}
