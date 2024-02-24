//
//  UIBarButtonItem.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/4/23.
//

import Foundation

extension UIBarButtonItem {
    convenience init(title: String, target: Any?, action: Selector, config: ((UIButton) -> Void)?) {
        let button: UIButton = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        config?(button)
        self.init(customView: button)
    }
    convenience init(image: UIImage, target: Any?, action: Selector, config: ((UIButton) -> Void)?) {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        config?(button)
        self.init(customView: button)
    }
}
