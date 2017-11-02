//
//  ScanPermission.swift
//  ScanDemo
//
//  Created by 李 on 2017/10/27.
//  Copyright © 2017年 Archerycn. All rights reserved.
//

import Foundation
import AVKit

class ScanPermission {
    
    static func isGetCameraPerssion() -> Bool {
        let authStaus = AVCaptureDevice.authorizationStatus(for: .video)
        return authStaus != AVAuthorizationStatus.denied
    }
}

extension UIViewController {
    
    
    func showDeniedMessage() {
        
        let authStaus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStaus == AVAuthorizationStatus.denied {
            let alertContrller = UIAlertController(title: "温馨提示", message: "请您设置允许APP访问您的相机->设置->隐私->相机", preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .default, handler: { (_) in
                alertContrller.dismiss(animated: true, completion: nil)
            })
            alertContrller.addAction(action)
            present(alertContrller, animated: true, completion: nil)
        }
    }
}
