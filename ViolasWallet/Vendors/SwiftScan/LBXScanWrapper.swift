//
//  LBXScanWrapper.swift
//  swiftScan
//
//  Created by lbxia on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation

public struct LBXScanResult {
    /// 码内容
    public var strScanned: String? = ""
    /// 扫描图像
    public var imgScanned: UIImage?
    /// 码的类型
    public var strBarCodeType: String? = ""
    /// 码在图像中的位置
    public var arrayCorner: [AnyObject]?
}

open class LBXScanWrapper: NSObject {

    //存储返回结果
    var arrayResult: [LBXScanResult] = [];
    
    //扫码结果返回block
    var successBlock: ([LBXScanResult]) -> Void
    
    //是否需要拍照
    var isNeedCaptureImage: Bool
    
    //当前扫码结果是否处理
    var isNeedScanResult: Bool = true
    
    /**
     初始化设备
     - parameter videoPreView: 视频显示UIView
     - parameter objType:      识别码的类型,缺省值 QR二维码
     - parameter isCaptureImg: 识别后是否采集当前照片
     - parameter cropRect:     识别区域
     - parameter success:      返回识别信息
     - returns:
     */
    init(videoPreView: UIView, objType: [AVMetadataObject.ObjectType], isCaptureImg: Bool, cropRect: CGRect = CGRect.zero, success: @escaping (([LBXScanResult]) -> Void)) {
        successBlock = success
        isNeedCaptureImage = isCaptureImg

        super.init()
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("初始化设备失败")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if (device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus)) {
                do {
                    try input.device.lockForConfiguration()
                    
                    input.device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                    
                    input.device.unlockForConfiguration()
                }
                catch {
                    print("device.lockForConfiguration(): \(error)")
                }
            }
        } catch {
            print("AVCaptureDeviceInput(): \(error)")
            return
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
        
        // 识别类型
//        #warning("objType数量未统计")
        output.metadataObjectTypes = objType
        // 设置识别区域
        if !cropRect.equalTo(CGRect.zero) {
            //启动相机后，直接修改该参数无效
            output.rectOfInterest = cropRect
        }
        
        var frame:CGRect = videoPreView.frame
        frame.origin = CGPoint.zero
        previewLayer.frame = frame
        
        videoPreView.layer.insertSublayer(previewLayer, at: 0)
    }
    lazy var output: AVCaptureMetadataOutput = {
        let metadataOutput = AVCaptureMetadataOutput()
        // 设置数据处理方法，设置数据处理线程
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return metadataOutput
    }()
    lazy var stillImageOutput: AVCapturePhotoOutput = {
        return AVCapturePhotoOutput()
    }()
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
    }()
    lazy var session: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        return captureSession
    }()

    func start() {
        guard session.isRunning == false else {
            return
        }
        isNeedScanResult = true
        session.startRunning()
    }
    func stop() {
        guard session.isRunning == true else {
            return
        }
        isNeedScanResult = false
        session.stopRunning()
    }
    
    open func captureOutput(_ captureOutput: AVCaptureOutput, didOutputMetadataObjects metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection!) {
        
        guard isNeedScanResult == true else {
            return
        }
        
        isNeedScanResult = false
        
        arrayResult.removeAll()
        
        //识别扫码类型
        for current in metadataObjects {
            if current.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                let code = current as! AVMetadataMachineReadableCodeObject
                
                //码类型
                let codeType = code.type
                //                print("code type:%@",codeType)
                //码内容
                let codeContent = code.stringValue
                //                print("code string:%@",codeContent)
                
                //4个字典，分别 左上角-右上角-右下角-左下角的 坐标百分百，可以使用这个比例抠出码的图像
                // let arrayRatio = code.corners
                let result = LBXScanResult.init(strScanned: codeContent, imgScanned: UIImage(), strBarCodeType: codeType.rawValue, arrayCorner: code.corners as [AnyObject]?)
                arrayResult.append(result)
            }
        }
        
        if arrayResult.count > 0 {
            if !isNeedCaptureImage {
                captureImage()
            } else {
                stop()
                successBlock(arrayResult)
            }
            
        } else {
            isNeedScanResult = true
        }
        
    }
    
    //MARK: ----拍照
    open func captureImage() {
//        let stillImageConnection:AVCaptureConnection? = connectionWithMediaType(mediaType: AVMediaType.video as AVMediaType, connections: (stillImageOutput?.connections)! as [AnyObject])
        
        
//        stillImageOutput?.captureStillImageAsynchronously(from: stillImageConnection!, completionHandler: { (imageDataSampleBuffer, error) -> Void in
//
//            self.stop()
//            if imageDataSampleBuffer != nil {
//                let imageData: Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)!
//                let scanImg:UIImage? = UIImage(data: imageData)
//
//                for idx in 0...self.arrayResult.count-1 {
//                    self.arrayResult[idx].imgScanned = scanImg
//                }
//            }
//
//            self.successBlock(self.arrayResult)
//
//        })
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
//    open func connectionWithMediaType(mediaType:AVMediaType, connections:[AnyObject]) -> AVCaptureConnection? {
//        for connection:AnyObject in connections {
//            let connectionTmp:AVCaptureConnection = connection as! AVCaptureConnection
//
//            for port:Any in connectionTmp.inputPorts {
//                if (port as AnyObject).isKind(of: AVCaptureInput.Port.self) {
//                    let portTmp:AVCaptureInput.Port = port as! AVCaptureInput.Port
//                    if portTmp.mediaType == mediaType {
//                        return connectionTmp
//                    }
//                }
//            }
//        }
//        return nil
//    }
//    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//
//        if let error = error {
//            print("error occure : \(error.localizedDescription)")
//        }
//
//        if  let sampleBuffer = photoSampleBuffer,
//            let previewBuffer = previewPhotoSampleBuffer,
//            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
//                print(UIImage(data: dataImage)?.size as Any)
////let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer)
//            let dataProvider = CGDataProvider(data: dataImage as CFData)
//            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
//            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
//
////            self.capturedImage.image = image
//            for idx in 0...self.arrayResult.count-1 {
//                self.arrayResult[idx].imgScanned = image
//            }
//            self.successBlock(self.arrayResult)
//        } else {
//            print("some error here")
//        }
//    }
    
    //MARK:切换识别区域
    open func changeScanRect(cropRect:CGRect) {
        //待测试，不知道是否有效
        stop()
        output.rectOfInterest = cropRect
        start()
    }
    
    //MARK: 切换识别码的类型
    open func changeScanType(objType:[AVMetadataObject.ObjectType]) {
        //待测试中途修改是否有效
        output.metadataObjectTypes = objType
    }
    
    open func isFlashValid()->Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return false
        }
        guard device.hasFlash == true else {
            return false
        }
        guard device.hasTorch == true else {
            return false
        }
        return true
    }
    /**
     打开或关闭闪关灯
     - parameter torch: true：打开闪关灯 false:关闭闪光灯
     */
    open func setTorch(torch:Bool) {
        guard isFlashValid() == true else {
            return
        }
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            try input.device.lockForConfiguration()
            input.device.torchMode = torch ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
            input.device.unlockForConfiguration()
        } catch {
            print("device.lockForConfiguration(): \(error)")
        }
    }
    /**
     ------闪光灯打开或关闭
     */
    open func changeTorch() {
        guard isFlashValid() == true else {
            return
        }
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            try input.device.lockForConfiguration()
            input.device.torchMode = input.device.torchMode == .on ? AVCaptureDevice.TorchMode.off : AVCaptureDevice.TorchMode.on
            input.device.unlockForConfiguration()
        } catch {
            print("device.lockForConfiguration(): \(error)")
        }
    }
    //MARK: ------获取系统默认支持的码的类型
    static func defaultMetaDataObjectTypes() ->[AVMetadataObject.ObjectType] {
        var types = [AVMetadataObject.ObjectType.qr,
             AVMetadataObject.ObjectType.upce,
             AVMetadataObject.ObjectType.code39,
             AVMetadataObject.ObjectType.code39Mod43,
             AVMetadataObject.ObjectType.ean13,
             AVMetadataObject.ObjectType.ean8,
             AVMetadataObject.ObjectType.code93,
             AVMetadataObject.ObjectType.code128,
             AVMetadataObject.ObjectType.pdf417,
             AVMetadataObject.ObjectType.aztec
        ]
        
        types.append(AVMetadataObject.ObjectType.interleaved2of5)
        types.append(AVMetadataObject.ObjectType.itf14)
        types.append(AVMetadataObject.ObjectType.dataMatrix)
        return types
    }
    /**
     识别二维码码图像
     
     - parameter image: 二维码图像
     
     - returns: 返回识别结果
     */
    static public func recognizeQRImage(image:UIImage) throws -> [LBXScanResult] {
        var returnResult: [LBXScanResult] = []
        
        if let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]) {
            let img = CIImage.init(cgImage: (image.cgImage)!)
            
            let features = detector.features(in: img, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            guard features.isEmpty == false else {
                throw LBXScanError.error("二维码未识别")
            }
            if let feature = features[0] as? CIQRCodeFeature {
                                
                let result = LBXScanResult.init(strScanned: feature.messageString, imgScanned: image, strBarCodeType: AVMetadataObject.ObjectType.qr.rawValue, arrayCorner: nil)
                returnResult.append(result)
            } else {
                throw LBXScanError.error("获取识别结果失败")
            }
        } else {
            throw LBXScanError.error("获取识别器失败")
        }
        
        return returnResult
    }
    //MARK: -- - 生成二维码，背景色及二维码颜色设置
    static public func createCode( codeType:String, codeString:String, size:CGSize,qrColor:UIColor,bkColor:UIColor ) -> UIImage? {
        //if #available(iOS 8.0, *)
        let stringData = codeString.data(using: String.Encoding.utf8)
        //系统自带能生成的码
        //        CIAztecCodeGenerator
        //        CICode128BarcodeGenerator
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator
        let qrFilter = CIFilter(name: codeType)
        
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        //上色
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":qrFilter!.outputImage!,"inputColor0":CIColor(cgColor: qrColor.cgColor),"inputColor1":CIColor(cgColor: bkColor.cgColor)])
        
        let qrImage = colorFilter!.outputImage!;
        //绘制
        let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent)!
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext()!;
        context.interpolationQuality = CGInterpolationQuality.none;
        context.scaleBy(x: 1.0, y: -1.0);
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return codeImage
        
    }
    
    static public func createCode128(  codeString:String, size:CGSize,qrColor:UIColor,bkColor:UIColor )->UIImage? {
        let stringData = codeString.data(using: String.Encoding.utf8)
        //系统自带能生成的码
        //        CIAztecCodeGenerator 二维码
        //        CICode128BarcodeGenerator 条形码
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator     二维码
        let qrFilter = CIFilter(name: "CICode128BarcodeGenerator")
        qrFilter?.setDefaults()
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        
        let outputImage:CIImage? = qrFilter?.outputImage
        let context = CIContext()
        let cgImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        
        let image = UIImage(cgImage: cgImage!, scale: 1.0, orientation: UIImage.Orientation.up)
        
        
        // Resize without interpolating
        let scaleRate:CGFloat = 20.0
        let resized = resizeImage(image: image, quality: CGInterpolationQuality.none, rate: scaleRate)
        
        return resized;
    }
    //MARK:根据扫描结果，获取图像中得二维码区域图像（如果相机拍摄角度故意很倾斜，获取的图像效果很差）
    static func getConcreteCodeImage(srcCodeImage:UIImage,codeResult:LBXScanResult)->UIImage? {
        let rect:CGRect = getConcreteCodeRectFromImage(srcCodeImage: srcCodeImage, codeResult: codeResult)
        
        if rect.isEmpty {
            return nil
        }
        let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect)
        
        if img != nil {
            let imgRotation = imageRotation(image: img!, orientation: UIImage.Orientation.right)
            return imgRotation
        }
        return nil
    }
    //根据二维码的区域截取二维码区域图像
    static public func getConcreteCodeImage(srcCodeImage:UIImage,rect:CGRect) -> UIImage? {
        if rect.isEmpty {
            return nil
        }
        
        let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect)
        
        if img != nil {
            let imgRotation = imageRotation(image: img!, orientation: UIImage.Orientation.right)
            return imgRotation
        }
        return nil
    }
    //获取二维码的图像区域
    static public func getConcreteCodeRectFromImage(srcCodeImage:UIImage,codeResult:LBXScanResult)->CGRect {
        if (codeResult.arrayCorner == nil || (codeResult.arrayCorner?.count)! < 4){
            return CGRect.zero
        }
        
        let corner:[[String:Float]] = codeResult.arrayCorner  as! [[String:Float]]
        
        let dicTopLeft     = corner[0]
        let dicTopRight    = corner[1]
        let dicBottomRight = corner[2]
        let dicBottomLeft  = corner[3]
        
        let xLeftTopRatio:Float = dicTopLeft["X"]!
        let yLeftTopRatio:Float  = dicTopLeft["Y"]!
        
        let xRightTopRatio:Float = dicTopRight["X"]!
        let yRightTopRatio:Float = dicTopRight["Y"]!
        
        let xBottomRightRatio:Float = dicBottomRight["X"]!
        let yBottomRightRatio:Float = dicBottomRight["Y"]!
        
        let xLeftBottomRatio:Float = dicBottomLeft["X"]!
        let yLeftBottomRatio:Float = dicBottomLeft["Y"]!
        
        //由于截图只能矩形，所以截图不规则四边形的最大外围
        let xMinLeft = CGFloat( min(xLeftTopRatio, xLeftBottomRatio) )
        let xMaxRight = CGFloat( max(xRightTopRatio, xBottomRightRatio) )
        
        let yMinTop = CGFloat( min(yLeftTopRatio, yRightTopRatio) )
        let yMaxBottom = CGFloat ( max(yLeftBottomRatio, yBottomRightRatio) )
        
        let imgW = srcCodeImage.size.width
        let imgH = srcCodeImage.size.height
        
        //宽高反过来计算
        let rect = CGRect(x: xMinLeft * imgH, y: yMinTop*imgW, width: (xMaxRight-xMinLeft)*imgH, height: (yMaxBottom-yMinTop)*imgW)
        return rect
    }
    //MARK: ----图像处理
    
    /// 图像中间加logo图片
    /// - Parameters:
    ///   - srcImg: 原图像
    ///   - logoImg: logo图像
    ///   - logoSize: logo图像尺寸
    static public func addImageLogo(srcImg:UIImage,logoImg:UIImage,logoSize:CGSize ) -> UIImage {
        UIGraphicsBeginImageContext(srcImg.size);
        srcImg.draw(in: CGRect(x: 0, y: 0, width: srcImg.size.width, height: srcImg.size.height))
        let rect = CGRect(x: srcImg.size.width/2 - logoSize.width/2, y: srcImg.size.height/2-logoSize.height/2, width:logoSize.width, height: logoSize.height);
        logoImg.draw(in: rect)
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultingImage!;
    }
    //图像缩放
    static func resizeImage(image:UIImage,quality:CGInterpolationQuality,rate:CGFloat) -> UIImage? {
        var resized:UIImage?;
        let width    = image.size.width * rate;
        let height   = image.size.height * rate;
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height));
        let context = UIGraphicsGetCurrentContext();
        context!.interpolationQuality = quality;
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resized;
    }
    //图像裁剪
    static func imageByCroppingWithStyle(srcImg:UIImage,rect:CGRect) -> UIImage? {
        let imageRef = srcImg.cgImage
        let imagePartRef = imageRef!.cropping(to: rect)
        let cropImage = UIImage(cgImage: imagePartRef!)
        
        return cropImage
    }
    //图像旋转
    static func imageRotation(image:UIImage,orientation:UIImage.Orientation) -> UIImage {
        var rotate:Double = 0.0;
        var rect:CGRect;
        var translateX:CGFloat = 0.0;
        var translateY:CGFloat = 0.0;
        var scaleX:CGFloat = 1.0;
        var scaleY:CGFloat = 1.0;
        
        switch (orientation) {
        case UIImage.Orientation.left:
            rotate = .pi/2;
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImage.Orientation.right:
            rotate = 3 * .pi/2;
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImage.Orientation.down:
            rotate = .pi;
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height);
            translateX = 0;
            translateY = 0;
            break;
        }
        
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()!;
        //做CTM变换
        context.translateBy(x: 0.0, y: rect.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        context.rotate(by: CGFloat(rotate));
        context.translateBy(x: translateX, y: translateY);
        
        context.scaleBy(x: scaleX, y: scaleY);
        //绘制图片
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let newPic = UIGraphicsGetImageFromCurrentImageContext();
        
        return newPic!;
    }
    deinit {
        //        print("LBXScanWrapper deinit")
    }
}
extension LBXScanWrapper: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureOutput(output, didOutputMetadataObjects: metadataObjects, from: connection)
    }
}
extension LBXScanWrapper: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        if let dataImage = photo.fileDataRepresentation() {
            print(UIImage(data: dataImage)?.size as Any)
        //let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer)
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)

//            self.capturedImage.image = image
            for idx in 0...self.arrayResult.count-1 {
                self.arrayResult[idx].imgScanned = image
            }
            self.successBlock(self.arrayResult)
        } else {
            print("some error here")
        }
    }
}
