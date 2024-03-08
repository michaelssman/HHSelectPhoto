//
//  UITextView.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/5/30.
//

import Foundation

public extension UITextView {
    func setTextViewSelectedRange() {
        //光标移动到末尾
        let textView = UITextView()
        textView.selectedRange = NSMakeRange(textView.text.count, 0)
    }
}
