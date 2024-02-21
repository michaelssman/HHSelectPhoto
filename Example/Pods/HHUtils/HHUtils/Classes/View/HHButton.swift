//
//  HHButton.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/5/19.
//

import UIKit
import Foundation

public class HHButton: UIButton {
    @objc public var titleRect: CGRect = CGRect.zero
    @objc public var imageRect: CGRect = CGRect.zero
    /// 文字宽度
    @objc public var titleWidth: CGFloat = 0.0
    @objc public var space: CGFloat = 0.0
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if !titleRect.isEmpty && titleRect != CGRect.zero {
            return titleRect
        }
        return super.titleRect(forContentRect: contentRect)
    }
    
    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        if !imageRect.isEmpty && imageRect != CGRect.zero {
            return imageRect
        }
        return super.imageRect(forContentRect: contentRect)
    }
    
    /// 计算文字宽度
    var calculatedTitleWidth: CGFloat {
        if let titleLabel = self.titleLabel, let text = titleLabel.text {
            return text.calculateStringSize(font: titleLabel.font).width
        } else {
            return titleWidth;
        }
    }
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        var titleRect = self.titleRect
        var imageRect = self.imageRect
        
        if titleRect.origin.x < imageRect.origin.x {
            let maxTitleWidth = self.frame.size.width - titleRect.origin.x - space - imageRect.size.width
            titleRect.size.width = titleWidth > maxTitleWidth ? maxTitleWidth : titleWidth
            self.titleRect = titleRect
            imageRect.origin.x = self.titleRect.maxX + space
            self.imageRect = imageRect
        } else {
            let maxTitleWidth = self.frame.size.width - imageRect.origin.x - imageRect.size.width - space
            titleRect.size.width = titleWidth > maxTitleWidth ? maxTitleWidth : titleWidth
            self.titleRect = titleRect
        }
    }
}

