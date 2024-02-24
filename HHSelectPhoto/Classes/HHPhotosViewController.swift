//
//  HHPhotosViewController.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/10.
//

import UIKit
import HHUtils

class HHAssetCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var selectButton: UIButton = {
        let selectButton = UIButton(type: .custom)
        selectButton.frame = CGRect(x: bounds.width - 29, y: 4, width: 25, height: 25)
        selectButton.setBackgroundImage(bundleImage("imgSelecte_NO"), for: .normal)
        selectButton.setBackgroundImage(bundleImage("imgSelecte_YES"), for: .selected)
        selectButton.setEnlargeEdge(size: 10)
        return selectButton
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(selectButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc public protocol HHPhotosViewControllerDelegate: NSObjectProtocol {
    ///上传成功
    @objc optional func saveAction(_ photoArray: Array<HHAssetModel>)
    @objc optional func cancelAction()
}

public class HHPhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 选中的照片
    @objc var selectedPHArray: Array<HHAssetModel> = []
    
    /// 最小照片必选张数,默认是0
    var minImagesCount: Int = 0
    /// 最多选择照片个数
    @objc public var maxCount: Int = 9
    /// Default is true, if set false, user can't picking video.
    /// 默认为YES，如果设置为NO,用户将不能选择视频
    @objc public var allowPickingVideo: Bool = true
    /// 默认为YES，如果设置为NO,用户将不能选择发送图片
    @objc public var allowPickingImage: Bool = true
    
    
    ///当前相簿
    var albumModel: HHAlbumModel?
    
    /// 相册
    lazy var albumVC: HHAlbumPickerController = {
        let albumVC: HHAlbumPickerController = HHAlbumPickerController()
        return albumVC
    }()
    
    ///所有图片 数据源
    var assetModels: Array<HHAssetModel> = []
    ///代理
    @objc public weak var delegate: HHPhotosViewControllerDelegate?
    
    static let itemMargin: CGFloat = 2
    let itemSize: CGFloat = (SCREEN_WIDTH - 4 * itemMargin) / 3
    let titleButtonHeight: CGFloat = 34
    let bottomHeight: CGFloat = 50
    var partPermissionAlertVHeight: CGFloat = 30
    let selectedViewHeight: CGFloat = 73
    var collectionViewHeightConstraint: NSLayoutConstraint!
    
    lazy var collectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = .zero
        flowLayout.itemSize = CGSizeMake(itemSize, itemSize)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: Self.itemMargin, left: Self.itemMargin, bottom: Self.itemMargin, right: Self.itemMargin)
        collectionView.register(HHAssetCell.self, forCellWithReuseIdentifier: "HHAssetCell")
        return collectionView
    }()
    lazy var partPermissionAlertV: HHPhotosView = {
        let partPermissionAlertV: HHPhotosView = HHPhotosView()
        return partPermissionAlertV
    }()
    lazy var bottomV: HHPhotosBottomView = {
        let bottomV: HHPhotosBottomView = HHPhotosBottomView()
        bottomV.previewBtn.addTarget(self, action: #selector(previewAction), for: .touchUpInside)
        bottomV.countLab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneAction)))
        bottomV.countLab.isUserInteractionEnabled = true
        return bottomV
    }()
    lazy var selectedView: HHPreviewSelectedView = {
        let selectedView: HHPreviewSelectedView = HHPreviewSelectedView(frame: .zero)
        selectedView.deleteItem = { [weak self] (photoModel: HHAssetModel!) -> Void in
            for model in self!.selectedPHArray[0...] {
                if model.asset.localIdentifier == photoModel.asset.localIdentifier {
                    self!.mutableArrayValue(forKey: #keyPath(selectedPHArray)).remove(model)
                }
            }
        }
        return selectedView
    }()
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setNavigationBar()
        view.addSubview(collectionView)
        view.addSubview(partPermissionAlertV)
        view.addSubview(bottomV)
        view.addSubview(selectedView)
        if HHPermissionTool.selectPartialPphotoPermission() {
            partPermissionAlertVHeight = 30
            partPermissionAlertV.isHidden = false
        } else {
            partPermissionAlertVHeight = 0
            partPermissionAlertV.isHidden = true
        }
        ///初始frame
        setUpSubViewsConstraints()
        //已选
        bottomV.setupCount(currentCount: selectedPHArray.count, totalCount: maxCount)
        
        fetchDatas()
        
        ///添加相册控制器
        addChild(albumVC)
        albumVC.view.frame = CGRect(x: 0, y: -view.bounds.height, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(albumVC.view)
        
    }
    
    func setUpSubViewsConstraints() {
        // 首先，禁用视图的自动尺寸调整掩码，因为我们要使用Auto Layout来定义它们的尺寸和位置
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        partPermissionAlertV.translatesAutoresizingMaskIntoConstraints = false
        bottomV.translatesAutoresizingMaskIntoConstraints = false
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        
        // 为collectionView添加高度约束
        // collectionView高度约束，这里计算高度时考虑了是否有选中的图片、底部视图、权限提示视图的高度以及设备的安全区域
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: SCREEN_HEIGHT - (selectedPHArray.count > 0 ? selectedViewHeight : 0) - bottomHeight - partPermissionAlertVHeight - UIDevice.hh_safeDistance().bottom)
        collectionViewHeightConstraint.isActive = true
        
        // 为collectionView添加约束
        NSLayoutConstraint.activate([
            // collectionView左边缘与父视图左边缘对齐
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // collectionView右边缘与父视图右边缘对齐
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // collectionView顶部与父视图顶部对齐
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            
            // partPermissionAlertV左边缘与父视图左边缘对齐
            partPermissionAlertV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // partPermissionAlertV右边缘与父视图右边缘对齐
            partPermissionAlertV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // partPermissionAlertV顶部与collectionView底部对齐
            partPermissionAlertV.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            // partPermissionAlertV高度固定，不根据其他条件变化
            partPermissionAlertV.heightAnchor.constraint(equalToConstant: partPermissionAlertVHeight),
            
            // bottomV左边缘与父视图左边缘对齐
            bottomV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // bottomV右边缘与父视图右边缘对齐
            bottomV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // bottomV顶部与partPermissionAlertV底部对齐
            bottomV.topAnchor.constraint(equalTo: partPermissionAlertV.bottomAnchor),
            // bottomV高度固定
            bottomV.heightAnchor.constraint(equalToConstant: bottomHeight),
            
            // selectedView左边缘与父视图左边缘对齐
            selectedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // selectedView右边缘与父视图右边缘对齐
            selectedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // selectedView顶部与bottomV底部对齐
            selectedView.topAnchor.constraint(equalTo: bottomV.bottomAnchor),
            // selectedView高度固定
            selectedView.heightAnchor.constraint(equalToConstant: selectedViewHeight)
        ])
    }
    
    func setNavigationBar() {
        let titleButton: HHButton = HHButton(type: .custom)
        titleButton.setTitle(albumModel?.name, for: .normal)
        titleButton.setTitleColor(.darkGray, for: .normal)
        titleButton.setImage(bundleImage("triangle"), for: .normal)
        titleButton.setImage(bundleImage("triangle_sel"), for: .selected)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: titleButtonHeight)
        titleButton.layer.masksToBounds = true
        titleButton.layer.cornerRadius = 6.0
        titleButton.addTarget(self, action: #selector(titleClickAction), for: .touchUpInside)
        navigationItem.titleView = titleButton
        ///取消按钮
        let left: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(clickCancel))
        left.tintColor = .darkGray
        navigationItem.leftBarButtonItem = left
    }
    
    // MARK: 数据数组
    func fetchDatas() {
        if let albumModel = albumModel {
            HHImageManager.getAssets(result: albumModel.result, allowPickingVideo: true, allowPickingImage: true) { [self] models in
                assetModels = models
                collectionView.reloadData()
            }
        } else {
            HHImageManager.getCameraRollAlbum(allowPickingVideo: false, allowPickingImage: true) { [self] model in
                albumModel = model
                HHImageManager.getAssets(result: albumModel!.result, allowPickingVideo: true, allowPickingImage: true) { [self] models in
                    assetModels = models
                    collectionView.reloadData()
                }
            }
        }
        let titleButton: HHButton = navigationItem.titleView as! HHButton
        titleButton.setTitle(albumModel?.name ?? "默认相册", for: .normal)
        titleButton.isSelected = false
        var titleButtonWidth: CGFloat = 100
        if (titleButton.titleWidth + 8 + 12 + 4) > titleButtonWidth {
            titleButtonWidth = (titleButton.titleWidth + 8 + 12 + 4);
        }
        titleButton.frame = CGRect(x: 0, y: 0, width: titleButtonWidth, height: titleButtonHeight)
        titleButton.titleRect = CGRect(x: (titleButtonWidth - (titleButton.titleWidth + 8 + 12)) / 2.0, y: 0, width: titleButton.titleWidth + 8, height: titleButtonHeight)
        titleButton.imageRect = CGRect(x: (titleButtonWidth - (titleButton.titleWidth + 8 + 12)) / 2.0 + (titleButton.titleWidth + 8), y: (titleButtonHeight - 9.5) / 2.0, width: 12, height: 9.5)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HHAssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HHAssetCell", for: indexPath) as! HHAssetCell
        HHImageManager.getPhoto(asset: assetModels[indexPath.row].asset, photoWidth: itemSize, networkAccessAllowed: false) { photo, info, isDegraded in
            cell.imageView.image = photo
        } progressHandler: { progress, error, stop, info in
            //
        }
        cell.selectButton.tag = indexPath.row
        cell.selectButton.addTarget(self, action: #selector(didSelectedCellSelectButton(_:)), for: .touchUpInside)
        cell.selectButton.isSelected = false
        for model in selectedPHArray {
            if model.asset.localIdentifier == assetModels[indexPath.row].asset.localIdentifier {
                cell.selectButton.isSelected = true
                break
            }
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    // MARK: 点击cell上的选择按钮
    @objc func didSelectedCellSelectButton(_ sender: UIButton) {
        if sender.isSelected == false && selectedPHArray.count == maxCount {
            print("选择图片个数已达上限")
            return
        }
        let index = sender.tag
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            var isContain: Bool = false
            for model in selectedPHArray[0...] {
                if model.asset.localIdentifier == assetModels[index].asset.localIdentifier {
                    isContain = true
                    break
                }
            }
            if !isContain {
                mutableArrayValue(forKey: #keyPath(selectedPHArray)).add(assetModels[index])
            }
        } else {
            for model in selectedPHArray[0...] {
                if model.asset.localIdentifier == assetModels[index].asset.localIdentifier {
                    mutableArrayValue(forKey: #keyPath(selectedPHArray)).remove(model)
                }
            }
        }
    }
    
    // MARK: 选择相册
    @objc func titleClickAction() {
        let titleButton: HHButton = navigationItem.titleView as! HHButton
        if titleButton.isSelected {
            albumVC.hiddenAction()
        } else {
            albumVC.showAction()
        }
        titleButton.isSelected = !titleButton.isSelected
    }
    
    @objc func clickCancel() {
        let titleButton: HHButton = navigationItem.titleView as! HHButton
        if titleButton.isSelected {
            titleClickAction()
        } else {
            navigationController?.dismiss(animated: true, completion: {
                self.delegate?.cancelAction?()
            })
        }
    }
    
    // MARK: 预览
    @objc func previewAction() {
        guard selectedPHArray.count > 0 else {
            print("未选中任何照片")
            return
        }
        let preview: HHPreviewViewController = HHPreviewViewController()
        preview.images = selectedPHArray.map({$0.asset})
        navigationController?.present(preview, animated: true)
    }
    
    @objc func doneAction() {
        //判断是否满足最小必选张数限制
        if minImagesCount > 0, selectedPHArray.count < minImagesCount {
            print("请至少选择 \(minImagesCount) 张照片")
            return
        }
        if let d = self.delegate, d.responds(to: #selector(d.saveAction(_:))) {
            d.saveAction?(selectedPHArray)
        }
        navigationController?.dismiss(animated: true, completion: {
        })
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(selectedPHArray) {
            guard let change = change else { return }
            let kind: Int64 = change[.kindKey] as! Int64
            selectedView.selectedPHArray = selectedPHArray
            if kind == NSKeyValueChange.insertion.rawValue {
                selectedView.insertItems(index: selectedView.selectedPHArray.count - 1)
            } else if kind == NSKeyValueChange.removal.rawValue {
                let set =  change[.indexesKey] as! NSIndexSet
                selectedView.deleteItems(index: set.firstIndex)
            }
            // 切换collectionView的高度
            collectionViewHeightConstraint.constant = SCREEN_HEIGHT - (selectedPHArray.count > 0 ? selectedViewHeight : 0) - bottomHeight - partPermissionAlertVHeight - UIDevice.hh_safeDistance().bottom
            // 调用UIView的类方法来开始动画
            UIView.animate(withDuration: 0.3) {
                // 这将会触发视图的布局更新，应用新的约束
                self.view.layoutIfNeeded()
            } completion: { [self] result in
                collectionView.reloadData()
            }
            //已选
            bottomV.setupCount(currentCount: selectedPHArray.count, totalCount: maxCount)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        addObserver(self, forKeyPath: #keyPath(selectedPHArray), options: .new, context: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        removeObserver(self, forKeyPath:#keyPath(selectedPHArray) , context: nil)
    }
    
    deinit {
        print("图片选择释放了～")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
