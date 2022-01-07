//
//  WYDDropper.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2021/1/13.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit

struct DropperData {
    var title: String
    var icon: String
}
class WYDDropper: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(whiteBackgroundView)
//        whiteBackgroundView.
        addSubview(tableView)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        self.tag = 20200115
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(data: [DropperData], button: UIButton, successClosure: @escaping successClosure) {
        self.init(frame: CGRect.zero)
        self.actionClosure = successClosure
        self.dataModels = data
        self.originButton = button
        let tempRect = button.convert(button.frame, to: window)
        self.buttonFrame = tempRect
    }
    deinit {
        print("WYDDropper销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
//        whiteBackgroundView.snp.makeConstraints { (make) in
//            make.top.bottom.left.right.equalTo(self)
//        }
        tableView.snp.makeConstraints { (make) in
            make.right.equalTo(self.originButton!.snp.centerX)
            make.top.equalTo(self.originButton!.snp.bottom).offset(10)
            make.height.equalTo(90)
            let width = filterWidth(data: self.dataModels ?? [DropperData]())
            make.width.equalTo(width)
        }
    }
    //MARK: - 懒加载对象
    //懒加载子View
//    lazy var whiteBackgroundView: UIView = {
//        let view = UIView.init()
//        view.backgroundColor = UIColor.clear
//        return view
//    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        tableView.backgroundColor = UIColor.white
        tableView.register(OrderStatusCell.classForCoder(), forCellReuseIdentifier: "NormalCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.alpha = 1
        tableView.tag = self.tag + 1
        tableView.layer.cornerRadius = 4
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
    typealias successClosure = (DropperData, Int) -> Void
    var actionClosure: successClosure?
    var dataModels: [DropperData]?
    var showLeft: Bool = true
    var pickerRow: Int?
    private func filterWidth(data: [DropperData]) -> CGFloat {
        let tempData = data.sorted {
            libraWalletTool.ga_widthForComment(content: $0.title, fontSize: 14, height: 20) > libraWalletTool.ga_widthForComment(content: $1.title, fontSize: 14, height: 20)
        }
        let tempLength = libraWalletTool.ga_widthForComment(content: tempData.first?.title ?? "", fontSize: 14, height: 20)
        let length = tempLength > 56 ? tempLength:56
        return 17 + 18 + 3 + length + 17
    }
    private var buttonFrame: CGRect?
    private var originButton: UIButton? {
        didSet {
            if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                self.frame = window.frame
                
            }
        }
    }
}
extension WYDDropper {
    func show() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            self.frame = window.frame
//            self.insertSubview(blurView, at: 0)
//            self.tag = 89899
            window.addSubview(self)
            self.showAnimation()
        }
    }
    private func hide() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            for views in window.subviews {
                if views.tag == 20200115 {
                    views.viewWithTag(20200115 + 1)?.removeFromSuperview()
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
extension WYDDropper: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = self.dataModels else {
            return
        }
        if let action = self.actionClosure {
            action(model[indexPath.row], indexPath.row)
        }
        self.hideAnimation()
    }
}
extension WYDDropper: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NormalCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WYDDropperCell {
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = WYDDropperCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            if let data = dataModels, data.isEmpty == false {
                cell.model = data[indexPath.row]
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}
class WYDDropperCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(indicatorImageView)
        contentView.addSubview(contentLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("WYDDropperCell销毁了")
    }
    //pragma MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(17)
            make.size.equalTo(CGSize.init(width: 18, height: 15))
        }
        contentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(indicatorImageView.snp.right).offset(3)
            make.right.equalTo(contentView.snp.right)
        }
    }
    // MARK: - 懒加载对象
    private lazy var indicatorImageView : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        label.textColor = UIColor.init(hex: "333333")
        label.font = UIFont.systemFont(ofSize: adaptFont(fontSize: 14), weight: UIFont.Weight.regular)
        label.text = "---"
        return label
    }()
    //MARK: - 设置数据
    var indexPath: IndexPath?
    var model: DropperData? {
        didSet {
            indicatorImageView.image = UIImage.init(named: model?.icon ?? "wallet_icon_default")
            contentLabel.text = model?.title
        }
    }
}
extension WYDDropper {
    func showAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
//                self.whiteBackgroundView.snp.remakeConstraints { (make) in
//                    make.top.equalTo(self).offset(navigationBarHeight + 24 + 5).priority(250)
//                    if let models = self.dataModels, models.isEmpty == false {
//                        let height = models.count > 5 ? (5 * 36):(models.count * 36)
//                        make.height.equalTo(height).priority(250)
//                    } else {
//                        make.height.equalTo(50).priority(250)
//                    }
//                    make.left.right.equalTo(self)
//                }
                self.tableView.alpha = 1
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func hideAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
//                self.whiteBackgroundView.snp.remakeConstraints { (make) in
//                    make.top.equalTo(self).offset(navigationBarHeight + 24 + 5).priority(250)
//                    make.height.equalTo(0).priority(250)
//                    make.left.right.equalTo(self)
//                }
                self.tableView.alpha = 0
                self.layoutIfNeeded()
            }, completion: { (status) in
                self.hide()
                print(status)
            })
        }
    }
}
