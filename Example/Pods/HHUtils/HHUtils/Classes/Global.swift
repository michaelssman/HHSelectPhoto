//
//  Global.swift
//  HHSwift
//
//  Created by Michael on 2022/4/13.
//

//在swift中, 并非是预编译代码替换, 而是设置全局常量或函数

import Foundation
import UIKit

public let SCREEN_WIDTH = UIScreen.main.bounds.width
public let SCREEN_HEIGHT = UIScreen.main.bounds.height

/// 安全区高度
@inline(__always)
public func hh_safeDistance() -> UIEdgeInsets {
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
public func vg_statusBarHeight() -> CGFloat {
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
public let vg_navigationBarHeight: CGFloat = 44.0

/// 状态栏+导航栏的高度
@inline(__always)
public func vg_navigationFullHeight() -> CGFloat {
    return vg_statusBarHeight() + vg_navigationBarHeight
}

/// 底部导航栏高度
public let vg_tabBarHeight: CGFloat = 49.0

/// 底部导航栏高度（包括安全区）
@inline(__always)
public func vg_tabBarFullHeight() -> CGFloat {
    return vg_tabBarHeight + hh_safeDistance().bottom
}

// MARK: 正式测试库
@inline(__always)
public func debug() -> Bool {
#if DEBUG
    return true
#else
    return false
#endif
}

// MARK: keyWindow
@inline(__always)
public func keyWindow() -> UIWindow {
    if Thread.isMainThread {
        // 直接在主线程中执行
        return getKeyWindow()
    } else {
        // 同步到主线程
        return DispatchQueue.main.sync {
            getKeyWindow()
        }
    }
}

@inline(__always)
private func getKeyWindow() -> UIWindow {
    if #available(iOS 13.0, *) {
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            if scene.activationState == .foregroundActive, let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        return window
                    }
                }
            }
        }
    } else {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow
        }
    }
    
    // 如果没有找到 keyWindow，创建并返回一个新的 UIWindow 实例
    let newWindow = UIWindow(frame: UIScreen.main.bounds)
    return newWindow
}
