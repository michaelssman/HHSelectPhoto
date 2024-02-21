# HHSelectPhoto

[![CI Status](https://img.shields.io/travis/michaelstrongself@outlook.com/HHSelectPhoto.svg?style=flat)](https://travis-ci.org/michaelstrongself@outlook.com/HHSelectPhoto)
[![Version](https://img.shields.io/cocoapods/v/HHSelectPhoto.svg?style=flat)](https://cocoapods.org/pods/HHSelectPhoto)
[![License](https://img.shields.io/cocoapods/l/HHSelectPhoto.svg?style=flat)](https://cocoapods.org/pods/HHSelectPhoto)
[![Platform](https://img.shields.io/cocoapods/p/HHSelectPhoto.svg?style=flat)](https://cocoapods.org/pods/HHSelectPhoto)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HHSelectPhoto is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HHSelectPhoto'
```

## Author

michaelstrongself@outlook.com, michaelstrongself@outlook.com

## License

HHSelectPhoto is available under the MIT license. See the LICENSE file for more info.

## HHSelectPhoto
相册图片选择
参考TZImagePickerController

### 导航控制器
- 最大选择数量
    因为有三个地方都需要设置：
    1:相册选择控制器
    2:多选图片控制器
    3:预览图片控制器
    这三个地方都需要设置，所以可以借用导航控制器，在导航控制器中设置。设置比较统一。
- 最小/最大选择数量
- 已选图片数组

### 选中cell才下载原图，不选中的话不显示原图。

### 照片选择导航栏选择相册
- 根据顶部按钮select状态去控制显示、隐藏相册选择页面。

### 相册选择
相册选择设置为导航控制器的一个属性。整个功能使用同一个。

关于第一次打开进入相册列表或相册的所有照片白屏的问题：
因为需要请求用户使用相册的权限，没有得到用户允许直接进入的话会显示空白的，需要进入之前就去请求权限。
使用之前都需要先申请权限。

判断照片是否是同一张:
有可能同一个照片在不同的相册中（例：即在最近相册又在所有图片相册）
根据PHAsset的localIdentifier去判断，每个照片的localIdentifier都不一样，类似图片的路径地址。

选中的图片数据：
跨相册也保存之前选中的图片的话，需要使用一个数组去保存选中的图片，定义一个model，model中包含选中的图片的略缩图、原图、和asset对象。
asset对象用来判断图片是不是同一张 是否已存在。

### 更新底部按钮状态和已选数量
底部按钮是否可以点击和修改显示状态，和底部文字数量等等是同步修改的。在一个方法中。

### 弹出选择器时，保持图片的选中状态
必须在弹出前传递上次已选中的Asset数组。那么如何保存Asset数组呢？
通过序列化PHAsset的localIdentifier，最后通过PHAsset的类方法，即可获得PHAsset对象
```
+ (PHFetchResult<PHAsset *> *)fetchAssetsWithLocalIdentifiers:(NSArray<NSString *> *)identifiers options:(nullable PHFetchOptions *)options;
```

#### 关于图片类型
定义一个枚举类型。
GIF和图片不同， 不能压缩，只能用nsdata，使用UIImage不会动。

### HHNative （调用原生的相册和拍照功能）
```
UIImagePickerController *controller = [[UIImagePickerController alloc] init];
controller.delegate = self;
```
关于delegate：点击进入看到delegate属性 ` @property(nullable,nonatomic,weak)      id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate; ` ，包括导航栏代理方法和照片代理方法。

#### 相机拍照要保存到相册。获取到PHAsset。

### 底部选中的小图显示
使用KVO，观察选中的数组个数，为0时消失，大于0时显示。
