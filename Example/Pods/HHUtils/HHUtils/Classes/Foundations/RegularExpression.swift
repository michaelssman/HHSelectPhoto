//
//  RegularExpression.swift
//  HHUtils
//
//  Created by Michael on 2024/6/17.
//  正则表达式

import Foundation


/// 数学运算式验证
/// 开头可以为-
/// 开头可以为.
/// "-.5 - 23.2 + 2 * 3.3 - 4",
public func isValidExpression(_ input: String) -> Bool {
    let pattern = "^-?\\d*\\.?\\d+([+\\-*/]?\\d*\\.?\\d+)*$"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    
    let range = NSRange(location: 0, length: input.utf16.count)
    let match = regex.firstMatch(in: input, options: [], range: range)
    return match != nil
}
