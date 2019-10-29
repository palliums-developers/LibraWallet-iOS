//
//  LibraWalletTool.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/16.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit

func screenSnapshot() -> UIImage? {
    
    guard let window = UIApplication.shared.keyWindow else { return nil }
    
    // 用下面这行而不是UIGraphicsBeginImageContext()，因为前者支持Retina
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
    
    window.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
}
extension UIImage {
    func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
func colorGradualChange(size: CGSize) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer.init()
    gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
    gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
    gradientLayer.locations = [0,1.0]
    gradientLayer.colors = [UIColor.init(hex: "9339F3").cgColor, UIColor.init(hex: "7038FD").cgColor]
    return gradientLayer
}
func checkMnenoicInvalid(mnemonicArray: [String]) -> Bool {
    guard mnemonicArray.count != 0 else {
        return false
    }
    let wordList: [String.SubSequence] =  WordList.english
    for i in 0...mnemonicArray.count - 1 {
        let status = wordList.contains(Substring.init(mnemonicArray[i]))
        if status == false {
            return false
        }
    }
    return true
}
