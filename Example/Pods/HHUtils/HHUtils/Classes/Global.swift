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
    var result: UIWindow = UIWindow()
    if #available(iOS 13.0, *) {
        let scenes: Set = UIApplication.shared.connectedScenes
        for scene in scenes {
            if (scene.activationState == .foregroundActive) && (scene.isKind(of: UIWindowScene.self)) {
                let windowScene: UIWindowScene = scene as! UIWindowScene
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        result = window
                        break
                    }
                }
                break
            }
        }
    } else {
        result = UIApplication.shared.keyWindow!
    }
    return result
}
