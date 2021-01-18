//
//  ScanView.swift
//  HKWallet
//
//  Created by palliums on 2019/7/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
protocol ScanViewDelegate: NSObjectProtocol {
    func searchUser(content: String)
}
class ScanView: UIView {
    weak var delegate: ScanViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scanView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("ScanView销毁了")
    }
    //MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        scanView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
    }
    lazy var scanView: LBXScanView = {
        let view = LBXScanView(frame: CGRect.zero,vstyle:scanStyle)
        return view
    }()
    lazy var scanStyle: LBXScanViewStyle = {
        var style = LBXScanViewStyle()
        // 距离中心偏移
        style.centerUpOffset = 120
        // 距离两边距离
        style.xScanRetangleOffset = 76
        // 扫描区域外颜色
        style.color_NotRecoginitonArea = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)
        // 扫描区域四个角类型
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        // 扫描区域四个角宽度
        style.photoframeLineW = 5
        // 扫描区域四个角大小
        style.photoframeAngleW = 30
        style.photoframeAngleH = 30
        // 扫描区域四个角颜色
        style.colorAngle = UIColor.init(hex: "504ACB")
        // 扫描区域四边颜色
        style.colorRetangleLine = UIColor.init(hex: "504ACB")
        // 扫描区域动画类型
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        // 扫描区域动画图片
        style.animationImage = UIImage(named: "scan_line")
        return style
    }()    
    func stopScan() {
        scanView.stopScanAnimation()
    }
    func startScan() {
        scanView.startScanAnimation()
    }
}
//scan_line
