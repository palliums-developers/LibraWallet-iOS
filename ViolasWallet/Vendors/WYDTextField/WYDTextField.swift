//
//  WYDTextField.swift
//  ViolasWallet
//
//  Created by wangyingdong on 2019/12/30.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class WYDTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 禁用粘贴功能
        if action == #selector(paste(_:)) {
            return false
        }
        // 禁用选择功能
        if action == #selector(select(_:)) {
            return false;
        }
        // 禁用全选功能
        if action == #selector(selectAll(_:)) {
            return false;
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
