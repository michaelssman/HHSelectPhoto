//
//  HHAlbumPickerController.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/1/10.
//

import UIKit
import HHUtils

class HHAlbumCell: UITableViewCell {
    lazy var thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.backgroundColor = .lightGray
        thumbnailImageView.layer.masksToBounds = true;
        thumbnailImageView.contentMode = .scaleAspectFill
        return thumbnailImageView
    }()
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 18)
        return nameLabel
    }()
    lazy var countLabel: UILabel = {
        let countLable = UILabel()
        countLable.font = .systemFont(ofSize: 18)
        return countLable
    }()
    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        return lineView
    }()
    var model: HHAlbumModel? {
        didSet {
            nameLabel.text = model?.name
            countLabel.text = "\(model!.count)"
            HHImageManager.getPhoto(asset: (model?.result.firstObject)!, photoSize: 40) { [self] photo, info, isDegraded in
                thumbnailImageView.image = photo
                setNeedsLayout()
            } progressHandler: { progress, error, stop, info in
                //
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(lineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        thumbnailImageView.frame = CGRect(x: 0, y: 0, width: 57, height: 57)
        nameLabel.frame = CGRect(x: 65, y: 16, width: 180, height: 25)
        countLabel.frame = CGRect(x: 250, y: 16, width: 80, height: 25)
        lineView.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }
}

class HHAlbumPickerController: UIViewController {
    
    let tableViewHeight: CGFloat = (SCREEN_HEIGHT - vg_navigationFullHeight()) / 2
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: tableViewHeight),
                                    style: .plain)
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HHAlbumCell.self, forCellReuseIdentifier: "HHAlbumCell")
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()
    lazy var objects: Array = Array<HHAlbumModel>() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        HHImageManager.getAllAlbums(allowPickingVideo: false, allowPickingImage: true) { albums in
            self.objects = albums ?? []
        }
        
        let tapView: UIView = UIView(frame: CGRect(x: 0, y: tableViewHeight, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - tableViewHeight))
        tapView.backgroundColor = .init(white: 0, alpha: 0.6)
        view.addSubview(tapView)
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelAlbumPicker)))
    }
    
    @objc func showAction() {
        UIView.animate(withDuration: 0.25) {
            self.view.frame = CGRect(x: 0, y: vg_navigationFullHeight(), width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }
    }
    @objc func hiddenAction() {
        UIView.animate(withDuration: 0.25) {
            self.view.frame = CGRect(x: 0, y: -SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }
    }
    @objc func cancelAlbumPicker() {
        let vc: HHPhotosViewController = parent as! HHPhotosViewController
        vc.fetchDatas()
        hiddenAction()
    }
    
    deinit {
        print("相册释放了～")
    }
}

extension HHAlbumPickerController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HHAlbumCell = tableView.dequeueReusableCell(withIdentifier: "HHAlbumCell", for: indexPath) as! HHAlbumCell
        cell.model = objects[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc: HHPhotosViewController = parent as! HHPhotosViewController
        vc.albumModel = objects[indexPath.row]
        vc.fetchDatas()
        hiddenAction()
    }
}
