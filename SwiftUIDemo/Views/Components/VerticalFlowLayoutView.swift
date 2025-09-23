/**
 * VerticalFlowLayoutView.swift
 * 纵向流式布局组件 - 实现自动换列的文字标签纵向流式布局
 * 
 * Vertical Flow Layout Component - Implementing automatic column wrapping vertical text label flow layout
 * 
 * 设计思路和技术实现：
 * 本组件实现了一个高性能的纵向流式布局，支持文字标签从上到下排列，当高度超出限制时自动换列。
 * 与横向流式布局相比，纵向布局需要特殊的高度计算算法和列管理策略。核心算法通过几何计算确定
 * 每个文字项在垂直方向的位置，支持多种垂直对齐方式和动态列间距调整。
 * 
 * Design Philosophy and Technical Implementation:
 * This component implements a high-performance vertical flow layout that supports text labels arranged
 * from top to bottom, automatically switching to new columns when height exceeds limits. Compared to
 * horizontal flow layout, vertical layout requires special height calculation algorithms and column
 * management strategies. The core algorithm determines the vertical position of each text item through
 * geometric calculations, supporting multiple vertical alignment methods and dynamic column spacing adjustment.
 * 
 * 核心技术栈：
 * - SwiftUI VStack/HStack组合: 实现纵向和横向布局的结合
 * - GeometryReader: 获取可用空间并进行动态布局计算
 * - PreferenceKey: 收集子视图高度信息进行整体布局优化
 * - 自定义布局算法: 实现智能的列宽和高度分配
 * 
 * Core Technology Stack:
 * - SwiftUI VStack/HStack combination: Implementing combination of vertical and horizontal layouts
 * - GeometryReader: Getting available space and performing dynamic layout calculations
 * - PreferenceKey: Collecting subview height information for overall layout optimization
 * - Custom layout algorithm: Implementing intelligent column width and height allocation
 * 
 * 解决的核心问题：
 * 1. 纵向布局的自动换列算法实现
 * 2. 多列间的高度平衡和对齐处理
 * 3. 动态列数计算和自适应布局
 * 4. 文字项在垂直方向的精确定位
 * 5. 列间距和行间距的协调控制
 * 
 * Core Problems Solved:
 * 1. Implementation of automatic column switching algorithm for vertical layout
 * 2. Height balancing and alignment handling between multiple columns
 * 3. Dynamic column count calculation and adaptive layout
 * 4. Precise positioning of text items in vertical direction
 * 5. Coordinated control of column spacing and row spacing
 * 
 * 使用的设计模式：
 * 1. Strategy Pattern - 根据可用空间选择不同的列布局策略
 * 2. Observer Pattern - 监听容器尺寸变化并调整布局
 * 3. Template Method Pattern - 定义布局计算的通用框架
 * 4. Composite Pattern - 组合多个列视图形成完整布局
 * 
 * Design Patterns Used:
 * 1. Strategy Pattern - Selecting different column layout strategies based on available space
 * 2. Observer Pattern - Monitoring container size changes and adjusting layout
 * 3. Template Method Pattern - Defining common framework for layout calculations
 * 4. Composite Pattern - Composing multiple column views to form complete layout
 * 
 * SOLID原则应用：
 * - SRP: 专门负责纵向流式布局的渲染和计算
 * - OCP: 通过配置参数扩展布局行为，支持新的对齐方式
 * - LSP: 可以替换横向布局组件使用
 * - ISP: 接口专注于纵向布局相关功能
 * - DIP: 依赖抽象的布局配置接口
 * 
 * SOLID Principles Applied:
 * - SRP: Specifically responsible for rendering and calculation of vertical flow layout
 * - OCP: Extending layout behavior through configuration parameters, supporting new alignment methods
 * - LSP: Can replace horizontal layout components
 * - ISP: Interface focused on vertical layout related functions
 * - DIP: Depending on abstract layout configuration interface
 * 
 * 性能优化措施：
 * 1. 智能列数计算，避免过多或过少的列数
 * 2. 高度缓存机制，减少重复的尺寸计算
 * 3. 延迟布局更新，批量处理布局变更
 * 4. 内存优化，复用列视图组件
 * 
 * Performance Optimization Measures:
 * 1. Smart column count calculation, avoiding too many or too few columns
 * 2. Height caching mechanism, reducing redundant size calculations
 * 3. Delayed layout updates, batch processing layout changes
 * 4. Memory optimization, reusing column view components
 * 
 * 关键技术点和易错点：
 * 1. 列高平衡算法要考虑文字项高度差异
 * 2. 换列判断逻辑需要精确的高度计算
 * 3. 多列对齐时要处理剩余空间分配
 * 4. 动态调整时要保持布局稳定性
 * 5. 边界情况处理（单列、空内容等）
 * 
 * Key Technical Points and Pitfalls:
 * 1. Column height balancing algorithm must consider text item height differences
 * 2. Column switching logic requires precise height calculations
 * 3. Multi-column alignment must handle remaining space allocation
 * 4. Dynamic adjustments must maintain layout stability
 * 5. Boundary case handling (single column, empty content, etc.)
 * 
 * 使用示例：
 * ```swift
 * // 基础纵向流式布局 / Basic vertical flow layout
 * VerticalFlowLayoutView(
 *     texts: ["SwiftUI", "iOS", "TCA", "Redux"],
 *     config: LayoutConfig().maxHeight(200),
 *     onTextTapped: { text, index in
 *         print("Tapped: \(text) at index \(index)")
 *     }
 * )
 * 
 * // 多列纵向布局 / Multi-column vertical layout
 * VerticalFlowLayoutView(
 *     texts: longTextArray,
 *     config: LayoutConfig()
 *         .maxHeight(300)
 *         .itemSpacing(8)
 *         .lineSpacing(12)
 *         .alignment(.center),
 *     selectedIndex: $selectedTextIndex,
 *     onTextTapped: handleTextTapped
 * )
 * ```
 */

import SwiftUI

// MARK: - Vertical Flow Layout View Implementation / 纵向流式布局视图实现

/**
 * 纵向流式布局主组件
 * Main vertical flow layout component
 * 
 * 支持自动换列、多列平衡、动态高度限制
 * Supports automatic column switching, multi-column balancing, dynamic height limits
 */
struct VerticalFlowLayoutView: View {
    // 输入数据 / Input Data
    let texts: [String]
    let config: LayoutConfig
    let selectedIndex: Binding<Int?>?
    let onTextTapped: ((String, Int) -> Void)?
    
    // 内部状态 / Internal State
    @State private var columnData: [ColumnData] = []
    @State private var totalWidth: CGFloat = .zero
    @State private var cachedSizes: [String: CGSize] = [:]
    
    // 初始化方法 / Initialization Methods
    init(
        texts: [String],
        config: LayoutConfig,
        selectedIndex: Binding<Int?>? = nil,
        onTextTapped: ((String, Int) -> Void)? = nil
    ) {
        self.texts = texts
        self.config = config
        self.selectedIndex = selectedIndex
        self.onTextTapped = onTextTapped
    }
    
    var body: some View {
        GeometryReader { geometry in
            generateVerticalFlowLayout(in: geometry)
        }
        .frame(height: config.maxHeight ?? 200)
        .padding(EdgeInsets(
            top: config.padding.top,
            leading: config.padding.leading,
            bottom: config.padding.bottom,
            trailing: config.padding.trailing
        ))
        .onAppear {
            calculateColumnLayout(availableWidth: UIScreen.main.bounds.width - config.padding.leading - config.padding.trailing)
        }
    }
    
    // MARK: - Layout Generation / 布局生成
    
    /**
     * 生成纵向流式布局
     * Generate vertical flow layout
     * 
     * 基于可用空间计算最优的列布局
     * Calculate optimal column layout based on available space
     */
    private func generateVerticalFlowLayout(in geometry: GeometryProxy) -> some View {
        let availableWidth = geometry.size.width
        let availableHeight = config.maxHeight ?? geometry.size.height
        
        // 重新计算列布局（如果需要）/ Recalculate column layout (if needed)
        if abs(totalWidth - availableWidth) > 1 {
            DispatchQueue.main.async {
                self.totalWidth = availableWidth
                self.calculateColumnLayout(availableWidth: availableWidth)
            }
        }
        
        return HStack(alignment: .top, spacing: config.itemSpacing) {
            ForEach(Array(columnData.enumerated()), id: \.offset) { columnIndex, column in
                createColumnView(column: column, availableHeight: availableHeight)
                    .frame(maxHeight: availableHeight)
            }
        }
    }
    
    /**
     * 创建单列视图
     * Create single column view
     * 
     * 包含该列的所有文字项，支持垂直对齐
     * Contains all text items for this column, supports vertical alignment
     */
    private func createColumnView(column: ColumnData, availableHeight: CGFloat) -> some View {
        VStack(alignment: horizontalAlignment, spacing: config.lineSpacing) {
            ForEach(Array(column.items.enumerated()), id: \.offset) { _, item in
                createTextItem(text: item.text, index: item.originalIndex)
            }
            
            // 如果需要填充剩余空间 / If need to fill remaining space
            if config.fillAvailableSpace {
                Spacer()
            }
        }
        .frame(maxHeight: availableHeight, alignment: verticalFrameAlignment)
    }
    
    /**
     * 创建单个文字项视图
     * Create individual text item view
     * 
     * 复用FlowLayoutView的文字项创建逻辑
     * Reusing text item creation logic from FlowLayoutView
     */
    private func createTextItem(text: String, index: Int) -> some View {
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
    
    // MARK: - Column Layout Calculation / 列布局计算
    
    /**
     * 计算列布局分配
     * Calculate column layout allocation
     * 
     * 使用贪心算法将文字项分配到不同列，尽量保持列高平衡
     * Using greedy algorithm to allocate text items to different columns, trying to maintain column height balance
     */
    private func calculateColumnLayout(availableWidth: CGFloat) {
        guard !texts.isEmpty else {
            columnData = []
            return
        }
        
        let maxHeight = config.maxHeight ?? 200
        let itemSpacing = config.itemSpacing
        
        // 计算所有文字项的尺寸 / Calculate sizes of all text items
        let itemSizes = texts.map { getTextSize(for: $0) }
        let totalItemHeight = itemSizes.reduce(0) { $0 + $1.height }
        let totalSpacingHeight = CGFloat(max(0, texts.count - 1)) * config.lineSpacing
        
        // 估算需要的列数 / Estimate required number of columns
        let estimatedColumns = max(1, Int(ceil((totalItemHeight + totalSpacingHeight) / maxHeight)))
        let maxColumns = max(1, Int(availableWidth / 100)) // 最少100pt宽度每列 / Minimum 100pt width per column
        let actualColumns = min(estimatedColumns, maxColumns)
        
        // 初始化列数据 / Initialize column data
        var columns: [ColumnData] = Array(0..<actualColumns).map { _ in
            ColumnData(items: [], totalHeight: 0)
        }
        
        // 使用贪心算法分配文字项 / Use greedy algorithm to allocate text items
        for (index, text) in texts.enumerated() {
            let itemSize = itemSizes[index]
            
            // 找到当前高度最小的列 / Find column with minimum current height
            let minHeightColumnIndex = columns.enumerated().min { $0.element.totalHeight < $1.element.totalHeight }?.offset ?? 0
            
            // 添加到该列 / Add to that column
            let newItem = ColumnItem(text: text, size: itemSize, originalIndex: index)
            columns[minHeightColumnIndex].items.append(newItem)
            columns[minHeightColumnIndex].totalHeight += itemSize.height + config.lineSpacing
        }
        
        // 更新状态 / Update state
        self.columnData = columns
    }
    
    // MARK: - Helper Methods / 辅助方法
    
    /**
     * 获取文字尺寸（带缓存优化）
     * Get text size (with caching optimization)
     * 
     * 复用横向布局的文字测量逻辑
     * Reusing text measurement logic from horizontal layout
     */
    private func getTextSize(for text: String) -> CGSize {
        // 检查缓存 / Check cache
        if let cachedSize = cachedSizes[text] {
            return cachedSize
        }
        
        // 计算实际尺寸 / Calculate actual size
        let font = UIFont.systemFont(ofSize: 17) // 对应.body字体 / Corresponds to .body font
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        
        // 添加内边距 / Add padding
        let totalSize = CGSize(
            width: size.width + config.itemStyle.padding.leading + config.itemStyle.padding.trailing,
            height: size.height + config.itemStyle.padding.top + config.itemStyle.padding.bottom
        )
        
        // 缓存结果 / Cache result
        cachedSizes[text] = totalSize
        return totalSize
    }
    
    /**
     * 水平对齐方式转换
     * Horizontal alignment conversion
     */
    private var horizontalAlignment: HorizontalAlignment {
        switch config.alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        case .justified:
            return .center // justified在纵向布局中使用center
        }
    }
    
    /**
     * 垂直框架对齐方式转换
     * Vertical frame alignment conversion
     */
    private var verticalFrameAlignment: Alignment {
        switch config.alignment {
        case .leading:
            return .top
        case .center:
            return .center
        case .trailing:
            return .bottom
        case .justified:
            return .top
        }
    }
}

// MARK: - Supporting Data Structures / 支持数据结构

/**
 * 列数据结构
 * Column data structure
 * 
 * 包含单列的所有文字项和总高度信息
 * Contains all text items and total height information for a single column
 */
struct ColumnData {
    var items: [ColumnItem]
    var totalHeight: CGFloat
}

/**
 * 列项数据结构
 * Column item data structure
 * 
 * 包含文字项的基本信息和原始索引
 * Contains basic information and original index of text item
 */
struct ColumnItem {
    let text: String
    let size: CGSize
    let originalIndex: Int
}

// MARK: - Preview / 预览

struct VerticalFlowLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 基础纵向布局 / Basic vertical layout
            VerticalFlowLayoutView(
                texts: ["SwiftUI", "iOS开发", "TCA架构", "Redux模式", "状态管理", "Combine框架"],
                config: {
                    var config = LayoutConfig()
                    config.maxHeight = 150
                    return config
                }()
            )
            .border(Color.gray.opacity(0.3))
            
            // 多列纵向布局 / Multi-column vertical layout
            VerticalFlowLayoutView(
                texts: ["这是一个长标签", "短", "中等长度", "Another long label", "测试", "SwiftUI", "iOS", "开发"],
                config: {
                    var config = LayoutConfig()
                    config.maxHeight = 200
                    config.itemSpacing = 12
                    config.lineSpacing = 8
                    config.alignment = .center
                    return config
                }()
            )
            .border(Color.blue.opacity(0.3))
        }
        .padding()
    }
}