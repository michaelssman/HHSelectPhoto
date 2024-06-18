//
//  HHFloatingView.swift
//  HHUtils
//
//  Created by Michael on 2024/4/24.
//

import UIKit

// 定义一个浮动视图类
public class HHFloatingView: UIView {
    
    // 初始化方法
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // 添加拖动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 显示视图
    func showView() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { finished in
            self.isHidden = false
        }
    }
    
    // 隐藏视图
    func hiddenView() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { finished in
            self.isHidden = true
        }
    }
    
    // 拖动手势的响应方法
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        // 确保有一个父视图，否则直接返回
        guard let superView = superview else { return }
        
        // 获取手势在父视图中的位移
        let translation = gesture.translation(in: superView)
        // 计算新的中心点位置
        var newCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        
        // 限制按钮移动范围在屏幕内
        let halfWidth = frame.width / 2
        let halfHeight = frame.height / 2
        let superViewWidth = superView.bounds.width
        let superViewHeight = superView.bounds.height
        
        // 如果手势状态正在改变
        if gesture.state == .changed {
            // 确保新中心点的 x 坐标不会超出父视图的范围
            newCenter.x = max(halfWidth, min(superViewWidth - halfWidth, newCenter.x))
            // 确保新中心点的 y 坐标不会超出父视图的范围
            newCenter.y = max(halfHeight, min(superViewHeight - halfHeight, newCenter.y))
            
            // 将视图的中心点设置为新的中心点
            center = newCenter
            // 重置手势的位移
            gesture.setTranslation(.zero, in: superView)
        }
        // 如果手势状态已经结束
        else if gesture.state == .ended {
            // 计算父视图中点的 x 坐标
            let midX = superView.bounds.midX
            // 根据视图在父视图中的位置决定吸附到左边缘还是右边缘
            newCenter.x = newCenter.x <= midX ? halfWidth : superViewWidth - halfWidth
            
            // 使用动画将视图吸附到最近的边缘
            UIView.animate(withDuration: 0.3) {
                self.center = newCenter
            }
        }
    }
    
}
