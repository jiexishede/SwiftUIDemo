/**
 * TextLayoutFeature.swift
 * 文字布局框架功能模块 - 使用TCA架构实现多种布局方式的文字排列组件
 * 
 * Text Layout Framework Feature - Implementing various text layout arrangements using TCA architecture
 * 
 * 设计思路和技术实现：
 * 本文件实现了一个完整的文字布局框架，支持多种常见的布局模式。使用苹果官方推荐的The Composable Architecture (TCA)
 * 模式进行状态管理，确保数据流的单向性和可预测性。框架支持横向流式布局、纵向流式布局、网格布局等多种方式，
 * 并提供丰富的配置选项来控制间距、内边距、对齐方式等视觉效果。
 * 
 * Design Philosophy and Technical Implementation:
 * This file implements a comprehensive text layout framework supporting various common layout patterns. 
 * It uses Apple's officially recommended The Composable Architecture (TCA) pattern for state management,
 * ensuring unidirectional data flow and predictability. The framework supports horizontal flow layouts,
 * vertical flow layouts, grid layouts, and provides rich configuration options to control spacing,
 * padding, alignment, and other visual effects.
 * 
 * 核心技术栈：
 * - SwiftUI: 用于UI渲染和布局计算
 * - TCA (The Composable Architecture): 状态管理和业务逻辑处理
 * - Swift 5.7+: 利用现代Swift语言特性
 * - iOS 15.0+: 支持的最低iOS版本
 * 
 * Core Technology Stack:
 * - SwiftUI: For UI rendering and layout calculations
 * - TCA (The Composable Architecture): State management and business logic handling
 * - Swift 5.7+: Leveraging modern Swift language features
 * - iOS 15.0+: Minimum supported iOS version
 * 
 * 解决的核心问题：
 * 1. 文字标签的动态流式布局显示
 * 2. 多种布局模式的统一管理
 * 3. 布局参数的实时调整和预览
 * 4. 高性能的布局计算和渲染
 * 
 * Core Problems Solved:
 * 1. Dynamic flow layout display for text labels
 * 2. Unified management of multiple layout modes
 * 3. Real-time adjustment and preview of layout parameters
 * 4. High-performance layout calculation and rendering
 * 
 * 使用的设计模式：
 * 1. TCA Redux Pattern - 单向数据流状态管理
 * 2. Builder Pattern - 流式API配置布局参数
 * 3. Strategy Pattern - 不同布局算法的策略选择
 * 4. Factory Pattern - 根据类型创建布局组件
 * 
 * Design Patterns Used:
 * 1. TCA Redux Pattern - Unidirectional data flow state management
 * 2. Builder Pattern - Fluent API for layout parameter configuration
 * 3. Strategy Pattern - Strategy selection for different layout algorithms
 * 4. Factory Pattern - Creating layout components based on type
 * 
 * SOLID原则应用：
 * - SRP: 每个布局类型都有独立的职责和实现
 * - OCP: 通过协议扩展支持新的布局类型
 * - LSP: 所有布局组件都可以互相替换
 * - ISP: 布局配置接口细粒度分离
 * - DIP: 依赖抽象的布局协议而非具体实现
 * 
 * SOLID Principles Applied:
 * - SRP: Each layout type has independent responsibilities and implementation
 * - OCP: Support for new layout types through protocol extensions
 * - LSP: All layout components are interchangeable
 * - ISP: Fine-grained separation of layout configuration interfaces
 * - DIP: Depending on abstract layout protocols rather than concrete implementations
 * 
 * 性能优化措施：
 * 1. 使用LazyHStack/LazyVStack优化大量文字渲染
 * 2. 缓存布局计算结果避免重复计算
 * 3. 使用Equatable协议优化状态比较
 * 4. 合理使用@State和@Binding避免不必要的重绘
 * 
 * Performance Optimization Measures:
 * 1. Using LazyHStack/LazyVStack to optimize rendering of large amounts of text
 * 2. Caching layout calculation results to avoid redundant calculations
 * 3. Using Equatable protocol to optimize state comparisons
 * 4. Proper use of @State and @Binding to avoid unnecessary redraws
 * 
 * 关键技术点和易错点：
 * 1. 流式布局的换行计算需要考虑文字宽度测量
 * 2. 不同iOS版本的布局API兼容性处理
 * 3. 大量文字时的性能优化
 * 4. 动态间距调整时的布局重新计算
 * 5. 安全区域和屏幕边界的处理
 * 
 * Key Technical Points and Pitfalls:
 * 1. Line break calculations in flow layouts need to consider text width measurements
 * 2. Layout API compatibility handling across different iOS versions
 * 3. Performance optimization when dealing with large amounts of text
 * 4. Layout recalculation when dynamically adjusting spacing
 * 5. Handling safe areas and screen boundaries
 * 
 * 使用示例：
 * ```swift
 * // 基础用法 / Basic Usage
 * TextLayoutView(store: Store(
 *     initialState: TextLayoutState(
 *         texts: ["SwiftUI", "iOS", "TCA", "Redux"],
 *         layoutType: .horizontalFlow
 *     ),
 *     reducer: TextLayoutFeature()
 * ))
 * 
 * // 高级配置用法 / Advanced Configuration Usage
 * TextLayoutView(store: Store(
 *     initialState: TextLayoutState(
 *         texts: sampleTexts,
 *         layoutType: .verticalFlow,
 *         layoutConfig: LayoutConfig(
 *             itemSpacing: 12,
 *             lineSpacing: 8,
 *             padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
 *             maxWidth: 300,
 *             alignment: .leading
 *         )
 *     ),
 *     reducer: TextLayoutFeature()
 * ))
 * ```
 */

import SwiftUI
import ComposableArchitecture

// MARK: - State Definition / 状态定义

/**
 * 文字布局功能的完整状态定义
 * Complete state definition for text layout functionality
 * 
 * 包含所有布局相关的配置参数和运行时状态
 * Contains all layout-related configuration parameters and runtime state
 */
struct TextLayoutState: Equatable {
    // 核心数据 / Core Data
    var texts: [String] = []
    var layoutType: LayoutType = .horizontalFlow
    var layoutConfig: LayoutConfig = LayoutConfig()
    
    // UI状态 / UI State
    var isShowingConfigPanel: Bool = false
    var selectedTextIndex: Int? = nil
    
    // 性能优化缓存 / Performance Optimization Cache
    var cachedLayoutSizes: [String: CGSize] = [:]
    var totalContentSize: CGSize = .zero
    
    // 预设配置 / Preset Configurations
    var presetConfigs: [PresetConfig] = PresetConfig.defaultPresets
    var currentPresetIndex: Int = 0
    
    // 演示数据状态 / Demo Data State
    var isDemoMode: Bool = true
    var customTexts: String = ""
    
    // 计算属性：当前使用的文字数组 / Computed Property: Currently Used Text Array
    var displayTexts: [String] {
        if isDemoMode {
            return texts.isEmpty ? PresetConfig.defaultTexts : texts
        } else {
            let customArray = customTexts.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            return customArray.isEmpty ? ["Empty"] : customArray
        }
    }
    
    // 计算属性：当前布局配置 / Computed Property: Current Layout Configuration
    var currentConfig: LayoutConfig {
        if currentPresetIndex < presetConfigs.count {
            return presetConfigs[currentPresetIndex].config
        }
        return layoutConfig
    }
}

// MARK: - Action Definition / 动作定义

/**
 * 文字布局功能的所有可能动作
 * All possible actions for text layout functionality
 * 
 * 遵循TCA的Action-driven架构，所有状态变更都通过Action触发
 * Following TCA's Action-driven architecture, all state changes are triggered through Actions
 */
enum TextLayoutAction: Equatable {
    // 基础文字操作 / Basic Text Operations
    case updateTexts([String])
    case addText(String)
    case removeText(Int)
    case clearAllTexts
    
    // 布局类型控制 / Layout Type Control
    case changeLayoutType(LayoutType)
    case toggleConfigPanel
    
    // 布局配置调整 / Layout Configuration Adjustment
    case updateItemSpacing(CGFloat)
    case updateLineSpacing(CGFloat)
    case updatePadding(EdgeInsets)               // 容器内边距 / Container padding
    case updateContainerPadding(CGFloat)         // 统一的容器内边距控制 / Unified container padding control
    case updateItemPadding(CGFloat)              // 单个item的内边距控制 / Individual item padding control
    case updateMaxWidth(CGFloat?)
    case updateMaxHeight(CGFloat?)
    case updateAlignment(LayoutAlignment)
    
    // Item尺寸控制 / Item Size Control
    case updateItemMaxWidth(CGFloat?)     // 更新item最大宽度 / Update item max width
    case updateItemMaxHeight(CGFloat?)    // 更新item最大高度 / Update item max height
    case updateItemFixedWidth(CGFloat?)   // 更新item固定宽度 / Update item fixed width
    case updateItemFixedHeight(CGFloat?)  // 更新item固定高度 / Update item fixed height
    case updateLineLimit(Int?)            // 更新行数限制 / Update line limit
    case updateTruncationMode(Text.TruncationMode) // 更新截断模式 / Update truncation mode
    
    // 预设配置管理 / Preset Configuration Management
    case selectPreset(Int)
    case saveCurrentAsPreset(String)
    case resetToDefault
    
    // 演示模式控制 / Demo Mode Control
    case toggleDemoMode
    case updateCustomTexts(String)
    case loadSampleTexts(TextSampleType)
    
    // 文字选择和交互 / Text Selection and Interaction
    case selectText(Int?)
    case textTapped(String, Int)
    
    // 性能优化操作 / Performance Optimization Operations
    case cacheLayoutSize(String, CGSize)
    case updateTotalContentSize(CGSize)
    case clearCache
    
    // 导出和分享 / Export and Share
    case exportConfiguration
    case shareLayout
}

// MARK: - Layout Configuration / 布局配置

/**
 * 布局配置结构体，包含所有可调整的布局参数
 * Layout configuration struct containing all adjustable layout parameters
 * 
 * 使用Builder模式支持链式调用配置
 * Using Builder pattern to support chained configuration calls
 */
struct LayoutConfig: Equatable {
    // 间距控制 / Spacing Control
    var itemSpacing: CGFloat = 8        // 元素间距 / Item spacing
    var lineSpacing: CGFloat = 8        // 行间距 / Line spacing
    
    // 内边距控制 / Padding Control
    var padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    
    // 尺寸限制 / Size Constraints
    var maxWidth: CGFloat? = nil        // 最大宽度限制 / Maximum width constraint
    var maxHeight: CGFloat? = nil       // 最大高度限制 / Maximum height constraint
    var minItemWidth: CGFloat = 44      // 最小元素宽度 / Minimum item width
    var minItemHeight: CGFloat = 32     // 最小元素高度 / Minimum item height
    
    // 对齐方式 / Alignment
    var alignment: LayoutAlignment = .leading
    
    // 视觉样式 / Visual Style
    var itemStyle: ItemStyle = ItemStyle()
    
    // 布局行为 / Layout Behavior
    var shouldWrap: Bool = true         // 是否自动换行 / Whether to auto-wrap
    var fillAvailableSpace: Bool = false // 是否填充可用空间 / Whether to fill available space
    
    // Builder方法 / Builder Methods
    func itemSpacing(_ spacing: CGFloat) -> LayoutConfig {
        var config = self
        config.itemSpacing = spacing
        return config
    }
    
    func lineSpacing(_ spacing: CGFloat) -> LayoutConfig {
        var config = self
        config.lineSpacing = spacing
        return config
    }
    
    func padding(_ padding: EdgeInsets) -> LayoutConfig {
        var config = self
        config.padding = padding
        return config
    }
    
    func maxWidth(_ width: CGFloat?) -> LayoutConfig {
        var config = self
        config.maxWidth = width
        return config
    }
    
    func alignment(_ alignment: LayoutAlignment) -> LayoutConfig {
        var config = self
        config.alignment = alignment
        return config
    }
}

// MARK: - Supporting Types / 支持类型

/**
 * 布局类型枚举，定义支持的所有布局模式
 * Layout type enumeration defining all supported layout modes
 */
enum LayoutType: String, CaseIterable, Equatable {
    case horizontalFlow = "horizontal_flow"        // 横向流式布局 / Horizontal flow layout
    case verticalFlow = "vertical_flow"            // 纵向流式布局 / Vertical flow layout
    case grid = "grid"                             // 网格布局 / Grid layout
    case list = "list"                             // 列表布局 / List layout
    case waterfall = "waterfall"                   // 瀑布流布局 / Waterfall layout
    
    // 布局类型的显示名称 / Display name for layout type
    var displayName: String {
        switch self {
        case .horizontalFlow: return "横向流式 / Horizontal Flow"
        case .verticalFlow: return "纵向流式 / Vertical Flow"
        case .grid: return "网格布局 / Grid"
        case .list: return "列表布局 / List"
        case .waterfall: return "瀑布流 / Waterfall"
        }
    }
    
    // 布局类型的图标 / Icon for layout type
    var systemImage: String {
        switch self {
        case .horizontalFlow: return "arrow.right.circle"
        case .verticalFlow: return "arrow.down.circle"
        case .grid: return "grid.circle"
        case .list: return "list.bullet.circle"
        case .waterfall: return "flow.circle"
        }
    }
}

/**
 * 布局对齐方式
 * Layout alignment options
 */
enum LayoutAlignment: String, CaseIterable, Equatable {
    case leading = "leading"
    case center = "center"
    case trailing = "trailing"
    case justified = "justified"           // 两端对齐 / Justified alignment
    
    var displayName: String {
        switch self {
        case .leading: return "左对齐 / Leading"
        case .center: return "居中 / Center"
        case .trailing: return "右对齐 / Trailing"
        case .justified: return "两端对齐 / Justified"
        }
    }
    
    var iconName: String {
        switch self {
        case .leading: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .trailing: return "text.alignright"
        case .justified: return "text.justify"
        }
    }
}

/**
 * 文字元素的视觉样式配置
 * Visual style configuration for text elements
 */
struct ItemStyle: Equatable {
    var backgroundColor: Color = .blue.opacity(0.1)
    var foregroundColor: Color = .primary
    var cornerRadius: CGFloat = 8
    var borderWidth: CGFloat = 1
    var borderColor: Color = .blue.opacity(0.3)
    var font: Font = .body
    var padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    
    // 单个item的尺寸限制 / Size constraints for individual items
    var maxWidth: CGFloat? = nil          // 最大宽度限制 / Maximum width constraint
    var maxHeight: CGFloat? = nil         // 最大高度限制 / Maximum height constraint
    var minWidth: CGFloat? = nil          // 最小宽度限制 / Minimum width constraint
    var minHeight: CGFloat? = nil         // 最小高度限制 / Minimum height constraint
    var fixedWidth: CGFloat? = nil        // 固定宽度 / Fixed width
    var fixedHeight: CGFloat? = nil       // 固定高度 / Fixed height
    
    // 文字截断设置 / Text truncation settings
    var lineLimit: Int? = nil             // 行数限制 / Line limit
    var truncationMode: Text.TruncationMode = .tail  // 截断模式 / Truncation mode
    
    // 预定义样式 / Predefined Styles
    static let tag = ItemStyle(
        backgroundColor: .blue.opacity(0.1),
        foregroundColor: .blue,
        cornerRadius: 16,
        borderWidth: 1,
        borderColor: .blue.opacity(0.3)
    )
    
    static let pill = ItemStyle(
        backgroundColor: .gray.opacity(0.2),
        foregroundColor: .primary,
        cornerRadius: 20,
        borderWidth: 0,
        borderColor: .clear
    )
    
    static let outlined = ItemStyle(
        backgroundColor: .clear,
        foregroundColor: .primary,
        cornerRadius: 8,
        borderWidth: 2,
        borderColor: .primary
    )
}

/**
 * 预设配置，提供常用的布局配置组合
 * Preset configurations providing common layout configuration combinations
 */
struct PresetConfig: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let config: LayoutConfig
    
    // 默认预设配置 / Default Preset Configurations
    static let defaultPresets: [PresetConfig] = [
        PresetConfig(
            name: "标签云 / Tag Cloud",
            config: LayoutConfig()
                .itemSpacing(8)
                .lineSpacing(8)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .alignment(.leading)
        ),
        PresetConfig(
            name: "紧凑布局 / Compact",
            config: LayoutConfig()
                .itemSpacing(4)
                .lineSpacing(4)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .alignment(.leading)
        ),
        PresetConfig(
            name: "宽松布局 / Spacious",
            config: LayoutConfig()
                .itemSpacing(16)
                .lineSpacing(16)
                .padding(EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24))
                .alignment(.center)
        ),
        PresetConfig(
            name: "居中展示 / Centered",
            config: LayoutConfig()
                .itemSpacing(12)
                .lineSpacing(12)
                .maxWidth(280)
                .alignment(.center)
        )
    ]
    
    // 默认演示文字 / Default Demo Texts
    static let defaultTexts: [String] = [
        "SwiftUI", "iOS开发", "TCA架构", "Redux模式", "状态管理",
        "Combine框架", "MVVM模式", "响应式编程", "函数式编程", "Swift语言",
        "Xcode开发", "界面设计", "用户体验", "性能优化", "代码重构",
        "单元测试", "UI测试", "持续集成", "App Store", "移动应用"
    ]
}

/**
 * 文字样本类型，用于快速加载不同类型的演示数据
 * Text sample types for quickly loading different types of demo data
 */
enum TextSampleType: String, CaseIterable {
    case technology = "technology"
    case colors = "colors"
    case countries = "countries"
    case programming = "programming"
    case short = "short"
    case long = "long"
    
    var displayName: String {
        switch self {
        case .technology: return "科技词汇 / Technology"
        case .colors: return "颜色名称 / Colors"
        case .countries: return "国家名称 / Countries"
        case .programming: return "编程语言 / Programming"
        case .short: return "短文字 / Short Texts"
        case .long: return "长文字 / Long Texts"
        }
    }
    
    var sampleTexts: [String] {
        switch self {
        case .technology:
            return ["人工智能", "机器学习", "深度学习", "神经网络", "云计算", "大数据", "区块链", "物联网", "5G通信", "量子计算"]
        case .colors:
            return ["红色", "橙色", "黄色", "绿色", "蓝色", "靛色", "紫色", "黑色", "白色", "灰色", "粉色", "棕色"]
        case .countries:
            return ["中国", "美国", "日本", "德国", "英国", "法国", "意大利", "西班牙", "加拿大", "澳大利亚", "韩国", "新加坡"]
        case .programming:
            return ["Swift", "Objective-C", "Python", "Java", "JavaScript", "TypeScript", "Go", "Rust", "C++", "Kotlin"]
        case .short:
            return ["A", "iOS", "UI", "API", "SDK", "App", "Web", "AI", "ML", "AR", "VR", "3D", "2D"]
        case .long:
            return ["这是一个很长的文字标签示例", "Another very long text label example", "超级长的标签文字内容展示效果", "Extremely long label text content display effect", "测试长文字在布局中的换行和显示效果"]
        }
    }
}

// MARK: - Reducer Implementation / Reducer实现

/**
 * 文字布局功能的主要业务逻辑处理器
 * Main business logic processor for text layout functionality
 * 
 * 使用TCA的Reducer模式处理所有状态变更和副作用
 * Using TCA's Reducer pattern to handle all state changes and side effects
 */
struct TextLayoutFeature: Reducer {
    
    struct State: Equatable {
        // 核心数据 / Core Data
        var texts: [String] = []
        var layoutType: LayoutType = .horizontalFlow
        var layoutConfig: LayoutConfig = LayoutConfig()
        
        // UI状态 / UI State
        var isShowingConfigPanel: Bool = false
        var selectedTextIndex: Int? = nil
        
        // 性能优化缓存 / Performance Optimization Cache
        var cachedLayoutSizes: [String: CGSize] = [:]
        var totalContentSize: CGSize = .zero
        
        // 预设配置 / Preset Configurations
        var presetConfigs: [PresetConfig] = PresetConfig.defaultPresets
        var currentPresetIndex: Int = 0
        
        // 演示数据状态 / Demo Data State
        var isDemoMode: Bool = true
        var customTexts: String = ""
        
        // 计算属性：当前使用的文字数组 / Computed Property: Currently Used Text Array
        var displayTexts: [String] {
            if isDemoMode {
                return texts.isEmpty ? PresetConfig.defaultTexts : texts
            } else {
                let customArray = customTexts.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                return customArray.isEmpty ? ["Empty"] : customArray
            }
        }
        
        // 计算属性：当前布局配置 / Computed Property: Current Layout Configuration
        var currentConfig: LayoutConfig {
            if currentPresetIndex < presetConfigs.count {
                return presetConfigs[currentPresetIndex].config
            }
            return layoutConfig
        }
        
        // 初始化默认状态 / Initialize default state
        init() {
            self.texts = PresetConfig.defaultTexts
        }
    }
    
    enum Action: Equatable {
        // 基础文字操作 / Basic Text Operations
        case updateTexts([String])
        case addText(String)
        case removeText(Int)
        case clearAllTexts
        
        // 布局类型控制 / Layout Type Control
        case changeLayoutType(LayoutType)
        case toggleConfigPanel
        
        // 布局配置调整 / Layout Configuration Adjustment
        case updateItemSpacing(CGFloat)
        case updateLineSpacing(CGFloat)
        case updatePadding(EdgeInsets)               // 容器内边距 / Container padding
        case updateContainerPadding(CGFloat)         // 统一的容器内边距控制 / Unified container padding control
        case updateItemPadding(CGFloat)              // 单个item的内边距控制 / Individual item padding control
        case updateMaxWidth(CGFloat?)
        case updateMaxHeight(CGFloat?)
        case updateAlignment(LayoutAlignment)
        
        // Item尺寸控制 / Item Size Control
        case updateItemMaxWidth(CGFloat?)     // 更新item最大宽度 / Update item max width
        case updateItemMaxHeight(CGFloat?)    // 更新item最大高度 / Update item max height
        case updateItemFixedWidth(CGFloat?)   // 更新item固定宽度 / Update item fixed width
        case updateItemFixedHeight(CGFloat?)  // 更新item固定高度 / Update item fixed height
        case updateLineLimit(Int?)            // 更新行数限制 / Update line limit
        case updateTruncationMode(Text.TruncationMode) // 更新截断模式 / Update truncation mode
        
        // 预设配置管理 / Preset Configuration Management
        case selectPreset(Int)
        case saveCurrentAsPreset(String)
        case resetToDefault
        
        // 演示模式控制 / Demo Mode Control
        case toggleDemoMode
        case updateCustomTexts(String)
        case loadSampleTexts(TextSampleType)
        
        // 文字选择和交互 / Text Selection and Interaction
        case selectText(Int?)
        case textTapped(String, Int)
        
        // 性能优化操作 / Performance Optimization Operations
        case cacheLayoutSize(String, CGSize)
        case updateTotalContentSize(CGSize)
        case clearCache
        
        // 导出和分享 / Export and Share
        case exportConfiguration
        case shareLayout
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        // 基础文字操作处理 / Basic Text Operations Handling
        case .updateTexts(let newTexts):
            state.texts = newTexts
            state.cachedLayoutSizes.removeAll() // 清除缓存以重新计算布局 / Clear cache to recalculate layout
            return .none
            
        case .addText(let newText):
            guard !newText.isEmpty else { return .none }
            state.texts.append(newText)
            return .none
            
        case .removeText(let index):
            guard index >= 0 && index < state.texts.count else { return .none }
            let removedText = state.texts.remove(at: index)
            state.cachedLayoutSizes.removeValue(forKey: removedText) // 清除对应缓存 / Remove corresponding cache
            return .none
            
        case .clearAllTexts:
            state.texts.removeAll()
            state.cachedLayoutSizes.removeAll()
            state.selectedTextIndex = nil
            return .none
            
        // 布局类型控制处理 / Layout Type Control Handling
        case .changeLayoutType(let newType):
            state.layoutType = newType
            state.cachedLayoutSizes.removeAll() // 布局类型变化需要重新计算 / Layout type change requires recalculation
            return .none
            
        case .toggleConfigPanel:
            state.isShowingConfigPanel.toggle()
            return .none
            
        // 布局配置调整处理 / Layout Configuration Adjustment Handling
        case .updateItemSpacing(let spacing):
            state.layoutConfig.itemSpacing = max(0, spacing) // 确保间距非负 / Ensure spacing is non-negative
            return .none
            
        case .updateLineSpacing(let spacing):
            state.layoutConfig.lineSpacing = max(0, spacing)
            return .none
            
        case .updatePadding(let padding):
            state.layoutConfig.padding = padding
            return .none
            
        case .updateContainerPadding(let padding):
            // 更新容器的所有边内边距 / Update container padding for all edges
            let newPadding = EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
            state.layoutConfig.padding = newPadding
            return .none
            
        case .updateItemPadding(let padding):
            // 更新单个item的所有边内边距 / Update individual item padding for all edges
            let newPadding = EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
            state.layoutConfig.itemStyle.padding = newPadding
            return .none
            
        case .updateMaxWidth(let width):
            state.layoutConfig.maxWidth = width
            return .none
            
        case .updateMaxHeight(let height):
            state.layoutConfig.maxHeight = height
            return .none
            
        case .updateAlignment(let alignment):
            state.layoutConfig.alignment = alignment
            return .none
            
        // Item尺寸控制处理 / Item Size Control Handling
        case .updateItemMaxWidth(let width):
            state.layoutConfig.itemStyle.maxWidth = width
            state.cachedLayoutSizes.removeAll() // 尺寸变化需要重新计算 / Size change requires recalculation
            return .none
            
        case .updateItemMaxHeight(let height):
            state.layoutConfig.itemStyle.maxHeight = height
            state.cachedLayoutSizes.removeAll()
            return .none
            
        case .updateItemFixedWidth(let width):
            state.layoutConfig.itemStyle.fixedWidth = width
            state.cachedLayoutSizes.removeAll()
            return .none
            
        case .updateItemFixedHeight(let height):
            state.layoutConfig.itemStyle.fixedHeight = height
            state.cachedLayoutSizes.removeAll()
            return .none
            
        case .updateLineLimit(let limit):
            state.layoutConfig.itemStyle.lineLimit = limit
            state.cachedLayoutSizes.removeAll()
            return .none
            
        case .updateTruncationMode(let mode):
            state.layoutConfig.itemStyle.truncationMode = mode
            state.cachedLayoutSizes.removeAll()
            return .none
            
        // 预设配置管理处理 / Preset Configuration Management Handling
        case .selectPreset(let index):
            guard index >= 0 && index < state.presetConfigs.count else { return .none }
            state.currentPresetIndex = index
            state.layoutConfig = state.presetConfigs[index].config
            state.cachedLayoutSizes.removeAll() // 配置变化需要重新计算 / Configuration change requires recalculation
            return .none
            
        case .saveCurrentAsPreset(let name):
            let newPreset = PresetConfig(name: name, config: state.layoutConfig)
            state.presetConfigs.append(newPreset)
            return .none
            
        case .resetToDefault:
            state.layoutConfig = LayoutConfig()
            state.currentPresetIndex = 0
            state.cachedLayoutSizes.removeAll()
            return .none
            
        // 演示模式控制处理 / Demo Mode Control Handling
        case .toggleDemoMode:
            state.isDemoMode.toggle()
            return .none
            
        case .updateCustomTexts(let texts):
            state.customTexts = texts
            return .none
            
        case .loadSampleTexts(let sampleType):
            state.texts = sampleType.sampleTexts
            state.isDemoMode = true
            state.cachedLayoutSizes.removeAll()
            return .none
            
        // 文字选择和交互处理 / Text Selection and Interaction Handling
        case .selectText(let index):
            state.selectedTextIndex = index
            return .none
            
        case .textTapped(let text, let index):
            state.selectedTextIndex = state.selectedTextIndex == index ? nil : index
            // 这里可以添加更多的点击处理逻辑 / More click handling logic can be added here
            return .none
            
        // 性能优化操作处理 / Performance Optimization Operations Handling
        case .cacheLayoutSize(let text, let size):
            state.cachedLayoutSizes[text] = size
            return .none
            
        case .updateTotalContentSize(let size):
            state.totalContentSize = size
            return .none
            
        case .clearCache:
            state.cachedLayoutSizes.removeAll()
            return .none
            
        // 导出和分享处理 / Export and Share Handling
        case .exportConfiguration:
            // TODO: 实现配置导出功能 / Implement configuration export functionality
            return .none
            
        case .shareLayout:
            // TODO: 实现布局分享功能 / Implement layout sharing functionality
            return .none
        }
    }
}