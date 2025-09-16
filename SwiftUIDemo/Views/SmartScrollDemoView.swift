import SwiftUI

/**
 * 智能滚动演示视图 - SwiftUI 嵌套滚动最佳实践的完整展示
 *
 * Smart Scroll Demo View - Complete demonstration of SwiftUI nested scrolling best practices
 *
 * ==================== 核心设计理念 ====================
 *
 * 本演示视图是 SwiftUI 滚动视图架构的集大成者，展示了如何优雅地解决 iOS 开发中
 * 最具挑战性的 UI 问题之一：嵌套滚动。通过这个演示，你将学习到：
 *
 * 1. 如何让垂直和横向滚动和谐共存
 * 2. 如何避免手势冲突
 * 3. 如何优化滚动性能
 * 4. 如何保持代码的简洁性
 *
 * This demo view is the culmination of SwiftUI scroll view architecture, demonstrating how to
 * elegantly solve one of the most challenging UI problems in iOS development: nested scrolling.
 * Through this demo, you will learn:
 *
 * 1. How to make vertical and horizontal scrolling coexist harmoniously
 * 2. How to avoid gesture conflicts
 * 3. How to optimize scrolling performance
 * 4. How to maintain code simplicity
 *
 * ==================== 技术实现详解 ====================
 *
 * 关键技术决策：
 * - 使用计算属性分解复杂视图，避免编译器超时
 * - 最小化状态管理，只保留必要的 UI 状态
 * - 信任 iOS 原生滚动行为，不做过度干预
 * - 采用声明式编程，让代码自文档化
 *
 * Key Technical Decisions:
 * - Use computed properties to decompose complex views, avoiding compiler timeout
 * - Minimize state management, keeping only necessary UI state
 * - Trust iOS native scrolling behavior without over-intervention
 * - Adopt declarative programming for self-documenting code
 *
 * ==================== 性能优化策略 ====================
 *
 * 1. 视图分解：每个部分都是独立的计算属性或函数
 * 2. 懒加载：使用 ForEach 而不是重复的视图
 * 3. 状态隔离：每个组件管理自己的状态
 * 4. 避免重渲染：使用 @ViewBuilder 优化视图构建
 *
 * Performance Optimization Strategies:
 * 1. View decomposition: Each section is an independent computed property or function
 * 2. Lazy loading: Use ForEach instead of repeated views
 * 3. State isolation: Each component manages its own state
 * 4. Avoid re-rendering: Use @ViewBuilder to optimize view construction
 *
 * ==================== 使用场景示例 ====================
 *
 * 这个演示可以直接应用于：
 * - 电商应用的商品展示页
 * - 社交媒体的信息流
 * - 新闻应用的文章列表
 * - 视频平台的内容推荐
 * - 音乐应用的播放列表
 *
 * This demo can be directly applied to:
 * - E-commerce product display pages
 * - Social media feeds
 * - News article lists
 * - Video platform content recommendations
 * - Music app playlists
 */

struct SmartScrollDemoView: View {
    // MARK: - State Properties / 状态属性

    /**
     * 调试信息 - 显示当前的滚动方向和状态
     *
     * Debug info - Shows current scroll direction and status
     *
     * 这个状态帮助开发者理解用户的滚动意图和系统的响应。
     * 在生产环境中，这些调试信息应该被移除或者只在开发模式下显示。
     *
     * This state helps developers understand user scroll intent and system response.
     * In production, this debug info should be removed or only shown in development mode.
     */
    @State private var debugInfo: String = "滑动方向: 无"

    /**
     * 垂直滚动偏移量 - 追踪主滚动视图的位置
     *
     * Vertical scroll offset - Tracks main scroll view position
     *
     * 这个值可以用于：
     * - 实现视差效果
     * - 触发加载更多内容
     * - 显示/隐藏导航栏
     * - 实现下拉刷新
     *
     * This value can be used for:
     * - Implementing parallax effects
     * - Triggering load more content
     * - Showing/hiding navigation bar
     * - Implementing pull-to-refresh
     */
    @State private var verticalScrollOffset: CGFloat = 0

    /**
     * 垂直滚动状态 - 标识是否正在进行垂直滚动
     *
     * Vertical scrolling state - Indicates if vertical scrolling is in progress
     *
     * 这个布尔值帮助协调父子滚动视图之间的交互。
     * 当为 true 时，可以禁用某些交互或动画以提高性能。
     *
     * This boolean helps coordinate interaction between parent-child scroll views.
     * When true, certain interactions or animations can be disabled to improve performance.
     */
    @State private var isVerticalScrolling: Bool = false

    /**
     * 调试信息显示开关 - 控制调试面板的可见性
     *
     * Debug info toggle - Controls debug panel visibility
     *
     * 提供给开发者的便利功能，可以随时开关调试信息。
     * 这展示了如何在应用中集成开发者工具。
     *
     * Convenient feature for developers to toggle debug info anytime.
     * This demonstrates how to integrate developer tools in the app.
     */
    @State private var showDebugInfo: Bool = true

    // MARK: - Body / 主体

    var body: some View {
        VStack(spacing: 0) {
            // 调试信息头部 - 可折叠的调试面板
            // Debug info header - Collapsible debug panel
            debugHeader

            // 主滚动内容 - 包含所有演示内容
            // Main scroll content - Contains all demo content
            mainScrollContent
        }
        .navigationTitle("智能滚动演示")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Debug Header / 调试头部

    /**
     * 调试信息显示区域 - 为开发者提供实时反馈
     *
     * Debug info display area - Provides real-time feedback for developers
     *
     * 设计要点：
     * 1. 紧凑的布局，不占用太多屏幕空间
     * 2. 可切换显示，方便查看实际效果
     * 3. 实时更新，立即反映状态变化
     * 4. 清晰的视觉层次，易于阅读
     *
     * Design points:
     * 1. Compact layout, doesn't take too much screen space
     * 2. Toggleable display for easy viewing of actual effects
     * 3. Real-time updates, immediately reflects state changes
     * 4. Clear visual hierarchy, easy to read
     */
    private var debugHeader: some View {
        VStack(spacing: 5) {
            // 调试开关行
            // Debug toggle row
            HStack {
                Text("调试信息")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Toggle("", isOn: $showDebugInfo)
                    .labelsHidden()
            }
            .padding(.horizontal)

            // 条件显示的调试信息
            // Conditionally displayed debug info
            if showDebugInfo {
                HStack {
                    // 滚动方向指示
                    // Scroll direction indicator
                    Text(debugInfo)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    // 滚动偏移量显示
                    // Scroll offset display
                    Text("偏移: \(Int(verticalScrollOffset))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
        }
    }

    // MARK: - Main Scroll Content / 主滚动内容

    /**
     * 主要滚动视图内容 - 演示的核心部分
     *
     * Main scroll view content - Core part of the demo
     *
     * 这个视图展示了如何构建一个复杂的、多层次的滚动界面。
     * 关键设计决策：
     *
     * 1. 使用 SmartVerticalScrollView 作为主容器
     * 2. 内部使用 VStack 组织内容
     * 3. 通过 ForEach 动态生成内容部分
     * 4. 每个部分都是独立的、可复用的组件
     *
     * This view demonstrates how to build a complex, multi-level scrolling interface.
     * Key design decisions:
     *
     * 1. Use SmartVerticalScrollView as main container
     * 2. Use VStack internally to organize content
     * 3. Dynamically generate content sections through ForEach
     * 4. Each section is an independent, reusable component
     */
    private var mainScrollContent: some View {
        SmartVerticalScrollView(
            verticalScrollOffset: $verticalScrollOffset,
            isVerticalScrolling: $isVerticalScrolling,
            debugInfo: $debugInfo
        ) {
            VStack(spacing: 20) {
                // 动态生成 10 个不同类型的内容部分
                // Dynamically generate 10 different types of content sections
                ForEach(0..<10) { index in
                    sectionContent(for: index)
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Section Content / 部分内容

    /**
     * 根据索引返回不同类型的内容部分 - 展示内容多样性
     *
     * Returns different types of content sections based on index - Shows content diversity
     *
     * 这个函数展示了一个重要的模式：根据数据动态决定 UI 结构。
     * 在实际应用中，这个索引可以替换为数据模型的类型字段。
     *
     * 模式分配逻辑：
     * - index % 3 == 0: 横向滚动卡片（如商品推荐）
     * - index % 3 == 1: 垂直限制滚动（如表格数据）
     * - 其他: 常规内容（如文章列表）
     *
     * This function demonstrates an important pattern: dynamically determining UI structure based on data.
     * In real applications, this index can be replaced with a type field from the data model.
     *
     * Pattern allocation logic:
     * - index % 3 == 0: Horizontal scroll cards (e.g., product recommendations)
     * - index % 3 == 1: Vertical restricted scroll (e.g., table data)
     * - Others: Regular content (e.g., article list)
     */
    @ViewBuilder
    private func sectionContent(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 部分标题 - 提供视觉锚点
            // Section title - Provides visual anchor
            Text("Section \(index + 1)")
                .font(.headline)
                .padding(.horizontal)

            // 根据索引选择不同的内容类型
            // Choose different content types based on index
            if index % 3 == 0 {
                horizontalScrollSection()
            } else if index % 3 == 1 {
                verticalOnlyScrollSection()
            } else {
                regularContentSection(index: index)
            }
        }
    }

    // MARK: - Horizontal Scroll Section / 横向滚动部分

    /**
     * 横向滚动区域 - 展示卡片式内容的最佳实践
     *
     * Horizontal scroll area - Best practices for displaying card-style content
     *
     * ==================== 设计理念 ====================
     *
     * 这个组件模拟了常见的"卡片轮播"UI 模式，广泛应用于：
     * - App Store 的应用推荐
     * - Netflix 的视频列表
     * - Instagram 的故事
     * - 电商的商品展示
     *
     * This component simulates the common "card carousel" UI pattern, widely used in:
     * - App Store app recommendations
     * - Netflix video lists
     * - Instagram stories
     * - E-commerce product displays
     *
     * ==================== 技术细节 ====================
     *
     * 1. 使用 SmartHorizontalScrollView 确保手势正确处理
     * 2. HStack 提供横向布局
     * 3. ForEach 动态生成卡片
     * 4. 每个卡片使用随机颜色增加视觉吸引力
     * 5. 固定高度确保布局稳定性
     *
     * Technical Details:
     * 1. Use SmartHorizontalScrollView to ensure correct gesture handling
     * 2. HStack provides horizontal layout
     * 3. ForEach dynamically generates cards
     * 4. Each card uses random colors for visual appeal
     * 5. Fixed height ensures layout stability
     *
     * ==================== 性能考虑 ====================
     *
     * 在生产环境中应该：
     * - 使用 LazyHStack 替代 HStack
     * - 实现图片懒加载
     * - 添加预加载机制
     * - 考虑内存管理
     *
     * In production should:
     * - Use LazyHStack instead of HStack
     * - Implement image lazy loading
     * - Add preloading mechanism
     * - Consider memory management
     */
    private func horizontalScrollSection() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // 使用说明文字 - 引导用户交互
            // Usage instruction text - Guides user interaction
            Text("横向滚动区域 - 上下滑动会触发页面滚动")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // 横向滚动容器
            // Horizontal scroll container
            SmartHorizontalScrollView(
                parentVerticalScrollOffset: $verticalScrollOffset,
                isParentScrolling: $isVerticalScrolling,
                debugInfo: $debugInfo
            ) {
                HStack(spacing: 15) {
                    // 生成 10 个彩色卡片
                    // Generate 10 colored cards
                    ForEach(0..<10) { itemIndex in
                        CardView(
                            title: "卡片 \(itemIndex + 1)",
                            subtitle: "横向滚动",
                            color: Color.random
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 200)
            .background(
                // 视觉边界 - 帮助用户识别可滚动区域
                // Visual boundary - Helps users identify scrollable area
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.05))
            )
            .padding(.horizontal)
        }
    }

    // MARK: - Vertical Only Scroll Section / 仅垂直滚动部分

    /**
     * 仅垂直滚动区域 - 展示受限滚动的实现
     *
     * Vertical only scroll area - Demonstrates restricted scrolling implementation
     *
     * ==================== 应用场景 ====================
     *
     * 这种滚动模式适用于：
     * - 数据表格
     * - 设置列表
     * - 表单输入
     * - 任何需要防止横向滚动的场景
     *
     * This scrolling pattern is suitable for:
     * - Data tables
     * - Settings lists
     * - Form inputs
     * - Any scenario requiring prevention of horizontal scrolling
     *
     * ==================== 实现策略 ====================
     *
     * SmartVerticalOnlyScrollView 通过以下方式实现垂直限制：
     * 1. 只接受垂直方向的手势
     * 2. 忽略横向滑动
     * 3. 保持与父视图的滚动协调
     *
     * SmartVerticalOnlyScrollView implements vertical restriction through:
     * 1. Only accepting vertical gestures
     * 2. Ignoring horizontal swipes
     * 3. Maintaining scroll coordination with parent view
     */
    private func verticalOnlyScrollSection() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // 功能说明 - 告知用户交互限制
            // Function description - Informs users of interaction restrictions
            Text("智能竖向滚动区域 - 只能上下滚动")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // 垂直限制滚动容器
            // Vertical restricted scroll container
            SmartVerticalOnlyScrollView(
                debugInfo: $debugInfo
            ) {
                gridContent()
            }
            .frame(height: 250)
            .background(
                // 紫色背景 - 视觉区分不同的滚动区域
                // Purple background - Visually distinguishes different scroll areas
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple.opacity(0.05))
            )
            .padding(.horizontal)
        }
    }

    // MARK: - Grid Content / 网格内容

    /**
     * 网格布局内容 - 展示二维布局在滚动视图中的应用
     *
     * Grid layout content - Shows 2D layout application in scroll views
     *
     * 这个网格演示了如何在有限的垂直空间内展示更多内容。
     * 3x5 的网格布局是经过精心设计的，确保在各种屏幕尺寸上都有良好的显示效果。
     *
     * This grid demonstrates how to display more content in limited vertical space.
     * The 3x5 grid layout is carefully designed to ensure good display on various screen sizes.
     */
    private func gridContent() -> some View {
        VStack(spacing: 10) {
            // 生成 5 行网格
            // Generate 5 rows of grid
            ForEach(0..<5) { subIndex in
                HStack(spacing: 10) {
                    // 每行 3 列
                    // 3 columns per row
                    ForEach(0..<3) { colIndex in
                        gridItem(row: subIndex, col: colIndex)
                    }
                }
            }
        }
        .padding()
    }

    /**
     * 单个网格项 - 可复用的网格单元组件
     *
     * Single grid item - Reusable grid cell component
     *
     * 设计细节：
     * - 圆角矩形提供现代感
     * - 半透明紫色保持视觉一致性
     * - 图标和文字的组合提供清晰的信息层次
     * - 固定高度确保网格对齐
     *
     * Design details:
     * - Rounded rectangle provides modern feel
     * - Semi-transparent purple maintains visual consistency
     * - Icon and text combination provides clear information hierarchy
     * - Fixed height ensures grid alignment
     */
    private func gridItem(row: Int, col: Int) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.purple.opacity(0.3))
            .frame(height: 80)
            .overlay(
                VStack {
                    // 方向指示图标
                    // Direction indicator icon
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.white)
                    // 位置标识文字
                    // Position identifier text
                    Text("项目 \(row)-\(col)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            )
    }

    // MARK: - Regular Content Section / 常规内容部分

    /**
     * 常规内容区域 - 展示标准的垂直列表布局
     *
     * Regular content area - Shows standard vertical list layout
     *
     * 这是最基础也是最常用的布局模式。
     * 适用于大多数内容展示场景，如：
     * - 新闻列表
     * - 消息对话
     * - 任务清单
     * - 搜索结果
     *
     * This is the most basic and commonly used layout pattern.
     * Suitable for most content display scenarios, such as:
     * - News lists
     * - Message conversations
     * - Task lists
     * - Search results
     */
    private func regularContentSection(index: Int) -> some View {
        VStack(spacing: 10) {
            // 部分标题
            // Section title
            Text("普通内容区域")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // 生成 3 个内容项
            // Generate 3 content items
            ForEach(0..<3) { subIndex in
                regularContentItem(section: index, item: subIndex)
            }
        }
    }

    /**
     * 常规内容项 - 标准列表项组件
     *
     * Regular content item - Standard list item component
     *
     * 这个组件展示了列表项的经典设计：
     * - 灰色背景提供视觉分组
     * - 圆角增加友好感
     * - 内边距确保内容不会贴边
     * - 文字提供清晰的标识
     *
     * This component shows classic list item design:
     * - Gray background provides visual grouping
     * - Rounded corners add friendliness
     * - Padding ensures content doesn't stick to edges
     * - Text provides clear identification
     */
    private func regularContentItem(section: Int, item: Int) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 60)
            .overlay(
                Text("竖向内容 \(section)-\(item + 1)")
            )
            .padding(.horizontal)
    }
}

// MARK: - Card View / 卡片视图

/**
 * 可复用的卡片组件 - 横向滚动的核心视觉元素
 *
 * Reusable card component - Core visual element for horizontal scrolling
 *
 * ==================== 设计哲学 ====================
 *
 * 这个卡片组件体现了现代 UI 设计的几个关键原则：
 * 1. 深度感：通过渐变和阴影创建层次
 * 2. 信息层次：图标、标题、副标题的清晰排列
 * 3. 视觉吸引力：使用随机颜色保持新鲜感
 * 4. 一致性：固定的尺寸和布局结构
 *
 * This card component embodies several key principles of modern UI design:
 * 1. Depth: Create hierarchy through gradients and shadows
 * 2. Information hierarchy: Clear arrangement of icon, title, subtitle
 * 3. Visual appeal: Use random colors to maintain freshness
 * 4. Consistency: Fixed dimensions and layout structure
 *
 * ==================== 技术实现 ====================
 *
 * 渐变实现：
 * - 起点：左上角（更亮）
 * - 终点：右下角（更暗）
 * - 效果：创建自然的光照感
 *
 * 阴影设计：
 * - 颜色：与卡片颜色相同但透明度降低
 * - 半径：5 点，提供柔和的边缘
 * - 偏移：(0, 2) 创建底部阴影效果
 *
 * Gradient implementation:
 * - Start: Top-left (brighter)
 * - End: Bottom-right (darker)
 * - Effect: Creates natural lighting feel
 *
 * Shadow design:
 * - Color: Same as card color but with reduced opacity
 * - Radius: 5 points for soft edges
 * - Offset: (0, 2) creates bottom shadow effect
 */
struct CardView: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(
                // 线性渐变 - 增加视觉深度
                // Linear gradient - Adds visual depth
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 150, height: 180)
            .overlay(
                // 内容叠加层 - 展示信息
                // Content overlay - Display information
                VStack(spacing: 10) {
                    // 星形图标 - 视觉焦点
                    // Star icon - Visual focus
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // 主标题 - 主要信息
                    // Main title - Primary information
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    // 副标题 - 补充信息
                    // Subtitle - Supplementary information
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            )
            // 彩色阴影 - 增强立体感
            // Colored shadow - Enhances 3D effect
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview / 预览

/**
 * 预览配置 - 开发时的实时反馈
 *
 * Preview configuration - Real-time feedback during development
 *
 * 预览提供了一个完整的导航环境，
 * 让开发者可以看到视图在实际应用中的表现。
 *
 * Preview provides a complete navigation environment,
 * allowing developers to see how the view performs in actual applications.
 */
#Preview {
    NavigationView {
        SmartScrollDemoView()
    }
}