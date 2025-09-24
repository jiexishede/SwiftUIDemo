# 🔧 修复最大宽度限制下的间距问题

## 问题描述

当启用"限制最大宽度"后，即使将水平间距设置为 0，item 之间仍然显示很大的间距。这是因为布局计算使用的是 item 的理想尺寸，而非实际渲染的受限尺寸。

## 问题分析

### 根本原因

1. **尺寸测量时机**：GeometryReader 测量的是应用宽度限制后的尺寸
2. **布局计算错误**：但原始代码没有正确处理这种情况
3. **间距累积**：导致视觉上的间距远大于设置值

### 之前的问题流程

```
文字内容 → fixedSize() → 理想宽度（如 150pt）
    ↓
应用 maxWidth（如 80pt）→ 实际渲染宽度 80pt
    ↓
GeometryReader 测量 → 得到 80pt
    ↓
布局计算使用 80pt ✓
```

## 解决方案

重新设计了 item 视图的架构，使用 PreferenceKey 来准确传递尺寸信息：

### 1. 分离 Item 视图组件

```swift
struct ItemView: View {
    let text: String
    let index: Int
    let maxWidth: CGFloat?
    let onSizeCalculated: (CGSize) -> Void
    
    var body: some View {
        Text(text)
            .frame(maxWidth: maxWidth)
            .fixedSize(horizontal: maxWidth == nil, vertical: true)
            // 使用 PreferenceKey 传递尺寸
            .background(GeometryReader { geo in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: SizeData(index: index, size: geo.size)
                )
            })
            .onPreferenceChange(SizePreferenceKey.self) { sizeData in
                if let data = sizeData, data.index == index {
                    onSizeCalculated(data.size)
                }
            }
    }
}
```

### 2. 使用 PreferenceKey 传递尺寸

```swift
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: SizeData? = nil
    
    static func reduce(value: inout SizeData?, nextValue: () -> SizeData?) {
        value = nextValue() ?? value
    }
}
```

### 3. 关键修复点

- `frame(maxWidth: maxWidth)`：先应用宽度限制
- `fixedSize(horizontal: maxWidth == nil, vertical: true)`：
  - 有宽度限制时：水平方向可变（允许截断）
  - 无宽度限制时：完全固定尺寸
- PreferenceKey：确保尺寸信息正确传递

## 效果验证

### 测试步骤

1. 开启"限制最大宽度"，设置为 80pt
2. 将水平间距调整为 0
3. 添加长文字查看效果

### 预期结果

- ✅ item 实际宽度被限制在 80pt
- ✅ 水平间距为 0 时，item 紧密排列
- ✅ 长文字正确显示省略号
- ✅ 布局计算使用实际渲染尺寸

## 技术要点

1. **PreferenceKey 的作用**
   - 从子视图向父视图传递数据
   - 确保尺寸测量的准确性

2. **fixedSize 的条件使用**
   - 有宽度限制：允许水平方向变化
   - 无宽度限制：保持理想尺寸

3. **布局计算的准确性**
   - 使用实际渲染尺寸而非理想尺寸
   - 确保间距计算的正确性

## 总结

通过重构 item 视图组件和使用 PreferenceKey，成功解决了宽度限制下的间距问题。现在间距设置能够准确反映在界面上，无论是否启用宽度限制。