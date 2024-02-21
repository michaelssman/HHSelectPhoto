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
        selectButton.setBackgroundImage(UIImage(named: "imgSelecte_NO"), for: .normal)
        selectButton.setBackgroundImage(UIImage(named: "imgSelecte_YES"), for: .selected)
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

@objc protocol HHPhotosViewControllerDelegate: NSObjectProtocol {
    ///上传成功
    @objc optional func HHPhotosViewControllerUploadPhotosSucceed(_ photoArray: Array<HHAssetModel>)
    /// 取消选择
    @objc optional func HHPhotosViewControllerCancel()
}

class HHPhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 选中的照片
    @objc public var selectedPHArray: Array<HHAssetModel> = []
    
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
    @objc weak var delegate: HHPhotosViewControllerDelegate?
    
    static let itemMargin: CGFloat = 2
    let itemSize: CGFloat = (SCREEN_WIDTH - 4 * itemMargin) / 3
    let titleButtonHeight: CGFloat = 34
    let bottomHeight: CGFloat = 50
    var partPermissionAlertVHeight: CGFloat = 30
    let selectedViewHeight: CGFloat = 73
    
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
    override func viewDidLoad() {
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
        setUpSubViewsFrame()
        
        fetchDatas()
        
        addObserver(self, forKeyPath: #keyPath(selectedPHArray), options: .new, context: nil)
        ///添加相册控制器
        addChild(albumVC)
        albumVC.view.frame = CGRect(x: 0, y: -view.bounds.height, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(albumVC.view)
        
    }
    
    func setUpSubViewsFrame() {
        collectionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - (selectedPHArray.count > 0 ? selectedViewHeight : 0) - bottomHeight - partPermissionAlertVHeight - UIDevice.hh_safeDistance().bottom)
        partPermissionAlertV.frame = CGRect(x: 0, y: CGRectGetMaxY(collectionView.frame), width: SCREEN_WIDTH, height: partPermissionAlertVHeight)
        bottomV.frame = CGRect(x: 0, y: CGRectGetMaxY(collectionView.frame) + partPermissionAlertVHeight, width: SCREEN_WIDTH, height: bottomHeight)
        selectedView.frame = CGRect(x: 0, y: CGRectGetMaxY(bottomV.frame), width: SCREEN_WIDTH, height: selectedViewHeight)
        bottomV.setupCount(currentCount: 0, totalCount: maxCount)
    }
    
    func setNavigationBar() {
        let titleButton: HHButton = HHButton(type: .custom)
        titleButton.setTitle(albumModel?.name, for: .normal)
        titleButton.setTitleColor(.darkGray, for: .normal)
        titleButton.setImage(UIImage(named: "triangle"), for: .normal)
        titleButton.setImage(UIImage(named: "triangle_sel"), for: .selected)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: titleButtonHeight)
        titleButton.layer.masksToBounds = true
        titleButton.layer.cornerRadius = 6.0
        titleButton.addTarget(self, action: #selector(titleClickAction), for: .touchUpInside)
        navigationItem.titleView = titleButton
        ///取消按钮
        let left: UIBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didSelectedNavCancelButton))
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    @objc func didSelectedNavCancelButton() {
        let titleButton: HHButton = navigationItem.titleView as! HHButton
        if titleButton.isSelected {
            titleClickAction()
        } else {
            if self.delegate != nil && ((self.delegate?.responds(to: #selector(self.delegate?.HHPhotosViewControllerCancel))) != nil) {
                self.delegate?.HHPhotosViewControllerCancel?()
            }
            navigationController?.dismiss(animated: true, completion: {
            })
        }
    }

    @objc func previewAction() {
        if selectedPHArray.count == 0 {
            print("未选中任何照片")
            return
        }
    }
    
    @objc func doneAction() {
        //判断是否满足最小必选张数限制
        if minImagesCount > 0, selectedPHArray.count < minImagesCount {
            print("请至少选择 \(minImagesCount) 张照片")
            return
        }
        if (self.delegate?.responds(to: #selector(self.delegate?.HHPhotosViewControllerUploadPhotosSucceed(_:))))! {
            self.delegate?.HHPhotosViewControllerUploadPhotosSucceed!(selectedPHArray)
        }
        navigationController?.dismiss(animated: true, completion: {
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
            layoutSubviews()
        }
    }
    
    func layoutSubviews() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut) { [self] in
            setUpSubViewsFrame()
            collectionView.reloadData()
        } completion: { Bool in
            //
        }
        
    }
    
    deinit {
        removeObserver(self, forKeyPath:#keyPath(selectedPHArray) , context: nil)
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
