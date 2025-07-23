#!/usr/bin/env swift

import Foundation

// 测试脚本：检查资源文件是否能被正确找到
print("🔍 测试资源文件访问...")

let currentDir = FileManager.default.currentDirectoryPath
print("当前目录: \(currentDir)")

// 检查HTML文件
let htmlPath = "JSONViewer/Resources/jsonviewer.html"
if FileManager.default.fileExists(atPath: htmlPath) {
    print("✅ 找到HTML文件: \(htmlPath)")
    
    do {
        let content = try String(contentsOfFile: htmlPath, encoding: .utf8)
        print("✅ HTML文件大小: \(content.count) 字符")
        print("✅ HTML文件前100字符: \(String(content.prefix(100)))")
    } catch {
        print("❌ 读取HTML文件失败: \(error)")
    }
} else {
    print("❌ 未找到HTML文件: \(htmlPath)")
}

// 检查CSS文件
let cssPath = "JSONViewer/Resources/jsoneditor.min.css"
if FileManager.default.fileExists(atPath: cssPath) {
    print("✅ 找到CSS文件: \(cssPath)")
    
    do {
        let content = try String(contentsOfFile: cssPath, encoding: .utf8)
        print("✅ CSS文件大小: \(content.count) 字符")
    } catch {
        print("❌ 读取CSS文件失败: \(error)")
    }
} else {
    print("❌ 未找到CSS文件: \(cssPath)")
}

// 检查JS文件
let jsPath = "JSONViewer/Resources/jsoneditor.min.js"
if FileManager.default.fileExists(atPath: jsPath) {
    print("✅ 找到JS文件: \(jsPath)")
    
    do {
        let content = try String(contentsOfFile: jsPath, encoding: .utf8)
        print("✅ JS文件大小: \(content.count) 字符")
    } catch {
        print("❌ 读取JS文件失败: \(error)")
    }
} else {
    print("❌ 未找到JS文件: \(jsPath)")
}

print("\n🚀 测试完成！")