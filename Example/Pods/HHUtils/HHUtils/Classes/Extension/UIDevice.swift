//
//  UIDeviceExtension.swift
//  HHSwift
//
//  Created by Michael on 2022/11/12.
//

import Foundation
import UIKit

public extension UIDevice {
    
    /// 安全区高度
    @inline(__always)
    @objc static func hh_safeDistance() -> UIEdgeInsets {
        guard #available(iOS 11.0, *) else {
            return UIEdgeInsets.zero //<11
        }
        guard #available(iOS 13.0, *) else {
            //11~13
            guard let window = UIApplication.shared.windows.first else { return UIEdgeInsets.zero }
            return window.safeAreaInsets
        }
        //>13
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return UIEdgeInsets.zero }
        guard let window = windowScene.windows.first else { return UIEdgeInsets.zero }
        return window.safeAreaInsets
    }
    
    /// 顶部状态栏高度（包括安全区）
    @inline(__always)
    static func vg_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    /// 导航栏高度
    @inline(__always)
    static func vg_navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    /// 状态栏+导航栏的高度
    @inline(__always)
    @objc static func vg_navigationFullHeight() -> CGFloat {
        return UIDevice.vg_statusBarHeight() + UIDevice.vg_navigationBarHeight()
    }
    
    /// 底部导航栏高度
    @inline(__always)
    static func vg_tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    /// 底部导航栏高度（包括安全区）
    @inline(__always)
    @objc static func vg_tabBarFullHeight() -> CGFloat {
        return UIDevice.vg_tabBarHeight() + UIDevice.hh_safeDistance().bottom
    }
    
    /**
     #pragma mark - 横竖屏切换
     //[UIDevice currentDevice] 使用setValue:forKey:的方式在iOS16上面已经不可用，继而要使用UIWindowScene里面的函数请求
     - (void)changeDeviceOrientation {
     UIDeviceOrientation deviceOrientation = UIDeviceOrientationPortrait;
     if (@available(iOS 16.0, *)) {
     UIWindowScene *windowScene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] allObjects].firstObject;
     UIWindowSceneGeometryPreferencesIOS *perference = [[UIWindowSceneGeometryPreferencesIOS alloc]init];
     perference.interfaceOrientations = 1 << deviceOrientation;
     [windowScene requestGeometryUpdateWithPreferences:perference errorHandler:^(NSError * _Nonnull error) {
     NSLog(@"error:%@",error);
     }];
     } else {
     [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:deviceOrientation] forKey:@"orientation"];
     [UIViewController attemptRotationToDeviceOrientation];
     }
     }
     */
}
