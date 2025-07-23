//
//  ContentView.swift
//  JSONViewer
//
//  Created by didong on 2025/7/22.
//

import SwiftUI
import WebKit

// MARK: - 测试示例
struct ContentView: View {
  var body: some View {
    JSONWebView(
      jsonString: """
        {
          "name": "xcode build server",
          "version": "0.2",
          "languages": ["c", "swift", "objective-c"],
          "enabled": true,
          "value": null
        }
        """
    )
    .frame(width: 600, height: 1000)
    .background(Color.red)
  }
}

#Preview {
  ContentView()
}
