//
//  HHPermissionTool.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/2/6.
//

///选择部分照片 禁止弹窗提示： Prevent limited photos access alert YES

import Foundation
import Photos
import HHUtils

public class HHPermissionTool: NSObject {
    // MARK: 相册权限
    static public func requestPHAuthorizationStatus(completion: @escaping ((_ success: Bool) -> Void)) {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        switch status {
        case .notDetermined:
            // 用户还没有做出选择
            // 弹框请求用户授权
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status: PHAuthorizationStatus) in
                    if status.rawValue == PHAuthorizationStatus.authorized.rawValue {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    if status.rawValue == PHAuthorizationStatus.authorized.rawValue {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        case .restricted:
            // 此应用程序没有被授权访问的照片数据。可能是家长控制权限。
            completion(false)
        case .denied:
            // 用户拒绝访问相册
            let alertVC = UIAlertController(title: "相册授权未开启", message: "请在系统设置中开启相册授权", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "设置", style: .default, handler: { (action: UIAlertAction) in
                requestAuthorization()
            }))
            alertVC.addAction(UIAlertAction(title: "暂不", style: .default, handler: { (action: UIAlertAction) in
                //
            }))
            keyWindow().rootViewController!.topViewController?.present(alertVC, animated: true, completion: nil)
        case .authorized:
            // 用户允许访问相册
            completion(true)
        case .limited:
            //部分照片
            completion(true)
        default:
            break
        }
    }
    
    // MARK: 选择部分照片
    static public func selectPartialPphotoPermission() -> Bool {
        if #available(iOS 14, *) {
            let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .limited
        } else {
            // Fallback on earlier versions
        }
        return false
    }
    
    // MARK: 相机权限
    static public func requestCameraAuthorizationStatus(completion: @escaping ((_ success: Bool) -> Void)) {
        let device: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
        guard device != nil else {
            print("未检测到摄像头")
            completion(false)
            return
        }
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .restricted:
            print("因为系统原因, 无法访问相机")
        case .denied:
            // 用户拒绝当前应用访问相机
            let alertVC = UIAlertController(title: "相机授权未开启", message: "请在系统设置中开启相机授权", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "设置", style: .default, handler: { (action: UIAlertAction) in
                requestAuthorization()
            }))
            alertVC.addAction(UIAlertAction(title: "暂不", style: .default, handler: { (action: UIAlertAction) in
                //
            }))
            keyWindow().rootViewController!.topViewController?.present(alertVC, animated: true, completion: nil)
        case .authorized:
            completion(true)
        case .notDetermined:
            // 用户还没有做出选择
            // 请求授权
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            break
        }
    }
    
    /// 麦克风授权
    /// - Returns: 0 ：未授权 1:已授权 -1：拒绝
    static public func checkMicrophoneAuthor() -> Int {
        var result: Int = 0
        let status: AVAudioSession.RecordPermission = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case AVAudioSession.RecordPermission.undetermined:
            //请求授权
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                //
            }
            result = 0;
        case AVAudioSession.RecordPermission.denied:
            //拒绝
            result = -1
        case AVAudioSession.RecordPermission.granted:
            //允许
            result = 1
        default:
            break
        }
        return result
    }
    static func test() {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .restricted:
            break
        case .denied:
            // 用户拒绝当前应用访问相机
            break
        case .authorized:
            //已授权
            break
        case .notDetermined:
            // 用户还没有做出选择
            break
        default:
            break
        }
    }
    
    // MARK: 权限设置
    static func requestAuthorization() {
        var url: URL
        if (UIDevice.current.systemVersion as NSString).floatValue < 10.0 {
            url = URL(string: "prefs:root=privacy")!
        } else {
            url = URL(string: UIApplication.openSettingsURLString)!
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
