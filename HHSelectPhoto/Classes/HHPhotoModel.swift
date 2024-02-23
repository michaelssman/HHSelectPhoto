//
//  HHPhotoModel.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/9.
//

import UIKit
import Foundation
import Photos

public enum HHAssetModelMediaType: Int {
    case photo = 0
    case livePhoto
    case photoGif
    case video
    case audio
}

public class HHAssetModel: NSObject {
    @objc public var asset: PHAsset
    //    public var type: HHAssetModelMediaType
    //    init(asset: PHAsset, type: HHAssetModelMediaType) {
    //        self.asset = asset
    //        self.type = type
    //    }
    init(asset: PHAsset) {
        self.asset = asset
    }
}

// MARK: 相册
class HHAlbumModel: NSObject {
    let result: PHFetchResult<PHAsset>    ///所有图片 数据源
    let collection: PHAssetCollection   /**< 当前相簿*/
    var name: String?                    /**< 分组名*/
    let count: Int                      /**< 本组照片数*/
    
    init(result: PHFetchResult<PHAsset>, collection: PHAssetCollection, name: String? = nil, count: Int) {
        self.result = result
        self.collection = collection
        self.name = name
        self.count = count
    }
}
