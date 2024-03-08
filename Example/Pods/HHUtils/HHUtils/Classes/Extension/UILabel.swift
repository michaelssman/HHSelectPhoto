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
    
    /// label中特殊字符显示不同的样式
    /// - Parameters:
    ///   - text: 特殊字符
    ///   - color: 特殊字符的字体颜色
    ///   - font: 特殊字符的字体大小
    func setSpecialText(_ text: String, color: UIColor, font: UIFont) {
        // 传数字需要转换
        let text = "\(text)"
        // 如果不包含指定的字符串，直接return
        guard self.text?.contains(text) == true else {
            return
        }
        
        if let range = self.text?.range(of: text) {
            //将Range<String.Index>转换为NSRange
            let nsRange = self.text?.nsRange(from: range)
            if let nsRange = nsRange {
                setSpecialTextWithRange(nsRange, color: color, font: font)
            }
        }
    }
    
    func setSpecialTextWithRange(_ range: NSRange, color: UIColor, font: UIFont) {
        guard let attributedString = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        // 设置字号
        attributedString.addAttribute(.font, value: font, range: range)
        // 设置文字颜色
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        // 设置中划线
        //          attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: 12))
        
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
        if let image = bgView.image() {
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
