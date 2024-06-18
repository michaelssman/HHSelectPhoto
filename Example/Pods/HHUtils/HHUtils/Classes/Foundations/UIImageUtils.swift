//
//  UIImageUtils.swift
//  HHUtils
//
//  Created by Michael on 2024/5/24.
//

import UIKit

class UIImageUtils: NSObject {
    
    // MARK: 合并图片
    static func combineImages(bigImage: UIImage, smallImage: UIImage) -> UIImage? {
        let bigImageSize = bigImage.size
        let smallImageSize = smallImage.size
        
        // Create a graphics context with the size of the big image
        UIGraphicsBeginImageContextWithOptions(bigImageSize, false, 0.0)
        
        // Draw the big image in the context
        bigImage.draw(in: CGRect(origin: .zero, size: bigImageSize))
        
        // Calculate the position to draw the small image at the center of the big image
        let x = (bigImageSize.width - smallImageSize.width) / 2
        let y = (bigImageSize.height - smallImageSize.height) / 2
        let smallImageRect = CGRect(x: x, y: y, width: smallImageSize.width, height: smallImageSize.height)
        
        // Draw the small image in the context
        smallImage.draw(in: smallImageRect)
        
        // Get the new image from the context
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
}
