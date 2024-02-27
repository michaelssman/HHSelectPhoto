//
//  MBProgressHUD.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/28.
//

/// 背景圆角更改
/// hud.bezelView.layer.cornerRadius = 20;
/// 背景颜色更改
/// hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
/// hud.bezelView.backgroundColor = [UIColor blackColor];
/// 修改字体颜色
/// hud.contentColor
/// 修改字体大小
/// hud.label.font = [UIFont boldSystemFontOfSize:18];

import Foundation
import HHUtils

extension MBProgressHUD {
    /// 文字颜色
    static let themeColor: UIColor = .white
    /// 背景颜色
    static let bgColor: UIColor = .init(white: 0.0, alpha: 0.8)
    static let hubCornerRadius = 8.0
    
    /// 显示过程处理信息
    /// - Parameters:
    ///   - message: 信息内容
    ///   - mode: <#mode description#>
    ///   - toView: <#toView description#>
    /// - Returns: 需要手动关闭。注意事项: 若hud已创建，需在viewWillDisappear方法直接调用hideHUD方法。
    @objc static func showProgress(message: String, mode: MBProgressHUDMode = .indeterminate, view: UIView = keyWindow()) -> MBProgressHUD {
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = message
        hud.contentColor = themeColor
        hud.mode = mode
        hud.removeFromSuperViewOnHide = true
        hud.isUserInteractionEnabled = true
        //背景
        hud.bezelView.layer.cornerRadius = hubCornerRadius
        hud.bezelView.style = .solidColor;
        hud.bezelView.backgroundColor = bgColor;
        return hud
    }
    
    /// 显示文本信息
    /// - Parameters:
    ///   - message: 信息内容
    ///   - autoHide: 是否需要自动隐藏
    ///   - view: 目标视图
    /// - Returns: MBProgressHUD, autoHide为No时需手动关闭。注意事项: 若hud已创建，需在viewWillDisappear方法直接调用hideHUD方法。
    @objc static func showMessage(message: String, autoHide: Bool, view: UIView = keyWindow()) -> MBProgressHUD {
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = message
        hud.contentColor = themeColor
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        if autoHide {
            hud.hide(animated: true, afterDelay: 1.0)
        }
        //背景
        hud.bezelView.layer.cornerRadius = hubCornerRadius
        hud.bezelView.style = .solidColor;
        hud.bezelView.backgroundColor = bgColor;
        return hud
    }
    
    private static func show(text: String, icon: String, view: UIView = keyWindow(), delay: TimeInterval) {
        DispatchQueue.main.async {
            //同一个view上只有一个HUD
            hideHUD(view: view)
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            hud.label.text = text
            hud.contentColor = themeColor
            hud.customView = UIImageView(image: UIImage(named: icon))
            hud.mode = .customView
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: true, afterDelay: delay)
            //背景
            hud.bezelView.layer.cornerRadius = hubCornerRadius
            hud.bezelView.style = .solidColor;
            hud.bezelView.backgroundColor = bgColor;
        }
    }
    
    @objc static func showSuccess(success: String, view: UIView = keyWindow()) {
        show(text: success, icon: "done", view: view, delay: 0.7)
    }
    @objc static func showError(error: String, view: UIView = keyWindow()) {
        show(text: error, icon: "error", view: view, delay: 1.0)
    }
    @objc static func showInfo(info: String, view: UIView = keyWindow()) {
        show(text: info, icon: "info", view: view, delay: 2.0)
    }
    
    /// 手动关闭MBProgressHUD
    /// - Parameter view: 显示MBProgressHUD的视图
    private static func hideHUD(view: UIView = keyWindow()) {
        hide(for: view, animated: true)
    }
}
