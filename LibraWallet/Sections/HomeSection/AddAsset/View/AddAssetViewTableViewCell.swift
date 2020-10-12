//
//  AddAssetViewTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/11/1.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Kingfisher
protocol AddAssetViewTableViewCellDelegate: NSObjectProtocol {
    func switchButtonChange(model: AssetsModel, state: Bool, indexPath: IndexPath)
}
class AddAssetViewTableViewCell: UITableViewCell {
    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(iconBackground)
        iconBackground.addSubview(iconImageView)
        contentBackgroundView.addSubview(nameLabel)
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
            make.top.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
        iconBackground.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView)
            make.left.equalTo(contentBackgroundView).offset(13)
            make.size.equalTo(CGSize.init(width: 40, height: 40))
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(iconBackground)
            make.size.equalTo(CGSize.init(width: 26, height: 26))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        switchButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentBackgroundView)
            make.right.equalTo(contentBackgroundView).offset(-15)
//            make.size.equalTo(CGSize.init(width: 38, height: 19))
        }
    }
    //MARK: - 懒加载对象
    private lazy var contentBackgroundView: UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 3
        view.layer.backgroundColor = UIColor.init(hex: "F7F7F9").cgColor
        return view
    }()
    private lazy var iconBackground : UIView = {
        let view = UIView.init()
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.init(hex: "333333").cgColor
        view.layer.borderWidth = 0.25
        view.layer.masksToBounds = true
       return view
   }()
    private lazy var iconImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
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
    lazy var switchButton: UISwitch = {
        let button = UISwitch.init()
        button.onTintColor = UIColor.init(hex: "4730A7")
        // 不能设置frame，只能缩放
        button.transform = CGAffineTransform(scaleX: 0.74, y: 0.74);
        button.addTarget(self, action: #selector(valueChange(button:)), for: UIControl.Event.valueChanged)
        return button
    }()
    @objc func valueChange(button: UISwitch) {
        guard let tempModel = self.token else {
            return
        }
        guard let tempIndexPath = self.indexPath else {
            return
        }
        self.delegate?.switchButtonChange(model: tempModel, state: button.isOn, indexPath: tempIndexPath)
    }
    //MARK: - 设置数据
    var token: AssetsModel? {
        didSet {
            nameLabel.text = token?.show_name
//            detailLabel.text = token?.description
            if let iconName = token?.icon, iconName.isEmpty == false {
                if iconName.hasPrefix("http") {
                    let url = URL(string: token?.icon ?? "")
                    iconImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
                } else {
                    iconImageView.image = UIImage.init(named: iconName)
                }
            } else {
                iconImageView.image = UIImage.init(named: "wallet_icon_default")
            }
            
            switchButton.setOn(token?.enable ?? false, animated: false)
        }
    }
    var indexPath: IndexPath?
}
