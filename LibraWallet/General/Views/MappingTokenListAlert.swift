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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(data: [MarketSupportTokensDataModel], successClosure: @escaping successClosure) {
        self.init(frame: CGRect.zero)
        self.actionClosure = successClosure
        self.dataModels = data
        self.originModels = data
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    deinit {
        print("MappingTokenListAlert销毁了")
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(319)
            make.bottom.equalTo(self).offset(319).priority(250)
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
            make.bottom.equalTo(whiteBackgroundView).offset(-34)
        }
    }
    //MARK: - 懒加载对象
    //懒加载子View
    lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        return view
    }()
    lazy var tap: UIGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
//        tapGesture.delegate = self
        return tapGesture
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
        bar.keyboardType = .alphabet
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
    typealias successClosure = (MarketSupportTokensDataModel) -> Void
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
    var originModels: [MarketSupportTokensDataModel]?
    
    var pickerRow: Int?
    //MARK:键盘通知相关操作
    @objc func keyBoardWillShow(_ notification:Notification){

        DispatchQueue.main.async {

            let user_info = notification.userInfo
            let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(-(keyboardRect.size.height))
                    make.left.right.equalTo(self)
                    make.height.equalTo(319)
                }
                self.layoutIfNeeded()
                
            })
        }
    }
    @objc func keyBoardWillHide(_ notification:Notification){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom)
                    make.left.right.equalTo(self)
                    make.height.equalTo(319)
                }
                self.layoutIfNeeded()
            })
        }
    }
    @objc internal func tapRecognized(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == .ended {
            //Resigning currently responder textField.
            self.searchBar.resignFirstResponder()
        }
    }
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
            if let oldCell = tableView.cellForRow(at: tempIndexPath) as? TokenListCell {
                oldCell.showSelectState = false
                indexPaths.append(tempIndexPath)
            }
        }
        let cell = tableView.cellForRow(at: indexPath) as! TokenListCell
        cell.showSelectState = true
        indexPaths.append(indexPath)
        pickerRow = indexPath.row
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        tableView.endUpdates()
        //        self.delegate?.tableViewDidSelectRowAtIndexPath(indexPath: indexPath, model: model[indexPath.row])
        if let action = self.actionClosure {
            action(model[indexPath.row])
            self.hideAnimation(tag: 199)
        }
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        let tempModel = self.dataModels?.filter({
            $0.show_name?.lowercased().contains(searchText.lowercased()) == true
        })
        if searchText.isEmpty == true {
            self.dataModels = self.originModels
        } else {
            self.dataModels = tempModel
        }
        self.tableView.reloadData()
    }
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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TokenListCell销毁了")
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
            if let iconName = model?.icon, iconName.isEmpty == false {
                let url = URL(string: iconName)
                transactionTypeImageView.kf.setImage(with: url, placeholder: UIImage.init(named: "wallet_icon_default"))
            }
            var unit = 1000000
            if model?.chainType == 2 {
                unit = 100000000
            }
            amountLabel.text = localLanguage(keyString: "wallet_transfer_balance_title") + getDecimalNumberAmount(amount: NSDecimalNumber.init(value: model?.amount ?? 0),
                                                                                                                  scale: 6,
                                                                                                                  unit: unit)
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
}
extension MappingTokenListAlert: actionViewAnimationProtocol {
    func showAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(0);
                    make.left.right.equalTo(self)
                    make.height.equalTo(319)
                }
                self.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    func hideAnimation(tag: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self).offset(319);
                    make.left.right.equalTo(self)
                    make.height.equalTo(319)
                }
                self.layoutIfNeeded()
            }, completion: { (status) in
                self.hide(tag: tag)
            })
        }
    }
}
