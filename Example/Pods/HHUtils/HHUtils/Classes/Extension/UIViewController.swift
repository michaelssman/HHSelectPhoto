//
//  UIViewController.swift
//  HHSwift
//
//  Created by Michael on 2023/2/3.
//

import Foundation
import UIKit

private var keyboardHeightKey: Void?
private var keyboardAnimationDurationKey: Void?

extension UIViewController {
    public func showToast() {
        let alertVC = UIAlertController(title: "提示", message: "用户名或密码错误", preferredStyle: .alert)
        present(alertVC, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            alertVC.dismiss(animated: true) {
                //                self.navigationController?.pushViewController(HomeViewController(), animated: true)
            }
        }
    }
    // MARK: 回收键盘
    @objc public func addDismissKeyboard() {
        let nc = NotificationCenter.default
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(tapAnywhereToDismissKeyboard(_:)))
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(tapAnywhereToDismissKeyboard(_:)))
        let tapV = UIView(frame: UIScreen.main.bounds)
        tapV.addGestureRecognizer(singleTapGR)
        tapV.addGestureRecognizer(panGR)
        weak var weakSelf = self
        let mainQuene = OperationQueue.main
        nc.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: mainQuene) { (note) in
            weakSelf?.view.addSubview(tapV)
        }
        nc.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: mainQuene) { (note) in
            tapV.removeFromSuperview()
        }
    }
    
    @objc func tapAnywhereToDismissKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        //此method会将self.view里所有的subview的first responder都resign掉
        view.endEditing(true)
    }
    /// 移除观察者，需要手动调用
    @objc public func removeDismissKeyboard() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // MARK: 键盘遮挡输入框问题
    //键盘高度
    var keyboardHeight: CGFloat {
        set {
            objc_setAssociatedObject(self, &keyboardHeightKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            objc_getAssociatedObject(self, &keyboardHeightKey) as? CGFloat ?? 0
        }
    }
    var keyboardAnimationDuration: TimeInterval {
        get {
            ((objc_getAssociatedObject(self, &keyboardAnimationDurationKey) ?? NSNumber(value: 0)) as! NSNumber).doubleValue
        }
        set {
            objc_setAssociatedObject(self, &keyboardAnimationDurationKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    //添加观察者  在viewDidLoad中调用
    @objc public func addResizeForKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ note: Notification) {
        guard let info = note.userInfo,
              let keyboardSize = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        keyboardHeight = keyboardSize.height
        keyboardAnimationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.5
        updateViewFrame()
        print("keyboardWillShow")
    }
    
    //更新frame，防止键盘遮挡输入框
    @objc func updateViewFrame() {
        //转变firstResponderView相对于window屏幕的坐标，必须得是从firstResponderView的superview转。
        let firstResponderView: UIView = UIResponder.firstResponderTextView!
        let frame: CGRect = firstResponderView.superview!.convert(firstResponderView.frame, to: keyWindow())
        
        let offset = frame.maxY - (UIScreen.main.bounds.size.height - keyboardHeight)
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        UIView.animate(withDuration: keyboardAnimationDuration) { [self] in
            if offset > 0 {
                view.bounds = CGRect(x: 0.0, y: view.bounds.origin.y + offset, width: view.frame.size.width, height: view.frame.size.height)
            }
        }
    }
    
    @objc func keyboardWillHide(_ note: Notification) {
        guard let info = note.userInfo,
              let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        UIView.animate(withDuration: animationDuration) { [self] in
            view.bounds = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        }
        
        print("keyboardWillHide")
    }
    //移除观察者 防止内存泄漏   在viewWillDisappear中调用
    @objc public func removeResizeForKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: topViewController
    //里面用到递归
    //    keyWindow().rootViewController!
    public var topViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topViewController
        } else if let presentedViewController = self.presentedViewController {
            return presentedViewController.topViewController
        } else {
            return self
        }
    }
}
