/**
 * GridLayoutView.swift
 * 网格布局组件 - 实现固定列数的网格布局和自适应网格布局
 * 
 * Grid Layout Component - Implementing fixed column count grid layout and adaptive grid layout
 * 
 * 设计思路和技术实现：
 * 本组件实现了灵活的网格布局系统，支持固定列数网格和自适应网格两种模式。固定列数模式按指定列数
 * 均匀分布文字项，自适应模式根据容器宽度和最小项宽度自动计算最优列数。使用SwiftUI的LazyVGrid
 * 实现高性能的网格渲染，支持多种对齐方式和间距控制。
 * 
 * Design Philosophy and Technical Implementation:
 * This component implements a flexible grid layout system supporting both fixed column count and adaptive
 * grid modes. Fixed column mode evenly distributes text items according to specified column count, while
 * adaptive mode automatically calculates optimal column count based on container width and minimum item width.
 * Uses SwiftUI's LazyVGrid for high-performance grid rendering, supporting multiple alignment methods and spacing control.
 * 
 * 核心技术栈：
 * - SwiftUI LazyVGrid: 高性能的网格布局实现
 * - GridItem配置: 灵活的列配置和尺寸控制
 * - GeometryReader: 动态响应容器尺寸变化
 * - 自适应算法: 智能计算最优网格配置
 * 
 * Core Technology Stack:
 * - SwiftUI LazyVGrid: High-performance grid layout implementation
 * - GridItem configuration: Flexible column configuration and size control
 * - GeometryReader: Dynamic response to container size changes
 * - Adaptive algorithm: Intelligent calculation of optimal grid configuration
 * 
 * 解决的核心问题：
 * 1. 固定列数和自适应列数的统一处理
 * 2. 网格项尺寸的自动调整和对齐
 * 3. 不同屏幕尺寸下的响应式布局
 * 4. 网格间距和内边距的精确控制
 * 5. 大量数据时的性能优化
 * 
 * Core Problems Solved:
 * 1. Unified handling of fixed and adaptive column counts
 * 2. Automatic adjustment and alignment of grid item sizes
 * 3. Responsive layout for different screen sizes
 * 4. Precise control of grid spacing and padding
 * 5. Performance optimization for large amounts of data
 * 
 * 使用的设计模式：
 * 1. Strategy Pattern - 固定列数和自适应列数的不同策略
 * 2. Builder Pattern - 网格配置的链式构建
 * 3. Template Method Pattern - 网格布局的通用模板
 * 4. Observer Pattern - 响应容器尺寸变化
 * 
 * Design Patterns Used:
 * 1. Strategy Pattern - Different strategies for fixed and adaptive column counts
 * 2. Builder Pattern - Chain building of grid configuration
 * 3. Template Method Pattern - Common template for grid layout
 * 4. Observer Pattern - Responding to container size changes
 * 
 * SOLID原则应用：
 * - SRP: 专门负责网格布局的渲染和配置
 * - OCP: 通过配置参数扩展网格行为
 * - LSP: 可以替换其他布局组件
 * - ISP: 接口专注于网格布局功能
 * - DIP: 依赖抽象的配置接口
 * 
 * SOLID Principles Applied:
 * - SRP: Specifically responsible for grid layout rendering and configuration
 * - OCP: Extending grid behavior through configuration parameters
 * - LSP: Can replace other layout components
 * - ISP: Interface focused on grid layout functions
 * - DIP: Depending on abstract configuration interface
 * 
 * 性能优化措施：
 * 1. 使用LazyVGrid实现按需渲染
 * 2. 缓存网格配置计算结果
 * 3. 优化列数计算算法
 * 4. 减少不必要的重新布局
 * 
 * Performance Optimization Measures:
 * 1. Using LazyVGrid for on-demand rendering
 * 2. Caching grid configuration calculation results
 * 3. Optimizing column count calculation algorithm
 * 4. Reducing unnecessary re-layouts
 * 
 * 关键技术点和易错点：
 * 1. GridItem的尺寸配置要考虑不同场景
 * 2. 自适应列数计算要处理边界情况
 * 3. 网格对齐时要考虑剩余空间分布
 * 4. 动态调整时要保持视觉连续性
 * 5. 内容溢出时的处理策略
 * 
 * Key Technical Points and Pitfalls:
 * 1. GridItem size configuration must consider different scenarios
 * 2. Adaptive column count calculation must handle boundary conditions
 * 3. Grid alignment must consider remaining space distribution
 * 4. Dynamic adjustments must maintain visual continuity
 * 5. Handling strategies for content overflow
 * 
 * 使用示例：
 * ```swift
 * // 固定3列网格 / Fixed 3-column grid
 * GridLayoutView(
 *     texts: ["SwiftUI", "iOS", "TCA", "Redux"],
 *     config: LayoutConfig(),
 *     gridType: .fixed(columns: 3),
 *     onTextTapped: { text, index in
 *         print("Tapped: \(text) at index \(index)")
 *     }
 * )
 * 
 * // 自适应网格布局 / Adaptive grid layout
 * GridLayoutView(
 *     texts: longTextArray,
 *     config: LayoutConfig()
 *         .itemSpacing(12)
 *         .lineSpacing(10),
 *     gridType: .adaptive(minItemWidth: 100),
 *     selectedIndex: $selectedTextIndex,
 *     onTextTapped: handleTextTapped
 * )
 * ```
 */

import SwiftUI

// MARK: - Grid Layout View Implementation / 网格布局视图实现

/**
 * 网格布局主组件
 * Main grid layout component
 * 
 * 支持固定列数和自适应列数两种网格模式
 * Supports both fixed column count and adaptive column count grid modes
 */
struct GridLayoutView: View {
    // 输入数据 / Input Data
    let texts: [String]
    let config: LayoutConfig
    let gridType: GridType
    let selectedIndex: Binding<Int?>?
    let onTextTapped: ((String, Int) -> Void)?
    
    // 内部状态 / Internal State
    @State private var calculatedColumns: [GridItem] = []
    @State private var containerWidth: CGFloat = .zero
    
    // 初始化方法 / Initialization Methods
    init(
        texts: [String],
        config: LayoutConfig,
        gridType: GridType = .adaptive(minItemWidth: 120),
        selectedIndex: Binding<Int?>? = nil,
        onTextTapped: ((String, Int) -> Void)? = nil
    ) {
        self.texts = texts
        self.config = config
        self.gridType = gridType
        self.selectedIndex = selectedIndex
        self.onTextTapped = onTextTapped
    }
    
    var body: some View {
        GeometryReader { geometry in
            generateGridLayout(in: geometry)
        }
        .padding(EdgeInsets(
            top: config.padding.top,
            leading: config.padding.leading,
            bottom: config.padding.bottom,
            trailing: config.padding.trailing
        ))
        .frame(maxWidth: config.maxWidth)
        .onAppear {
            updateGridConfiguration(availableWidth: UIScreen.main.bounds.width)
        }
    }
    
    // MARK: - Grid Layout Generation / 网格布局生成
    
    /**
     * 生成网格布局
     * Generate grid layout
     * 
     * 根据容器尺寸动态调整网格配置
     * Dynamically adjust grid configuration based on container size
     */
    private func generateGridLayout(in geometry: GeometryProxy) -> some View {
        let availableWidth = geometry.size.width
        
        // 如果容器宽度发生变化，重新计算网格配置 / If container width changes, recalculate grid configuration
        if abs(containerWidth - availableWidth) > 1 {
            DispatchQueue.main.async {
                self.containerWidth = availableWidth
                self.updateGridConfiguration(availableWidth: availableWidth)
            }
        }
        
        return ScrollView(.vertical) {
            LazyVGrid(
                columns: calculatedColumns,
                alignment: horizontalGridAlignment,
                spacing: config.lineSpacing
            ) {
                ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                    createGridItem(text: text, index: index)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: calculatedColumns.count)
        }
    }
    
    /**
     * 创建网格项视图
     * Create grid item view
     * 
     * 支持选中状态和点击交互
     * Supports selected state and click interaction
     */
    private func createGridItem(text: String, index: Int) -> some View {
        let isSelected = selectedIndex?.wrappedValue == index
        
        return Text(text)
            .font(config.itemStyle.font)
            .foregroundColor(isSelected ? .white : config.itemStyle.foregroundColor)
            .lineLimit(config.itemStyle.lineLimit)
            .truncationMode(config.itemStyle.truncationMode)
            .multilineTextAlignment(.center)
            .padding(EdgeInsets(
                top: config.itemStyle.padding.top,
                leading: config.itemStyle.padding.leading,
                bottom: config.itemStyle.padding.bottom,
                trailing: config.itemStyle.padding.trailing
            ))
            .applyItemSizeConstraints(style: config.itemStyle)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: config.itemStyle.cornerRadius)
                    .fill(isSelected ? Color.blue : config.itemStyle.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: config.itemStyle.cornerRadius)
                            .stroke(
                                isSelected ? Color.blue : config.itemStyle.borderColor,
                                lineWidth: config.itemStyle.borderWidth
                            )
                    )
            )
            .onTapGesture {
                selectedIndex?.wrappedValue = selectedIndex?.wrappedValue == index ? nil : index
                onTextTapped?(text, index)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - Grid Configuration / 网格配置
    
    /**
     * 更新网格配置
     * Update grid configuration
     * 
     * 根据网格类型和容器宽度计算最优的列配置
     * Calculate optimal column configuration based on grid type and container width
     */
    private func updateGridConfiguration(availableWidth: CGFloat) {
        switch gridType {
        case .fixed(let columns):
            calculatedColumns = Array(repeating: GridItem(.flexible(), spacing: config.itemSpacing), count: max(1, columns))
            
        case .adaptive(let minItemWidth):
            let effectiveWidth = availableWidth - config.padding.leading - config.padding.trailing
            let itemWidth = max(minItemWidth, config.minItemWidth)
            let maxColumns = max(1, Int(effectiveWidth / (itemWidth + config.itemSpacing)))
            
            calculatedColumns = Array(
                repeating: GridItem(.adaptive(minimum: itemWidth), spacing: config.itemSpacing),
                count: maxColumns
            )
            
        case .flexible(let columns, let minWidth, let maxWidth):
            let flexibleItem = GridItem(
                .flexible(minimum: minWidth, maximum: maxWidth),
                spacing: config.itemSpacing
            )
            calculatedColumns = Array(repeating: flexibleItem, count: max(1, columns))
        }
    }
    
    // MARK: - Helper Methods / 辅助方法
    
    /**
     * 水平网格对齐方式转换
     * Horizontal grid alignment conversion
     */
    private var horizontalGridAlignment: HorizontalAlignment {
        switch config.alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        case .justified:
            return .center // justified在网格中使用center
        }
    }
}

// MARK: - Grid Type Definition / 网格类型定义

/**
 * 网格类型枚举
 * Grid type enumeration
 * 
 * 定义不同的网格布局模式
 * Defines different grid layout modes
 */
enum GridType: Equatable {
    case fixed(columns: Int)                                    // 固定列数 / Fixed column count
    case adaptive(minItemWidth: CGFloat)                        // 自适应列数 / Adaptive column count
    case flexible(columns: Int, minWidth: CGFloat, maxWidth: CGFloat)  // 灵活列宽 / Flexible column width
    
    // 网格类型的显示名称 / Display name for grid type
    var displayName: String {
        switch self {
        case .fixed(let columns):
            return "\(columns)列固定 / \(columns) Columns Fixed"
        case .adaptive(let minWidth):
            return "自适应(最小\(Int(minWidth))pt) / Adaptive(Min \(Int(minWidth))pt)"
        case .flexible(let columns, let minWidth, let maxWidth):
            return "\(columns)列灵活(\(Int(minWidth))-\(Int(maxWidth))pt) / \(columns) Flexible(\(Int(minWidth))-\(Int(maxWidth))pt)"
        }
    }
    
    // 预定义的网格类型 / Predefined grid types
    static let presets: [GridType] = [
        .fixed(columns: 2),
        .fixed(columns: 3),
        .fixed(columns: 4),
        .adaptive(minItemWidth: 100),
        .adaptive(minItemWidth: 120),
        .adaptive(minItemWidth: 150),
        .flexible(columns: 2, minWidth: 80, maxWidth: 200),
        .flexible(columns: 3, minWidth: 60, maxWidth: 150)
    ]
}

// MARK: - Grid Configuration Extensions / 网格配置扩展

extension LayoutConfig {
    /**
     * 网格特定的配置扩展
     * Grid-specific configuration extensions
     */
    
    // 设置最小项宽度 / Set minimum item width
    func minItemWidth(_ width: CGFloat) -> LayoutConfig {
        var config = self
        config.minItemWidth = width
        return config
    }
    
    // 设置最小项高度 / Set minimum item height
    func minItemHeight(_ height: CGFloat) -> LayoutConfig {
        var config = self
        config.minItemHeight = height
        return config
    }
    
    // 设置网格填充模式 / Set grid fill mode
    func fillAvailableSpace(_ fill: Bool) -> LayoutConfig {
        var config = self
        config.fillAvailableSpace = fill
        return config
    }
}

// MARK: - Preview / 预览

struct GridLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 固定3列网格 / Fixed 3-column grid
            GridLayoutView(
                texts: ["SwiftUI", "iOS开发", "TCA架构", "Redux模式", "状态管理", "Combine框架"],
                config: LayoutConfig(),
                gridType: .fixed(columns: 3)
            )
            .frame(height: 150)
            .border(Color.gray.opacity(0.3))
            
            // 自适应网格 / Adaptive grid
            GridLayoutView(
                texts: ["短", "这是一个较长的标签", "中等", "Another long label", "测试", "SwiftUI"],
                config: LayoutConfig()
                    .itemSpacing(12)
                    .lineSpacing(10),
                gridType: .adaptive(minItemWidth: 100)
            )
            .frame(height: 150)
            .border(Color.blue.opacity(0.3))
            
            // 灵活网格 / Flexible grid
            GridLayoutView(
                texts: ["A", "BB", "CCC", "DDDD", "EEEEE", "FFFFFF"],
                config: LayoutConfig()
                    .alignment(.center),
                gridType: .flexible(columns: 3, minWidth: 60, maxWidth: 120)
            )
            .frame(height: 100)
            .border(Color.green.opacity(0.3))
        }
        .padding()
    }
}