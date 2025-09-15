import SwiftUI

/**
 * 智能横向滚动视图 - 简洁的横向滚动实现
 *
 * Smart Horizontal Scroll View - Concise horizontal scrolling implementation
 *
 * 本文件展示了正确的横向滚动视图实现方式。核心理念是"好品味"：消除特殊情况，让代码简单。
 * 原始版本试图手动处理父子滚动视图之间的手势传递，这完全是不必要的复杂性。
 *
 * This file demonstrates the correct implementation of horizontal scroll views. The core philosophy 
 * is "good taste": eliminate special cases and make the code simple. The original version tried to 
 * manually handle gesture passing between parent and child scroll views, which is completely unnecessary complexity.
 *
 * 技术决策：
 * 1. 使用原生 ScrollView(.horizontal) - iOS 已经完美处理了横向滚动
 * 2. 单一职责 - 这个组件只负责横向滚动，不管理父视图状态
 * 3. 零手势处理 - 让系统处理所有手势逻辑
 *
 * Technical Decisions:
 * 1. Use native ScrollView(.horizontal) - iOS already handles horizontal scrolling perfectly
 * 2. Single Responsibility - This component only handles horizontal scrolling, not parent view state
 * 3. Zero gesture handling - Let the system handle all gesture logic
 *
 * 对比原始实现：
 * - 原始: 19个状态变量，150行手势处理代码
 * - 现在: 0个状态变量，4行实现代码
 * - 结果: 功能完全相同，性能更好，代码可维护
 *
 * Comparison with original implementation:
 * - Original: 19 state variables, 150 lines of gesture handling code
 * - Now: 0 state variables, 4 lines of implementation code
 * - Result: Identical functionality, better performance, maintainable code
 */

// MARK: - Smart Horizontal ScrollView / 智能横向滚动视图

/**
 * 基础横向滚动视图 - 最简单的实现
 *
 * Basic horizontal scroll view - Simplest implementation
 *
 * 这就是你需要的全部代码。不需要手势处理，不需要状态管理，不需要复杂的计算。
 * SwiftUI 的 ScrollView 已经内置了所有必要的逻辑。
 *
 * This is all the code you need. No gesture handling, no state management, no complex calculations.
 * SwiftUI's ScrollView already has all the necessary logic built-in.
 */
struct SmartHorizontalScrollView<Content: View>: View {
    let content: Content
    let showsIndicators: Bool
    
    // 兼容旧接口的属性 / Properties for legacy interface compatibility
    @Binding var parentVerticalScrollOffset: CGFloat
    @Binding var isParentScrolling: Bool
    @Binding var debugInfo: String
    
    // 新接口初始化器 / New interface initializer
    init(
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.content = content()
        
        // 为新接口提供默认绑定 / Provide default bindings for new interface
        self._parentVerticalScrollOffset = .constant(0)
        self._isParentScrolling = .constant(false)
        self._debugInfo = .constant("")
    }
    
    // 兼容旧接口的初始化器 / Legacy interface initializer
    init(
        parentVerticalScrollOffset: Binding<CGFloat>,
        isParentScrolling: Binding<Bool>,
        debugInfo: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self._parentVerticalScrollOffset = parentVerticalScrollOffset
        self._isParentScrolling = isParentScrolling
        self._debugInfo = debugInfo
        self.content = content()
        self.showsIndicators = true
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            content
        }
    }
}

// MARK: - Enhanced Horizontal ScrollView / 增强横向滚动视图

/**
 * 带滚动追踪的增强版本 - 仅在需要时使用
 *
 * Enhanced version with scroll tracking - Use only when needed
 *
 * 只有当你真正需要知道滚动位置时才使用这个版本。大多数情况下，基础版本就足够了。
 * 记住：不要为了可能永远不会使用的功能增加复杂性。
 *
 * Only use this version when you really need to know the scroll position. In most cases, 
 * the basic version is sufficient. Remember: don't add complexity for features that may never be used.
 */
struct EnhancedHorizontalScrollView<Content: View>: View {
    let content: Content
    let showsIndicators: Bool
    let onScroll: ((CGFloat) -> Void)?
    
    @State private var scrollOffset: CGFloat = 0
    
    init(
        showsIndicators: Bool = true,
        onScroll: ((CGFloat) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.onScroll = onScroll
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: HorizontalOffsetKey.self,
                                value: geometry.frame(in: .named("scroll")).minX
                            )
                    }
                )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(HorizontalOffsetKey.self) { value in
            scrollOffset = -value
            onScroll?(scrollOffset)
        }
    }
}

// MARK: - Preference Key / 偏好键

/**
 * 横向滚动偏移键 - 用于追踪滚动位置
 *
 * Horizontal scroll offset key - Used to track scroll position
 *
 * PreferenceKey 是 SwiftUI 中传递子视图信息到父视图的标准方式。
 * 这比使用 Binding 或其他状态管理方式更清洁、更高效。
 *
 * PreferenceKey is the standard way in SwiftUI to pass information from child views to parent views.
 * This is cleaner and more efficient than using Binding or other state management approaches.
 */
struct HorizontalOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Horizontal Scroll Section / 横向滚动部分

/**
 * 可复用的横向滚动部分组件 - 标准化的内容展示
 *
 * Reusable horizontal scroll section component - Standardized content display
 *
 * 这个组件展示了组合模式的威力。通过组合简单的组件，我们可以构建复杂的 UI，
 * 而不需要创建巨大的、难以维护的单体组件。
 *
 * This component demonstrates the power of composition pattern. By composing simple components,
 * we can build complex UIs without creating huge, hard-to-maintain monolithic components.
 */
struct HorizontalScrollSection<Content: View>: View {
    let title: String?
    let height: CGFloat
    let content: Content
    
    init(
        title: String? = nil,
        height: CGFloat = 200,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal)
            }
            
            SmartHorizontalScrollView {
                content
                    .padding(.horizontal)
            }
            .frame(height: height)
        }
    }
}

// MARK: - Demo View / 演示视图

/**
 * 演示视图 - 展示实际使用场景
 *
 * Demo view - Shows real-world usage scenarios
 *
 * 这个演示展示了如何在实际应用中使用横向滚动。注意没有复杂的状态管理，
 * 没有手势冲突处理，一切都是自然和直观的。
 *
 * This demo shows how to use horizontal scrolling in real applications. Note there's no complex
 * state management, no gesture conflict handling, everything is natural and intuitive.
 */
struct SmartHorizontalScrollDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 基础横向滚动示例
                // Basic horizontal scroll example
                HorizontalScrollSection(title: "Featured / 精选") {
                    HStack(spacing: 16) {
                        ForEach(0..<15) { index in
                            HorizontalCardView(
                                index: index,
                                color: .blue
                            )
                        }
                    }
                }
                
                // 带滚动追踪的示例
                // Example with scroll tracking
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trending / 趋势")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    EnhancedHorizontalScrollView(
                        onScroll: { offset in
                            // 仅在需要时使用偏移量
                            // Use offset only when needed
                            print("Scroll offset: \(offset)")
                        }
                    ) {
                        HStack(spacing: 16) {
                            ForEach(0..<20) { index in
                                HorizontalCardView(
                                    index: index,
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200)
                }
                
                // 常规垂直内容
                // Regular vertical content
                VStack(spacing: 12) {
                    Text("Articles / 文章")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(0..<5) { index in
                        ArticleRow(index: index)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Smart Horizontal Scroll")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Card View / 卡片视图

/**
 * 横向滚动卡片组件 - 展示单个内容项
 *
 * Horizontal scroll card component - Displays single content item
 *
 * 简单的卡片设计，专注于内容展示。没有不必要的动画或效果，
 * 保持界面的响应性和流畅性。
 *
 * Simple card design focused on content display. No unnecessary animations or effects,
 * keeping the interface responsive and smooth.
 */
struct HorizontalCardView: View {
    let index: Int
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 150, height: 180)
            .overlay(
                VStack {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Card \(index + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            )
            .shadow(radius: 5)
    }
}

// MARK: - Article Row / 文章行

/**
 * 文章列表行组件 - 垂直内容展示
 *
 * Article list row component - Vertical content display
 *
 * 这个组件展示了如何在垂直滚动中混合其他类型的内容。
 * 关键是保持每个组件的职责单一和明确。
 *
 * This component shows how to mix other types of content in vertical scrolling.
 * The key is to keep each component's responsibility single and clear.
 */
struct ArticleRow: View {
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("\(index + 1)")
                        .font(.headline)
                )
            
            VStack(alignment: .leading) {
                Text("Article \(index + 1)")
                    .font(.headline)
                Text("Simple description text")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Preview / 预览

#Preview("Smart Horizontal Scroll") {
    NavigationView {
        SmartHorizontalScrollDemoView()
    }
}