//
//  AlertView.swift
//  HHSwift
//
//  Created by Michael on 2023/1/3.
//

import UIKit

public class AlertView: UIView {
    var sureClosure: ((_ clickOK: Bool) -> Void)?
    
    lazy var contentBgView: UIView = {
        let contentBgView: UIView =  UIView()
        contentBgView.backgroundColor = .white
        contentBgView.layer.masksToBounds = true
        contentBgView.layer.cornerRadius = 6.0
        return contentBgView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel: UILabel = UILabel()
        titleLabel.textColor = UIColor(0x0D0D0D)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    lazy var contentLabel: UILabel = {
        let contentLabel: UILabel = UILabel()
        contentLabel.textColor = UIColor(0x0D0D0D)
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        return contentLabel
    }()
    
    lazy var leftButton: UIButton = {
        let leftButton: UIButton = UIButton(type: .custom)
        leftButton.setTitle("取消", for: .normal)
        leftButton.setTitleColor(UIColor(0x0D0D0D), for: .normal)
        leftButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return leftButton
    }()
    
    lazy var rightButton: UIButton = {
        let rightButton: UIButton = UIButton(type: .custom)
        rightButton.setTitle("设置", for: .normal)
        rightButton.setTitleColor(UIColor(0x477AFF), for: .normal)
        rightButton.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        return rightButton
    }()
    
    lazy var HLine: UIView = {
        let HLine: UIView = UIView()
        HLine.backgroundColor = UIColor(0xF2F2F2)
        return HLine
    }()
    
    lazy var VLine: UIView = {
        let VLine: UIView = UIView()
        VLine.backgroundColor = UIColor(0xF2F2F2)
        return VLine
    }()
    
    private
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black.withAlphaComponent(0.4)
        addSubview(contentBgView)
        contentBgView.addSubview(titleLabel)
        contentBgView.addSubview(contentLabel)
        contentBgView.addSubview(leftButton)
        contentBgView.addSubview(rightButton)
        contentBgView.addSubview(HLine)
        contentBgView.addSubview(VLine)
        keyWindow().addSubview(self)
        setUpSubViewsFrame()
    }
    
    public static func showAlertView(title: String, contentText: String, sureHandle: ((_ clickOK: Bool) -> Void)?) -> AlertView {
        let alertView: AlertView = AlertView(frame: UIScreen.main.bounds)//调用私有的init方法
        alertView.titleLabel.text = title
        alertView.contentLabel.text = contentText
        alertView.sureClosure = sureHandle //操作从外面传进来，函数式编程
        return alertView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpSubViewsFrame() {
        contentBgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.size.equalTo(CGSize(width: 250, height: 140))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        leftButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(50)
            // 设置宽度为父视图的一半
            make.width.equalTo(contentBgView.snp.width).multipliedBy(0.5)
        }
        rightButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.width.equalTo(leftButton)
        }
        HLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(1)
        }
        VLine.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(HLine.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
    }
    
    @objc func cancelAction() {
        if let handle = sureClosure {
            handle(false)
        }
        removeFromSuperview()
    }
    @objc func sureAction() {
        if let handle = sureClosure {
            handle(true)
        }
        removeFromSuperview()
    }
    
    static func AlertViewForView() -> AlertView? {
        for (_, item) in keyWindow().subviews.reversed().enumerated() {
            if item.isKind(of: self) {
                return item as? AlertView
            }
        }
        return nil
    }
}
