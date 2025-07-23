import SwiftUI
import WebKit

struct EmbeddedJSONViewer: View {
    let jsonString: String
    
    var body: some View {
        EmbeddedWebView(jsonString: jsonString)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - 内嵌HTML的WebView实现
#if os(macOS)
struct EmbeddedWebView: NSViewRepresentable {
    let jsonString: String
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "jsonClick")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        
        // 使用内嵌的HTML和CSS
        let htmlContent = createEmbeddedHTML()
        webView.loadHTMLString(htmlContent, baseURL: nil)
        
        context.coordinator.webView = webView
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 延迟执行，确保页面已加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let js = "setJSON(\(jsonString.debugDescription))"
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("JavaScript执行错误: \(error)")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        weak var webView: WKWebView?
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if message.name == "jsonClick" {
                print("点击节点返回：\(message.body)")
            }
        }
    }
}

#else
struct EmbeddedWebView: UIViewRepresentable {
    let jsonString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "jsonClick")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.bounces = false
        
        // 使用内嵌的HTML和CSS
        let htmlContent = createEmbeddedHTML()
        webView.loadHTMLString(htmlContent, baseURL: nil)
        
        context.coordinator.webView = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 延迟执行，确保页面已加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let js = "setJSON(\(jsonString.debugDescription))"
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("JavaScript执行错误: \(error)")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        weak var webView: WKWebView?
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if message.name == "jsonClick" {
                print("点击节点返回：\(message.body)")
            }
        }
    }
}
#endif

// MARK: - 创建内嵌HTML内容
func createEmbeddedHTML() -> String {
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>JSON Viewer</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
                background: #1e1e1e;
                color: #d4d4d4;
                padding: 16px;
                line-height: 1.4;
            }
            
            .json-container {
                background: #252526;
                border-radius: 8px;
                padding: 16px;
                border: 1px solid #3e3e42;
                overflow: auto;
                max-height: 100vh;
            }
            
            .json-key {
                color: #9cdcfe;
                font-weight: bold;
            }
            
            .json-string {
                color: #ce9178;
            }
            
            .json-number {
                color: #b5cea8;
            }
            
            .json-boolean {
                color: #569cd6;
                font-weight: bold;
            }
            
            .json-null {
                color: #569cd6;
                font-style: italic;
            }
            
            .json-bracket {
                color: #d4d4d4;
                font-weight: bold;
            }
            
            .json-indent {
                margin-left: 20px;
            }
            
            .json-line {
                margin: 2px 0;
            }
            
            .collapsible {
                cursor: pointer;
                user-select: none;
            }
            
            .collapsible:hover {
                background-color: #2d2d30;
                border-radius: 3px;
            }
            
            .collapsed {
                display: none;
            }
            
            .toggle {
                display: inline-block;
                width: 12px;
                text-align: center;
                color: #cccccc;
                font-size: 10px;
            }
        </style>
    </head>
    <body>
        <div id="json-viewer" class="json-container">
            <div>等待JSON数据...</div>
        </div>
        
        <script>
            function setJSON(jsonString) {
                try {
                    const json = JSON.parse(jsonString);
                    const container = document.getElementById('json-viewer');
                    container.innerHTML = formatJSON(json, 0);
                    addToggleListeners();
                } catch (e) {
                    console.error("Invalid JSON", e);
                    document.getElementById('json-viewer').innerHTML = 
                        '<div style="color: #f44747;">JSON解析错误: ' + e.message + '</div>';
                }
            }
            
            function formatJSON(obj, indent = 0) {
                const indentStr = '  '.repeat(indent);
                
                if (obj === null) {
                    return '<span class="json-null">null</span>';
                }
                
                if (typeof obj === 'string') {
                    return '<span class="json-string">"' + escapeHtml(obj) + '"</span>';
                }
                
                if (typeof obj === 'number') {
                    return '<span class="json-number">' + obj + '</span>';
                }
                
                if (typeof obj === 'boolean') {
                    return '<span class="json-boolean">' + obj + '</span>';
                }
                
                if (Array.isArray(obj)) {
                    if (obj.length === 0) {
                        return '<span class="json-bracket">[]</span>';
                    }
                    
                    let result = '<div class="json-line">';
                    result += '<span class="collapsible"><span class="toggle">▼</span><span class="json-bracket">[</span></span>';
                    result += '<div class="json-content">';
                    
                    obj.forEach((item, index) => {
                        result += '<div class="json-line json-indent">';
                        result += formatJSON(item, indent + 1);
                        if (index < obj.length - 1) {
                            result += '<span class="json-bracket">,</span>';
                        }
                        result += '</div>';
                    });
                    
                    result += '</div>';
                    result += '<div class="json-line"><span class="json-bracket">]</span></div>';
                    result += '</div>';
                    return result;
                }
                
                if (typeof obj === 'object') {
                    const keys = Object.keys(obj);
                    if (keys.length === 0) {
                        return '<span class="json-bracket">{}</span>';
                    }
                    
                    let result = '<div class="json-line">';
                    result += '<span class="collapsible"><span class="toggle">▼</span><span class="json-bracket">{</span></span>';
                    result += '<div class="json-content">';
                    
                    keys.forEach((key, index) => {
                        result += '<div class="json-line json-indent">';
                        result += '<span class="json-key">"' + escapeHtml(key) + '"</span>';
                        result += '<span class="json-bracket">: </span>';
                        result += formatJSON(obj[key], indent + 1);
                        if (index < keys.length - 1) {
                            result += '<span class="json-bracket">,</span>';
                        }
                        result += '</div>';
                    });
                    
                    result += '</div>';
                    result += '<div class="json-line"><span class="json-bracket">}</span></div>';
                    result += '</div>';
                    return result;
                }
                
                return String(obj);
            }
            
            function escapeHtml(text) {
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }
            
            function addToggleListeners() {
                document.querySelectorAll('.collapsible').forEach(element => {
                    element.addEventListener('click', function(e) {
                        e.stopPropagation();
                        const content = this.parentNode.querySelector('.json-content');
                        const toggle = this.querySelector('.toggle');
                        
                        if (content.style.display === 'none') {
                            content.style.display = 'block';
                            toggle.textContent = '▼';
                        } else {
                            content.style.display = 'none';
                            toggle.textContent = '▶';
                        }
                        
                        // 通知原生代码
                        if (window.webkit && window.webkit.messageHandlers.jsonClick) {
                            window.webkit.messageHandlers.jsonClick.postMessage({
                                action: 'toggle',
                                expanded: content.style.display !== 'none'
                            });
                        }
                    });
                });
            }
        </script>
    </body>
    </html>
    """
}