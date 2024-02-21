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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        HHPermissionTool.requestPHAuthorizationStatus { success in
            guard success else {return}
            DispatchQueue.main.async {
                let vc: HHPhotosViewController = HHPhotosViewController()
                vc.maxCount = 3
                let navC: UINavigationController = UINavigationController(rootViewController: vc)
                navC.modalTransitionStyle = .coverVertical
                navC.modalPresentationStyle = .fullScreen
                self.present(navC, animated: true) {
                    //
                }
            }
        }
    }
    
}

