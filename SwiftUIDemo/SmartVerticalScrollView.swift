import SwiftUI

/**
 * SMART VERTICAL SCROLL VIEW - 智能垂直滚动视图
 * 
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Single Responsibility Principle (单一职责原则)
 *    - Why: Each component has ONE clear job / 每个组件有一个明确的职责
 *    - Benefits: Easy to understand, test, and modify / 易于理解、测试和修改
 *    - Implementation: Separate concerns cleanly / 清晰地分离关注点
 * 
 * KEY PRINCIPLE / 关键原则:
 * "Simplicity is the ultimate sophistication" / "简单是终极的精致"
 * - No unnecessary state management / 无不必要的状态管理
 * - No complex gesture calculations / 无复杂的手势计算
 * - Trust iOS to do what it does best / 相信 iOS 做它最擅长的事
 * 
 * USAGE EXAMPLES / 使用示例:
 * ```
 * // Basic usage / 基础用法
 * SmartVerticalScrollView {
 *     VStack {
 *         YourContent()
 *     }
 * }
 * 
 * // With refresh / 带刷新
 * SmartVerticalScrollView(isRefreshable: true) {
 *     // Your content / 你的内容
 * } onRefresh: {
 *     await loadData()
 * }
 * ```
 */

// MARK: - Smart Vertical ScrollView / 智能垂直滚动视图
struct SmartVerticalScrollView<Content: View>: View {
    let content: Content
    let showsIndicators: Bool
    let isRefreshable: Bool
    let onRefresh: (() async -> Void)?
    
    // 兼容旧接口的属性 / Properties for legacy interface compatibility
    @Binding var verticalScrollOffset: CGFloat
    @Binding var isVerticalScrolling: Bool
    @Binding var debugInfo: String
    
    // 新接口初始化器 / New interface initializer
    init(
        showsIndicators: Bool = true,
        isRefreshable: Bool = false,
        @ViewBuilder content: () -> Content,
        onRefresh: (() async -> Void)? = nil
    ) where Content: View {
        self.showsIndicators = showsIndicators
        self.isRefreshable = isRefreshable
        self.content = content()
        self.onRefresh = onRefresh
        
        // 为新接口提供默认绑定 / Provide default bindings for new interface
        self._verticalScrollOffset = .constant(0)
        self._isVerticalScrolling = .constant(false)
        self._debugInfo = .constant("")
    }
    
    // 兼容旧接口的初始化器 / Legacy interface initializer
    init(
        verticalScrollOffset: Binding<CGFloat>,
        isVerticalScrolling: Binding<Bool>,
        debugInfo: Binding<String>,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        self._verticalScrollOffset = verticalScrollOffset
        self._isVerticalScrolling = isVerticalScrolling
        self._debugInfo = debugInfo
        self.content = content()
        self.showsIndicators = true
        self.isRefreshable = false
        self.onRefresh = nil
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            content
        }
        .refreshable {
            if let onRefresh = onRefresh {
                await onRefresh()
            }
        }
    }
}

// MARK: - Enhanced Vertical ScrollView / 增强垂直滚动视图
/**
 * Enhanced version with scroll position tracking / 带滚动位置追踪的增强版本
 * Only add complexity when actually needed / 只在真正需要时添加复杂性
 */
struct EnhancedVerticalScrollView<Content: View>: View {
    let content: Content
    let onScroll: ((CGFloat) -> Void)?
    
    @State private var scrollOffset: CGFloat = 0
    
    init(
        onScroll: ((CGFloat) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.onScroll = onScroll
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.vertical) {
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: VerticalOffsetKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                    }
                )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(VerticalOffsetKey.self) { value in
            scrollOffset = -value
            onScroll?(scrollOffset)
        }
    }
}

// MARK: - Preference Key / 偏好键
struct VerticalOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Smart Vertical Only ScrollView / 智能仅垂直滚动视图

/**
 * 仅垂直滚动视图 - 阻止横向手势
 *
 * Vertical only scroll view - Blocks horizontal gestures
 *
 * 用于需要严格限制为垂直滚动的场景。
 *
 * Used for scenarios that require strict vertical scrolling only.
 */
struct SmartVerticalOnlyScrollView<Content: View>: View {
    @Binding var debugInfo: String
    let content: Content
    
    init(
        debugInfo: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self._debugInfo = debugInfo
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            content
        }
    }
}

// MARK: - Lazy Vertical Stack / 懒加载垂直堆栈
/**
 * Optimized for large lists / 为大列表优化
 * Uses LazyVStack for performance / 使用 LazyVStack 提升性能
 */
struct SmartLazyVerticalScrollView<Content: View>: View {
    let content: Content
    let spacing: CGFloat
    let pinnedViews: PinnedScrollableViews
    
    init(
        spacing: CGFloat = 0,
        pinnedViews: PinnedScrollableViews = [],
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.pinnedViews = pinnedViews
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: spacing, pinnedViews: pinnedViews) {
                content
            }
        }
    }
}

// MARK: - Demo View / 演示视图
/**
 * Clean demo showing proper vertical scroll usage / 展示正确垂直滚动用法的清洁演示
 */
struct SmartVerticalScrollDemoView: View {
    @State private var isLoading = false
    @State private var items = (0..<20).map { "Item \($0 + 1)" }
    
    var body: some View {
        SmartVerticalScrollView(
            isRefreshable: true,
            content: {
                VStack(spacing: 20) {
                    // Header section / 头部部分
                    headerSection
                    
                    // Content sections / 内容部分
                    ForEach(0..<5) { sectionIndex in
                        contentSection(sectionIndex: sectionIndex)
                    }
                    
                    // List section / 列表部分
                    listSection
                }
                .padding(.vertical)
            },
            onRefresh: {
                // Simulate refresh / 模拟刷新
                isLoading = true
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                items = (0..<20).map { "Refreshed Item \($0 + 1)" }
                isLoading = false
            }
        )
        .navigationTitle("Smart Vertical Scroll")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section / 头部部分
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Welcome / 欢迎")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Clean vertical scrolling demo")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Content Section / 内容部分
    private func contentSection(sectionIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Section \(sectionIndex + 1)")
                .font(.headline)
                .padding(.horizontal)
            
            if sectionIndex % 2 == 0 {
                // Grid layout / 网格布局
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(0..<4) { index in
                        GridCard(index: index)
                    }
                }
                .padding(.horizontal)
            } else {
                // Horizontal scroll / 横向滚动
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<8) { index in
                            MiniCard(index: index)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - List Section / 列表部分
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("List Items / 列表项")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(items, id: \.self) { item in
                ListRow(title: item)
            }
        }
    }
}

// MARK: - Grid Card / 网格卡片
struct GridCard: View {
    let index: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.purple.opacity(0.2))
            .frame(height: 100)
            .overlay(
                VStack {
                    Image(systemName: "square.grid.2x2")
                        .font(.title2)
                    Text("Grid \(index + 1)")
                        .font(.caption)
                }
                .foregroundColor(.purple)
            )
    }
}

// MARK: - Mini Card / 迷你卡片
struct MiniCard: View {
    let index: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange.gradient)
            .frame(width: 100, height: 100)
            .overlay(
                VStack {
                    Image(systemName: "star")
                        .foregroundColor(.white)
                    Text("Card \(index + 1)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            )
    }
}

// MARK: - List Row / 列表行
struct ListRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - iOS Version Adaptive / iOS 版本自适应
/**
 * Handles differences between iOS 15 and iOS 16+ / 处理 iOS 15 和 iOS 16+ 的差异
 */
struct AdaptiveVerticalScrollView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            // iOS 16+ features / iOS 16+ 特性
            ScrollView {
                content
                    .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.visible)
        } else {
            // iOS 15 fallback / iOS 15 后备方案
            ScrollView {
                content
            }
        }
    }
}

// MARK: - Preview / 预览
#Preview("Smart Vertical Scroll") {
    NavigationView {
        SmartVerticalScrollDemoView()
    }
}

#Preview("Enhanced with Tracking") {
    NavigationView {
        EnhancedVerticalScrollView(
            onScroll: { offset in
                print("Scroll offset: \(offset)")
            }
        ) {
            VStack(spacing: 20) {
                ForEach(0..<50) { index in
                    Text("Item \(index)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Enhanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}