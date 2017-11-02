//
//  ScanWrapper.swift
//  ScanDemo
//
//  Created by 李 on 2017/10/26.
//  Copyright © 2017年 Archerycn. All rights reserved.
//

import Foundation
import AVKit

class ScanWrapper: NSObject {
    
    // 扫描结果
    var scanQrCodeResult: ((_ qrCodeString: String) -> ())?
    // 是否允许放大二维码
    var shouldZoomOutQRCode = true
    
    fileprivate let device = AVCaptureDevice.default(for: .video)
    fileprivate var input: AVCaptureDeviceInput?
    fileprivate var output = AVCaptureMetadataOutput()
    fileprivate var imageOutput = AVCaptureStillImageOutput()
    fileprivate let session = AVCaptureSession()
    
    init(preview: UIView) {
        
        super.init()
        guard ScanPermission.isGetCameraPerssion() else { return }
        guard let device = device else { return}
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        
        guard let input = input else { return }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }

        session.sessionPreset = AVCaptureSession.Preset.high
        imageOutput.outputSettings = [AVVideoCodecJPEG: AVVideoCodecKey]

        //参数设置
        output.metadataObjectTypes = [.qr]
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = preview.bounds  
        preview.layer.insertSublayer(previewLayer, at: 0)
    }
    
    /// 打开摄像头
    func start() {
        if session.isRunning == false {
            session.startRunning()
        }
    }
    
    /// 关闭摄像头
    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    /// 摄像头截图
    ///
    /// - Parameter success: 截图UIImage
    func screenShot( success: @escaping ((UIImage?) -> ())) {
        let imageConnect = getConnection()
        imageOutput.captureStillImageAsynchronously(from: imageConnect!) { (buffer, _) in
            self.stop()
            if buffer != nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!)
                if imageData != nil {
                    let scanImage = UIImage(data: imageData!)
                    success(scanImage)
                }
                
            }
        }
    }
    
    /// 控制闪光灯
    ///
    /// - Parameter level: 闪光灯等级（0，1）
    func changeTorchLevel(level: Float) {
        if (device?.hasFlash ?? false)  && (device?.hasTorch ?? false) {
            try? device?.lockForConfiguration()
            try? device?.setTorchModeOn(level: level)
            
            device?.unlockForConfiguration()
        }
    }
    
    /// 切换前后摄像头
    func switchCarema() {
        
        let inputs = session.inputs
        for deviceInput in inputs {
            let device = (deviceInput as! AVCaptureDeviceInput).device
            let newCamera: AVCaptureDevice?
            let newInput: AVCaptureDeviceInput?
            
            if device.hasMediaType(.video) {
               newCamera = cameraWithPosition(position: self.input?.device.position == .front ? .back : .front)
                newInput = try? AVCaptureDeviceInput(device: newCamera!)
                session.beginConfiguration()
                session.removeInput(input!)
                session.addInput(newInput!)
                session.commitConfiguration()
                self.input = newInput
            }
        }
    }
    
}

// MARK: - fileprivate method
extension ScanWrapper {
    fileprivate func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    fileprivate func getConnection() -> AVCaptureConnection? {
        for connection in imageOutput.connections {
            for port in connection.inputPorts {
                if port.isKind(of: AVCaptureInput.Port.self) {
                    if port.mediaType == .video {
                        return connection
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - <#AVCaptureMetadataOutputObjectsDelegate#>
extension ScanWrapper: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
     
        for current in metadataObjects {
            if (current as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self) {
                let code = current as! AVMetadataMachineReadableCodeObject
                //码类型
                //let codeType = code.type
                //码内容
                //let codeContent = code.stringValue
                //4个字典，分别 左上角-右上角-右下角-左下角的 坐标百分百，可以使用这个比例抠出码的图像
                 let arrayRatio = code.corners
                //成功回调
                if scanQrCodeResult != nil {
                    if let qrCodeString = code.stringValue {
                        scanQrCodeResult!(qrCodeString)
                    }
                }
                self.stop()
                guard shouldZoomOutQRCode else { return }
                //只有中心点附近才能放大
                let centerX = arrayRatio[1].x - (arrayRatio[1].x - arrayRatio[0].x) / 2
                let centerY = arrayRatio[3].y - (arrayRatio[3].y - arrayRatio[2].y) / 2
                if  centerX >= 0.45 && centerX <= 0.55 && centerY >= 0.45 && centerY <= 0.55 {
                    //0.3是给2边留一点空隙
                    let qrcodeWidth = arrayRatio[1].x - arrayRatio[0].x + 0.3
                    let scale = 1 / qrcodeWidth
                    if scale < 1.5 { return } //1.5被没必要放大
                    try? device?.lockForConfiguration()
                    device?.videoZoomFactor = scale
                    device?.unlockForConfiguration()
                }
            }
        }
    }
}
