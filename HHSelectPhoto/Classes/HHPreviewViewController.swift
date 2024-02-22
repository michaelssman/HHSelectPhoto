//
//  HHPreviewViewController.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/7/25.
//

import UIKit
import Photos

class HHPreviewViewController: UIViewController, UICollectionViewDataSource {
    
    lazy var collectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = view.bounds.size
        let collectionView: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        // 注册自定义的UICollectionViewCell类
        collectionView.register(PreviewCollectionViewCell.self, forCellWithReuseIdentifier: "PreviewCell")
        return collectionView
    }()
    
    public var images: [Any] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }
    
    // UICollectionViewDataSource方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! PreviewCollectionViewCell
        if let phAsset = images[indexPath.item] as? PHAsset {
            HHImageManager.getPhoto(asset: phAsset, completionHandler: { image in
                cell.imageView.image = image
            })
        } else if let img = images[indexPath.item] as? UIImage {
            cell.imageView.image = img
        }
        return cell
    }
}


class PreviewCollectionViewCell: UICollectionViewCell {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView = UIScrollView(frame: contentView.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        // 设置UIScrollView的初始缩放比例
        scrollView.zoomScale = 1.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(scrollView)
        
        imageView = UIImageView(frame: scrollView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)
        
        // 添加双击手势识别器，用于双击还原缩放
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 双击手势处理方法
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

extension PreviewCollectionViewCell: UIScrollViewDelegate {
    // 返回要缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
