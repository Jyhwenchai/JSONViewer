import SwiftUI
import WebKit

struct JSONWebView: View {
  let jsonString: String

  var body: some View {
    _PlatformWebView(jsonString: jsonString)
      .edgesIgnoringSafeArea(.all)
  }
}

#if os(macOS)
  struct _PlatformWebView: NSViewRepresentable {
    let jsonString: String

    func makeNSView(context: Context) -> WKWebView {
      let config = WKWebViewConfiguration()
      config.userContentController.add(context.coordinator, name: "jsonClick")

      let webView = WKWebView(
        frame: .zero,
        configuration: config
      )
      webView.navigationDelegate = context.coordinator
      webView.setValue(false, forKey: "drawsBackground")

      //      webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
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

      context.coordinator.webView = webView
      context.coordinator.pendingJSON = jsonString
      if let svgURL = Bundle.main.url(forResource: "jsoneditor-icons", withExtension: "svg", subdirectory: "img") {
          print("✅ 找到SVG:", svgURL.path)
      } else {
          print("❌ SVG未找到")
      }

      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
      weak var webView: WKWebView?
      var pendingJSON: String?

      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let json = pendingJSON {
          injectJSON(to: webView, jsonString: json)
          pendingJSON = nil
        }
      }

      func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
      ) {
        if message.name == "jsonClick" {
          print("点击节点返回：\(message.body)")
        }
      }
    }
  }
#else
  struct _PlatformWebView: UIViewRepresentable {
    let jsonString: String

    func makeUIView(context: Context) -> WKWebView {
      let config = WKWebViewConfiguration()
      config.userContentController.add(context.coordinator, name: "jsonClick")

      let webView = WKWebView(frame: .zero, configuration: config)
      webView.scrollView.bounces = false
      webView.navigationDelegate = context.coordinator

      if let htmlURL = Bundle.main.url(
        forResource: "jsonviewer",
        withExtension: "html",
        subdirectory: "jsoneditor"
      ) {
        webView.loadFileURL(
          htmlURL,
          allowingReadAccessTo: htmlURL.deletingLastPathComponent()
        )
      }

      context.coordinator.webView = webView
      context.coordinator.pendingJSON = jsonString
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
      weak var webView: WKWebView?
      var pendingJSON: String?

      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let json = pendingJSON {
          injectJSON(to: webView, jsonString: json)
          pendingJSON = nil
        }
      }

      func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
      ) {
        if message.name == "jsonClick" {
          print("点击节点返回：\(message.body)")
        }
      }
    }
  }
#endif

// MARK: - 注入 JSON
private func injectJSON(to webView: WKWebView, jsonString: String) {
  guard let data = jsonString.data(using: .utf8),
    let obj = try? JSONSerialization.jsonObject(with: data),
    let validJSONString = String(
      data: try! JSONSerialization.data(withJSONObject: obj),
      encoding: .utf8
    )
  else {
    print("⚠️ JSON 格式错误，无法解析")
    return
  }

  let js = "setJSON(\(validJSONString))"  // ✅ 直接传对象
  webView.evaluateJavaScript(js) { result, error in
    if let error = error {
      print("JavaScript执行错误: \(error)")
    }
  }
}
