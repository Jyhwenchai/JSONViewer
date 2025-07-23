# JSONViewer

一个基于SwiftUI和WebKit的JSON查看器应用。

## 问题诊断与解决方案

### 问题描述
应用运行后WebView无法正确渲染，显示空白页面。

### 根本原因
资源文件（HTML、CSS、JS）没有正确添加到Xcode项目的bundle中，导致`Bundle.main.url(forResource:withExtension:)`返回nil。

### 解决方案

#### 方案1：使用内嵌HTML版本（推荐）
已创建`EmbeddedJSONViewer`组件，将所有HTML、CSS、JavaScript代码内嵌到Swift文件中，避免资源文件依赖问题。

使用方法：
```swift
EmbeddedJSONViewer(jsonString: yourJSONString)
```

#### 方案2：修复资源文件配置
如果要使用外部资源文件，需要在Xcode中：

1. 选中`JSONViewer.xcodeproj`
2. 选择`JSONViewer` target
3. 在`Build Phases`中找到`Copy Bundle Resources`
4. 点击`+`添加以下文件：
   - `jsonviewer.html`
   - `jsoneditor.min.css`
   - `jsoneditor.min.js`

### 功能特性

- ✅ JSON语法高亮
- ✅ 可折叠的树形结构
- ✅ 深色主题
- ✅ 跨平台支持（iOS/macOS）
- ✅ 点击节点交互

### 使用示例

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        EmbeddedJSONViewer(jsonString: """
        {
          "name": "example",
          "data": [1, 2, 3],
          "enabled": true
        }
        """)
    }
}
```

一个基于SwiftUI和WebKit的跨平台JSON查看器应用，支持macOS和iOS平台。

## 项目概述

JSONViewer是一个简洁高效的JSON数据可视化工具，使用SwiftUI构建用户界面，集成WebKit来展示格式化的JSON内容。应用采用成熟的jsoneditor JavaScript库来提供专业的JSON展示效果。

## 功能特性

- ✅ **JSON可视化展示** - 清晰的树状结构展示JSON数据
- ✅ **跨平台支持** - 同时支持macOS和iOS
- ✅ **交互式浏览** - 支持点击JSON节点查看详细信息
- ✅ **只读模式** - 专注于数据查看，避免意外修改
- ✅ **响应式设计** - 适配不同屏幕尺寸
- ✅ **安全沙盒** - 遵循Apple安全最佳实践

## 技术架构

### 核心组件

```
JSONViewer/
├── JSONViewerApp.swift      # 应用入口点
├── ContentView.swift        # 主界面视图
├── JSONWebView.swift        # WebView封装组件
├── Resources/
│   └── jsonviewer.html      # JSON展示页面
└── JSONViewer.entitlements  # 安全权限配置
```

### 技术栈

- **前端框架**: SwiftUI
- **Web组件**: WebKit (WKWebView)
- **JSON渲染**: jsoneditor JavaScript库
- **平台支持**: macOS 15.5+, iOS (通过条件编译)
- **开发工具**: Xcode 16.4

## 快速开始

### 环境要求

- macOS 15.5 或更高版本
- Xcode 16.4 或更高版本
- Swift 5.0

### 构建和运行

1. 克隆项目到本地
```bash
git clone <repository-url>
cd JSONViewer
```

2. 使用Xcode打开项目
```bash
open JSONViewer.xcodeproj
```

3. 选择目标平台并运行
   - 对于macOS: 选择"My Mac"
   - 对于iOS: 选择iOS模拟器或真机

## 使用方法

### 基本用法

应用启动后会显示一个示例JSON数据：

```json
{
  "name": "xcode build server",
  "version": "0.2", 
  "languages": ["c", "swift", "objective-c"],
  "enabled": true,
  "value": null
}
```

### 自定义JSON数据

要显示自己的JSON数据，可以修改`ContentView.swift`中的`jsonString`参数：

```swift
JSONWebView(jsonString: """
{
  "your": "json",
  "data": "here"
}
""")
```

### 交互功能

- **点击节点**: 点击任意JSON节点会在控制台输出选中的路径和值
- **导航栏**: 使用内置导航栏浏览JSON结构
- **展开/折叠**: 点击节点前的箭头展开或折叠子项

## 平台差异

### macOS特性
- 透明背景支持
- 使用`NSViewRepresentable`集成WebView
- 完整的窗口管理

### iOS特性  
- 禁用滚动弹性效果
- 使用`UIViewRepresentable`集成WebView
- 触摸优化的交互体验

## 项目结构详解

### Swift文件

- **JSONViewerApp.swift**: 应用的主入口点，定义了SwiftUI应用的生命周期
- **ContentView.swift**: 主视图控制器，包含测试数据和界面布局
- **JSONWebView.swift**: 核心组件，封装了WebView并处理平台差异

### Web资源

- **jsonviewer.html**: 包含jsoneditor库的HTML页面
- **jsoneditor.min.js**: JSON编辑器JavaScript库（需要添加到项目中）
- **jsoneditor.min.css**: 样式文件（需要添加到项目中）

### 配置文件

- **JSONViewer.entitlements**: 定义应用权限，启用沙盒和文件访问
- **project.pbxproj**: Xcode项目配置文件

## 开发指南

### 添加新功能

1. **文件导入功能**
```swift
// 在ContentView中添加文件选择器
@State private var showingFilePicker = false

Button("导入JSON文件") {
    showingFilePicker = true
}
.fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.json]) { result in
    // 处理文件导入逻辑
}
```

2. **错误处理增强**
```swift
// 在JSONWebView中添加错误状态
@State private var errorMessage: String?

if let error = errorMessage {
    Text("JSON解析错误: \(error)")
        .foregroundColor(.red)
}
```

### 自定义样式

修改`jsonviewer.html`中的CSS来自定义外观：

```css
#jsoneditor {
    font-family: 'SF Mono', monospace;
    font-size: 14px;
    background-color: #f8f9fa;
}
```

## 安全考虑

- 应用运行在沙盒环境中，限制了系统访问
- 只有只读文件访问权限
- WebView内容受到严格的安全策略限制
- 适合Mac App Store分发

## 性能优化

- 对于大型JSON文件，考虑实现懒加载
- 使用虚拟滚动来处理大量数据
- 缓存解析结果以提高响应速度

## 故障排除

### 常见问题

1. **HTML文件无法加载**
   - 确保`jsonviewer.html`在Bundle中正确包含
   - 检查文件路径和权限设置

2. **JavaScript库缺失**
   - 确保`jsoneditor.min.js`和`jsoneditor.min.css`已添加到项目
   - 验证文件引用路径正确

3. **JSON解析失败**
   - 检查JSON格式是否有效
   - 查看控制台错误信息

## 贡献指南

欢迎提交Issue和Pull Request来改进这个项目。

### 开发流程

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 许可证

本项目采用MIT许可证。详见LICENSE文件。

## 更新日志

### v1.0.0 (2025-07-22)
- 初始版本发布
- 支持基本JSON查看功能
- 跨平台macOS/iOS支持
- 集成jsoneditor库

## 联系方式

如有问题或建议，请通过以下方式联系：

- 创建GitHub Issue
- 发送邮件至开发者

---

**JSONViewer** - 让JSON数据查看变得简单高效 🚀