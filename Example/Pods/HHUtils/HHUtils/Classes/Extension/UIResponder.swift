//
//  UIResponder.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2024/2/19.
//

import UIKit

// 扩展 UIResponder 类，添加处理第一响应者的功能
extension UIResponder {
    // 使用 static 关键字声明一个类变量，用 weak 避免循环引用
    static weak var hh_currentFirstResponder: UIResponder?
    
    // 获取当前第一响应者视图的方法
    public static var firstResponderTextView: UIView? {
        /**
         `- (BOOL)sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event;`
         
         当target参数为nil时，sendAction:to:from:forEvent:方法会尝试将动作消息发送给响应者链中的第一个响应者，而不指定特定的目标对象。
         
         在这种情况下，系统会沿着响应者链向上搜索，直到找到能够响应该动作消息的对象。通常情况下，响应者链的起点是当前视图或视图控制器。
         
         如果找到能够响应该动作消息的对象，系统将调用其对应的方法来处理该动作。这可以用于实现一些通用的动作，例如在视图层次结构中找到第一个能够处理特定动作的对象，并将该动作传递给它。
         
         需要注意的是，如果没有找到能够响应该动作消息的对象，或者目标对象不支持指定的动作方法，该方法将返回NO，表示消息发送失败。
         
         当sender参数为nil时，sendAction:to:from:forEvent:方法会将动作消息发送给目标对象，但不会传递发送者对象的信息。
         
         通常情况下，sender参数用于标识触发该动作消息的对象，例如按钮控件。通过传递sender对象，目标对象可以获取关于发送者的相关信息，例如按钮的状态或标识符。
         
         如果将sender参数设置为nil，目标对象将无法获取关于发送者的信息，可能会导致在处理动作时缺少某些上下文。这种情况下，目标对象需要从其他途径获取所需的上下文信息，或者在实现动作方法时不依赖于发送者对象的信息。
         
         需要注意的是，如果目标对象的动作方法不依赖于发送者对象的信息，或者在该方法中可以处理缺少发送者信息的情况，那么将sender参数设置为nil并不会影响动作的处理。
         
         */
        UIApplication.shared.sendAction(#selector(findHHTradeFirstResponder(_:)), to: nil, from: nil, for: nil)
        return hh_currentFirstResponder as? UIView
    }
    
    // 输入文本的方法
    @objc static public func inputText(_ text: String) {
        // 尝试获取当前第一响应者，并且它遵守 UITextInput 协议
        if let textInput = firstResponderTextView as? UITextInput {
            let character = String(text)
            
            var canEdit = true // 是否可以编辑
            
            // 如果当前第一响应者是 UITextField 类型
            if let textField = textInput as? UITextField {
                if let delegate = textField.delegate, delegate.responds(to: #selector(UITextFieldDelegate.textField(_:shouldChangeCharactersIn:replacementString:))) {
                    canEdit = delegate.textField!(textField, shouldChangeCharactersIn: NSRange(location: textField.text?.count ?? 0, length: 0), replacementString: character)
                }
                
                if canEdit {
                    textField.replace(textField.selectedTextRange!, withText: text)
                }
            }
            // 如果当前第一响应者是 UITextView 类型
            else if let textView = textInput as? UITextView {
                if let delegate = textView.delegate, delegate.responds(to: #selector(UITextViewDelegate.textView(_:shouldChangeTextIn:replacementText:))) {
                    canEdit = delegate.textView!(textView, shouldChangeTextIn: NSRange(location: textView.text.count, length: 0), replacementText: character)
                }
                
                if canEdit {
                    textView.replace(textView.selectedTextRange!, withText: text)
                }
            }
        }
    }
    
    // 删除文本的方法
    @objc static public func hh_deleteBackward() {
        // 尝试获取当前第一响应者，并且它遵守 UITextInput 协议
        if let textInput = firstResponderTextView as? UITextInput {
            textInput.deleteBackward()
        }
    }
    
    // 获取当前第一响应者对象的方法
    @objc func findHHTradeFirstResponder(_ sender: Any) {
        // 第一响应者会响应这个方法，并将静态变量 hh_currentFirstResponder 设置为自己
        UIResponder.hh_currentFirstResponder = self
    }
}

// 使用示例
// UIResponder.inputText("Hello")
// UIResponder.hh_deleteBackward()

