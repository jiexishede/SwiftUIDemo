# 🔧 修复换行后首个 Item 的左对齐问题

## 问题描述

在流式布局中，当 item 换行时，新行的第一个 item 左边会有额外的间距，导致不是完全左对齐。这是因为在计算布局位置时，对所有 item 都统一加上了 `itemSpacing`。

When items wrap to a new line in the flow layout, the first item of the new line has extra spacing on the left, causing it not to be fully left-aligned. This is because `itemSpacing` was uniformly added to all items during layout position calculation.

## 问题分析

### 原始代码问题 / Original Code Issue

```swift
// 所有 item 都加上间距
let itemWidth = itemSizes[i].width + itemSpacing
```

这导致每行的第一个 item 也有左边距。

This causes the first item of each line to also have left margin.

## 解决方案

### 核心改进 / Core Improvement

只在必要时添加间距：每行的第一个 item 不添加左间距。

Only add spacing when necessary: don't add left spacing to the first item of each line.

```swift
// 只在非第一个 item 时加间距
let neededWidth = currentRowWidth + (currentRowWidth > 0 ? itemSpacing : 0) + itemWidth
```

### 修改的方法 / Modified Methods

1. **calculateLeadingAlignment** - 计算水平位置
2. **calculateTopAlignment** - 计算垂直位置  
3. **calculateHeight** - 计算总高度

## 技术实现细节

### 条件间距逻辑 / Conditional Spacing Logic

```swift
// 判断是否需要添加间距
// Determine if spacing is needed
(currentRowWidth > 0 ? itemSpacing : 0)
```

- `currentRowWidth > 0`: 表示当前行已有 item
- `currentRowWidth > 0`: Indicates current line already has items
- 返回 `itemSpacing`: 需要添加间距
- Returns `itemSpacing`: Need to add spacing  
- 返回 `0`: 行首，不需要间距
- Returns `0`: Start of line, no spacing needed

### 换行判断优化 / Line Wrap Logic Optimization

```swift
if neededWidth > containerWidth && currentRowWidth > 0 {
    // 换行逻辑
    // Line wrap logic
}
```

增加了 `currentRowWidth > 0` 条件，避免第一个 item 就触发换行。

Added `currentRowWidth > 0` condition to prevent first item from triggering line wrap.

## 效果对比

### 修复前 / Before Fix
```
|  [Item1]  [Item2]  [Item3]
|  [Item4]  [Item5]
```

### 修复后 / After Fix
```
|[Item1]  [Item2]  [Item3]
|[Item4]  [Item5]
```

## 测试验证

1. 设置水平间距为较大值（如 20pt）
2. 添加多个 item 直到换行
3. 观察每行第一个 item 是否左对齐
4. 验证行内 item 之间的间距是否正确

## 总结

通过条件间距逻辑，成功实现了：
- ✅ 每行第一个 item 完全左对齐
- ✅ 行内 item 之间保持设定的间距
- ✅ 换行逻辑更加准确
- ✅ 间距计算更符合用户预期

Successfully achieved through conditional spacing logic:
- ✅ First item of each line is fully left-aligned
- ✅ Items within a line maintain the set spacing
- ✅ More accurate line wrap logic
- ✅ Spacing calculation better matches user expectations