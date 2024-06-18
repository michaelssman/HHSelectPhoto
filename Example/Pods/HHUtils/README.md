# HHUtils

[![CI Status](https://img.shields.io/travis/michaelstrongself@outlook.com/HHUtils.svg?style=flat)](https://travis-ci.org/michaelstrongself@outlook.com/HHUtils)
[![Version](https://img.shields.io/cocoapods/v/HHUtils.svg?style=flat)](https://cocoapods.org/pods/HHUtils)
[![License](https://img.shields.io/cocoapods/l/HHUtils.svg?style=flat)](https://cocoapods.org/pods/HHUtils)
[![Platform](https://img.shields.io/cocoapods/p/HHUtils.svg?style=flat)](https://cocoapods.org/pods/HHUtils)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HHUtils is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HHUtils'
```

## Author

michaelstrongself@outlook.com, michaelstrongself@outlook.com

## License

HHUtils is available under the MIT license. See the LICENSE file for more info.

#### Global
- 屏幕宽高、导航栏、状态栏、安全区域尺寸
- 获取keyWindow
#### Foundations
- APISession：网络请求
- HHDecimalNumber：四舍五入，保留小数位
- RegularExpression：正则
    - 运算式表达式
- UIImageUtils
    - 两张图合成一张图
#### Extension
- MBProgressHUD
- String
    - 计算高度、宽度
    - 显示位数
- UIBarButtonItem
- UIButton：扩大响应范围
- UIColor
- UILabel
    - 便利构造函数，设置颜色和字体
    - 设置行间距
    - 特殊字符设置特殊样式
    - 添加附件
- UIResponder：获取第一响应者
- UITableViewHeightCache：tableView优化之---高度缓存
- UITextView：设置光标
- UIView
    - 查找viewController
    - 自动回收键盘
    - 设置阴影
    - 设置圆角
    - view转图片
    - 屏幕截图（UIGraphics）
- UIViewController
    - 回收键盘
    - 防止键盘遮挡输入框
    - 查找最上层的viewController
#### View
- CommonList：tableView封装
- HHButton：自定义titleRect和imageRect
- HHFloatingView：可以拖动的浮动视图类
- HHSearchTextField：自定义搜索输入框
- HHWebView：WKWebView
- AlertView：提示弹窗
