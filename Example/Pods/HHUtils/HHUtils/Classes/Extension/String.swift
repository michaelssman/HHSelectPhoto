//
//  String.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/5/30.
//

import Foundation
import UIKit

extension String {
    public func paddedNumber() -> String {
        let number = 5
        let paddedNumber = String(format: "%02d", number)
        print(paddedNumber) // 输出 "05"
        return paddedNumber
    }
    public func stringToInt() -> Int{
        let str = "5"
        let number: Int = Int(str) ?? 0
        return number
    }
    
    // MARK: 根据文本内容计算高度
    public func heightWithMaxWidth(maxWidth: CGFloat, fontSize: CGFloat, bold: Bool = false) -> CGFloat {
        let font: UIFont
        if bold {
            font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        return heightWithMaxWidth(maxWidth: maxWidth, attributes: attributes)
    }
    
    public func heightWithMaxWidth(maxWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin, .truncatesLastVisibleLine]
        return self.boundingRect(with: size, options: options, attributes: attributes, context: nil).size.height
    }
    
    //计算文本宽度
    public func calculateStringSize(font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString.size()
    }
    
    // MARK: NSRange和Range<String.Index>之间的转换来处理字符串索引
    // 转换方法是基于UTF-16编码的字符串。如果使用的是包含扩展字符的Unicode字符串，需要进行适当的调整。
    // Range<String.Index>转换为NSRange
    public func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16Start = range.lowerBound.utf16Offset(in: self)
        let utf16End = range.upperBound.utf16Offset(in: self)
        
        let location = utf16Start
        let length = utf16End - utf16Start
        
        return NSRange(location: location, length: length)
    }
    // 将NSRange转换为Range<String.Index>
    public func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard let utf16Start = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
              let utf16End = utf16.index(utf16Start, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
              let start = String.Index(utf16Start, within: self),
              let end = String.Index(utf16End, within: self)
        else {
            return nil
        }
        
        return start..<end
    }
    //    func testRange() {
    //        let string = "Hello, World!"
    //        let range = string.startIndex..<string.index(string.startIndex, offsetBy: 5)
    //
    //        let nsRange = string.nsRange(from: range)
    //        print(nsRange)  // 输出：{0, 5}
    //
    //        let convertedRange = string.range(from: nsRange)
    //        print(convertedRange)  // 输出：Optional(Range(0..<5))
    //    }
}
