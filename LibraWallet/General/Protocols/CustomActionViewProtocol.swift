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
            blurView.alpha = 0.3
            
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
            for views in window.subviews{
                views.viewWithTag(tag)?.removeFromSuperview()
            }
        }
        for views in self.subviews{
            views.removeFromSuperview()
        }
    }
}
protocol actionViewAnimationProtocol {
    func showAnimation()
    func hideAnimation(tag: Int)
}
extension actionViewAnimationProtocol where Self: TokenPickerViewAlert {
    func showAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(0);
                    make.left.right.equalTo(self)
                    make.height.equalTo(358)
                }
                self.layoutIfNeeded()
            })
        }
    }
    func hideAnimation(tag: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
            UIView.animate(withDuration: 0.3, animations: {
                self.whiteBackgroundView.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(self.snp.bottom).offset(358);
                    make.left.right.equalTo(self)
                    make.height.equalTo(358)
                }
                self.layoutIfNeeded()
            }, completion: { (status) in
                self.hide(tag: tag)
            })
        }
    }
}
