//
//  WalletTransactionsTableViewCell.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WalletTransactionsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(transactionTypeImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(stateLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(cellSpaceLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WalletDetailTableViewCell销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        transactionTypeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(29)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionTypeImageView.snp.right).offset(15)
            make.right.equalTo(amountLabel.snp.left).offset(-5)
            make.centerY.equalTo(contentView).offset(-10)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionTypeImageView.snp.right).offset(15)
            make.centerY.equalTo(contentView).offset(10)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-27)
            make.centerY.equalTo(addressLabel)
        }
        stateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-27)
            make.centerY.equalTo(dateLabel)
        }
        cellSpaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(29)
            make.right.equalTo(contentView.snp.right).offset(-29)
            make.height.equalTo(1)
        }
        //防止用户名字挤压
        //宽度不够时，可以被压缩
        addressLabel.setContentCompressionResistancePriority(UILayoutPriority.fittingSizeLevel, for: NSLayoutConstraint.Axis.horizontal)
        //抱紧内容
        addressLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        //不可以被压缩，尽量显示完整
    }
    //MARK: - 懒加载对象
    private lazy var transactionTypeImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        return view
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "BCBCBC")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 10), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "3C3848")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = ""
        return label
    }()
    lazy var addressLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.lineBreakMode = .byTruncatingMiddle
        label.text = "---"
        return label
    }()
    lazy var cellSpaceLabel: UILabel = {
        //#263C4E
        let label = UILabel.init()
        label.backgroundColor = UIColor.init(hex: "DEDFE0")
        return label
    }()
    //MARK: - 设置数据
    var tokenName: String?
    var btcModel: TrezorBTCTransactionDataModel? {
        didSet {
            guard let model = btcModel else {
                return
            }
            dateLabel.text = timestampToDateString(timestamp: model.blockTime ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.transaction_value ?? 0)),
                                                      scale: 8,
                                                      unit: 100000000)
            if model.transaction_type == 0 {
                // 转账
                amountLabel.textColor = UIColor.init(hex: "13B788")
                transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                addressLabel.text = model.vin?.first?.addresses?.first
            } else {
                // 收款
                amountLabel.textColor = UIColor.init(hex: "13B788")
                transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                addressLabel.text = model.vout?.first?.addresses?.first
                
            }
        }
    }
    var violasModel: ViolasDataModel? {
        didSet {
            guard let model = violasModel else {
                return
            }
            dateLabel.text = timestampToDateString(timestamp: model.expiration_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.amount ?? 0)),
                                                      scale: 4,
                                                      unit: 1000000)
            switch model.type {
            case 0:
                //ADD_CURRENCY_TO_ACCOUNT
                print("0")
                transactionTypeImageView.image = UIImage.init(named: "publish_sign")
                addressLabel.text = model.sender
            case 1:
                //ADD_VALIDATOR
                print("1")
            case 2:
                //BURN
                print("2")
            case 3:
                //BURN_TXN_FEES
                print("3")
            case 4:
                //CANCEL_BURN
                print("4")
            case 5:
                //CREATE_CHILD_VASP_ACCOUNT
                print("5")
            case 6:
                //CREATE_DESIGNATED_DEALER
                print("6")
            case 7:
                //CREATE_PARENT_VASP_ACCOUNT
                print("7")
            case 8:
                //CREATE_VALIDATOR_ACCOUNT
                print("8")
            case 9:
                //EMPTY_SCRIPT
                print("9")
            case 10:
                //FREEZE_ACCOUNT
                print("10")
            case 11:
                // MINT_LBR
                print("11")
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            case 12:
                //MINT_LBR_TO_ADDRESS
                print("12")
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            case 13:
                //MINT
                print("13")
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            case 14:
                //MODIFY_PUBLISHING_OPTION
                print("14")
            case 15:
                //PEER_TO_PEER_WITH_METADATA
                print("15")
                if model.transaction_type == 0 {
                    // 转账
                    amountLabel.textColor = UIColor.init(hex: "13B788")
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    addressLabel.text = model.receiver
                } else {
                    // 收款
                    amountLabel.textColor = UIColor.init(hex: "E54040")
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    addressLabel.text = model.sender
                }
            case 16:
                //PREBURN
                print("16")
            case 17:
                //PUBLISH_SHARED_ED25519_PUBLIC_KEY
                print("17")
            case 18:
                //REGISTER_PREBURNER
                print("18")
            case 19:
                //REGISTER_VALIDATOR
                print("19")
            case 20:
                //REMOVE_ASSOCIATION_PRIVILEGE
                print("20")
            case 21:
                //REMOVE_VALIDATOR
                print("21")
            case 22:
                //ROTATE_AUTHENTICATION_KEY
                print("22")
            case 23:
                //ROTATE_AUTHENTICATION_KEY_WITH_NONCE
                print("23")
            case 24:
                //ROTATE_BASE_URL
                print("24")
            case 25:
                //ROTATE_COMPLIANCE_PUBLIC_KEY
                print("25")
            case 26:
                //ROTATE_CONSENSUS_PUBKEY
                print("26")
            case 27:
                //ROTATE_SHARED_ED25519_PUBLIC_KEY
                print("27")
            case 28:
                //ROTATE_VALIDATOR_CONFIG
                print("28")
            case 29:
                //TIERED_MINT
                print("29")
            case 30:
                //UNFREEZE_ACCOUNT
                print("30")
            case 31:
                //UNMINT_LBR
                print("31")
            case 32:
                //UPDATE_EXCHANGE_RATE
                print("32")
            case 33:
                //UPDATE_LIBRA_VERSION
                print("33")
            case 34:
                //UPDATE_MINTING_ABILITY
                print("34")
            case 97:
                //CHANGE_SET
                print("97")
            case 98:
                //BLOCK_METADATA
                print("98")
            case 100:
                //UNKNOWN
                print("100")
            default:
                print("others")
            }
        }
    }
    var libraModel: LibraDataModel? {
        didSet {
            guard let model = libraModel else {
                return
            }
            dateLabel.text = timestampToDateString(timestamp: model.expiration_time ?? 0, dateFormat: "yyyy-MM-dd HH:mm:ss")
            amountLabel.text = getDecimalNumberAmount(amount: NSDecimalNumber.init(value: (model.amount ?? 0)),
                                                      scale: 4,
                                                      unit: 1000000)
            switch model.type {
            case 0:
                //ADD_CURRENCY_TO_ACCOUNT
                print("0")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                
            case 1:
                //ADD_VALIDATOR
                print("1")
            case 2:
                //BURN
                print("2")
            case 3:
                //BURN_TXN_FEES
                print("3")
            case 4:
                //CANCEL_BURN
                print("4")
            case 5:
                //CREATE_CHILD_VASP_ACCOUNT
                print("5")
            case 6:
                //CREATE_DESIGNATED_DEALER
                print("6")
            case 7:
                //CREATE_PARENT_VASP_ACCOUNT
                print("7")
            case 8:
                //CREATE_VALIDATOR_ACCOUNT
                print("8")
            case 9:
                //EMPTY_SCRIPT
                print("9")
            case 10:
                //FREEZE_ACCOUNT
                print("10")
            case 11:
                // MINT_LBR
                print("11")
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            case 12:
                //MINT_LBR_TO_ADDRESS
                print("12")
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            case 13:
                //MINT
                print("13")
                amountLabel.textColor = UIColor.init(hex: "FB8F0B")
                transactionTypeImageView.image = UIImage.init(named: "mint_sign")
                addressLabel.text = model.sender
            case 14:
                //MODIFY_PUBLISHING_OPTION
                print("14")
            case 15:
                //PEER_TO_PEER_WITH_METADATA
                print("15")
                if model.transaction_type == 0 {
                    // 转账
                    amountLabel.textColor = UIColor.init(hex: "13B788")
                    transactionTypeImageView.image = UIImage.init(named: "transfer_sign")
                    addressLabel.text = model.receiver
                } else {
                    // 收款
                    amountLabel.textColor = UIColor.init(hex: "E54040")
                    transactionTypeImageView.image = UIImage.init(named: "receive_sign")
                    addressLabel.text = model.sender
                }
            case 16:
                //PREBURN
                print("16")
            case 17:
                //PUBLISH_SHARED_ED25519_PUBLIC_KEY
                print("17")
            case 18:
                //REGISTER_PREBURNER
                print("18")
            case 19:
                //REGISTER_VALIDATOR
                print("19")
            case 20:
                //REMOVE_ASSOCIATION_PRIVILEGE
                print("20")
            case 21:
                //REMOVE_VALIDATOR
                print("21")
            case 22:
                //ROTATE_AUTHENTICATION_KEY
                print("22")
            case 23:
                //ROTATE_AUTHENTICATION_KEY_WITH_NONCE
                print("23")
            case 24:
                //ROTATE_BASE_URL
                print("24")
            case 25:
                //ROTATE_COMPLIANCE_PUBLIC_KEY
                print("25")
            case 26:
                //ROTATE_CONSENSUS_PUBKEY
                print("26")
            case 27:
                //ROTATE_SHARED_ED25519_PUBLIC_KEY
                print("27")
            case 28:
                //ROTATE_VALIDATOR_CONFIG
                print("28")
            case 29:
                //TIERED_MINT
                print("29")
            case 30:
                //UNFREEZE_ACCOUNT
                print("30")
            case 31:
                //UNMINT_LBR
                print("31")
            case 32:
                //UPDATE_EXCHANGE_RATE
                print("32")
            case 33:
                //UPDATE_LIBRA_VERSION
                print("33")
            case 34:
                //UPDATE_MINTING_ABILITY
                print("34")
            case 97:
                //CHANGE_SET
                print("97")
            case 98:
                //BLOCK_METADATA
                print("98")
            case 100:
                //UNKNOWN
                print("100")
            default:
                print("others")
            }
        }
    }
}
//ADD_CURRENCY_TO_ACCOUNT = 0
//ADD_VALIDATOR = 1
//BURN = 2
//BURN_TXN_FEES = 3
//CANCEL_BURN = 4
//CREATE_CHILD_VASP_ACCOUNT = 5
//CREATE_DESIGNATED_DEALER = 6
//CREATE_PARENT_VASP_ACCOUNT = 7
//CREATE_VALIDATOR_ACCOUNT = 8
//EMPTY_SCRIPT = 9
//FREEZE_ACCOUNT = 10
//MINT_LBR = 11
//MINT_LBR_TO_ADDRESS = 12
//MINT = 13
//MODIFY_PUBLISHING_OPTION = 14
//PEER_TO_PEER_WITH_METADATA = 15
//PREBURN = 16
//PUBLISH_SHARED_ED25519_PUBLIC_KEY = 17
//REGISTER_PREBURNER = 18
//REGISTER_VALIDATOR = 19
//REMOVE_ASSOCIATION_PRIVILEGE = 20
//REMOVE_VALIDATOR = 21
//ROTATE_AUTHENTICATION_KEY = 22
//ROTATE_AUTHENTICATION_KEY_WITH_NONCE = 23
//ROTATE_BASE_URL = 24
//ROTATE_COMPLIANCE_PUBLIC_KEY = 25
//ROTATE_CONSENSUS_PUBKEY = 26
//ROTATE_SHARED_ED25519_PUBLIC_KEY = 27
//ROTATE_VALIDATOR_CONFIG = 28
//TIERED_MINT = 29
//UNFREEZE_ACCOUNT = 30
//UNMINT_LBR = 31
//UPDATE_EXCHANGE_RATE = 32
//UPDATE_LIBRA_VERSION = 33
//UPDATE_MINTING_ABILITY = 34
//CHANGE_SET = 97
//BLOCK_METADATA = 98
//UNKNOWN = 100
//switch model.type {
//case 0:
//    //ADD_CURRENCY_TO_ACCOUNT
//    print("0")
//case 1:
//    //ADD_VALIDATOR
//    print("1")
//case 2:
//    //BURN
//    print("2")
//case 3:
//    //BURN_TXN_FEES
//    print("3")
//case 4:
//    //CANCEL_BURN
//    print("4")
//case 5:
//    //CREATE_CHILD_VASP_ACCOUNT
//    print("5")
//case 6:
//    //CREATE_DESIGNATED_DEALER
//    print("6")
//case 7:
//    //CREATE_PARENT_VASP_ACCOUNT
//    print("7")
//case 8:
//    //CREATE_VALIDATOR_ACCOUNT
//    print("8")
//case 9:
//    //EMPTY_SCRIPT
//    print("9")
//case 10:
//    //FREEZE_ACCOUNT
//    print("10")
//case 11:
//    // MINT_LBR
//    print("11")
//case 12:
//    //MINT_LBR_TO_ADDRESS
//    print("12")
//case 13:
//    //MINT
//    print("13")
//case 14:
//    //MODIFY_PUBLISHING_OPTION
//    print("14")
//case 15:
//    //PEER_TO_PEER_WITH_METADATA
//    print("15")
//case 16:
//    //PREBURN
//    print("16")
//case 17:
//    //PUBLISH_SHARED_ED25519_PUBLIC_KEY
//    print("17")
//case 18:
//    //REGISTER_PREBURNER
//    print("18")
//case 19:
//    //REGISTER_VALIDATOR
//    print("19")
//case 20:
//    //REMOVE_ASSOCIATION_PRIVILEGE
//    print("20")
//case 21:
//    //REMOVE_VALIDATOR
//    print("21")
//case 22:
//    //ROTATE_AUTHENTICATION_KEY
//    print("22")
//case 23:
//    //ROTATE_AUTHENTICATION_KEY_WITH_NONCE
//    print("23")
//case 24:
//    //ROTATE_BASE_URL
//    print("24")
//case 25:
//    //ROTATE_COMPLIANCE_PUBLIC_KEY
//    print("25")
//case 26:
//    //ROTATE_CONSENSUS_PUBKEY
//    print("26")
//case 27:
//    //ROTATE_SHARED_ED25519_PUBLIC_KEY
//    print("27")
//case 28:
//    //ROTATE_VALIDATOR_CONFIG
//    print("28")
//case 29:
//    //TIERED_MINT
//    print("29")
//case 30:
//    //UNFREEZE_ACCOUNT
//    print("30")
//case 31:
//    //UNMINT_LBR
//    print("31")
//case 32:
//    //UPDATE_EXCHANGE_RATE
//    print("32")
//case 33:
//    //UPDATE_LIBRA_VERSION
//    print("33")
//case 34:
//    //UPDATE_MINTING_ABILITY
//    print("34")
//case 97:
//    //CHANGE_SET
//    print("97")
//case 98:
//    //BLOCK_METADATA
//    print("98")
//case 100:
//    //UNKNOWN
//    print("100")
//default:
//    print("others")
//}
