//
//  HHImageManager.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/4.
//

import UIKit
import Foundation
import Photos

public class HHImageManager: NSObject {
    
    @objc static public let manager = HHImageManager()//使用let这种方式来保证线程安全
    private override init() { }// 私有化构造方法(如果有需要也可以去掉)
    
    // MARK: 获取所有相册
    static func getAllAlbums(allowPickingVideo: Bool, allowPickingImage: Bool, completionHandler: @escaping((_ albums: Array<HHAlbumModel>?) -> Void)) {
        var albumArr: Array = [HHAlbumModel]()
        
        let option: PHFetchOptions = PHFetchOptions()
        if allowPickingVideo == false {
            option.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
        }
        if allowPickingImage == false {
            option.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.video.rawValue)")
        }
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //        option.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
        /// 我的照片流 1.6.10重新加入
        let albumMyPhotoStream: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil)
        let albumRegular: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let albumSyncedAlbum: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil)
        let albumCloudShared: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil)
        let topLevelUserCollections: PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        let allAlbums = [albumMyPhotoStream, albumRegular, albumSyncedAlbum, albumCloudShared, topLevelUserCollections]
        
        for album in allAlbums {
            if !album.isKind(of: PHFetchResult<PHAssetCollection>.self) {
                continue
            }
            let fetchResult0 = album as! PHFetchResult<PHAssetCollection>
            fetchResult0.enumerateObjects { (assetCollection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                //空相册
                if assetCollection.estimatedAssetCount == 0 {
                    return
                }
                let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: assetCollection, options: option)
                if fetchResult.count < 1 {
                    return
                }
                
                if (assetCollection.localizedTitle?.contains("Hidden"))! || assetCollection.localizedTitle == "已隐藏" {
                    return
                }
                if (assetCollection.localizedTitle?.contains("Deleted"))! || assetCollection.localizedTitle == "最近删除" {
                    return
                }
                
                if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    albumArr.insert(HHAlbumModel(result: fetchResult, collection: assetCollection, name: assetCollection.localizedTitle, count: fetchResult.count), at: 0)
                } else {
                    albumArr.append(HHAlbumModel(result: fetchResult, collection: assetCollection, name: assetCollection.localizedTitle, count: fetchResult.count))
                }
            }
        }
        completionHandler(albumArr)
        //            677 61 1 7 212 233 20 11 1 1
    }
    // MARK: 获取拍照相册 默认的相册
    static func getCameraRollAlbum(allowPickingVideo: Bool, allowPickingImage: Bool, completion: @escaping (_ model: HHAlbumModel) -> Void) {
        let option: PHFetchOptions = PHFetchOptions()
        if allowPickingVideo == false {
            option.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
        }
        if allowPickingImage == false {
            option.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.video.rawValue)")
        }
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        smartAlbums.enumerateObjects { (collection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if self.isCameraRollAlbum(collection) {
                let fetchResult = PHAsset.fetchAssets(in: collection, options: option)
                let model = HHAlbumModel(result: fetchResult, collection: collection, name: collection.localizedTitle, count: fetchResult.count)
                completion(model)
            }
        }
    }
    
    static func isCameraRollAlbum(_ metadata: PHCollection) -> Bool {
        if metadata.isMember(of: PHAssetCollection.classForCoder()) {
            let metadata = metadata as! PHAssetCollection
            var versionStr = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "")
            if versionStr.count <= 1 {
                versionStr = versionStr.appending("00")
            } else if versionStr.count <= 2 {
                versionStr = versionStr.appending("0")
            }
            let version = Int(versionStr) ?? 0
            // 目前已知8.0.0 ~ 8.0.2系统，拍照后的图片会保存在最近添加中
            if version >= 800 && version <= 802 {
                return metadata.assetCollectionSubtype == .smartAlbumRecentlyAdded
            } else {
                return metadata.assetCollectionSubtype == .smartAlbumUserLibrary
            }
        }
        return false;
    }
    
    // MARK: 获取相册中的照片数组 获取当前相簿的所有PHAsset对象
    static func getAssets(result: PHFetchResult<PHAsset>, allowPickingVideo: Bool, allowPickingImage: Bool, completion: @escaping ((_ models: Array<HHAssetModel>) -> Void)) {
        var photoArr: Array = Array<HHAssetModel>()
        result.enumerateObjects { (asset: PHAsset, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            photoArr.append(HHAssetModel(asset: asset))
        }
        completion(photoArr)
    }
    
    // MARK: 根据PHAsset获取图片
    @objc static public func getPhoto(asset: PHAsset, photoWidth: CGFloat, networkAccessAllowed: Bool, completionHandler: @escaping((_ photo: UIImage?, _ info: Dictionary<AnyHashable, Any>?, _ isDegraded: Bool) -> Void), progressHandler: @escaping((_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: [AnyHashable : Any]?) -> Void)) {
        
        let imageSize: CGSize = CGSize(width: photoWidth, height: photoWidth)
        var image: UIImage?
        // 修复获取图片时出现的瞬间内存过高问题
        // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
        let option: PHImageRequestOptions = PHImageRequestOptions()
        option.resizeMode = .fast
        option.isSynchronous = true//只调一次
        let _: PHImageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option) { (result: UIImage?, info: [AnyHashable : Any]?) in
            guard let result_image = result, let _info = info else { return }
            image = result_image
            
            let isCancelled = _info[PHImageCancelledKey] as? Bool
            let isError = _info[PHImageErrorKey] as? Bool
            let downloadFinished = (isCancelled == nil || !isCancelled!) && (isError == nil || !isError!)
            if downloadFinished {
                completionHandler(image, info, info![PHImageResultIsDegradedKey] as! Bool)
            }
            
            //download image from iCloud
            guard let isCloud = _info[PHImageResultIsInCloudKey] as? Bool else {
                return
            }
            if isCloud, networkAccessAllowed {
                let options: PHImageRequestOptions = PHImageRequestOptions()
                //下载进度
                options.progressHandler = { (progress: Double, error: Error?, stop: UnsafeMutablePointer<ObjCBool>, info: [AnyHashable : Any]?) in
                    DispatchQueue.main.async(execute: {
                        progressHandler(progress, error, stop, info)
                    })
                }
                options.isNetworkAccessAllowed = true
                options.resizeMode = .fast
                //
                if #available(iOS 13, *) {
                    PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { (imageData: Data?, dataUTI: String?, orientation: CGImagePropertyOrientation, info: [AnyHashable : Any]?) in
                        if let imageData = imageData {
                            let resultImage: UIImage? = UIImage(data: imageData)
                            // TODO: 缩放图片至新尺寸
                            completionHandler(resultImage, info, false)
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        //        return imageRequestID
    }
    
    // MARK: 根据identifiers去获取照片
    @objc static public func getPhoto(identifiers: Array<String>, completionHandler: @escaping((_ models: Array<HHAssetModel>) -> Void)) {
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        getAssets(result: fetchResult, allowPickingVideo: true, allowPickingImage: true) { models in
            completionHandler(models)
        }
    }
    
    // MARK: 获取原图
    /// 如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
    @objc static public func getPhoto(asset: PHAsset, completionHandler: @escaping((_ image: UIImage?) -> Void)) {
        // 创建图片请求选项
        let requestOptions: PHImageRequestOptions = PHImageRequestOptions()
        requestOptions.version = .original // 请求原始图片
        requestOptions.isSynchronous = false // 如果需要异步获取图片，则设置为false
        requestOptions.deliveryMode = .highQualityFormat // 请求高质量图片
        requestOptions.isNetworkAccessAllowed = true
        
        // 请求原图
        // 应该将targetSize参数设置为PHImageManagerMaximumSize，这样就会返回原始尺寸的图片。
        let requestID = PHImageManager.default().requestImage(for: asset,
                                                              targetSize: PHImageManagerMaximumSize,
                                                              contentMode: .aspectFill,
                                                              options: requestOptions) { (image: UIImage?, info: [AnyHashable : Any]?) in
            let downloadFinished = !(info![PHImageCancelledKey] != nil) && !(info![PHImageErrorKey] != nil)
            if downloadFinished, let result_image = image {
                completionHandler(result_image)
            }
        }
        
        // 如果需要，可以使用requestID来取消请求
    }
    
    // MARK: 保存图片到相册
    @objc static public func savePhoto(image: UIImage, location: CLLocation?, completionHandler: @escaping((_ asset: PHAsset?, _ error: Error?) -> Void)) {
        var localIndentifier: String = String()
        PHPhotoLibrary.shared().performChanges {
            let request: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIndentifier = request.placeholderForCreatedAsset!.localIdentifier
            if let location = location {
                request.location = location
            }
            request.creationDate = Date()
        } completionHandler: {(success: Bool, error: Error?) in
            if success {
                let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [localIndentifier], options: nil).firstObject!
                completionHandler(asset, nil)
            } else if let error = error {
                print("保存图片出错：\(error.localizedDescription)")
                completionHandler(nil, error)
            }
        }
    }
    
    /// 压缩图片 尺寸和质量
    /// - Parameters:
    ///   - image: 原图
    ///   - maxLength: 压缩到多大，5M：5 * 1024 * 1024
    /// - Returns: 压缩后的数据
    @objc static public func compressImage(_ image: UIImage, maxFileSize: Int) -> Data? {
        // Compress by quality
        var compression: CGFloat = 1
        let minCompression: CGFloat = 0.01
        guard var compressedData = image.jpegData(compressionQuality: compression) else {
            return nil
        }
        // 检查图片是否已经小于最大文件大小
        if compressedData.count < maxFileSize {
            return compressedData
        }
        while compressedData.count > maxFileSize, compression > minCompression {
            compression -= 0.05 // 每次减少5%
            if let data = image.jpegData(compressionQuality: compression) {
                compressedData = data
            } else {
                return nil
            }
        }
        
        //        // Compress by size
        //        let resultImage: UIImage = UIImage(data: compressedData)!
        //        let ratio: Float = Float(maxFileSize / compressedData.count)
        //        let size: CGSize = CGSize(width: resultImage.size.width * CGFloat(sqrtf(ratio)), height: resultImage.size.height * CGFloat(sqrtf(ratio)))
        //        let newImage: UIImage = scaleImage(image: resultImage, size: size)
        //        compressedData = newImage.jpegData(compressionQuality: 1)!
        
        return compressedData
    }
    // MARK: 缩放图片尺寸
    static public func scaleImage(image: UIImage, size: CGSize) -> UIImage {
        guard image.size.width > size.width else {
            return image
        }
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: 获取asset图片类型
    public func getAssetType(asset: PHAsset) -> HHAssetModelMediaType {
        var type = HHAssetModelMediaType.photo
        switch asset.mediaType {
        case .audio: type = .audio
        case .video: type = .video
        case .image:
            if (asset.value(forKey: "filename") as! String).hasSuffix("GIF") {
                type = .photoGif
            }
            break
        default:
            type = .photo
        }
        return type
    }
    
}
