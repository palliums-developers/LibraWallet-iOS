//
//  MappingTokenListAlert.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/2/18.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class MappingTokenListAlert: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(searchBar)
        whiteBackgroundView.addSubview(tableView)
//        whiteBackgroundView.addSubview(pickerView)
//
//        whiteBackgroundView.addSubview(cancelButton)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(data: [MarketSupportTokensDataModel], successClosure: @escaping successClosure) {
        self.init(frame: CGRect.zero)
        self.actionClosure = successClosure
        self.dataModels = data
    }
    deinit {
        print("MappingTokenListAlert销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(500)
            make.bottom.equalTo(self).offset(500).priority(250)
        }
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView).offset(18)
            make.left.equalTo(whiteBackgroundView).offset(15)
            make.right.equalTo(whiteBackgroundView.snp.right).offset(-15)
            make.height.equalTo(30)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(whiteBackgroundView)
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
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar.init()
        bar.placeholder = localLanguage(keyString: "搜索Token")
//        bar.backgroundColor = UIColor.red//UIColor.init(hex: "F8F8F8")
        bar.tintColor = DefaultGreenColor
        bar.backgroundImage = UIImage().imageWithColor(color: UIColor.init(hex: "F8F8F8"))
        bar.searchBarStyle = .minimal
        bar.setSearchFieldBackgroundImage(UIImage().imageWithColor(color: UIColor.init(hex: "F8F8F8"), width: mainWidth - 30, height: 30), for: UIControl.State.normal)
        bar.delegate = self
        bar.isUserInteractionEnabled = false
        return bar
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        tableView.backgroundColor = UIColor.clear
        tableView.register(TokenListCell.classForCoder(), forCellReuseIdentifier: "NormalCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    typealias successClosure = (TokenMappingListDataModel) -> Void
    var actionClosure: successClosure?
//    @objc func buttonClick(button: UIButton) {
//        guard let model = dataModels?[pickerRow] else {
//            self.hideAnimation(tag: 99)
//            return
//        }
//        if let action = self.actionClosure {
//            action(model)
//        }
//        self.hideAnimation(tag: 99)
//    }
    var dataModels: [MarketSupportTokensDataModel]?
    var pickerRow: Int?
}
extension MappingTokenListAlert: actionViewProtocol {
    
}
extension MappingTokenListAlert: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        var indexPaths = [IndexPath]()
        if let selectRow = pickerRow {
            let tempIndexPath = IndexPath.init(row: selectRow, section: 0)
            let cell = tableView.cellForRow(at: tempIndexPath) as! TokenListCell
            cell.showSelectState = false
            indexPaths.append(tempIndexPath)
        }
        let cell = tableView.cellForRow(at: indexPath) as! TokenListCell
        cell.showSelectState = true
        indexPaths.append(indexPath)
        pickerRow = indexPath.row
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        tableView.endUpdates()
//        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
    }
}
extension MappingTokenListAlert: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let identifier = "NormalCell"
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TokenListCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
                cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            }
            if let selectRow = pickerRow, selectRow == indexPath.row {
                cell.showSelectState = true
            } else {
                cell.showSelectState = false
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = TokenListCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
                cell.hideSpcaeLineState = (data.count - 1) == indexPath.row ? true:false
            }
            if let selectRow = pickerRow, selectRow == indexPath.row {
                cell.showSelectState = true
            } else {
                cell.showSelectState = false
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
extension MappingTokenListAlert: UISearchBarDelegate {
    
}
class TokenListCell: UITableViewCell {
    //    weak var delegate: AddAssetViewTableViewCellDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        contentView.addSubview(iconImageView)
        contentView.addSubview(transactionTypeImageView)
        contentView.addSubview(tokenNameLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(selectIndicatorImageView)
        contentView.addSubview(spaceLabel)
        // 添加语言变换通知
//        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TokenListCell销毁了")
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        transactionTypeImageView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 44, height: 44))
        }
        tokenNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView).offset(-13)
            make.left.equalTo(transactionTypeImageView.snp.right).offset(10)
        }
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(transactionTypeImageView.snp.right).offset(10)
            make.centerY.equalTo(contentView).offset(13)
        }
        spaceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentView)
            make.left.equalTo(contentView).offset(14)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.height.equalTo(0.5)
        }
        selectIndicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView.snp.right).offset(-15)
        }
    }
    // MARK: - 懒加载对象
    private lazy var transactionTypeImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "wallet_icon_default")
        view.layer.cornerRadius = 22
        view.layer.borderColor = UIColor.init(hex: "E0E0E0").cgColor
        view.layer.borderWidth = 0.5
        view.layer.masksToBounds = true
        return view
    }()
    lazy var tokenNameLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "000000")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "999999")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 12), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    private lazy var selectIndicatorImageView: UIImageView = {
        let view = UIImageView.init()
        view.image = UIImage.init(named: "exchange_token_list_select")
        view.alpha = 0
        return view
    }()
    lazy var spaceLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    //MARK: - 设置数据
    var indexPath: IndexPath?
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                spaceLabel.alpha = 0
            } else {
                spaceLabel.alpha = 1
            }
        }
    }
    var model: MarketSupportTokensDataModel? {
        didSet {
            tokenNameLabel.text = model?.show_name
            
        }
    }
    var showSelectState: Bool? {
        didSet {
            if showSelectState == true {
                selectIndicatorImageView.alpha = 1
            } else {
                selectIndicatorImageView.alpha = 0
            }
        }
    }
    /// 语言切换
    @objc func setText() {
    }
}
extension MappingTokenListAlert: actionViewAnimationProtocol {
    func showAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(0);
                    make.left.right.equalTo(self)
                    make.height.equalTo(500)
                }
                self.layoutIfNeeded()
            })
        }
    }
    func hideAnimation(tag: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(319);
                    make.left.right.equalTo(self)
                    make.height.equalTo(500)
                }
                self.layoutIfNeeded()
            }, completion: { (status) in
                self.hide(tag: tag)
            })
        }
    }
}
