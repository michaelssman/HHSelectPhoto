//
//  HHPreviewSelectedView.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/12.
//
//  底部选中图片

import UIKit
import HHUtils

// MARK: 插入删除cell的动画
public class HHCellAnimateFlowLayout: UICollectionViewFlowLayout {
    public var addAnimatedIndex = -1
    public var removeAnimatedIndex = -1
    
    // 添加时动画
    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if addAnimatedIndex == itemIndexPath.row {
            attributes?.transform = CGAffineTransformMakeScale(0.0, 0.0)
            attributes?.alpha = 0
        } else {
            attributes?.alpha = 1
        }
        return attributes
    }
    
    //删除时动画
    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        if removeAnimatedIndex == itemIndexPath.row {
            attributes?.transform = CGAffineTransformMakeScale(0.1, 0.1)
            attributes?.alpha = 0
        }
        return attributes
    }
    
    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        //释放插入和删除索引路径
        removeAnimatedIndex = -1
        addAnimatedIndex = -1
    }
}

class HHPreviewSelectedCell: UICollectionViewCell {
    lazy var bgView: UIView = {
        let bgView = UIView(frame: bounds)
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 4.0
        return bgView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }() /**< 缩略图*/
    lazy var deleteView: UIButton = {
        let deleteView = UIButton(type: .custom)
        deleteView.frame = CGRect(x: bounds.width - 16, y: 0, width: 16, height: 16)
        deleteView.backgroundColor = UIColor(white: 0, alpha: 0.9)
        deleteView .setTitle("X", for: .normal)
        let rect: CGRect = CGRect(x: 0, y: 0, width: 16, height: 16)
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .bottomLeft], cornerRadii: CGSize(width: 4.0, height: 4.0))
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.frame = rect
        shapeLayer.path = maskPath.cgPath
        deleteView.layer.masksToBounds = true
        deleteView.layer.mask = shapeLayer
        return deleteView
    }()
    var checked: Bool = false {
        didSet {
            if checked {
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                imageView.layer.borderWidth = 0
                imageView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }   /**< 是否已经选中(YES:已选中 / NO:未选中)*/
    
    var clickDelete: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bgView)
        bgView.addSubview(imageView)
        bgView.addSubview(deleteView)
        deleteView.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteAction() {
        if let clickDelete = clickDelete {
            clickDelete()
        }
    }
}

class HHPreviewSelectedView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var selectedPHArray: Array<HHAssetModel> = []
    ///当前图片是选中的第几张图片
    var selectedCurrentRow: NSInteger = 0
    
    /// 删除item
    var deleteItem: ((_ photoModel: HHAssetModel) -> Void)?
    /// 点击item
    var didSelectItem: ((_ indexPath: IndexPath) -> Void)?
    
    
    let kCellSize: CGFloat = 53
    lazy var flowLayout: HHCellAnimateFlowLayout = {
        let flowLayout: HHCellAnimateFlowLayout = HHCellAnimateFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.minimumLineSpacing = 15
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        flowLayout.itemSize = CGSizeMake(kCellSize, kCellSize)
        flowLayout.addAnimatedIndex = -1
        flowLayout.removeAnimatedIndex = -1
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 73), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HHPreviewSelectedCell.self, forCellWithReuseIdentifier: "HHPreviewSelectedCell")
        return collectionView
    }()
    
    /// 模糊效果
    lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.alpha = 0.4
        return effectView
    }()
    
    override init(frame: CGRect) {
        /// 一定要调super
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.8)
        addSubview(effectView)
        addSubview(collectionView)
        //分割线
        let line: UIView = UIView(frame: CGRect(x: 0, y: 72.5, width: SCREEN_WIDTH, height: 0.5))
        line.backgroundColor = .black
        addSubview(line)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: method
    func fitWithSelectedCurrentRow(selectedCurrentRow: NSInteger) {
        // 让当前图片尽可能居中显示
        // 只有collectionView的contentSize超出屏幕宽时需要移动
        // 1. 当前图片的中心偏向于右侧时, 如果使它居中不会让collectionView滚动超过最大值, 就让它居中
        // 2. 当前图片的中心偏向于右侧时, 如果使它居中会让collectionView滚动超过最大值, 就让它滚动到最大值的位置
        // 3. collectionView显示在初始位置
        guard collectionView.contentSize.width > SCREEN_WIDTH else {
            return
        }
        //当前图片的中心
        let currentX = (kCellSize + 15) * Double(selectedCurrentRow) + (kCellSize / 2.0)
        if (currentX > SCREEN_WIDTH / 2.0 && currentX + SCREEN_WIDTH / 2.0 <= collectionView.contentSize.width) {
            collectionView.setContentOffset(CGPointMake(currentX - SCREEN_WIDTH / 2.0, 0), animated: true)
        } else if (currentX > SCREEN_WIDTH / 2.0 && currentX + SCREEN_WIDTH / 2.0 > collectionView.contentSize.width) {
            collectionView.setContentOffset(CGPointMake(collectionView.contentSize.width - SCREEN_WIDTH, 0), animated: true)
        } else {
            collectionView.setContentOffset(.zero, animated: true)
        }
    }
    
    public func insertItems(index: NSInteger) {
        flowLayout.addAnimatedIndex = index
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        } completion: { [self] Bool in
            collectionView.reloadData()
            fitWithSelectedCurrentRow(selectedCurrentRow: index)
        }
    }
    public func deleteItems(index: NSInteger) {
        flowLayout.removeAnimatedIndex = index
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        } completion: { [self] Bool in
            collectionView.reloadData()
            fitWithSelectedCurrentRow(selectedCurrentRow: index)
        }
    }
    
    // MARK: 代理
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HHPreviewSelectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HHPreviewSelectedCell", for: indexPath) as! HHPreviewSelectedCell
        HHImageManager.getPhoto(asset: selectedPHArray[indexPath.row].asset, photoWidth: 90, networkAccessAllowed: false) { photo, info, isDegraded in
            cell.imageView.image = photo
        } progressHandler: { progress, error, stop, info in
            //
        }
        if indexPath.row == selectedCurrentRow {
            cell.checked = true
        } else {
            cell.checked = false
        }
        cell.clickDelete = { [self] in
            if let deleteItem = deleteItem {
                deleteItem(selectedPHArray[indexPath.row])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPHArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let didSelectItem = didSelectItem {
            didSelectItem(indexPath)
        }
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
