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
    var result: UIWindow?
    if #available(iOS 13.0, *) {
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            if scene.activationState == .foregroundActive, let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        result = window
                        break
                    }
                }
                if result != nil {
                    break
                }
            }
        }
    } else {
        result = UIApplication.shared.keyWindow
    }
    return result!
}
