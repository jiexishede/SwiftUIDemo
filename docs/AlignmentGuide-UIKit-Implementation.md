# 🎯 UIKit 实现的流式布局

## 概述

`AlignmentGuideFlowLayoutSimpleUIKitView` 展示了如何使用 UIKit 的 `UICollectionView` 实现流式布局，然后通过 `UIViewRepresentable` 包装成 SwiftUI 组件。

This implementation demonstrates how to use UIKit's `UICollectionView` for flow layout, wrapped as a SwiftUI component through `UIViewRepresentable`.

## 为什么选择 UIKit

### 优势
1. **稳定性** - UICollectionViewFlowLayout 经过多年优化，布局算法成熟稳定
2. **性能** - 原生 UIKit 在处理大量数据时性能更好
3. **灵活性** - 提供更多布局控制选项
4. **可靠性** - 避免 SwiftUI alignmentGuide 的作用域问题

### Advantages
1. **Stability** - UICollectionViewFlowLayout is mature and well-optimized
2. **Performance** - Native UIKit performs better with large datasets
3. **Flexibility** - More layout control options
4. **Reliability** - Avoids SwiftUI alignmentGuide scope issues

## 技术架构

### 核心组件

```swift
// 1. SwiftUI 包装视图
struct AlignmentGuideFlowLayoutSimpleUIKitView: View

// 2. UIViewRepresentable 桥接
struct UIKitFlowLayout: UIViewRepresentable

// 3. UICollectionView 协调器
class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

// 4. 自定义 Cell
class TextCollectionViewCell: UICollectionViewCell
```

### 数据流

```
SwiftUI State → UIViewRepresentable → Coordinator → UICollectionView → Cells
     ↑                                                                      ↓
     └─────────────────── Height Update Callback ──────────────────────────┘
```

## 功能实现

### 1. 容器内边距
通过 `UICollectionViewFlowLayout.sectionInset` 实现：
```swift
layout.sectionInset = UIEdgeInsets(
    top: containerPadding,
    left: containerPadding,
    bottom: containerPadding,
    right: containerPadding
)
```

### 2. 项目间距
通过 FlowLayout 的间距属性控制：
```swift
layout.minimumInteritemSpacing = itemSpacing  // 水平间距
layout.minimumLineSpacing = lineSpacing        // 垂直间距
```

### 3. 最大宽度限制
在 `sizeForItemAt` 代理方法中计算：
```swift
let maxWidth = itemMaxWidth.map { $0 - padding } ?? .greatestFiniteMagnitude
let textSize = (text as NSString).boundingRect(
    with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
    options: [.usesLineFragmentOrigin, .usesFontLeading],
    attributes: [.font: font],
    context: nil
).size
```

### 4. 文字截断
在 Cell 中配置：
```swift
label.numberOfLines = 1
label.lineBreakMode = .byTruncatingTail
```

## 与 SwiftUI 版本对比

| 特性 | SwiftUI AlignmentGuide | UIKit CollectionView |
|-----|------------------------|---------------------|
| 布局稳定性 | ⚠️ 有闭包作用域问题 | ✅ 稳定可靠 |
| 性能 | 🔶 中等 | ✅ 优秀 |
| 代码复杂度 | ✅ 简单 | 🔶 中等 |
| 自定义能力 | 🔶 有限 | ✅ 强大 |
| iOS 兼容性 | ✅ iOS 15+ | ✅ iOS 15+ |

## 关键实现细节

### 1. 动态高度计算
```swift
// 禁用 CollectionView 自身滚动
collectionView.isScrollEnabled = false

// 计算内容高度
let height = uiView.collectionViewLayout.collectionViewContentSize.height
```

### 2. 数据更新机制
```swift
func updateUIView(_ uiView: UICollectionView, context: Context) {
    // 更新布局参数
    if let layout = uiView.collectionViewLayout as? UICollectionViewFlowLayout {
        // 更新间距等参数
    }
    
    // 更新数据并刷新
    context.coordinator.texts = texts
    uiView.reloadData()
}
```

### 3. 尺寸计算优化
使用 NSString 的 boundingRect 方法精确计算文字尺寸，确保布局准确。

## 使用建议

### 适用场景
1. 需要稳定可靠的流式布局
2. 处理大量数据项
3. 需要精确控制布局行为
4. 对性能有较高要求

### 注意事项
1. UIKit 组件需要更多样板代码
2. 与 SwiftUI 状态管理的集成需要通过 Coordinator
3. 样式定制需要同时处理 UIKit 和 SwiftUI

## 总结

UIKit 实现提供了一个稳定、高性能的流式布局解决方案。虽然代码复杂度略高，但在布局可靠性和性能方面具有明显优势，特别适合生产环境使用。

The UIKit implementation provides a stable, high-performance flow layout solution. While it requires more code, it offers significant advantages in layout reliability and performance, making it particularly suitable for production use.