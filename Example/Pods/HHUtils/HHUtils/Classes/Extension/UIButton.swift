//
//  UIButton.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/2/3.
//

import Foundation

private var topNameKey: Void?
private var rightNameKey: Void?
private var bottomNameKey: Void?
private var leftNameKey: Void?

extension UIButton {
    
    // MARK: 扩大响应范围
    public func setEnlargeEdge(size: Float) {
        setEnlargeEdge(top: size, right: size, bottom: size, left: size)
    }
    public func setEnlargeEdge(top: Float, right: Float, bottom: Float, left: Float) {
        objc_setAssociatedObject(self, &topNameKey, NSNumber(value: top), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &rightNameKey, NSNumber(value: right), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &bottomNameKey, NSNumber(value: bottom), .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &leftNameKey, NSNumber(value: left), .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    func enlargedRect() -> CGRect {
        let topEdge: NSNumber = (objc_getAssociatedObject(self, &topNameKey) ?? NSNumber(value: 0)) as! NSNumber
        let rightEdge: NSNumber = (objc_getAssociatedObject(self, &rightNameKey) ?? NSNumber(value: 0)) as! NSNumber
        let bottomEdge: NSNumber = (objc_getAssociatedObject(self, &bottomNameKey) ?? NSNumber(value: 0)) as! NSNumber
        let leftEdge: NSNumber = (objc_getAssociatedObject(self, &leftNameKey) ?? NSNumber(value: 0)) as! NSNumber
        return CGRect(x: bounds.origin.x - CGFloat(leftEdge.floatValue), y: bounds.origin.y - CGFloat(topEdge.floatValue), width: bounds.width + CGFloat(leftEdge.floatValue) + CGFloat(rightEdge.floatValue), height: bounds.height + CGFloat(topEdge.floatValue) + CGFloat(bottomEdge.floatValue))
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = enlargedRect()
        if CGRectEqualToRect(rect, bounds) {
            return super.hitTest(point, with: event)
        }
        return CGRectContainsPoint(rect, point) ? self : nil
    }
}
