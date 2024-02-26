//
//  HHWebView.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/7/21.
//

import UIKit
import WebKit

public class HHWebView: UIView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    // MARK: - Lazy Initialization of WKWebView
    lazy var webView: WKWebView = {
        // Configure user content controller for handling JavaScript messages
        let userContentController: WKUserContentController = WKUserContentController()
        let config: WKWebViewConfiguration = WKWebViewConfiguration()
        config.userContentController = userContentController
        //视频播放器，禁止默认全屏播放
        config.allowsInlineMediaPlayback = true
        
        // Configure preferences
        let preferences: WKPreferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        // Create the WKWebView instance
        //webView的frame初始CGRectMake(0, 0, self.view.bounds.size.width, 0)，是因为如果设置frame高度大，contentSize小的时候，返回的contentSize的高度就是frame的高度。就不会准确。
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: SCREEN_HEIGHT), configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        return webView
    }()
    
    public var urlString: String = "" {
        didSet {
            if let url = URL(string: urlString) {
                let urlRequest: URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                webView.load(urlRequest)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(webView)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocated.")
        removeObserver()
    }
    
    func addObserver() {
        // Add observers for handling web view events
        //交互 WKScriptMessageHandler
        webView.configuration.userContentController.add(self, name: "Native")
        //监听webview高度变化
        webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //获取网页标题
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        //获取网页加载进度和加载状态
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new, .old], context: nil)
        //监听UIWindow隐藏(防止全屏播放视频返回后状态栏消失)
        NotificationCenter.default.addObserver(self, selector: #selector(endFullScreen), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }
    
    func removeObserver() {
        // Remove observers when the view is about to disappear
        // 这个也需要移除 不然不释放 应该是在viewWillDisappear中移除，在viewWillAppear中添加。
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "Native")
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeHiddenNotification, object: nil)
    }
    
    // MARK: 设置userAgent
    func setUserAgent() {
        webView.evaluateJavaScript("navigator.userAgent") { [self] (result: Any?, error: Error?) in
            var userAgent: String = result as! String
            userAgent.append("")
            webView.customUserAgent = userAgent
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webViewDidStartLoad")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webViewDidFinishLoad")
        // You can perform any additional tasks after the webView finishes loading here.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if #available(iOS 11.0, *) {
                takeScreenshot()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webViewDidFail")
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webViewDidFailProvisional")
    }
    
    /// 截获点击网页上的链接方法 可以自己去跳转
    /// - Parameters:
    ///   - webView: <#webView description#>
    ///   - navigationAction: <#navigationAction description#>
    ///   - decisionHandler: 发送请求之前，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
        // Decide whether to allow the navigation or not based on the URL
        let originalRequest = navigationAction.request
        let url = originalRequest.url?.absoluteString
        if let url = url, url == "某一个地址" {
            // Do your custom handling for this URL
            // 1. Set request header
            var modifiedRequest = originalRequest
            modifiedRequest.addValue("token", forHTTPHeaderField: "Authorization")
            webView.evaluateJavaScript("'\(url)'.setCoustomHeader = function() { this.setRequestHeader('Authorization', 'Bearer ') }", completionHandler: { _, _ in
                print("Successfully injected JS")
            })
            
            // 2. Perform your custom page navigation
            
            // Cancel automatic H5 navigation
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
        // Do any custom handling for the navigation response, such as extracting headers, etc.
        decisionHandler(.allow)
    }
    
    
    // MARK: - WKUIDelegate Methods
    //创建一个新的webView
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Create a new webView for the given navigation action
        webView.load(navigationAction.request)
        return webView
    }
    //警告框
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // Handle JavaScript alert() call
        let alertVC = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler()
        }))
        self.viewController()?.present(alertVC, animated: true, completion: nil)
    }
    //确认框
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // Handle JavaScript confirm() call
        let alertVC = UIAlertController(title: "confirm", message: "JS调用confirm", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        self.viewController()?.present(alertVC, animated: true, completion: nil)
    }
    //输入框
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // Handle JavaScript prompt() call
        let alertVC = UIAlertController(title: "textInput", message: "js调用输入框", preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.textColor = UIColor.red
        }
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(alertVC.textFields?.last?.text)
        }))
        self.viewController()?.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - WKScriptMessageHandler Method
    // Implement the WKScriptMessageHandler method to handle JavaScript messages
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "Native", let bodyParam = message.body as? [String: Any], let funcName = bodyParam["func"] as? String {
            if funcName == "" {
                // Perform actions for native methods
            }
        }
    }
    
    // MARK: - KVO (Key-Value Observing) Method
    // Implement KVO to observe changes in web view properties
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", webView.isLoading {
            let webViewHeight = webView.scrollView.contentSize.height
            print("hhhhh:\(webView.isLoading) contentH:\(webViewHeight)")
            webView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: webViewHeight > bounds.height ? bounds.height : webViewHeight)
            frame = webView.frame;
        } else if keyPath == "title", let title = webView.title, viewController()?.navigationController != nil {
            viewController()?.navigationItem.title = title
        } else if keyPath == "estimatedProgress", let newProgress = change?[.newKey] as? Double {
            print("Loading progress: \(newProgress)")
            if newProgress >= 1.0 {
                print("Loading finished")
            }
        }
    }
    
    // MARK: - Full-Screen Video Handling
    @objc func endFullScreen() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: - Load Local File (Optional)
    @objc public func loadLocalFile(filePath: String?) {
        guard let filePath = filePath,
              let url = URL(string: filePath) else {
            return
        }
        var mimeType = ""
        if filePath.hasSuffix(".pdf") {
            mimeType = "application/pdf"
        } else if filePath.hasSuffix(".docx") {
            mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        } else if filePath.hasSuffix(".pptx") {
            mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        } else if filePath.hasSuffix(".xlsx") {
            mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        }
        
        let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
        webView.loadFileURL(url, allowingReadAccessTo: baseURL)
        do {
            try webView.load(Data(contentsOf: url), mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: baseURL)
        } catch {
            print("loadLocalFile")
        }
    }
    
    // MARK: 截图
    @available(iOS 11.0, *)
    func takeScreenshot() {
        let configuration = WKSnapshotConfiguration()
        configuration.rect = CGRect(origin: .zero, size: webView.scrollView.contentSize)
        
        webView.takeSnapshot(with: configuration) { (image, error) in
            if let error = error {
                print("Failed to take screenshot: \(error.localizedDescription)")
                return
            }
            
            if let image = image {
                // 这里可以将截图得到的image进行保存或显示
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
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
