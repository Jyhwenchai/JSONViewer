import SwiftUI
import WebKit

// MARK: - WKWebView 的 SwiftUI 包装器
struct WebView: NSViewRepresentable {
    let url: URL?
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var title: String
    
    // 用于从外部控制 WebView 的类
    class WebViewController: ObservableObject {
        var webView: WKWebView?
        
        func goBack() {
            webView?.goBack()
        }
        
        func goForward() {
            webView?.goForward()
        }
        
        func reload() {
            webView?.reload()
        }
        
        func stopLoading() {
            webView?.stopLoading()
        }
        
        func loadURL(_ url: URL) {
            let request = URLRequest(url: url)
            webView?.load(request)
        }
    }
    
    let controller: WebViewController
    
    init(url: URL?, isLoading: Binding<Bool>, canGoBack: Binding<Bool>, canGoForward: Binding<Bool>, title: Binding<String>, controller: WebViewController) {
        self.url = url
        self._isLoading = isLoading
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self._title = title
        self.controller = controller
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // 启用 JavaScript
        configuration.preferences.javaScriptEnabled = true
        
        // 配置用户代理
        configuration.applicationNameForUserAgent = "MyApp/1.0"
        
        // 启用开发者工具（调试用）
        #if DEBUG
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // 设置委托
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // 启用手势导航
        webView.allowsBackForwardNavigationGestures = true
        
        // 保存 webView 实例到 controller
        controller.webView = webView
        
        // 立即加载 URL（如果有的话）
//        if let url = url {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
        
      if let htmlURL = Bundle.main.url(
//        forResource: "03_switch_mode",
        forResource: "jsonviewer",
        withExtension: "html",
      ) {
        webView.loadFileURL(
          htmlURL,
          allowingReadAccessTo: htmlURL.deletingLastPathComponent()
        )
      }
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 当 URL 改变时重新加载
//        if let url = url, webView.url != url {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
    }
    
    // MARK: - Coordinator 类
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.parent.title = webView.title ?? ""
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                print("Navigation failed: \(error.localizedDescription)")
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                print("Provisional navigation failed: \(error.localizedDescription)")
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("Loading URL: \(navigationAction.request.url?.absoluteString ?? "unknown")")
            decisionHandler(.allow)
        }
        
        // MARK: - WKUIDelegate
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "网页消息"
                alert.informativeText = message
                alert.addButton(withTitle: "确定")
                alert.runModal()
                completionHandler()
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "确认"
                alert.informativeText = message
                alert.addButton(withTitle: "确定")
                alert.addButton(withTitle: "取消")
                let response = alert.runModal()
                completionHandler(response == .alertFirstButtonReturn)
            }
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

// MARK: - 主应用视图
struct ContentView1: View {
    @State private var urlString = "https://www.baidu.com"
    @State private var currentURL: URL?
    @State private var isLoading = false
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var title = ""
    @StateObject private var webViewController = WebView.WebViewController()
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            VStack {
                HStack {
                    // URL 输入框
                    HStack {
                        TextField("输入网址", text: $urlString)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                loadURL()
                            }
                        
                        Button("前往") {
                            loadURL()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Spacer()
                    
                    // 导航按钮
                    HStack {
                        Button(action: {
                            webViewController.goBack()
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(!canGoBack)
                        
                        Button(action: {
                            webViewController.goForward()
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(!canGoForward)
                        
                        Button(action: {
                            if isLoading {
                                webViewController.stopLoading()
                            } else {
                                webViewController.reload()
                            }
                        }) {
                            Image(systemName: isLoading ? "xmark" : "arrow.clockwise")
                        }
                    }
                }
                
                // 标题和加载状态
                HStack {
                    if !title.isEmpty {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("加载中...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 5)
            }
            .padding()
            
            Divider()
            
            // WebView 容器
            ZStack {
                // 背景色
                Color.white
                
                // WebView
                if let url = currentURL {
                    WebView(
                        url: url,
                        isLoading: $isLoading,
                        canGoBack: $canGoBack,
                        canGoForward: $canGoForward,
                        title: $title,
                        controller: webViewController
                    )
                } else {
                    // 占位视图
                    VStack {
                        Image(systemName: "globe")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("请输入网址开始浏览")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        Button("加载默认页面") {
                            urlString = "https://www.baidu.com"
                            loadURL()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 700)
        .onAppear {
            // 应用启动时加载默认页面
            loadURL()
        }
    }
    
    // MARK: - 私有方法
    
    private func loadURL() {
        var urlToLoad = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 如果为空，使用默认 URL
        if urlToLoad.isEmpty {
            urlToLoad = "https://www.baidu.com"
            urlString = urlToLoad
        }
        
        // 如果没有协议前缀，自动添加 https://
        if !urlToLoad.hasPrefix("http://") && !urlToLoad.hasPrefix("https://") {
            urlToLoad = "https://" + urlToLoad
            urlString = urlToLoad
        }
        
        // 创建 URL 并触发加载
        if let url = URL(string: urlToLoad) {
            currentURL = url
            
            // 如果 WebView 已经创建，直接加载
            if webViewController.webView != nil {
                webViewController.loadURL(url)
            }
        } else {
            print("无效的 URL: \(urlToLoad)")
        }
    }
}

// MARK: - App 入口
//@main
//struct WebBrowserApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .navigationTitle("Web Browser")
//        }
//        .windowStyle(DefaultWindowStyle())
//        .commands {
//            CommandGroup(after: .newItem) {
//                Button("刷新页面") {
//                    NotificationCenter.default.post(name: .refreshWebView, object: nil)
//                }
//                .keyboardShortcut("r", modifiers: .command)
//            }
//        }
//    }
//}

// MARK: - 扩展和通知
extension Notification.Name {
    static let refreshWebView = Notification.Name("refreshWebView")
}
