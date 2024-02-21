//
//  HHSelectPhoto.swift
//  HHSelectPhoto
//
//  Created by Michael on 2024/2/21.
//

import Foundation


// 如果你使用了 resource_bundles
@inline(__always)
public func bundleImage(_ imageName: String) -> UIImage {
    let bundleURL = Bundle(for: HHAssetCell.self).url(forResource: "HHSelectPhoto", withExtension: "bundle")!
    let resourceBundle = Bundle(url: bundleURL)!
    return UIImage(named: imageName, in: resourceBundle, compatibleWith: nil) ?? UIImage()
}
