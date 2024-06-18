//
//  UITableViewHeightCache.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/8/16.
//

/*
 tableView优化之---高度缓存方案
 这是一个tableView高度缓存的分类。
 你只需调用 UITableView (HeightCache) 中的五个方法即可完成对高度缓存的所有操作
 所有方法请在操作数据源之前调用，切记切记。
 */

import UIKit

extension UITableViewCell {
    
    // 设置计算用的cell标识符的属性（将计算用的cell与正常显示的cell进行区分，避免不必要的ui响应）
    private struct AssociatedKeys {
        static var JustForCal = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        static var NoAutoSizing = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
    }
    
    // 计算用的cell标识符
    var JustForCal: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.JustForCal) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.JustForCal, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 不适用autoSizing标识符（不依靠约束计算，只进行自适应）
    var NoAutoSizing: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.NoAutoSizing) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.NoAutoSizing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// 高度缓存类
class HeightCache: NSObject {
    
    // 竖直行高缓存字典
    var dicHeightCacheV: [String: Double] = [:]
    
    // 水平行高缓存字典
    var dicHeightCacheH: [String: Double] = [:]
    
    // 当前状态行高缓存字典（中间量）
    var dicHeightCurrent: [String: Double] {
        return UIDevice.current.orientation.isPortrait ? dicHeightCacheV : dicHeightCacheH
    }
    
    /// 取出缓存的高度
    func heightFromCache(key: String) -> Double? {
        if UIDevice.current.orientation.isPortrait {
            return dicHeightCacheV[key]
        } else {
            return dicHeightCacheH[key]
        }
    }
    
    /// 高度缓存
    func cacheHeight(key: String, height: Double) {
        if UIDevice.current.orientation.isPortrait {
            dicHeightCacheV[key] = height
        } else {
            dicHeightCacheH[key] = height
        }
    }
    
    // 制作key
    func makeKey(withIdentifier identifier: String, indexPath: IndexPath) -> String {
        return "\(identifier)S\(indexPath.section)R\(indexPath.row)"
    }
    
    /// 删除指定的高度缓存
    /// - Parameters:
    ///   - identifier: cell的标识
    ///   - indexPath: 删除缓存高度是哪一行
    ///   - rows: 总行数，删除行下面的所有行都需要向上移动。
    func removeHeight(identifier: String, indexPath: IndexPath, rows: Int) {
        // 例如删除第3行，共10行数据
        if indexPath.row < rows {
            //遍历:
            //第4行变为第3行、第5行变为第4行...，最后第10行变成第9行，最后一行的数据变为了要删除的第3行的数据。
            for i in 0..<(rows - 1 - indexPath.row) {
                let indexPathA = IndexPath(row: indexPath.row + i, section: indexPath.section)
                let indexPathB = IndexPath(row: indexPath.row + i + 1, section: indexPath.section)
                exchangeValue(indexPathA: indexPathA, indexPathB: indexPathB, identifier: identifier, dic: &dicHeightCacheH)
                exchangeValue(indexPathA: indexPathA, indexPathB: indexPathB, identifier: identifier, dic: &dicHeightCacheV)
            }
            //删除最后一行的数据
            let indexPathC = IndexPath(row: rows - 1, section: indexPath.section)
            let key = makeKey(withIdentifier: identifier, indexPath: indexPathC)
            dicHeightCacheH.removeValue(forKey: key)
            dicHeightCacheV.removeValue(forKey: key)
        }
    }
    
    // MARK: 删除所有的高度缓存
    func removeAllHeight() {
        dicHeightCacheH.removeAll()
        dicHeightCacheV.removeAll()
    }
    
    // MARK: 插入cell
    func insertCell(indexPath: IndexPath, rows: Int, height: Double, identifier: String, dic: inout [String: Double]) {
        if indexPath.row < rows + 1 {
            for i in 0..<(rows - indexPath.row) {
                let indexPathA = IndexPath(row: rows - i, section: indexPath.section)
                let indexPathB = IndexPath(row: rows - i - 1, section: indexPath.section)
                exchangeValue(indexPathA: indexPathA, indexPathB: indexPathB, identifier: identifier, dic: &dic)
            }
            let key = makeKey(withIdentifier: identifier, indexPath: indexPath)
            dic[key] = height
        }
    }
    
    // MARK: 移动cell
    func moveCell(fromIndexPath sourceIndexPath: IndexPath, sourceSectionNumberOfRows sourceRows: Int, toIndexPath destinationIndexPath: IndexPath, destinationSectionNumberOfRows destinationRows: Int, withIdentifier identifier: String) {
        if sourceIndexPath.section == destinationIndexPath.section {
            moveCell(inSectionFromIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath, withIdentifier: identifier)
        } else {
            moveCellOutSection(fromIndexPath: sourceIndexPath, sourceSectionNumberOfRows: sourceRows, toIndexPath: destinationIndexPath, destinationSectionNumberOfRows: destinationRows, withIdentifier: identifier)
        }
    }
    
    // MARK: 组内移动
    // 例如：同一个分区 从第三行移到第一行
    func moveCell(inSectionFromIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath, withIdentifier identifier: String) {
        let rowA = sourceIndexPath.row
        let rowB = destinationIndexPath.row
        let minRow = min(rowA, rowB)
        let maxRow = max(rowA, rowB)
        for i in 0..<(maxRow - minRow) {
            let indexPathA = IndexPath(row: minRow + i, section: sourceIndexPath.section)
            let indexPathB = IndexPath(row: minRow + i + 1, section: sourceIndexPath.section)
            exchangeValue(indexPathA: indexPathA, indexPathB: indexPathB, identifier: identifier, dic: &dicHeightCacheV)
            exchangeValue(indexPathA: indexPathA, indexPathB: indexPathB, identifier: identifier, dic: &dicHeightCacheH)
        }
    }
    
    // MARK: 组外移动
    func moveCellOutSection(fromIndexPath sourceIndexPath: IndexPath, sourceSectionNumberOfRows sourceRows: Int, toIndexPath destinationIndexPath: IndexPath, destinationSectionNumberOfRows destinationRows: Int, withIdentifier identifier: String) {
        var numberH: Double = 0
        var numberV: Double = 0
        if sourceIndexPath.row < sourceRows {
            let key = makeKey(withIdentifier: identifier, indexPath: sourceIndexPath)
            numberH = dicHeightCacheH[key] ?? 0
            numberV = dicHeightCacheV[key] ?? 0
            removeHeight(identifier: identifier, indexPath: sourceIndexPath, rows: sourceRows)
        }
        insertCell(indexPath: destinationIndexPath, rows: destinationRows, height: numberH, identifier: identifier, dic: &dicHeightCacheH)
        insertCell(indexPath: destinationIndexPath, rows: destinationRows, height: numberV, identifier: identifier, dic: &dicHeightCacheV)
    }
    
    // 根据indexPath交换两个Key
    func exchangeValue(indexPathA: IndexPath, indexPathB: IndexPath, identifier: String, dic: inout [String: Double]) {
        let keyA = makeKey(withIdentifier: identifier, indexPath: indexPathA)
        let keyB = makeKey(withIdentifier: identifier, indexPath: indexPathB)
        let temp = dic[keyA]
        dic[keyA] = dic[keyB]
        dic[keyB] = temp
    }
}

// 为UITableView添加高度缓存功能
private var CacheKey: UInt8 = 0
extension UITableView {
    // 缓存实例
    var cache: HeightCache {
        get {
            if let cache = objc_getAssociatedObject(self, &CacheKey) as? HeightCache {
                return cache
            } else {
                let cache = HeightCache()
                objc_setAssociatedObject(self, &CacheKey, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cache
            }
        }
        set {
            objc_setAssociatedObject(self, &CacheKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 计算cell高度
    @objc func DW_CalculateCell(withIdentifier identifier: String, indexPath: IndexPath, configuration: ((UITableViewCell) -> Void)?) -> CGFloat {
        //width等于0时，高度直接返回0
        if bounds.size.width == 0 || identifier.isEmpty || indexPath.count == 0 {
            return 0
        }
        let key = cache.makeKey(withIdentifier: identifier, indexPath: indexPath)
        // 高度是否存在
        if let height = cache.heightFromCache(key: key) {
            return CGFloat(height)
        }
        // 计算高度
        let height = DW_CalCulateCell(withIdentifier: identifier, configuration: configuration)
        // 高度缓存
        cache.cacheHeight(key: key, height: height)
        return height
    }
    
    // MARK: 工具方法
    // MARK: 从重用池中根据identifier取出cell
    func dequeueCell(identifier: String) -> UITableViewCell? {
        // 确保identifier不为空
        if identifier.isEmpty {
            return nil
        }
        
        // 从关联对象中获取cell字典，如果没有则新建一个
        var cellDic = objc_getAssociatedObject(self, &CacheKey) as? [String: UITableViewCell]
        if cellDic == nil {
            cellDic = [String: UITableViewCell]()
            objc_setAssociatedObject(self, &CacheKey, cellDic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        // 从字典中获取cell，如果没有则从重用池中获取
        var cell = cellDic?[identifier]
        if cell == nil {
            cell = dequeueReusableCell(withIdentifier: identifier)
            cell?.contentView.translatesAutoresizingMaskIntoConstraints = false
            cellDic?[identifier] = cell
        }
        
        return cell
    }
    
    // 根据重用表示取出cell并操作cell后，计算高度
    func DW_CalCulateCell(withIdentifier identifier: String, configuration: ((UITableViewCell) -> Void)?) -> CGFloat {
        guard let cell = dequeueCell(identifier: identifier) else {
            return 0
        }
        cell.prepareForReuse()
        configuration?(cell)
        return calculateCellHeight(cell: cell)
    }
    
    // MARK: 计算cell的高度
    func calculateCellHeight(cell: UITableViewCell) -> CGFloat {
        var width = self.bounds.size.width
        // 根据辅助视图校正width
        if let accessoryView = cell.accessoryView {
            width -= accessoryView.bounds.size.width + 16
        } else {
            let accessoryWidths: [UITableViewCell.AccessoryType: CGFloat] = [
                .none: 0,
                .disclosureIndicator: 34,
                .detailDisclosureButton: 68,
                .checkmark: 40,
                .detailButton: 48
            ]
            width -= accessoryWidths[cell.accessoryType] ?? 0
        }
        var height: CGFloat = 0
        if width > 0 {
            // 创建一个宽度约束，用于计算内容视图的自适应大小
            let widthFenceConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
            // 添加宽度约束到内容视图
            cell.contentView.addConstraint(widthFenceConstraint)
            // 计算内容视图的自适应大小，并获取高度
            height = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            // 移除宽度约束
            cell.contentView.removeConstraint(widthFenceConstraint)
        }
        // 如果高度仍然为0，则使用sizeThatFits方法计算高度
        if height == 0 {
            height = cell.sizeThatFits(CGSize(width: width, height: 0)).height
        }
        if height == 0 {
            height = 44
        }
        if self.separatorStyle != .none {
            height += 1.0 / UIScreen.main.scale
        }
        return height
    }
}
