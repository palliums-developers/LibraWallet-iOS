//
//  GSCaptchaButton.swift
//  GSCaptchaButton
//
//  Created by Gesen on 15/6/4.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import UIKit

public class GSCaptchaButton: UIButton {

    // MARK: Properties
    public var maxSecond = 60
    public var countdown = false {
        didSet {
            if oldValue != countdown {
                countdown ? startCountdown() : stopCountdown()
            }
        }
    }
    
    private var second = 0
    private var timer: Timer?
    
    private var normalText: String!
    private var normalTextColor: UIColor!
    private var disabledText: String!
    private var disabledTextColor: UIColor!
    
    // MARK: Life Cycle
    //MARK:- 重写init函数
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupLabel()
    }
    
    //swift中规定:重写控件的init(frame方法)或者init()方法.必须重写 init?(coder aDecoder: NSCoder)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        countdown = false
    }
    // MARK: Setups
    
    func setupLabel() {
        normalText = title(for: .normal) ?? ""
        disabledText = title(for: .disabled) ?? ""
        normalTextColor = titleColor(for: .normal) ?? .black
        disabledTextColor = titleColor(for: .disabled) ?? .black
    }
    
    // MARK: Private
    
    private func startCountdown() {
        second = maxSecond
        updateDisabled()
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
        updateNormal()
    }
    
    private func updateNormal() {
        isEnabled = true
    }
    
    private func updateDisabled() {
        isEnabled = false
        
        self.setTitle("\(second)s", for: UIControl.State.disabled)
    }
    @objc private func updateCountdown() {
        second -= 1
        if second <= 0 {
            countdown = false
        } else {
            updateDisabled()
        }
    }
}
