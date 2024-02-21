//
//  HHPhotosBottomView.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/16.
//

import UIKit

class HHPhotosBottomView: UIView {

    lazy var previewBtn: UIButton = {
        let previewBtn = UIButton(type: .custom)
        previewBtn.setTitle("预览", for: .normal)
        previewBtn.setTitleColor(.darkGray, for: .normal)
        previewBtn.titleLabel?.font = .systemFont(ofSize: 16)
        return previewBtn
    }()
    lazy var countLab: UILabel = {
       let countLab = UILabel()
        countLab.backgroundColor = .lightGray
        countLab.font = .systemFont(ofSize: 16)
        countLab.layer.masksToBounds = true
        countLab.layer.cornerRadius = 5.0
        countLab.textAlignment = .center
        return countLab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .cyan
        addSubview(previewBtn)
        addSubview(countLab)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCount(currentCount: NSInteger, totalCount: NSInteger) {
        countLab.text = "完成\(currentCount)/\(totalCount)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewBtn.frame = CGRect(x: 10, y: 10, width: 66, height: bounds.height - 20)
        countLab.frame = CGRect(x: bounds.width - 96, y: 10, width: 86, height: bounds.height - 20)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
