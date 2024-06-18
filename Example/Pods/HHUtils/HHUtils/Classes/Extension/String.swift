//
//  String.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/5/30.
//

import Foundation
import UIKit

public extension String {
    func paddedNumber() -> String {
        let number = 5
        let paddedNumber = String(format: "%02d", number)
        print(paddedNumber) // 输出 "05"
        return paddedNumber
    }
    func stringToInt() -> Int{
        let str = "5"
        let number: Int = Int(str) ?? 0
        return number
    }
    
    // MARK: 根据文本内容计算高度
    func heightWithMaxWidth(maxWidth: CGFloat, fontSize: CGFloat, bold: Bool = false, numberOfLines: Int) -> CGFloat {
        let font: UIFont
        if bold {
            font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        
        /**
         使用 boundingRect(with:options:attributes:context:) 方法来计算给定文本的高度。
         constraintRect 定义了文本的最大宽度和高度。
         使用 .greatestFiniteMagnitude 来表示无限高。
         boundingBox 是计算出来的文本框的大小。
         使用 ceil 来确保返回的高度是一个整数。
         
         如果你需要考虑 numberOfLines 的限制，可以计算出每行的高度，然后乘以行数。
         */
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        if numberOfLines > 0 {//限制行数
            let lineHeight = ceil(boundingBox.height / CGFloat(numberOfLines))
            return min(lineHeight * CGFloat(numberOfLines), boundingBox.height)
        } else {
            return ceil(boundingBox.height)
        }
    }
    
    //计算文本宽度
    func calculateStringSize(font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString.size()
    }
    
}
