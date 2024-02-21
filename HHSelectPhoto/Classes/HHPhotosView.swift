//
//  HHPhotosView.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/2/8.
//

import UIKit

class HHPhotosView: UIView {

    lazy var alertImageView: UIImageView = {
        let alertImageView: UIImageView = UIImageView(image: bundleImage("alertP"))
        return alertImageView
    }()
    lazy var rightButton: UIButton = {
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setImage(bundleImage("alertP_r"), for: .normal)
        rightButton.addTarget(self, action: #selector(requestPermission), for: .touchUpInside)
        rightButton.setEnlargeEdge(size: 10)
        return rightButton
    }()
    lazy var textLabel: UILabel = {
        let textLabel: UILabel = UILabel()
        textLabel.text = "您设置只访问相册部分照片，建议允许访问「所有照片」"
        textLabel.textColor = UIColor(red: 1, green: 0.46, blue: 0, alpha: 1)
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 1, green: 0.46, blue: 0, alpha: 0.05)
        addSubview(alertImageView)
        addSubview(rightButton)
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func requestPermission() {
        HHPermissionTool.requestAuthorization()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        alertImageView.frame = CGRect(x: 10, y: (bounds.height - 16.5) / 2, width: 16.5, height: 16.5)
        rightButton.frame = CGRect(x: bounds.width - 25, y: (bounds.height - 14.5) / 2, width: 14.5, height: 14.5)
        textLabel.frame = CGRect(x: 30, y: 0, width: bounds.width - 30 - 30, height: bounds.height)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
