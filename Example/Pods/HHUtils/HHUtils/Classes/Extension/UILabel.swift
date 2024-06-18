//
//  UILabel.swift
//  HHSwift
//
//  Created by Michael on 2023/2/3.
//

import UIKit

public extension UILabel {
    
    @objc convenience init(textColor: UIColor, fontSize: CGFloat) {
        self.init()
        self.textColor = textColor
        font = .systemFont(ofSize: fontSize)
    }
    
    // MARK: 设置行间距
    @objc func setLineSpace(space: CGFloat) {
        guard text != nil else { return }
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedText!)
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        //设置行间距
        paragraphStyle.lineSpacing = space - (font.lineHeight - font.pointSize)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text?.count ?? 0))
        attributedText = attributedString
    }
    
    /// 特殊字符出现多次，都会被高亮显示
    /// - Parameters:
    ///   - keywords: 特殊字符
    ///   - color: 特殊字符的字体颜色
    ///   - font: 特殊字符的字体大小
    func setSpecialText(keywords: [String], color: UIColor, font: UIFont) {
        guard let text = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        
        for keyword in keywords {
            var searchRange = NSRange(location: 0, length: text.utf16.count)
            
            while searchRange.location < text.utf16.count {
                let foundRange = (text as NSString).range(of: keyword, options: [], range: searchRange)
                if foundRange.location != NSNotFound {
                    attributedString.addAttribute(.foregroundColor, value: color, range: foundRange)
                    // 设置字号
                    attributedString.addAttribute(.font, value: font, range: foundRange)
                    let newLocation = foundRange.location + foundRange.length
                    searchRange = NSRange(location: newLocation, length: text.utf16.count - newLocation)
                } else {
                    break
                }
            }
        }
        
        self.attributedText = attributedString
    }
    
    // 为UILabel添加附件
    @objc func setTextAttachment(label: UILabel) {
        // 获取附件Label的文本size
        let tagLabSize: CGSize = label.text?.size(withAttributes: [NSAttributedString.Key.font: label.font!]) ?? .zero
        let tagLabW = tagLabSize.width
        let tagH: CGFloat = tagLabSize.height + 1
        let space: CGFloat = 10
        label.frame = CGRect(x: 0, y: 0, width: tagLabW, height: tagH)
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: tagLabW + space, height: tagH))
        bgView.addSubview(label)
        // 将视图转换成图片
        if let image = bgView.toImage() {
            // 创建图像附件
            let attach = NSTextAttachment()
            // self.font.descender
            attach.bounds = CGRect(x: 0, y: self.font.descender, width: tagLabW + space, height: tagH)
            attach.image = image
            // 将附件添加到富文本中
            let imageStr = NSAttributedString(attachment: attach)
            // 创建可变富文本
            let maTitleString = NSMutableAttributedString(string: self.text ?? "")
            maTitleString.insert(imageStr, at: 0) // 加入文字前面
            // maTitleString.append(imageStr) // 加入文字后面
            // maTitleString.insert(imageStr, at: 4) // 加入文字第4的位置
            self.attributedText = maTitleString
        }
    }
    
}
