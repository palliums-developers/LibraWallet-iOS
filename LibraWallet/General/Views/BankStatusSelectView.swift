//
//  BankStatusSelectView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/12/30.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

class BankStatusSelectView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(tableView)
        self.addGestureRecognizer(tap)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(data: [String], showLeft: Bool, successClosure: @escaping successClosure) {
        self.init(frame: CGRect.zero)
        self.showLeft = showLeft
        self.actionClosure = successClosure
        self.dataModels = data
    }
    deinit {
        print("MappingTokensAlert销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        whiteBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(navigationBarHeight + 24 + 5).priority(250)
            make.height.equalTo(0).priority(250)
            make.left.right.equalTo(self)

        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(whiteBackgroundView.snp.top)
            if self.showLeft == true {
                make.left.equalTo(whiteBackgroundView)
            } else {
                make.right.equalTo(whiteBackgroundView)
            }
            make.bottom.equalTo(whiteBackgroundView.snp.bottom)
            make.width.equalTo(mainWidth / 2)
        }
    }
    //MARK: - 懒加载对象
    //懒加载子View
    lazy var whiteBackgroundView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        tableView.backgroundColor = UIColor.clear
        tableView.register(OrderStatusCell.classForCoder(), forCellReuseIdentifier: "NormalCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alpha = 0
        return tableView
    }()
    lazy var tap: UIGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        //        tapGesture.delegate = self
        return tapGesture
    }()
    @objc internal func tapRecognized(_ gesture: UITapGestureRecognizer) {
        self.hideAnimation()
    }
    typealias successClosure = (String) -> Void
    var actionClosure: successClosure?
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect.init(x: 0, y: navigationBarHeight + 24 + 5, width: mainWidth, height: mainHeight - navigationBarHeight - 24)
        blurView.alpha = 0
        blurView.tag = 89899 + 1
        blurView.isUserInteractionEnabled = true
        return blurView
    }()
    var dataModels: [String]?
    var showLeft: Bool = true
    var pickerRow: Int?
}
extension BankStatusSelectView {
    func show() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            self.frame = window.frame
            self.insertSubview(blurView, at: 0)
            self.tag = 89899
            window.addSubview(self)
            self.showAnimation()
        }
    }
    private func hide() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            for views in window.subviews {
                if views.tag == 89899 {
                    views.viewWithTag(89899 + 1)?.removeFromSuperview()
                    views.removeFromSuperview()
                }
            }
        } else {
            for views in self.subviews {
                views.removeFromSuperview()
            }
        }
    }
}
extension BankStatusSelectView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        if let action = self.actionClosure {
            action(model[indexPath.row])
        }
//        self.hideAnimation()
    }
}
extension BankStatusSelectView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? OrderStatusCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = OrderStatusCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
class OrderStatusCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(statusLabel)
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
        statusLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(contentView)
        }
    }
    // MARK: - 懒加载对象
    lazy var statusLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.init(hex: "5C5C5C")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var indexPath: IndexPath?
    var model: String? {
        didSet {
            statusLabel.text = model
        }
    }
}
extension BankStatusSelectView {
    func showAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self).offset(navigationBarHeight + 24 + 5).priority(250)
                    if let models = self.dataModels, models.isEmpty == false {
                        let height = models.count > 5 ? (5 * 36):(models.count * 36)
                        make.height.equalTo(height).priority(250)
                    } else {
                        make.height.equalTo(50).priority(250)
                    }
                    make.left.right.equalTo(self)
                }
                self.tableView.alpha = 1
                self.blurView.alpha = 0.6
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func hideAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self).offset(navigationBarHeight + 24 + 5).priority(250)
                    make.height.equalTo(0).priority(250)
                    make.left.right.equalTo(self)
                }
                self.tableView.alpha = 0
                self.blurView.alpha = 0
                self.layoutIfNeeded()
            }, completion: { (status) in
                self.hide()
                print(status)
            })
        }
    }
}
