/**
 * AlignmentGuideFlowLayoutDemoView.swift
 * 使用 .alignmentGuide API 实现的横向流式布局演示页面
 * 
 * Horizontal Flow Layout Demo Using .alignmentGuide API
 * 
 * 设计思路和技术实现：
 * 本页面展示了如何使用SwiftUI的 .alignmentGuide API 实现横向流式布局。这种方法通过几何计算
 * 来确定每个视图元素的位置，不依赖TCA状态管理，而是使用传参的方式进行配置。该方案更轻量级，
 * 适合简单的布局需求，但在复杂交互和状态管理方面不如TCA方案。
 * 
 * Design Philosophy and Technical Implementation:
 * This page demonstrates how to use SwiftUI's .alignmentGuide API to implement horizontal flow layout.
 * This approach uses geometric calculations to determine the position of each view element, without
 * relying on TCA state management, but using parameter passing for configuration. This solution is
 * more lightweight and suitable for simple layout requirements, but not as good as TCA solution
 * in complex interactions and state management.
 * 
 * 核心技术栈：
 * - SwiftUI .alignmentGuide API: 核心布局实现机制
 * - GeometryReader: 容器尺寸检测和响应
 * - @State 局部状态管理: 简单的内部状态控制
 * - 函数式参数传递: 配置和回调的轻量级管理
 * 
 * Core Technology Stack:
 * - SwiftUI .alignmentGuide API: Core layout implementation mechanism
 * - GeometryReader: Container size detection and response
 * - @State local state management: Simple internal state control
 * - Functional parameter passing: Lightweight management of configuration and callbacks
 * 
 * 解决的核心问题：
 * 1. 轻量级的流式布局实现
 * 2. 不依赖复杂状态管理框架的简单布局
 * 3. 参数化配置的灵活性
 * 4. 单个item的尺寸限制和文字截断
 * 5. 容器边距的动态调整
 * 
 * Core Problems Solved:
 * 1. Lightweight flow layout implementation
 * 2. Simple layout without complex state management frameworks
 * 3. Flexibility of parameterized configuration
 * 4. Size constraints and text truncation for individual items
 * 5. Dynamic adjustment of container margins
 * 
 * 使用的设计模式：
 * 1. Builder Pattern - 配置对象的构建
 * 2. Strategy Pattern - 不同对齐方式的策略
 * 3. Template Method Pattern - 布局计算的模板
 * 4. Delegation Pattern - 事件回调处理
 * 
 * Design Patterns Used:
 * 1. Builder Pattern - Configuration object construction
 * 2. Strategy Pattern - Strategies for different alignment methods
 * 3. Template Method Pattern - Template for layout calculations
 * 4. Delegation Pattern - Event callback handling
 * 
 * SOLID原则应用：
 * - SRP: 专注于使用 .alignmentGuide 的流式布局实现
 * - OCP: 通过参数配置扩展布局行为
 * - LSP: 可以替换其他布局实现
 * - ISP: 接口简洁，专注于布局功能
 * - DIP: 依赖于配置接口而非具体实现
 * 
 * SOLID Principles Applied:
 * - SRP: Focus on flow layout implementation using .alignmentGuide
 * - OCP: Extend layout behavior through parameter configuration
 * - LSP: Can replace other layout implementations
 * - ISP: Clean interface, focused on layout functionality
 * - DIP: Depend on configuration interface rather than concrete implementation
 * 
 * 优势和特点：
 * 1. 轻量级实现，无需复杂的状态管理
 * 2. 直接使用SwiftUI原生API，性能优异
 * 3. 配置灵活，易于定制
 * 4. 代码简洁，易于理解和维护
 * 
 * Advantages and Features:
 * 1. Lightweight implementation without complex state management
 * 2. Direct use of SwiftUI native API, excellent performance
 * 3. Flexible configuration, easy to customize
 * 4. Clean code, easy to understand and maintain
 * 
 * 局限性：
 * 1. 复杂状态管理能力较弱
 * 2. 多组件间状态同步困难
 * 3. 大型应用扩展性有限
 * 4. 调试和测试相对困难
 * 
 * Limitations:
 * 1. Weak complex state management capabilities
 * 2. Difficult state synchronization between multiple components
 * 3. Limited scalability for large applications
 * 4. Relatively difficult debugging and testing
 * 
 * 使用示例：
 * ```swift
 * // 基础用法 / Basic Usage
 * AlignmentGuideFlowLayoutDemoView()
 * 
 * // 在导航中使用 / Usage in Navigation
 * NavigationView {
 *     AlignmentGuideFlowLayoutDemoView()
 *         .navigationTitle("AlignmentGuide 流式布局")
 * }
 * ```
 */

import SwiftUI
import ComposableArchitecture  // 🎯 导入TCA以使用WithPerceptionTracking / Import TCA to use WithPerceptionTracking

// MARK: - 配置结构体定义 / Configuration Struct Definition

/**
 * 📏 项目尺寸模式枚举 - 控制item的尺寸行为
 * Item size mode enum - Controls the sizing behavior of items
 * 
 * 🎯 设计目标 / Design Goals:
 * • 提供灵活的尺寸控制选项 / Provide flexible size control options
 * • 支持不同的视觉效果需求 / Support different visual effect requirements
 * • 保持API的简洁性 / Maintain API simplicity
 * 
 * 📱 模式说明 / Mode Description:
 * • fixed: 固定尺寸模式，item保持统一的padding和最小尺寸
 * • adaptive: 自适应模式，item紧贴文字内容，使用更小的padding
 */
enum ItemSizeMode: String, CaseIterable {
    case fixed = "fixed"           // 🔒 固定尺寸模式 / Fixed size mode
    case adaptive = "adaptive"     // 🔄 自适应尺寸模式 / Adaptive size mode
    
    // 🏷️ 显示名称 / Display name
    var displayName: String {
        switch self {
        case .fixed:
            return "固定尺寸"     // Fixed size
        case .adaptive:
            return "自适应"       // Adaptive
        }
    }
    
    // 📝 详细描述 / Detailed description
    var description: String {
        switch self {
        case .fixed:
            return "保持统一padding和最小尺寸"  // Maintain uniform padding and minimum size
        case .adaptive:
            return "紧贴文字，使用小padding"    // Fit text closely with small padding
        }
    }
}

/**
 * 🎛️ 流式布局配置结构体 - 统一配置管理系统
 * Flow layout configuration struct - Unified configuration management system
 * 
 * 集中管理流式布局的所有可配置参数，支持链式调用的 Builder 模式
 * Centrally manages all configurable parameters for flow layout, supports chained Builder pattern
 * 
 * 🏗️ 设计模式 / Design Pattern: BUILDER PATTERN
 * • 支持链式配置调用 / Support chained configuration calls
 * • 参数分组管理 / Grouped parameter management  
 * • 默认值合理设置 / Reasonable default value settings
 * • 类型安全的参数传递 / Type-safe parameter passing
 * 
 * 📦 配置分类 / Configuration Categories:
 * 1. 布局间距控制 / Layout spacing control
 * 2. 容器边距设置 / Container padding settings
 * 3. 尺寸约束限制 / Size constraint limits
 * 4. 文字显示配置 / Text display configuration
 * 5. 视觉样式定制 / Visual style customization
 * 
 * 💡 使用示例 / Usage Example:
 * ```swift
 * let config = FlowLayoutConfig()
 *     .itemSpacing(12)           // 设置项目间距
 *     .lineSpacing(10)           // 设置行间距
 *     .containerPadding(20)      // 设置容器边距
 *     .itemMaxWidth(150)         // 设置最大宽度
 *     .alignment(.center)        // 设置对齐方式
 * ```
 */
struct FlowLayoutConfig {
    
    // MARK: - 📏 间距控制 / Spacing Control
    var itemSpacing: CGFloat = 8        // 📐 项目间的水平间距 (pt) / Horizontal spacing between items (pt)
    var lineSpacing: CGFloat = 8        // 📏 行与行之间的垂直间距 (pt) / Vertical spacing between lines (pt)
    
    // MARK: - 📦 容器边距 / Container Padding  
    var containerPadding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)  // 🔲 容器内部边距 / Container internal padding
    
    // MARK: - 📐 单个item的尺寸限制 / Size constraints for individual items
    var itemMaxWidth: CGFloat? = nil     // 🔒 最大宽度限制 (nil = 无限制) / Maximum width constraint (nil = no limit)
    var itemMaxHeight: CGFloat? = nil    // 🔒 最大高度限制 (nil = 无限制) / Maximum height constraint (nil = no limit)  
    var itemMinWidth: CGFloat = 44       // 📏 最小宽度保证 (确保可点击区域) / Minimum width guarantee (ensure tappable area)
    var itemMinHeight: CGFloat = 32      // 📏 最小高度保证 (确保可点击区域) / Minimum height guarantee (ensure tappable area)
    
    // MARK: - ✂️ 文字截断设置 / Text truncation settings
    var lineLimit: Int? = nil            // 🔢 文字行数限制 (nil = 无限制) / Text line limit (nil = no limit)
    var truncationMode: Text.TruncationMode = .tail  // ✂️ 截断模式 (.tail = "...在末尾") / Truncation mode (.tail = "... at end")
    
    // MARK: - 📍 对齐方式 / Alignment
    var alignment: HorizontalAlignment = .leading  // 📍 水平对齐方式 (.leading/.center/.trailing) / Horizontal alignment (.leading/.center/.trailing)
    
    // MARK: - 📏 尺寸模式控制 / Size Mode Control
    var itemSizeMode: ItemSizeMode = .fixed          // 🎛️ 项目尺寸模式 / Item size mode
    
    // MARK: - 🎨 样式配置 / Style Configuration
    var backgroundColor: Color = .blue.opacity(0.1)  // 🎨 背景色 (浅蓝色) / Background color (light blue)
    var foregroundColor: Color = .primary             // 🖤 前景色 (系统主色) / Foreground color (system primary)  
    var cornerRadius: CGFloat = 8                     // 🔘 圆角半径 (pt) / Corner radius (pt)
    var borderWidth: CGFloat = 1                      // 🖍️ 边框宽度 (pt) / Border width (pt)
    var borderColor: Color = .blue.opacity(0.3)      // 🎨 边框颜色 (半透明蓝色) / Border color (semi-transparent blue)
    var font: Font = .body                           // 🔤 字体样式 / Font style
    var itemPadding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)  // 📦 项目内部边距 (固定模式) / Item internal padding (fixed mode)
    
    // MARK: - 📦 动态计算的内边距 / Dynamically Calculated Padding
    /**
     * 🔄 根据尺寸模式获取实际使用的内边距
     * Get actual padding based on size mode
     * 
     * @return 根据当前模式返回相应的内边距值 / Return appropriate padding value based on current mode
     */
    var effectiveItemPadding: EdgeInsets {
        switch itemSizeMode {
        case .fixed:
            return itemPadding  // 🔒 固定模式：使用配置的padding / Fixed mode: use configured padding
        case .adaptive:
            return EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4)  // 🔄 自适应模式：使用很小的padding，让宽度紧贴文字 / Adaptive mode: use very small padding to fit text closely
        }
    }
    
    // Builder方法 / Builder Methods
    func itemSpacing(_ spacing: CGFloat) -> FlowLayoutConfig {
        var config = self
        config.itemSpacing = spacing
        return config
    }
    
    func lineSpacing(_ spacing: CGFloat) -> FlowLayoutConfig {
        var config = self
        config.lineSpacing = spacing
        return config
    }
    
    func containerPadding(_ padding: EdgeInsets) -> FlowLayoutConfig {
        var config = self
        config.containerPadding = padding
        return config
    }
    
    func containerPadding(_ padding: CGFloat) -> FlowLayoutConfig {
        var config = self
        config.containerPadding = EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        return config
    }
    
    func itemMaxWidth(_ width: CGFloat?) -> FlowLayoutConfig {
        var config = self
        config.itemMaxWidth = width
        return config
    }
    
    func itemMaxHeight(_ height: CGFloat?) -> FlowLayoutConfig {
        var config = self
        config.itemMaxHeight = height
        return config
    }
    
    func lineLimit(_ limit: Int?) -> FlowLayoutConfig {
        var config = self
        config.lineLimit = limit
        return config
    }
    
    func truncationMode(_ mode: Text.TruncationMode) -> FlowLayoutConfig {
        var config = self
        config.truncationMode = mode
        return config
    }
    
    func alignment(_ alignment: HorizontalAlignment) -> FlowLayoutConfig {
        var config = self
        config.alignment = alignment
        return config
    }
    
    /**
     * 🎛️ 设置项目尺寸模式
     * Set item size mode
     * 
     * @param mode 尺寸模式：.fixed 或 .adaptive / Size mode: .fixed or .adaptive
     * @return 更新后的配置对象 / Updated configuration object
     */
    func itemSizeMode(_ mode: ItemSizeMode) -> FlowLayoutConfig {
        var config = self
        config.itemSizeMode = mode
        return config
    }
}

// MARK: - 主演示页面 / Main Demo View

/**
 * AlignmentGuide 流式布局演示主页面
 * Main demo page for AlignmentGuide flow layout
 */
struct AlignmentGuideFlowLayoutDemoView: View {
    // 演示数据 / Demo Data
    @State private var texts: [String] = [
        "SwiftUI", "iOS开发", "TCA架构", "Redux模式", "状态管理",
        "Combine框架", "MVVM模式", "响应式编程", "函数式编程", "Swift语言",
        "Xcode开发", "界面设计", "用户体验", "性能优化", "代码重构",
        "单元测试", "UI测试", "持续集成", "App Store", "移动应用",
        "短", "中等长度", "这是一个比较长的文字标签", "A", "Hello",
        "🎯", "开发", "测试Demo", "SwiftUI is great", "iOS 17+"
    ]
    
    // 配置状态 / Configuration State
    @State private var config = FlowLayoutConfig()
    @State private var showConfigPanel = false
    @State private var selectedIndex: Int? = nil
    
    // 统计信息 / Statistics
    @State private var totalHeight: CGFloat = 0
    @State private var itemCount: Int = 0
    
    var body: some View {
        NavigationView {
            WithPerceptionTracking {  // 🎯 添加感知追踪以修复警告 / Add perception tracking to fix warning
                VStack(spacing: 0) {
                    // 顶部控制栏 / Top Control Bar - 缩短高度 / Reduce height
                    topControlBar
                        .padding(.horizontal, 12)  // 减少水平边距 / Reduce horizontal padding
                        .padding(.vertical, 4)     // 减少垂直边距 / Reduce vertical padding
                        .background(Color(.systemGroupedBackground))
                    
                    // 主要内容区域 / Main Content Area
                    GeometryReader { geometry in
                        WithPerceptionTracking {  // 🎯 GeometryReader 需要单独的感知追踪 / GeometryReader needs separate perception tracking
                            ScrollView {
                                VStack(spacing: 16) {
                                    // 统计信息 / Statistics
                                    statisticsSection
                                    
                                    // 流式布局展示区域 / Flow Layout Display Area - 缩短高度 / Reduce height
                                    AlignmentGuideFlowLayout(
                                        texts: texts,
                                        config: config,
                                        selectedIndex: $selectedIndex
                                    ) { text, index in
                                        handleTextTapped(text: text, index: index)
                                    }
                                    .frame(height: max(150, totalHeight * 0.7))  // 减少高度至70% / Reduce height to 70%
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)  // 减少圆角 / Reduce corner radius
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)  // 减少阴影 / Reduce shadow
                                    )
                                    .padding(.horizontal, 12)  // 减少水平边距 / Reduce horizontal padding
                                    
                                    // 配置面板 / Configuration Panel
                                    if showConfigPanel {
                                        configurationPanel
                                            .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.vertical, 8)  // 减少垂直边距 / Reduce vertical padding
                            }
                        }
                    }
                }
                .navigationTitle("AlignmentGuide 流式布局")
                .navigationBarTitleDisplayMode(.inline)  // 使用内联标题减少高度 / Use inline title to reduce height
            }
        }
        .onAppear {
            itemCount = texts.count
        }
    }
    
    // MARK: - 视图组件 / View Components
    
    /**
     * 顶部控制栏
     * Top control bar
     */
    private var topControlBar: some View {
        HStack {
            // 配置按钮 / Configuration Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showConfigPanel.toggle()
                }
            }) {
                Image(systemName: showConfigPanel ? "gear.circle.fill" : "gear.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // 重置按钮 / Reset Button
            Button("重置") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    config = FlowLayoutConfig()
                    selectedIndex = nil
                }
            }
            .font(.caption)
            .foregroundColor(.orange)
            
            // 添加文字按钮 / Add Text Button
            Button("添加") {
                // 生成1-12个字符的随机文字 / Generate random text with 1-12 characters
                let randomLength = Int.random(in: 5...15)  // 随机长度5-15 / Random length 5-15
                let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789中文测试数据内容展示效果"
                let randomText = String((0..<randomLength).compactMap { _ in characters.randomElement() })
                
                // 如果生成的是纯英文数字，添加一些常用词汇 / If generated pure English/numbers, add some common words
                let commonWords = ["SwiftUI", "TCA", "iOS", "开发", "测试", "布局", "组件", "框架", "演示", "配置"]
                let finalText = Bool.random() ? randomText : commonWords.randomElement() ?? randomText
                
                texts.append(finalText)  // 添加到文字数组 / Add to text array
                itemCount = texts.count  // 更新计数 / Update count
            }
            .font(.caption)
            .foregroundColor(.green)
            
            // 清除按钮 / Clear Button
            Button("清除") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    texts.removeAll()
                    selectedIndex = nil
                    itemCount = 0
                }
            }
            .font(.caption)
            .foregroundColor(.red)
        }
    }
    
    /**
     * 统计信息区域
     * Statistics section
     */
    private var statisticsSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("项目数量 / Item Count")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(itemCount)")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("布局高度 / Layout Height")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(Int(totalHeight))pt")
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 16)
    }
    
    /**
     * 配置面板
     * Configuration panel
     */
    private var configurationPanel: some View {
        VStack(spacing: 16) {
            // 间距配置 / Spacing Configuration
            VStack(alignment: .leading, spacing: 8) {
                Text("间距配置 / Spacing Configuration")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    // 项目间距 / Item Spacing
                    HStack {
                        Text("项目间距")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { config.itemSpacing },
                            set: { config.itemSpacing = $0 }
                        ), in: 0...20, step: 1)
                        Text("\(Int(config.itemSpacing))pt")
                            .font(.caption)
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    // 行间距 / Line Spacing
                    HStack {
                        Text("行间距")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { config.lineSpacing },
                            set: { config.lineSpacing = $0 }
                        ), in: 0...20, step: 1)
                        Text("\(Int(config.lineSpacing))pt")
                            .font(.caption)
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    // 容器边距 / Container Padding
                    HStack {
                        Text("容器边距")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { config.containerPadding.top },
                            set: { config = config.containerPadding($0) }
                        ), in: 0...40, step: 2)
                        Text("\(Int(config.containerPadding.top))pt")
                            .font(.caption)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            
            // 尺寸限制配置 / Size Constraints Configuration
            VStack(alignment: .leading, spacing: 8) {
                Text("尺寸限制 / Size Constraints")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    // 最大宽度 / Max Width
                    HStack {
                        Text("最大宽度")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { config.itemMaxWidth ?? 200 },
                            set: { config.itemMaxWidth = $0 > 20 ? $0 : nil }
                        ), in: 20...200, step: 10)  // 🎯 调整范围从 20-200 / Adjust range from 20-200
                        Text(config.itemMaxWidth != nil ? "\(Int(config.itemMaxWidth!))pt" : "无限制")
                            .font(.caption)
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    // 最大高度 / Max Height
                    HStack {
                        Text("最大高度")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { config.itemMaxHeight ?? 100 },
                            set: { config.itemMaxHeight = $0 > 30 ? $0 : nil }
                        ), in: 30...100, step: 5)
                        Text(config.itemMaxHeight != nil ? "\(Int(config.itemMaxHeight!))pt" : "无限制")
                            .font(.caption)
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    // 行数限制 / Line Limit
                    HStack {
                        Text("行数限制")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { Double(config.lineLimit ?? 3) },
                            set: { config.lineLimit = Int($0) > 0 ? Int($0) : nil }
                        ), in: 0...5, step: 1)
                        Text(config.lineLimit != nil ? "\(config.lineLimit!)行" : "无限制")
                            .font(.caption)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
            }
            
            // 尺寸模式配置 / Size Mode Configuration
            VStack(alignment: .leading, spacing: 8) {
                Text("尺寸模式 / Size Mode")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Button("固定尺寸") {
                            config = config.itemSizeMode(.fixed)
                        }
                        .buttonStyle(configButtonStyle(isSelected: config.itemSizeMode == .fixed))
                        
                        Button("自适应") {
                            config = config.itemSizeMode(.adaptive)
                        }
                        .buttonStyle(configButtonStyle(isSelected: config.itemSizeMode == .adaptive))
                        
                        Spacer()
                    }
                    
                    // 模式说明 / Mode description
                    Text(config.itemSizeMode.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            // 对齐方式配置 / Alignment Configuration
            VStack(alignment: .leading, spacing: 8) {
                Text("对齐方式 / Alignment")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Button("左对齐") {
                        config = config.alignment(.leading)
                    }
                    .buttonStyle(configButtonStyle(isSelected: config.alignment == .leading))
                    
                    Button("居中") {
                        config = config.alignment(.center)
                    }
                    .buttonStyle(configButtonStyle(isSelected: config.alignment == .center))
                    
                    Button("右对齐") {
                        config = config.alignment(.trailing)
                    }
                    .buttonStyle(configButtonStyle(isSelected: config.alignment == .trailing))
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGroupedBackground))
        )
    }
    
    // MARK: - 辅助方法 / Helper Methods
    
    /**
     * 处理文字点击事件
     * Handle text tap event
     */
    private func handleTextTapped(text: String, index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedIndex = selectedIndex == index ? nil : index
        }
        print("点击了文字: \(text) at index: \(index)")
    }
    
    /**
     * 配置按钮样式
     * Configuration button style
     */
    private func configButtonStyle(isSelected: Bool) -> some ButtonStyle {
        return PlainButtonStyle().toButtonStyle(isSelected: isSelected)
    }
}

// MARK: - AlignmentGuide 流式布局组件 / AlignmentGuide Flow Layout Component

/**
 * 使用 .alignmentGuide 实现的流式布局组件
 * Flow layout component implemented using .alignmentGuide
 * 
 * 这是核心的布局实现，展示了如何使用 .alignmentGuide API 进行复杂的布局计算
 * This is the core layout implementation, demonstrating how to use .alignmentGuide API for complex layout calculations
 */
struct AlignmentGuideFlowLayout: View {
    let texts: [String]
    let config: FlowLayoutConfig
    @Binding var selectedIndex: Int?
    let onTextTapped: (String, Int) -> Void
    
    @State private var totalHeight: CGFloat = 0
    
    var body: some View {
        WithPerceptionTracking {  // 🎯 添加感知追踪以修复警告 / Add perception tracking to fix warning
            GeometryReader { geometry in
                WithPerceptionTracking {  // 🎯 GeometryReader 需要单独的感知追踪 / GeometryReader needs separate perception tracking
                    ZStack(alignment: Alignment(horizontal: config.alignment, vertical: .top)) {
                        // 使用 alignmentGuide 进行布局计算 / Layout calculation using alignmentGuide
                        flowLayoutContent(in: geometry)
                    }
                    .padding(config.containerPadding)
                }
            }
            .frame(height: totalHeight)
        }
    }
    
    /**
     * 🎯 流式布局内容生成 - 核心算法实现
     * Flow layout content generation - Core algorithm implementation
     * 
     * 这是整个 AlignmentGuide 方案的核心算法，通过几何计算实现流式布局
     * This is the core algorithm of the AlignmentGuide approach, implementing flow layout through geometric calculations
     * 
     * 🧠 算法思路 / Algorithm Logic:
     * 1. 使用 var 变量追踪当前行宽度、总高度、行高
     * 2. 通过 .alignmentGuide(.leading) 控制水平位置
     * 3. 通过 .alignmentGuide(.top) 控制垂直位置
     * 4. 动态判断是否需要换行并重新计算位置
     * 
     * 1. Use var variables to track current line width, total height, line height
     * 2. Control horizontal position through .alignmentGuide(.leading)
     * 3. Control vertical position through .alignmentGuide(.top)
     * 4. Dynamically determine if line break is needed and recalculate positions
     */
    private func flowLayoutContent(in geometry: GeometryProxy) -> some View {
        // 📏 布局状态变量 / Layout state variables
        var width = CGFloat.zero      // 🔄 当前行已占用宽度 (从右到左递减) / Current line occupied width (decreasing from right to left)
        var height = CGFloat.zero     // 📐 当前总高度 (向上累积，所以是负值) / Current total height (accumulating upward, so negative)
        var lineHeight = CGFloat.zero // 📏 当前行的最大高度 / Maximum height of current line
        
        // 📦 计算可用宽度 = 容器宽度 - 左右边距 / Calculate available width = container width - left/right padding
        let availableWidth = geometry.size.width - config.containerPadding.leading - config.containerPadding.trailing
        
        return ZStack(alignment: .topLeading) {  // 🎯 使用 topLeading 对齐作为布局起点 / Use topLeading alignment as layout starting point
            
            // 🔄 遍历所有文字项并创建布局 / Iterate through all text items and create layout
            ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                createTextItem(text: text, index: index)  // 🎨 创建单个文字项视图 / Create individual text item view
                
                    // 🧮 水平位置计算 - 核心布局算法 / Horizontal position calculation - Core layout algorithm
                    .alignmentGuide(.leading) { dimension in
                        
                        // 🔍 换行判断逻辑 / Line break logic
                        // abs(width - dimension.width) 计算当前项放置后的行宽
                        // abs(width - dimension.width) calculates the line width after placing current item
                        if abs(width - dimension.width) > availableWidth {
                            
                            // 🆕 触发换行 / Trigger line break
                            width = 0  // 🔄 重置行宽为0 / Reset line width to 0
                            
                            // 📈 增加总高度 (向上移动，所以减去) / Increase total height (moving up, so subtract)
                            height -= lineHeight + config.lineSpacing
                            
                            // 📏 新行的初始高度为当前项高度 / Initial height of new line is current item height
                            lineHeight = dimension.height
                            
                        } else {
                            // 📐 同一行：更新行高为最大值 / Same line: update line height to maximum
                            // max() 确保行高足够容纳最高的元素 / max() ensures line height is sufficient for tallest element
                            lineHeight = max(lineHeight, dimension.height)
                        }
                        
                        // 💾 保存当前 width 作为返回值 (元素的 x 坐标) / Save current width as return value (element's x coordinate)
                        let result = width
                        
                        // 🏁 最后一个元素的特殊处理 / Special handling for last element
                        if index == texts.count - 1 {
                            
                            // 📊 计算并更新总布局高度 / Calculate and update total layout height
                            // 使用 DispatchQueue.main.async 避免在视图更新中修改状态
                            // Use DispatchQueue.main.async to avoid state modification during view update
                            DispatchQueue.main.async {
                                
                                // 🧮 总高度 = |累积高度| + 最后一行高度 + 上下边距
                                // Total height = |accumulated height| + last line height + top/bottom padding
                                self.totalHeight = abs(height) + lineHeight + config.containerPadding.top + config.containerPadding.bottom
                            }
                            
                            // 🔄 重置 width 为下一轮做准备 (虽然这是最后一个) / Reset width for next round (though this is the last one)
                            width = 0
                            
                        } else {
                            // 📏 计算下一个元素的起始位置 / Calculate starting position for next element
                            // width 递减：下一个元素向右移动 current_width + spacing 的距离
                            // width decreases: next element moves right by current_width + spacing distance
                            width -= dimension.width + config.itemSpacing
                        }
                        
                        // 🎯 返回当前元素的 x 坐标 / Return current element's x coordinate
                        return result
                    }
                    
                    // 📐 垂直位置计算 / Vertical position calculation
                    .alignmentGuide(.top) { _ in
                        // 🔝 返回累积的高度作为 y 坐标 / Return accumulated height as y coordinate
                        // height 是负值，表示向上偏移 / height is negative, indicating upward offset
                        height
                    }
            }
        }
    }
    
    /**
     * 🎨 创建单个文字项 - 视图构建与样式应用
     * Create individual text item - View construction and style application
     * 
     * 这个方法负责创建每个流式布局中的单个文字项，包含完整的样式配置和交互处理
     * This method creates individual text items in the flow layout, including complete style configuration and interaction handling
     * 
     * 🎯 功能特性 / Features:
     * • 文字内容渲染与截断处理 / Text content rendering and truncation handling
     * • 尺寸约束应用 / Size constraints application  
     * • 选中状态视觉反馈 / Selected state visual feedback
     * • 点击交互处理 / Tap interaction handling
     * • 动画过渡效果 / Animation transition effects
     * 
     * @param text 要显示的文字内容 / Text content to display
     * @param index 在数组中的索引位置 / Index position in array
     * @return 配置完整的文字项视图 / Fully configured text item view
     */
    private func createTextItem(text: String, index: Int) -> some View {
        // 🔍 选中状态判断 / Selected state determination
        let isSelected = selectedIndex == index  // 🎯 当前项是否被选中 / Whether current item is selected
        
        return Text(text)  // 📝 基础文字组件 / Base text component
        
            // 🎨 文字样式配置 / Text style configuration
            .font(config.itemSizeMode == .adaptive ? .caption : config.font)  // 🔤 自适应模式使用更小字体 / Use smaller font for adaptive mode
            .foregroundColor(isSelected ? .white : config.foregroundColor)  // 🎨 前景色：选中时白色，否则配置色 / Foreground color: white when selected, config color otherwise
            .lineLimit(config.itemSizeMode == .adaptive ? 1 : config.lineLimit)  // 📏 自适应模式强制单行以确保截断生效 / Force single line in adaptive mode to ensure truncation
            .truncationMode(config.truncationMode)  // ✂️ 截断模式 (.tail = "...") / Truncation mode (.tail = "...")
            .multilineTextAlignment(.center)  // 📐 多行文字居中对齐 / Multi-line text center alignment
            
            // 📦 内边距应用 / Padding application
            .padding(config.effectiveItemPadding)  // 🔲 根据尺寸模式动态调整的间距 / Dynamically adjusted spacing based on size mode
            
            // 📏 尺寸约束应用 / Size constraints application
            // 🎯 根据模式决定是否应用约束 / Apply constraints based on mode
            .if(config.itemSizeMode == .fixed) { view in
                view.applyItemSizeConstraints(config: config)  // 🔒 固定模式：应用完整约束 / Fixed mode: apply full constraints
            }
            // 🔄 自适应模式：智能应用宽度约束 / Adaptive mode: intelligently apply width constraints
            .if(config.itemSizeMode == .adaptive) { view in
                Group {
                    if let maxWidth = config.itemMaxWidth {
                        // 🔒 有最大宽度限制时：应用约束并确保截断生效 / With max width: apply constraint and ensure truncation works
                        view
                            .frame(minWidth: 0, maxWidth: maxWidth)  // 允许收缩到0，最大不超过设定值 / Allow shrink to 0, max to set value
                            .fixedSize(horizontal: false, vertical: true)  // 仅垂直固定，水平允许截断 / Fix vertical only, allow horizontal truncation
                    } else {
                        // 🔓 无最大宽度限制时：保持自然尺寸 / Without max width: maintain natural size
                        view.fixedSize()  // 完全固定到理想尺寸 / Fully fix to ideal size
                    }
                }
            }
            
            // 🎨 背景样式配置 / Background style configuration
            .background(
                RoundedRectangle(cornerRadius: config.itemSizeMode == .adaptive ? 4 : config.cornerRadius)  // 🔘 自适应模式使用更小圆角 / Use smaller corner radius for adaptive mode
                    .fill(isSelected ? Color.blue : config.backgroundColor)  // 🎨 填充色：选中时蓝色 / Fill color: blue when selected
                    .overlay(  // 🔲 叠加边框 / Overlay border
                        RoundedRectangle(cornerRadius: config.itemSizeMode == .adaptive ? 4 : config.cornerRadius)  // 🔘 边框圆角保持一致 / Keep consistent border radius
                            .stroke(  // 🖍️ 描边样式 / Stroke style
                                isSelected ? Color.blue : config.borderColor,  // 🎨 边框色：选中时蓝色 / Border color: blue when selected
                                lineWidth: config.itemSizeMode == .adaptive ? 0 : config.borderWidth  // 📏 自适应模式无边框 / No border for adaptive mode
                            )
                    )
            )
            
            // 👆 点击交互处理 / Tap interaction handling
            .onTapGesture {
                onTextTapped(text, index)  // 🎯 触发回调函数，传递文字和索引 / Trigger callback function with text and index
            }
            
            // 🎭 视觉反馈效果 / Visual feedback effects
            .scaleEffect(isSelected ? 1.05 : 1.0)  // 📈 选中时放大5% / Scale up 5% when selected
            .animation(.easeInOut(duration: 0.2), value: isSelected)  // 🎬 0.2秒缓动动画 / 0.2s ease-in-out animation
    }
}

// MARK: - 扩展和辅助类型 / Extensions and Helper Types


/**
 * 🎛️ 尺寸约束扩展 - View 框架尺寸控制
 * Size constraints extension - View frame size control
 * 
 * 为任意 View 添加灵活的尺寸约束功能，支持最大/最小宽高限制
 * Add flexible size constraint functionality to any View, supporting max/min width/height limits
 * 
 * 🎯 设计目标 / Design Goals:
 * • 统一的尺寸约束接口 / Unified size constraint interface
 * • 可选的最大尺寸限制 / Optional maximum size limits  
 * • 保证的最小尺寸要求 / Guaranteed minimum size requirements
 * • 响应式布局支持 / Responsive layout support
 * 
 * 💡 使用场景 / Use Cases:
 * • 防止文字项过宽影响布局 / Prevent text items from being too wide and affecting layout
 * • 确保按钮有足够的点击区域 / Ensure buttons have sufficient touch area
 * • 保持 UI 组件的一致性 / Maintain consistency of UI components
 */
extension View {
    
    /**
     * 🔧 应用项目尺寸约束 (仅用于固定模式)
     * Apply item size constraints (only for fixed mode)
     * 
     * @param config 流式布局配置对象，包含尺寸限制参数 / Flow layout config object containing size limit parameters
     * @return 应用了尺寸约束的视图 / View with applied size constraints
     * 
     * 🧮 约束逻辑 / Constraint Logic:
     * • 应用最小和最大尺寸约束 / Apply min and max size constraints
     * • nil 值表示无限制 / nil value means no restriction
     * 
     * ⚠️ 注意 / Note:
     * • 此方法现在仅在固定模式下使用 / This method is now only used in fixed mode
     * • 自适应模式完全不应用任何frame约束 / Adaptive mode doesn't apply any frame constraints at all
     */
    func applyItemSizeConstraints(config: FlowLayoutConfig) -> some View {
        self.frame(
            minWidth: config.itemMinWidth,    // 📏 最小宽度约束 / Minimum width constraint
            maxWidth: config.itemMaxWidth,    // 📐 最大宽度约束 (可选) / Maximum width constraint (optional)
            minHeight: config.itemMinHeight,  // 📏 最小高度约束 / Minimum height constraint  
            maxHeight: config.itemMaxHeight   // 📐 最大高度约束 (可选) / Maximum height constraint (optional)
        )
    }
}

/**
 * 🎨 按钮样式扩展 - 配置面板按钮样式转换
 * Button style extension - Config panel button style conversion
 * 
 * 为 PlainButtonStyle 添加状态感知的样式转换功能
 * Add state-aware style conversion functionality to PlainButtonStyle
 * 
 * 🎯 设计目标 / Design Goals:
 * • 简化配置按钮样式的使用 / Simplify the use of config button styles
 * • 统一的选中状态表示 / Unified selected state representation
 * • 链式调用API支持 / Chainable API support
 */
extension PlainButtonStyle {
    
    /**
     * 🔄 转换为配置按钮样式
     * Convert to config button style
     * 
     * @param isSelected 是否处于选中状态 / Whether in selected state
     * @return 配置好的按钮样式 / Configured button style
     */
    func toButtonStyle(isSelected: Bool) -> some ButtonStyle {
        return ConfigButtonStyle(isSelected: isSelected)  // 🎯 创建配置按钮样式实例 / Create config button style instance
    }
}

/**
 * 🎛️ 配置按钮样式 - 选中状态感知的按钮外观
 * Config button style - Selected state-aware button appearance
 * 
 * 专为配置面板设计的按钮样式，支持选中/未选中两种状态的视觉反馈
 * Button style designed specifically for config panels, supporting visual feedback for selected/unselected states
 * 
 * 🎨 视觉特性 / Visual Features:
 * • 选中状态：蓝色背景 + 白色文字 / Selected state: blue background + white text
 * • 未选中状态：灰色背景 + 默认文字色 / Unselected state: gray background + default text color
 * • 按压反馈：95% 缩放效果 / Press feedback: 95% scale effect
 * • 圆角设计：6pt 圆角半径 / Rounded design: 6pt corner radius
 * 
 * 📱 交互体验 / Interaction Experience:
 * • 即时的按压视觉反馈 / Instant press visual feedback
 * • 平滑的动画过渡 / Smooth animation transitions
 * • 清晰的状态区分 / Clear state differentiation
 */
struct ConfigButtonStyle: ButtonStyle {
    let isSelected: Bool  // 🔍 按钮选中状态 / Button selected state
    
    /**
     * 🎨 构建按钮视图体
     * Build button view body
     * 
     * @param configuration SwiftUI 按钮配置，包含标签和按压状态 / SwiftUI button configuration including label and press state
     * @return 完整样式的按钮视图 / Fully styled button view
     */
    func makeBody(configuration: Configuration) -> some View {
        configuration.label  // 📝 按钮标签内容 / Button label content
        
            // 🔤 文字样式配置 / Text style configuration
            .font(.caption)  // 📏 使用小字体 / Use caption font
            
            // 📦 内边距设置 / Padding settings
            .padding(.horizontal, 12)  // ↔️ 水平内边距 12pt / Horizontal padding 12pt
            .padding(.vertical, 6)     // ↕️ 垂直内边距 6pt / Vertical padding 6pt
            
            // 🎨 背景样式 / Background style
            .background(
                RoundedRectangle(cornerRadius: 6)  // 🔘 6pt 圆角矩形 / 6pt rounded rectangle
                    .fill(isSelected ? Color.blue : Color(.systemGray5))  // 🎨 填充色：选中时蓝色，否则系统灰色 / Fill color: blue when selected, system gray otherwise
            )
            
            // 🎨 前景色配置 / Foreground color configuration
            .foregroundColor(isSelected ? .white : .primary)  // 🎨 文字色：选中时白色，否则主色 / Text color: white when selected, primary otherwise
            
            // 🎭 按压反馈效果 / Press feedback effect
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)  // 📉 按压时缩放到 95% / Scale to 95% when pressed
            
            // 🎬 动画配置 / Animation configuration
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)  // ⚡ 0.1秒快速动画 / 0.1s fast animation
    }
}

// MARK: - 预览 / Preview

/**
 * 🎬 SwiftUI 预览提供器 - 开发时预览支持
 * SwiftUI Preview Provider - Development-time preview support
 * 
 * 为开发过程提供实时预览功能，可以在 Xcode Canvas 中查看组件效果
 * Provides real-time preview functionality for development, allows viewing component effects in Xcode Canvas
 * 
 * 🛠️ 开发优势 / Development Benefits:
 * • 实时视觉反馈 / Real-time visual feedback
 * • 无需运行模拟器 / No need to run simulator
 * • 快速迭代开发 / Fast iterative development
 * • 多设备尺寸预览 / Multi-device size preview
 * 
 * 💡 使用提示 / Usage Tips:
 * • 在 Xcode 中按 Option+Cmd+Enter 开启 Canvas
 * • Press Option+Cmd+Enter in Xcode to open Canvas
 * • 可添加 .previewDevice() 测试不同设备
 * • Can add .previewDevice() to test different devices
 */
struct AlignmentGuideFlowLayoutDemoView_Previews: PreviewProvider {
    static var previews: some View {
        AlignmentGuideFlowLayoutDemoView()  // 🎯 创建预览实例 / Create preview instance
            .preferredColorScheme(.light)   // 🌞 设置浅色模式预览 / Set light mode preview
            
        // 📱 可选：添加深色模式预览 / Optional: Add dark mode preview
        // AlignmentGuideFlowLayoutDemoView()
        //     .preferredColorScheme(.dark)
        //     .previewDisplayName("Dark Mode")
        
        // 📱 可选：添加不同设备预览 / Optional: Add different device previews  
        // AlignmentGuideFlowLayoutDemoView()
        //     .previewDevice("iPhone SE (3rd generation)")
        //     .previewDisplayName("iPhone SE")
    }
}
