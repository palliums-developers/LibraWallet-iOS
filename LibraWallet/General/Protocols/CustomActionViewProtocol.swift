//
//  CustomActionViewProtocol.swift
//  DingDing
//
//  Created by 王英东 on 2018/5/25.
//  Copyright © 2018年 王英东. All rights reserved.
//

import Foundation
import UIKit
protocol actionViewProtocol {
    func show(tag: Int)
    func hide(tag: Int)
}
extension actionViewProtocol where Self: UIView {
    func show(tag: Int) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            self.frame = window.frame
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame.size = CGSize(width: window.frame.size.width, height: window.frame.size.height)
            blurView.center = window.center
            blurView.alpha = 0.2
            blurView.tag = tag + 1
            blurView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init()
//            tap.addTarget(self, action: #selector(self.hideActionView))
            blurView.addGestureRecognizer(tap)
            self.insertSubview(blurView, at: 0)
            self.tag = tag
            window.addSubview(self)
        }
    }
    func hide(tag: Int) {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            for views in window.subviews {
                if views.tag == self.tag {
                    views.viewWithTag(tag + 1)?.removeFromSuperview()
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
protocol actionViewAnimationProtocol {
    func showAnimation()
    func hideAnimation(tag: Int)
}
