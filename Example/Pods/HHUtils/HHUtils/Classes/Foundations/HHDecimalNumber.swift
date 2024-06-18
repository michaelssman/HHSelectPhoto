//
//  HHDecimalNumber.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/7/7.
//

import UIKit
import Foundation

// MARK: 四舍五入，保留小数
@inline(__always)
public func decimalDigitsFormatter(_ value: String, decimalDigits: Int16) -> String {
    /**
     创建`NSDecimalNumberHandler`对象。`NSDecimalNumberHandler`是一个用于定义小数计算如何进行四舍五入和异常处理的类。这个对象通常与`NSDecimalNumber`对象一起使用，后者是一个用于高精度的十进制数运算的类。
     
     下面是代码参数的详细解释：
     
     1. `roundingMode: .plain`：设置四舍五入的模式。
     `.plain`模式表示四舍五入到最接近的数值，如果两边一样近，则舍入到更远的值。
     
     2. `scale`：设置计算结果的小数点后的位数。
     
     3. `raiseOnExactness: false`
     如果设置为`true`，当一个操作的结果需要被截断以符合处理器的精度时，会抛出一个异常。在这里设置为`false`，表示不抛出精确度异常。
     
     4. `raiseOnOverflow: false`
     如果设置为`true`，当一个操作的结果太大，无法表示为一个`NSDecimalNumber`时，会抛出一个溢出异常。在这里设置为`false`，表示不抛出溢出异常。
     
     5. `raiseOnUnderflow: false`
     如果设置为`true`，当一个操作的结果太小，无法表示为一个非零的`NSDecimalNumber`时，会抛出一个下溢异常。在这里设置为`false`，表示不抛出下溢异常。
     
     6. `raiseOnDivideByZero: false`
     如果设置为`true`，当除数为零时，会抛出一个除以零的异常。在这里设置为`false`，表示不抛出除以零的异常。
     
     总的来说，这个`NSDecimalNumberHandler`配置了一个四舍五入到四位小数的处理器，同时在计算过程中不会因为精确度问题、溢出、下溢或除以零而抛出异常。这允许计算在这些常见的数值问题发生时能够优雅地继续执行，而不是中断。这种处理方式对于金融计算等场合非常有用，因为它们通常需要高精度的十进制数运算，同时也需要避免因异常中断程序的执行。
     */
    let decimalNumberHandler: NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: .plain, scale: decimalDigits, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    let aDN: NSDecimalNumber = NSDecimalNumber(string: value)
    let resultDN: NSDecimalNumber = aDN.rounding(accordingToBehavior: decimalNumberHandler)
    return resultDN.stringValue
}

class HHDecimalNumber: NSObject {
    // MARK: DecimalNumber转String，并保留decimalPlaces小数位
    static func formatDecimalNumber(_ decimalNumber: NSDecimalNumber, decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        
        if let formattedString = formatter.string(from: decimalNumber) {
            return formattedString
        } else {
            return "Error formatting"
        }
    }

    @objc static func performDecimalFormatting() {
        let amount = NSDecimalNumber(string: "100.348")
        let formattedAmount = formatDecimalNumber(amount, decimalPlaces: 2)
        
        print("Formatted amount: \(formattedAmount)")
    }

}
