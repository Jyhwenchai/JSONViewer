#!/bin/bash

# 脚本：将Resources文件夹中的文件添加到Xcode项目
# 使用方法：在项目根目录运行 ./add_resources_to_xcode.sh

echo "🔧 正在检查资源文件..."

# 检查资源文件是否存在
RESOURCES_DIR="JSONViewer/Resources"
if [ ! -d "$RESOURCES_DIR" ]; then
    echo "❌ Resources目录不存在: $RESOURCES_DIR"
    exit 1
fi

echo "✅ 找到Resources目录"

# 列出资源文件
echo "📁 Resources目录内容:"
ls -la "$RESOURCES_DIR"

echo ""
echo "📋 需要手动在Xcode中执行以下步骤:"
echo "1. 打开 JSONViewer.xcodeproj"
echo "2. 在左侧项目导航器中右键点击 'JSONViewer' 文件夹"
echo "3. 选择 'Add Files to JSONViewer...'"
echo "4. 导航到 JSONViewer/Resources 文件夹"
echo "5. 选择以下文件:"
echo "   - jsonviewer.html"
echo "   - jsoneditor.min.css"
echo "   - jsoneditor.min.js"
echo "6. 确保 'Add to target' 中勾选了 'JSONViewer'"
echo "7. 点击 'Add'"
echo ""
echo "或者："
echo "1. 选中 JSONViewer target"
echo "2. 进入 'Build Phases' 标签"
echo "3. 展开 'Copy Bundle Resources'"
echo "4. 点击 '+' 按钮"
echo "5. 添加上述三个文件"
echo ""
echo "🚀 完成后重新构建项目即可！"