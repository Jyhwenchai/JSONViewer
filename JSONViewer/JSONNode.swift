import SwiftUI

// MARK: - 数据结构
struct JSONNode: Identifiable {
    let id = UUID()
    let key: String
    let value: JSONValue
    
    // 关键：为 OutlineGroup 提供 KeyPath
    var children: [JSONNode]? {
        switch value {
        case .object(let nodes), .array(let nodes):
            return nodes
        default:
            return nil
        }
    }
}

enum JSONValue {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    case object([JSONNode])
    case array([JSONNode])
}

// MARK: - JSON Viewer
struct JSONViewer: View {
    let data: [JSONNode]
    
    var body: some View {
        OutlineGroup(data, children: \.children) { node in
            JSONRowView(node: node)
        }
        .font(.system(.body, design: .monospaced))
        .padding()
    }
}

// MARK: - JSON 行样式（高亮规则）
struct JSONRowView: View {
    let node: JSONNode
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\"\(node.key)\"")
                .foregroundColor(.blue)
            
            Text(":")
                .foregroundColor(.primary)
            
            switch node.value {
            case .string(let str):
                Text("\"\(str)\"").foregroundColor(.green)
            case .number(let num):
                Text("\(num)").foregroundColor(.orange)
            case .bool(let bool):
                Text(bool ? "true" : "false").foregroundColor(.purple)
            case .null:
                Text("null").foregroundColor(.gray)
            case .object:
                Text("{...}").foregroundColor(.secondary)
            case .array:
                Text("[...]").foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - JSON Parser（把原始 JSON 转为 Node）
func parseJSON(_ json: Any, key: String = "root") -> JSONNode {
    if let dict = json as? [String: Any] {
        return JSONNode(key: key, value: .object(
            dict.map { parseJSON($0.value, key: $0.key) }
        ))
    } else if let arr = json as? [Any] {
        return JSONNode(key: key, value: .array(
            arr.enumerated().map { parseJSON($0.element, key: "\($0.offset)") }
        ))
    } else if let str = json as? String {
        return JSONNode(key: key, value: .string(str))
    } else if let num = json as? Double {
        return JSONNode(key: key, value: .number(num))
    } else if let num = json as? Int {
        return JSONNode(key: key, value: .number(Double(num)))
    } else if let bool = json as? Bool {
        return JSONNode(key: key, value: .bool(bool))
    } else {
        return JSONNode(key: key, value: .null)
    }
}
