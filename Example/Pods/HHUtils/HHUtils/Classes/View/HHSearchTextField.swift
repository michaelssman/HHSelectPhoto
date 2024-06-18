//
//  HHSearchTextField.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2024/3/27.
//

import UIKit

// 自定义搜索输入框
public class HHSearchTextField: UITextField {
    
    /// 占位文字
    public var placeholderString: String? {
        didSet {
            setUpPlaceholder()
        }
    }
    
    /// 占位文字字体大小
    public var placeholderFont: UIFont? {
        didSet {
            setUpPlaceholder()
        }
    }
    
    /// 占位文字字体颜色
    public var placeholderColor: UIColor? {
        didSet {
            setUpPlaceholder()
        }
    }
    
    /// 圆角
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            borderView.layer.cornerRadius = cornerRadius
        }
    }
    
    /// 背景色
    public var cornerBackgroundColor: UIColor? {
        didSet {
            borderView.backgroundColor = cornerBackgroundColor
        }
    }
    
    /// 边界视图
    private lazy var borderView: UIView = {
        let view: UIView = UIView()
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false // 设置为false，以便点击输入框时能够成为第一响应者
        self.insertSubview(view, at: 0)
        return view
    }()
    
    // 初始化函数
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    
    // 设置视图
    private func setUpViews() {
        backgroundColor = .cyan
        let imgView: UIImageView = UIImageView(image: UIColor.purple.toImage())
        leftView = imgView
        leftViewMode = .always
        // 移除键盘上面的工具栏
        inputAccessoryView = UIView()
    }
    
    // 设置占位文字样式
    private func setUpPlaceholder() {
        guard let placeholderString = placeholderString else { return }
        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.minimumLineHeight = font?.lineHeight ?? 0 - (font?.lineHeight ?? 0 - (placeholderFont?.lineHeight ?? 0)) / 2.0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor ?? UIColor.clear,
            .font: placeholderFont ?? UIFont.systemFont(ofSize: 12),
            .paragraphStyle: style
        ]
        
        let attributeStr: NSAttributedString = NSAttributedString(string: placeholderString, attributes: attributes)
        attributedPlaceholder = attributeStr
    }
    
    // 设置leftView的位置
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 15 // 向右偏移15
        return rect
    }
    
    // 设置占位文字的位置
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        let iconRect = self.leftViewRect(forBounds: bounds)
        rect.origin.x = iconRect.maxX + 20 // 向右偏移20
        return rect
    }
    
    // 设置编辑时文字的位置
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        let iconRect = self.leftViewRect(forBounds: bounds)
        rect.origin.x = iconRect.maxX + 20 // 向右偏移20
        rect.size.width = bounds.width - rect.origin.x - 5
        return rect
    }
    
    // 输入完成，取消编辑之后，文字的frame
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        let iconRect = self.leftViewRect(forBounds: bounds)
        rect.origin.x = iconRect.maxX + 20 // 向右偏移20
        rect.size.width = bounds.width - rect.origin.x - 5
        return rect
    }
    
    // 设置frame
    public override func layoutSubviews() {
        super.layoutSubviews()
        borderView.frame = self.bounds
    }
}

