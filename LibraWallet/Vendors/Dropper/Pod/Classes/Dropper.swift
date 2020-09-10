//
//  Dropdown.swift
//  SwiftyDropdown
//
//  Created by Ozzie Kirkby on 2015-09-26.
//  Copyright © 2015 kirkbyo. All rights reserved.
//

import UIKit

open class Dropper: UIView {
    
    /// Alignment of the dropdown menu compared to the button
    public enum Alignment {
        /// Dropdown is aligned to the left side the corresponding button
        case left
        /// Dropdown is aligned to the center of the corresponding button
        case center
        /// Dropdown is aligned to the right of the corresponding button
        case right
    }
    
    /// Position of the dropdown, relative to the top or bottom of the button
    public enum Position {
        /// Displayed on the top of the dropdown
        case top
        /// Displayed on bottom of the dropdown
        case bottom
    }
    
    /// The current status of the dropdowns state
    public enum Status {
        /// The dropdown is visible on screen
        case displayed
        /// The dropdwon is hidden or offscreen.
        case hidden
        /// The dropdown is visible on screen
        case shown
    }
    
    /// Default themes for dropdown menu
    public enum Themes {
        /// Black theme for dropdown. Black background, white text
        case black(UIColor?)
        /// White theme for dropdown. White background, black text
        case white
    }
    
    // MARK: - Public Properties
    /// Automaticly applies border radius of 10 to Dropdown
    open var trimCorners: Bool = false
    /// The default time for animations to take
    open var defaultAnimationTime: TimeInterval = 0.1
    /// Delegate Property
    open var delegate: DropperDelegate?
    /// The current state of the view
    open var status: Status = .hidden
    /// The distance from the button to the dropdown
    open var spacing: CGFloat = 10
    /// The maximum possible height of the dropdown
    open var maxHeight: CGFloat?
    /// Sets the cell background color
    open var cellBackgroundColor: UIColor?
    /// Sets the cell tint color and text color
    open var cellColor: UIColor?
    open var cellTextSize: CGFloat? {
        get {
            return cellTextFont?.pointSize
        }
        set {
            if let newValue = newValue {
                cellTextFont = UIFont.systemFont(ofSize: newValue)
            }else{
                cellTextFont = nil
            }
        }
    }
    /// Sets the size of the text to provided value
    open var cellTextFont: UIFont?
    
    // MARK: - Public Computed Properties
    /// The items to be dispalyed in the tableview
    open var items = [String]() {
        didSet {
            refreshHeight()
        }
    }
    
    /// Height of the Dropdown
    open var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    
    /// Width of the Dropdown
    open var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    
    /// Corner Radius of the Dropdown
    open var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set {
            TableMenu.layer.cornerRadius = newValue
            TableMenu.clipsToBounds = true
        }
    }
    
    /// Theme of dropdown menu (Defaults to White theme)
    open var theme: Themes = .white {
        didSet {
            switch theme {
            case .white:
                cellColor = UIColor.black
                cellBackgroundColor = UIColor.white
                border = (1, UIColor.black)
            case .black(let backgroundColor):
                let defaultColor = UIColor(red:0.149,  green:0.149,  blue:0.149, alpha:1)
                cellBackgroundColor = backgroundColor ?? defaultColor
                cellColor = UIColor.white
                border = (1, backgroundColor ?? defaultColor)
            }
        }
    }
    
    /**
     Dropdown border styling
     
     - (width: CGFloat) Border Width
     - (color: UIColor) Color of Border
     
     */
    open var border: (width: CGFloat, color: UIColor) {
        get { return (TableMenu.layer.borderWidth, UIColor(cgColor: TableMenu.layer.borderColor!)) }
        set {
            let (borderWidth, borderColor) = newValue
            TableMenu.layer.borderWidth = borderWidth
            TableMenu.layer.borderColor = borderColor.cgColor
        }
    }
    
    // MARK: - Private Computed Properties
    /// Private property used to determine if the user has set a max height or if no max height is provided then make sure its less then the height of the view
    fileprivate var max_Height: CGFloat {
        get {
            if let height = maxHeight { // Determines if max_height is provided
                return height
            }
            
            if let containingView = self.superview { // restrict to containing views height
                return containingView.frame.size.height - self.frame.origin.y
            }
            
            return self.frame.size.height // catch all returns the current height
        }
        set {
            maxHeight = newValue
        }
    }
    
    /// Gets the current root view of where the dropdown is
    fileprivate var root: UIView? {
        guard let current = UIApplication.shared.keyWindow?.subviews.last else {
            print("[Dropper] &Error:100: Could not find current view. Please report this issue @ https://github.com/kirkbyo/Dropper/issues")
            return nil
        }
        return current
    }
    
    // MARK: - Layout & Setup
    override open func layoutSubviews() {
        super.layoutSubviews()
        // Size of table menu
        TableMenu.frame.size.height = self.frame.size.height + 0.1
        TableMenu.frame.size.width = self.frame.size.width + 0.1
        
    }

    // MARK: - Private Properties
    /// Defines if the view has been shown yet
    fileprivate var shown: Status = .hidden
    
    // MARK: - Init
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        TableMenu.rowHeight = 34
        TableMenu.layer.borderColor = UIColor.lightGray.cgColor
        TableMenu.layer.borderWidth = 1
        self.superview?.addSubview(self)
        
        self.tag = 2038 // Year + Month + Day of Birthday. Used to distinguish the dropper from the rest of the views
    }
    
    convenience public init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: - API
    
    /// Displays the dropdown
    /// - Parameters:
    ///   - options: Vertical alignment of the dropdown corresponding of the button
    ///   - position: Horizontal alignment of the dropdown. Defaults to bottom.
    ///   - button: Button to which the dropdown will be aligned to
    open func show(_ options: Alignment, position: Position = .bottom, button: UIButton) {
        refreshHeight()
        
        switch options { // Aligns the view vertically to the button
        case .left:
            self.frame.origin.x = button.frame.origin.x
        case .right:
            self.frame.origin.x = button.frame.origin.x + button.frame.width
        case .center:
            self.frame.origin.x = button.frame.origin.x + (button.frame.width - self.frame.width)/2
        }
        
        switch position { // Aligns the view Horizontally to the button
        case .top:
            self.frame.origin.y = button.frame.origin.y - height - spacing
        case .bottom:
            self.frame.origin.y = button.frame.origin.y + button.frame.height + spacing
        }
        
        if (!self.isHidden) {
            self.addSubview(TableMenu)
            if let buttonRoot = findButtonFromSubviews((button.superview?.subviews)!, button: button) {
                buttonRoot.superview?.addSubview(self)
            } else {
                if let rootView = root {
                    rootView.addSubview(self)
                }
            }
        } else {
            self.TableMenu.isHidden = false
            self.isHidden = false
        }
        status = .displayed
    }
    
    /// Displays the dropdown with fade in type of aniamtion
    /// - Parameters:
    ///   - time: Time taken for the fade animation
    ///   - options: Position of the dropdown corresponding of the button
    ///   - position: Horizontal alignment of the dropdown. Defaults to bottom.
    ///   - button: Button to which the dropdown will be aligned to
    open func showWithAnimation(_ time: TimeInterval, options: Alignment, position: Position = .bottom, button: UIButton) {
        if (self.isHidden) {
            refresh()
            height = self.TableMenu.frame.height
        }
        
        self.TableMenu.alpha = 0.0
        self.show(options, position:  position, button: button)
        UIView.animate(withDuration: time, animations: {
            self.TableMenu.alpha = 1.0
        })
    }
    
    /// Hides the dropdown from the view
    open func hide() {
        status = .hidden
        self.isHidden = true
        if shown == .hidden {
            shown = .shown
        }
    }
    
    /// Fades out and hides the dropdown from the view
    /// - Parameter time: Time taken to fade out the dropdown
    open func hideWithAnimation(_ time: TimeInterval) {
        UIView.animate(withDuration: time, delay: 0.0, options: .curveEaseOut, animations: {
            self.TableMenu.alpha = 0.0
        }, completion: { finished in
            self.hide()
        })
    }
    
    /// Refresh the Tablemenu. For specifically calling .reloadData() on the TableView
    open func refresh() {
        TableMenu.reloadData()
    }

    /// Refreshes the table view height
    fileprivate func refreshHeight() {
        // Updates the height of the view depending on the amount of item
        let tempHeight: CGFloat = CGFloat(items.count) * TableMenu.rowHeight // Height of TableView
        if (tempHeight <= max_Height) { // Determines if tempHeight is greater then max height
            height = tempHeight
        } else {
            height = max_Height
        }
    }

    /// Find corresponding button to which the dropdown is aligned too
    /// - Parameters:
    ///   - subviews: All subviews of where the button is.
    ///   - button: Button to find
    /// - Returns: Found button or nil
    fileprivate func findButtonFromSubviews(_ subviews: [UIView], button: UIButton) -> UIView? {
        for subview in subviews {
            if (subview is UIButton && subview == button) {
                return button
            }
        }
        return nil
    }
    var defaultSelectRow: Int?
    lazy var TableMenu: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        tableView.register(DropperCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.lightGray
        tableView.bounces = false
        if (trimCorners) {
            tableView.layer.cornerRadius = 9.0
            tableView.clipsToBounds = true
        }
        return tableView
    }()
    private lazy var invisableBackgroundView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        return view
    }()
    var cellConfig: DropperCellConfig?

}

extension Dropper: UITableViewDelegate, DropperExtentsions {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.DropperSelectedRow(indexPath, contents: items[indexPath.row])
        delegate?.DropperSelectedRow(indexPath, contents: items[indexPath.row], tag: self.tag)
        self.hideWithAnimation(defaultAnimationTime)
    }
}
extension Dropper: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DropperCell {
            // Sets up Cell
            // Removes image and text just in case the cell still contains the view
            cell.imageItem.removeFromSuperview()
            cell.textItem.removeFromSuperview()
            cell.last = items.count - 1  // Sets the last item to the cell
            cell.indexPath = indexPath // Sets index path to the cell
            cell.borderColor = border.color // Sets the border color for the seperator
            let item = items[indexPath.row]
            
            if let color = cellBackgroundColor {
                cell.backgroundColor = color
            }
            
            if let color = cellColor {
                cell.textItem.textColor = color
                cell.imageItem.tintColor = color
            }
            
            if let font = cellTextFont {
                cell.textItem.font = font
            }
            if let image = toImage(item) { // Determines if item is an image or not
                //                cell.cellType = .icon
                cell.imageItem.image = image
            } else {
                //                cell.cellType = .text
                cell.textItem.text = item
            }
            if let selectRow = defaultSelectRow, indexPath.row == selectRow {
                cell.selectMode = true
            } else {
                cell.selectMode = false
            }
            cell.cellConfig = self.cellConfig
            return cell
        } else {
            let cell = DropperCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell", cellType: toImage(items[indexPath.row]) == nil ? .text:.icon)
            // Removes image and text just in case the cell still contains the view
            cell.imageItem.removeFromSuperview()
            cell.textItem.removeFromSuperview()
            cell.last = items.count - 1  // Sets the last item to the cell
            cell.indexPath = indexPath // Sets index path to the cell
            cell.borderColor = border.color // Sets the border color for the seperator
            let item = items[(indexPath as NSIndexPath).row]
            
            if let color = cellBackgroundColor {
                cell.backgroundColor = color
            }
            
            if let color = cellColor {
                cell.textItem.textColor = color
                cell.imageItem.tintColor = color
            }
            
            if let font = cellTextFont {
                cell.textItem.font = font
            }
            if let image = toImage(item) { // Determines if item is an image or not
                //                cell.cellType = .icon
                cell.imageItem.image = image
            } else {
                //                cell.cellType = .text
                cell.textItem.text = item
            }
            cell.cellConfig = self.cellConfig
            return cell
        }
    }
    
}
