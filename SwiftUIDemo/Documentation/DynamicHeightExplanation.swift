//
//  DynamicHeightExplanation.swift
//  SwiftUIDemo
//
//  Dynamic Height Implementation Detailed Explanation
//  动态高度实现详细解释
//

import SwiftUI

/**
 * DYNAMIC HEIGHT IMPLEMENTATION IN SWIFTUI - COMPLETE GUIDE
 * SwiftUI 中的动态高度实现 - 完整指南
 *
 * This file explains how dynamic height calculation works in our bottom sheet implementation
 * 本文件解释了底部弹窗实现中动态高度计算的工作原理
 */

// MARK: - 1. CORE CONCEPTS / 核心概念
/**
 * There are 3 main approaches to dynamic height in SwiftUI:
 * SwiftUI 中有 3 种主要的动态高度方法：
 *
 * 1. PreferenceKey - Child-to-parent size communication / 子到父的尺寸通信
 * 2. GeometryReader - Direct size measurement / 直接尺寸测量
 * 3. Intrinsic Content Size - SwiftUI's automatic sizing / SwiftUI 的自动尺寸
 */

// MARK: - 2. OUR IMPLEMENTATION APPROACH / 我们的实现方法
/**
 * We use a combination of all three approaches:
 * 我们使用了三种方法的组合：
 */

// ============================================================
// PART A: PreferenceKey for Height Reporting
// 部分 A：使用 PreferenceKey 报告高度
// ============================================================

/**
 * STEP 1: Define a PreferenceKey to collect height data
 * 步骤 1：定义 PreferenceKey 来收集高度数据
 *
 * WHY: PreferenceKey allows child views to send data up to parent views
 * 原因：PreferenceKey 允许子视图向父视图发送数据
 */
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    // Called when multiple views report heights - we take the maximum
    // 当多个视图报告高度时调用 - 我们取最大值
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/**
 * STEP 2: Measure content height using GeometryReader
 * 步骤 2：使用 GeometryReader 测量内容高度
 *
 * This is what happens in AdaptiveBottomSheet:
 * 这是在 AdaptiveBottomSheet 中发生的事情：
 */
struct ContentMeasurementExample: View {
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            // The actual content / 实际内容
            Text("Content")
                .fixedSize(horizontal: false, vertical: true) // CRITICAL: Allow vertical expansion / 关键：允许垂直扩展
                .background(
                    // Hidden GeometryReader that measures the content
                    // 隐藏的 GeometryReader 测量内容
                    GeometryReader { geometry in
                        Color.clear // Invisible / 不可见
                            .preference(
                                key: HeightPreferenceKey.self,
                                value: geometry.size.height // Report the height / 报告高度
                            )
                    }
                )
        }
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            // Receive the height value / 接收高度值
            contentHeight = height
            print("Content height is: \(height)")
        }
    }
}

// ============================================================
// PART B: Dynamic Height Calculation Logic
// 部分 B：动态高度计算逻辑
// ============================================================

/**
 * The height calculation happens in multiple stages:
 * 高度计算发生在多个阶段：
 */
struct DynamicHeightCalculationExample {
    
    /**
     * METHOD 1: Automatic Height Calculation
     * 方法 1：自动高度计算
     *
     * Used in AdaptiveBottomSheet's calculatedHeight method
     * 在 AdaptiveBottomSheet 的 calculatedHeight 方法中使用
     */
    func automaticHeightCalculation(
        contentHeight: CGFloat,
        screenHeight: CGFloat,
        dragIndicator: Bool
    ) -> CGFloat {
        // Step 1: Add indicator height if present
        // 步骤 1：如果存在，添加指示器高度
        let indicatorHeight: CGFloat = dragIndicator ? 30 : 0
        let measuredHeight = contentHeight + indicatorHeight
        
        // Step 2: Define bounds
        // 步骤 2：定义边界
        let minHeight: CGFloat = 150  // Minimum readable height / 最小可读高度
        let maxHeight: CGFloat = screenHeight * 0.85  // 85% of screen / 屏幕的 85%
        
        // Step 3: Apply bounds
        // 步骤 3：应用边界
        if measuredHeight < minHeight {
            return minHeight  // Too small, use minimum / 太小，使用最小值
        } else if measuredHeight > maxHeight {
            return maxHeight  // Too large, cap at maximum / 太大，限制在最大值
        } else {
            return measuredHeight  // Just right, use actual size / 正好，使用实际大小
        }
    }
    
    /**
     * METHOD 2: Dynamic Content-Based Calculation
     * 方法 2：基于内容的动态计算
     *
     * Used in DynamicCardsSheet for complex content
     * 在 DynamicCardsSheet 中用于复杂内容
     */
    func dynamicContentCalculation(
        cards: [Any],
        expandedCards: Set<UUID>,
        showAddForm: Bool
    ) -> CGFloat {
        // Base components height / 基础组件高度
        let headerHeight: CGFloat = 100     // Title, subtitle, controls / 标题、副标题、控件
        let controlsHeight: CGFloat = 100   // Filters and sort buttons / 过滤器和排序按钮
        
        // Dynamic card heights / 动态卡片高度
        let cardHeight: CGFloat = cards.reduce(0) { total, card in
            // Different height based on expansion state
            // 根据展开状态的不同高度
            // Example: In real implementation, this would be based on actual state
            // 示例：在实际实现中，这将基于实际状态
            let singleCardHeight: CGFloat = 80 // Default height for collapsed cards / 折叠卡片的默认高度
            return total + singleCardHeight
        }
        
        // Conditional form height / 条件表单高度
        let formHeight: CGFloat = showAddForm ? 200 : 0
        
        // Calculate total with maximum limit / 计算总数并限制最大值
        let totalHeight = headerHeight + controlsHeight + cardHeight + formHeight
        return min(totalHeight, 600)  // Cap at 600 points / 限制在 600 点
    }
}

// ============================================================
// PART C: Real-Time Height Updates
// 部分 C：实时高度更新
// ============================================================

/**
 * How height updates work in real-time:
 * 实时高度更新的工作原理：
 */
struct RealTimeHeightUpdateExample: View {
    @State private var items: [String] = ["Item 1", "Item 2"]
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            // Content that can change / 可以改变的内容
            ForEach(items, id: \.self) { item in
                Text(item)
                    .padding()
            }
            
            // Add/Remove buttons change content
            // 添加/删除按钮改变内容
            HStack {
                Button("Add") {
                    withAnimation {
                        items.append("Item \(items.count + 1)")
                        // Height will automatically recalculate
                        // 高度将自动重新计算
                    }
                }
                
                Button("Remove") {
                    withAnimation {
                        if !items.isEmpty {
                            items.removeLast()
                            // Height will automatically recalculate
                            // 高度将自动重新计算
                        }
                    }
                }
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { newHeight in
            // This is called EVERY time the content changes
            // 每次内容改变时都会调用
            print("Height updated from \(contentHeight) to \(newHeight)")
            contentHeight = newHeight
        }
    }
}

// ============================================================
// PART D: Special Cases and Optimizations
// 部分 D：特殊情况和优化
// ============================================================

/**
 * SPECIAL CASE 1: ScrollView Content
 * 特殊情况 1：ScrollView 内容
 *
 * ScrollViews have infinite height, so we need special handling
 * ScrollView 有无限高度，所以我们需要特殊处理
 */
struct ScrollViewHeightHandling: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<100) { i in
                    Text("Item \(i)")
                }
            }
        }
        .frame(maxHeight: 400)  // MUST limit ScrollView height / 必须限制 ScrollView 高度
        // Without this, the sheet would try to be infinitely tall
        // 没有这个，弹窗会尝试无限高
    }
}

/**
 * SPECIAL CASE 2: Async Content Loading
 * 特殊情况 2：异步内容加载
 *
 * Height changes when content loads asynchronously
 * 当内容异步加载时高度会改变
 */
struct AsyncContentHeightExample: View {
    @State private var isLoading = true
    @State private var items: [String] = []
    
    var body: some View {
        VStack {
            if isLoading {
                // Small height when loading / 加载时的小高度
                ProgressView()
                    .frame(height: 100)
            } else {
                // Larger height when content is loaded / 内容加载后的大高度
                ForEach(items, id: \.self) { item in
                    Text(item).padding()
                }
            }
        }
        .onAppear {
            // Simulate async loading / 模拟异步加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    items = ["Data 1", "Data 2", "Data 3", "Data 4", "Data 5"]
                    isLoading = false
                    // Height automatically updates / 高度自动更新
                }
            }
        }
    }
}

/**
 * SPECIAL CASE 3: Expandable/Collapsible Content
 * 特殊情况 3：可展开/折叠内容
 *
 * Height changes based on expansion state
 * 高度根据展开状态改变
 */
struct ExpandableContentHeightExample: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button("Toggle") {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                // Additional content when expanded / 展开时的额外内容
                VStack {
                    Text("Line 1")
                    Text("Line 2")
                    Text("Line 3")
                    Text("Line 4")
                    Text("Line 5")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                // The transition makes height changes smooth
                // 过渡使高度变化平滑
            }
        }
        // Parent view automatically adjusts to new height
        // 父视图自动调整到新高度
    }
}

// ============================================================
// PART E: Complete Implementation Flow
// 部分 E：完整实现流程
// ============================================================

/**
 * COMPLETE FLOW OF DYNAMIC HEIGHT IN OUR BOTTOM SHEET:
 * 我们底部弹窗中动态高度的完整流程：
 *
 * 1. Content is rendered in the sheet / 内容在弹窗中渲染
 *    ↓
 * 2. GeometryReader measures the content / GeometryReader 测量内容
 *    ↓
 * 3. Height is reported via PreferenceKey / 通过 PreferenceKey 报告高度
 *    ↓
 * 4. onPreferenceChange receives the height / onPreferenceChange 接收高度
 *    ↓
 * 5. calculatedHeight function processes it / calculatedHeight 函数处理它
 *    ↓
 * 6. Bounds are applied (min/max) / 应用边界（最小/最大）
 *    ↓
 * 7. Sheet frame is updated / 弹窗框架更新
 *    ↓
 * 8. Animation smooths the transition / 动画平滑过渡
 */

struct CompleteBottomSheetFlow: View {
    @State private var contentHeight: CGFloat = 0
    @State private var isPresented = false
    
    var body: some View {
        Button("Show Sheet") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            sheetContent
        }
    }
    
    private var sheetContent: some View {
        VStack {
            // Dynamic content / 动态内容
            DynamicContentView()
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: HeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                    }
                )
        }
        .frame(height: calculateHeight())
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            withAnimation(.spring()) {
                contentHeight = height
            }
        }
    }
    
    private func calculateHeight() -> CGFloat {
        let minHeight: CGFloat = 200
        let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.85
        
        if contentHeight < minHeight {
            return minHeight
        } else if contentHeight > maxHeight {
            return maxHeight
        } else {
            return contentHeight
        }
    }
}

struct DynamicContentView: View {
    @State private var items = ["Item 1", "Item 2"]
    
    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                Text(item).padding()
            }
            
            Button("Add Item") {
                items.append("Item \(items.count + 1)")
            }
        }
    }
}

// ============================================================
// PART F: Key Insights and Best Practices
// 部分 F：关键见解和最佳实践
// ============================================================

/**
 * KEY INSIGHTS / 关键见解:
 *
 * 1. fixedSize(horizontal: false, vertical: true) is CRITICAL
 *    - Without it, content won't expand to its natural height
 *    - 没有它，内容不会扩展到其自然高度
 *
 * 2. GeometryReader should be in background, not wrapping content
 *    - Wrapping changes layout behavior
 *    - 包装会改变布局行为
 *
 * 3. Always use animation when updating height state
 *    - Makes transitions smooth
 *    - 使过渡平滑
 *
 * 4. Set reasonable min/max bounds
 *    - Prevents unusable sizes
 *    - 防止不可用的大小
 *
 * 5. Handle ScrollView specially
 *    - Must set frame limit or it will be infinite
 *    - 必须设置框架限制，否则将是无限的
 *
 * 6. Test with dynamic content
 *    - Add/remove items
 *    - Expand/collapse sections
 *    - Async loading
 *    - 添加/删除项目、展开/折叠部分、异步加载
 */

/**
 * COMMON PITFALLS TO AVOID / 要避免的常见陷阱:
 *
 * 1. DON'T wrap content in GeometryReader directly
 *    ❌ GeometryReader { geometry in Content() }
 *    ✅ Content().background(GeometryReader { ... })
 *
 * 2. DON'T forget fixedSize for expanding content
 *    ❌ content.background(GeometryReader { ... })
 *    ✅ content.fixedSize(horizontal: false, vertical: true).background(...)
 *
 * 3. DON'T update height without animation
 *    ❌ contentHeight = newHeight
 *    ✅ withAnimation { contentHeight = newHeight }
 *
 * 4. DON'T allow unlimited height
 *    ❌ return contentHeight
 *    ✅ return min(contentHeight, screenHeight * 0.85)
 */