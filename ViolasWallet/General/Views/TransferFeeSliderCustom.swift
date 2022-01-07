//
//  TransferFeeSliderCustom.swift
//  PalliumsWallet
//
//  Created by palliums on 2019/5/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

class TransferFeeSliderCustom: UISlider {
    
    internal var slideHeight: CGFloat = 3.0
    
    override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    
    override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    // 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        return CGRect.init(x: rect.origin.x, y: (bounds.size.height-slideHeight)/2, width: rect.size.width, height: slideHeight)
    }
    // 改变滑块的触摸范围
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    }
}
