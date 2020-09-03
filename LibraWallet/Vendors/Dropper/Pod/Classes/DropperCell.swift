//
//  DropdownCell.swift
//  Pods
//
//  Created by Ozzie Kirkby on 2015-10-10.
//
//

import UIKit

internal class DropperCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, cellType: Options? = .text) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        //        switch cellType {
        //        case .icon:
        //            contentView.addSubview(imageItem)
        //        case .text:
        //            contentView.addSubview(textItem)
        //        case .none:
        //            print("none")
        //        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("PopMenuTableViewCell销毁了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        switch cellType {
        case .icon:
            let height = self.frame.size.height - 20
            imageItem.frame = CGRect(x: 0, y: (self.frame.height - height)/2, width: self.frame.width, height: height)
            contentView.addSubview(imageItem)
        case .text:
            contentView.addSubview(textItem)
            let leftContraint = NSLayoutConstraint.init(item: textItem,
                                                        attribute: .left,
                                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                                        toItem: contentView,
                                                        attribute: NSLayoutConstraint.Attribute.left,
                                                        multiplier: 1,
                                                        constant: 6)
            let rightContraint = NSLayoutConstraint.init(item: textItem,
                                                         attribute: .right,
                                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                                         toItem: contentView,
                                                         attribute: NSLayoutConstraint.Attribute.right,
                                                         multiplier: 1,
                                                         constant: -6)
            let topContraint = NSLayoutConstraint.init(item: textItem,
                                                       attribute: .top,
                                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                                       toItem: contentView,
                                                       attribute: NSLayoutConstraint.Attribute.top,
                                                       multiplier: 1,
                                                       constant: 5)
            let bottomContraint = NSLayoutConstraint.init(item: textItem,
                                                          attribute: .bottom,
                                                          relatedBy: NSLayoutConstraint.Relation.equal,
                                                          toItem: contentView,
                                                          attribute: NSLayoutConstraint.Attribute.bottom,
                                                          multiplier: 1,
                                                          constant: -5)
            textItem.superview?.addConstraints([leftContraint, rightContraint, topContraint, bottomContraint])
            
        }
        addBottomBorder()
    }
    fileprivate func addBottomBorder() {
        if let index = indexPath, let lastItem = last {
            if ((index as NSIndexPath).row != lastItem) {
                seperator.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
                seperator.backgroundColor = borderColor ?? UIColor.black
                addSubview(seperator)
            }
        }
    }
    /// Text item
    lazy var textItem: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 12
        return label
    }()
    /// Cell Image View
    lazy var imageItem: UIImageView = {
        let height = self.frame.size.height - 20
        let view = UIImageView.init()
        view.contentMode = UIView.ContentMode.scaleAspectFit
        return view
    }()
    /// Seperator of cells
    fileprivate lazy var seperator: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = DefaultSpaceColor
        return label
    }()
    /// Default Select Cell
    var selectMode: Bool? {
        didSet {
            guard let mode = selectMode else {
                return
            }
            if mode == true {
                textItem.layer.backgroundColor = UIColor.white.cgColor
            } else {
                textItem.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
    }
    var hideSpcaeLineState: Bool? {
        didSet {
            if hideSpcaeLineState == true {
                seperator.alpha = 0
            } else {
                seperator.alpha = 1
            }
        }
    }

    /// Cell Type Options
    enum Options {
        /// Cell contains a UIImage
        case icon
        /// Cell contains text
        case text
    }
    /// Default Cell type
    var cellType: Options = .text
    /// Last Item in array (Helps to determine weather or not to add another line)
    var last: Int?
    /// Index path of current cellForRow
    var indexPath: IndexPath?
    /// Border Color of custom Border
    var borderColor: UIColor?
    //    //MARK: - 设置数据
//    var cellConfig: CellConfig? {
//        didSet {
//            guard let config = cellConfig else {
//                return
//            }
//            textItem.font = config.textFont ?? UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
//            textItem.textColor = config.textColor ?? UIColor.black
//            seperator.alpha = config.showSeperator == true ? 1:0
//            contentView.backgroundColor = config.backgroundColor ?? UIColor.clear
//        }
//    }
}
