//
//  ScanViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/7/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
class ScanViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加返回按钮
        self.addNavigationBar()
        // 设置背景色为黑色
        self.view.backgroundColor = UIColor.black
        // 加载子View
        self.view.addSubview(detailView)
        // 延时启动相机
        perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .black
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    override open func viewWillDisappear(_ animated: Bool) {
        // 取消延迟启动
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        // 停止扫描动画
        detailView.stopScan()
        // 停止扫描解析
        scanManager.stop()
        
        self.navigationController?.navigationBar.barStyle = .default
    }
    @objc open func startScan() {
        // 开始扫描动画
        detailView.scanView.startScanAnimation()
        // 相机运行
        scanManager.start()
    }
    open func handleCodeResult(arrayResult:[LBXScanResult]) {
        guard arrayResult.isEmpty == false else {
            return
        }
        let result = arrayResult.first
        guard let address = result?.strScanned else {
            //没有获取到
            //开始扫描动画
            detailView.startScan()
            return
        }
        guard address.isEmpty == false else {
            //识别异常
            //开始扫描动画
            detailView.startScan()
            return
        }
        if let action = self.actionClosure {
            self.navigationController?.popViewController(animated: false)
            action(address)
        }
    }
    open func openPhotoAlbum() {
        LBXPermissions.authorizePhotoWith { [weak self] (granted) in
            
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            picker.delegate = self;
            
            picker.allowsEditing = true
            
            self?.present(picker, animated: true, completion: nil)
        }
    }
    func addNavigationBar() {
        // 自定义导航栏的UIBarButtonItem类型的按钮
        let backView = UIBarButtonItem(customView: backButton)
        // 重要方法，用来调整自定义返回view距离左边的距离
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = -5
        // 返回按钮设置成功
        self.navigationItem.leftBarButtonItems = [barButtonItem, backView]
        
        
//        // 自定义导航栏的UIBarButtonItem类型的按钮
//        let tempBackView = UIBarButtonItem(customView: albumButton)
//        // 重要方法，用来调整自定义返回view距离左边的距离
//        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        barButtonItem.width = 5
//        // 返回按钮设置成功
//        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, tempBackView]
    }
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    lazy var backButton: UIButton = {
        
        let backButton = UIButton(type: .custom)
        // 给按钮设置返回箭头图片
        backButton.setImage(UIImage.init(named: "navigation_back_white"), for: UIControl.State.normal)
        // 设置frame
        backButton.frame = CGRect(x: 200, y: 13, width: 22, height: 44)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        return backButton
    }()
    //是否需要识别后的当前图像
    public  var isNeedCodeImage = false
    typealias successClosure = (String) -> Void
    var actionClosure: successClosure?
    private lazy var detailView : ScanView = {
        let view = ScanView.init()
        return view
    }()
    private lazy var scanManager: LBXScanWrapper = {
        let cropRect = CGRect.zero
        //指定识别几种码
        let arrayCodeType = [AVMetadataObject.ObjectType.qr,
                             AVMetadataObject.ObjectType.ean13,
                             AVMetadataObject.ObjectType.code128]
        
        let scan = LBXScanWrapper(videoPreView: self.detailView, objType:arrayCodeType, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
            
            if let strongSelf = self {
                // 停止扫描动画
                strongSelf.detailView.stopScan()
                // 解析
                strongSelf.handleCodeResult(arrayResult: arrayResult)
            }
        })
        return scan
    }()
    lazy var albumButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(localLanguage(keyString: "wallet_scan_right_navigationbar_title"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        button.addTarget(self, action: #selector(rechargeHistory), for: .touchUpInside)
        return button
    }()
    @objc func rechargeHistory() {
        openPhotoAlbum()
    }
    deinit {
        print("ScanViewController销毁了")
    }
    var myContext = 0
}

extension ScanViewController: UIImagePickerControllerDelegate {
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let editedImage = info[.editedImage] as? UIImage {
            do {
                let arrayResult = try LBXScanWrapper.recognizeQRImage(image: editedImage)
                if arrayResult.count > 0 {
                    handleCodeResult(arrayResult: arrayResult)
                    return
                }
            } catch {
                print(error.localizedDescription)
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            do {
                let arrayResult = try LBXScanWrapper.recognizeQRImage(image: originalImage)
                if arrayResult.count > 0 {
                    handleCodeResult(arrayResult: arrayResult)
                    return
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
extension ScanViewController: UINavigationControllerDelegate {
    
}
