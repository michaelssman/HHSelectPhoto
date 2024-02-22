//
//  ViewController.swift
//  HHSelectPhoto
//
//  Created by michaelstrongself@outlook.com on 02/18/2024.
//  Copyright (c) 2024 michaelstrongself@outlook.com. All rights reserved.
//

import UIKit
import HHSelectPhoto

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let button: UIButton = UIButton(type: .custom)
        button.setTitle("选择相册", for: .normal)
        button.backgroundColor = .blue
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 200, width: 100, height: 80)
        button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
    }
    @objc func selectPhoto() {
        HHPermissionTool.requestPHAuthorizationStatus { success in
            guard success else {return}
            ///必须在主线程
            DispatchQueue.main.async {
                let vc: HHPhotosViewController = HHPhotosViewController()
                vc.maxCount = 3
                //            nav.photosVC.delegate = self;
                //            nav.allowPickingImage = YES;
                //            nav.allowPickingVideo = YES;
                //            nav.minImagesCount = 1;
                let navC: UINavigationController = UINavigationController(rootViewController: vc)
                navC.modalTransitionStyle = .coverVertical
                navC.modalPresentationStyle = .fullScreen
                self.present(navC, animated: true) {
                    //
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

