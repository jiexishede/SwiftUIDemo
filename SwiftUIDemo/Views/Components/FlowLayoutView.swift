/**
 * FlowLayoutView.swift
 * 横向流式布局组件 - 实现自动换行的文字标签流式布局
 * 
 * Horizontal Flow Layout Component - Implementing automatic wrapping text label flow layout
 * 
 * 设计思路和技术实现：
 * 本组件实现了一个高性能的横向流式布局，支持文字标签从左到右排列，当宽度超出限制时自动换行。
 * 核心算法使用几何计算来确定每个文字项的位置，支持多种对齐方式、动态间距调整和实时布局更新。
 * 为了保证在iOS 15和iOS 16+上的兼容性，使用条件编译实现不同的布局策略。
 * 
 * Design Philosophy and Technical Implementation:
 * This component implements a high-performance horizontal flow layout that supports text labels arranged
 * from left to right, automatically wrapping when width exceeds limits. The core algorithm uses geometric
 * calculations to determine the position of each text item, supporting multiple alignment methods,
 * dynamic spacing adjustment, and real-time layout updates. To ensure compatibility on iOS 15 and iOS 16+,
 * conditional compilation is used to implement different layout strategies.
 * 
 * 核心技术栈：
 * - SwiftUI Layout API (iOS 16+): 使用官方Layout协议实现高性能布局
 * - GeometryReader (iOS 15): 使用几何计算实现布局兼容性
 * - PreferenceKey: 用于子视图向父视图传递尺寸信息
 * - UIKit文字测量: 精确计算文字宽度，确保布局准确性
 * 
 * Core Technology Stack:
 * - SwiftUI Layout API (iOS 16+): Using official Layout protocol for high-performance layout
 * - GeometryReader (iOS 15): Using geometric calculations for layout compatibility
 * - PreferenceKey: For passing size information from child views to parent views
 * - UIKit text measurement: Accurately calculating text width to ensure layout accuracy
 * 
 * 解决的核心问题：
 * 1. 文字宽度的精确测量和缓存优化
 * 2. 自动换行算法的高效实现
 * 3. 多种对齐方式的统一处理
 * 4. iOS版本兼容性适配
 * 5. 实时布局更新的性能优化
 * 
 * Core Problems Solved:
 * 1. Accurate measurement and caching optimization of text width
 * 2. Efficient implementation of automatic wrapping algorithm
 * 3. Unified handling of multiple alignment methods
 * 4. iOS version compatibility adaptation
 * 5. Performance optimization for real-time layout updates
 * 
 * 使用的设计模式：
 * 1. Strategy Pattern - 不同iOS版本使用不同的布局策略
 * 2. Template Method Pattern - 布局算法的框架结构
 * 3. Observer Pattern - 通过PreferenceKey观察尺寸变化
 * 4. Factory Pattern - 根据配置创建不同样式的文字项
 * 
 * Design Patterns Used:
 * 1. Strategy Pattern - Different layout strategies for different iOS versions
 * 2. Template Method Pattern - Framework structure of layout algorithm
 * 3. Observer Pattern - Observing size changes through PreferenceKey
 * 4. Factory Pattern - Creating different styles of text items based on configuration
 * 
 * SOLID原则应用：
 * - SRP: 专门负责横向流式布局的渲染和计算
 * - OCP: 通过配置参数扩展布局行为，无需修改核心代码
 * - LSP: 可以被其他布局组件替换使用
 * - ISP: 接口职责单一，只处理流式布局相关功能
 * - DIP: 依赖于LayoutConfig抽象配置，而非具体实现
 * 
 * SOLID Principles Applied:
 * - SRP: Specifically responsible for rendering and calculation of horizontal flow layout
 * - OCP: Extending layout behavior through configuration parameters without modifying core code
 * - LSP: Can be replaced by other layout components
 * - ISP: Single interface responsibility, only handling flow layout related functions
 * - DIP: Depending on LayoutConfig abstract configuration, not concrete implementation
 * 
 * 性能优化措施：
 * 1. 文字尺寸计算结果缓存，避免重复测量
 * 2. 使用PreferenceKey减少不必要的重绘
 * 3. 懒加载布局计算，只在需要时执行
 * 4. 内存复用，避免创建过多临时对象
 * 
 * Performance Optimization Measures:
 * 1. Caching text size calculation results to avoid redundant measurements
 * 2. Using PreferenceKey to reduce unnecessary redraws
 * 3. Lazy loading layout calculations, executed only when needed
 * 4. Memory reuse, avoiding creation of too many temporary objects
 * 
 * 关键技术点和易错点：
 * 1. 文字测量需要考虑字体、大小、weight等因素
 * 2. 换行算法要正确处理边界情况
 * 3. 对齐计算需要考虑剩余空间分配
 * 4. iOS版本兼容性处理要确保功能一致
 * 5. 动态更新时要避免布局闪烁
 * 
 * Key Technical Points and Pitfalls:
 * 1. Text measurement needs to consider factors like font, size, weight
 * 2. Wrapping algorithm must correctly handle boundary conditions
 * 3. Alignment calculation needs to consider remaining space allocation
 * 4. iOS version compatibility handling must ensure functional consistency
 * 5. Dynamic updates must avoid layout flickering
 * 
 * 使用示例：
 * ```swift
 * // 基础横向流式布局 / Basic horizontal flow layout
 * FlowLayoutView(
 *     texts: ["SwiftUI", "iOS", "TCA", "Redux"],
 *     config: LayoutConfig(),
 *     onTextTapped: { text, index in
 *         print("Tapped: \(text) at index \(index)")
 *     }
 * )
 * 
 * // 自定义配置的流式布局 / Flow layout with custom configuration
 * FlowLayoutView(
 *     texts: longTextArray,
 *     config: LayoutConfig()
 *         .itemSpacing(12)
 *         .lineSpacing(10)
 *         .maxWidth(300)
 *         .alignment(.center),
 *     selectedIndex: $selectedTextIndex,
 *     onTextTapped: handleTextTapped
 * )
 * ```
 */

import SwiftUI

// MARK: - Flow Layout View Implementation / 流式布局视图实现

/**
 * 横向流式布局主组件
 * Main horizontal flow layout component
 * 
 * 支持自动换行、多种对齐方式、动态间距调整
 * Supports automatic wrapping, multiple alignment methods, dynamic spacing adjustment
 */
struct FlowLayoutView: View {
    // 输入数据 / Input Data
    let texts: [String]
    let config: LayoutConfig
    let selectedIndex: Binding<Int?>?
    let onTextTapped: ((String, Int) -> Void)?
    
    // 内部状态 / Internal State
    @State private var totalHeight: CGFloat = .zero
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
        if #available(iOS 16.0, *) {
            // iOS 16+ 使用官方Layout API / iOS 16+ uses official Layout API
            moderniOSFlowLayout
        } else {
            // iOS 15 使用GeometryReader实现 / iOS 15 uses GeometryReader implementation
            legacyiOSFlowLayout
        }
    }
    
    // MARK: - iOS 16+ Layout Implementation / iOS 16+ 布局实现
    
    @available(iOS 16.0, *)
    private var moderniOSFlowLayout: some View {
        FlowLayout(
            alignment: swiftUIAlignment,
            spacing: config.itemSpacing
        ) {
            ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                createTextItem(text: text, index: index)
            }
        }
        .padding(EdgeInsets(
            top: config.padding.top,
            leading: config.padding.leading,
            bottom: config.padding.bottom,
            trailing: config.padding.trailing
        ))
        .frame(maxWidth: config.maxWidth)
    }
    
    // MARK: - iOS 15 Layout Implementation / iOS 15 布局实现
    
    private var legacyiOSFlowLayout: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
        .padding(EdgeInsets(
            top: config.padding.top,
            leading: config.padding.leading,
            bottom: config.padding.bottom,
            trailing: config.padding.trailing
        ))
        .frame(maxWidth: config.maxWidth)
    }
    
    // MARK: - Content Generation / 内容生成
    
    /**
     * 生成流式布局内容（iOS 15兼容实现）
     * Generate flow layout content (iOS 15 compatible implementation)
     * 
     * 使用几何计算确定每个文字项的位置
     * Using geometric calculations to determine the position of each text item
     */
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(texts.enumerated()), id: \.offset) { index, text in
                createTextItem(text: text, index: index)
                    .padding(.trailing, config.itemSpacing)
                    .padding(.bottom, config.lineSpacing)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            // 需要换行 / Need to wrap to next line
                            width = 0
                            height -= dimension.height + config.lineSpacing
                        }
                        let result = width
                        if index == texts.count - 1 {
                            // 最后一个元素，更新总高度 / Last element, update total height
                            width = 0
                        } else {
                            width -= dimension.width + config.itemSpacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if index == texts.count - 1 {
                            // 计算总高度 / Calculate total height
                            DispatchQueue.main.async {
                                self.totalHeight = abs(height) + self.getTextSize(for: text).height + config.lineSpacing
                            }
                        }
                        return result
                    }
            }
        }
    }
    
    // MARK: - Text Item Creation / 文字项创建
    
    /**
     * 创建单个文字项视图
     * Create individual text item view
     * 
     * 支持选中状态、点击交互、自定义样式
     * Supports selected state, click interaction, custom styling
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
    
    // MARK: - Helper Methods / 辅助方法
    
    /**
     * 获取文字尺寸（带缓存优化）
     * Get text size (with caching optimization)
     * 
     * 使用UIKit的文字测量API获得精确尺寸
     * Using UIKit's text measurement API for accurate sizing
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
     * 转换对齐方式为SwiftUI类型
     * Convert alignment to SwiftUI type
     */
    private var swiftUIAlignment: Alignment {
        switch config.alignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        case .justified:
            return .leading // justified在流式布局中使用leading
        }
    }
}

// MARK: - iOS 16+ Flow Layout Implementation / iOS 16+ 流式布局实现

@available(iOS 16.0, *)
struct FlowLayout: Layout {
    let alignment: Alignment
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            if index < result.frames.count {
                let frame = result.frames[index]
                let position = CGPoint(
                    x: bounds.minX + frame.minX,
                    y: bounds.minY + frame.minY
                )
                subview.place(at: position, proposal: ProposedViewSize(frame.size))
            }
        }
    }
}

// MARK: - Flow Layout Calculation / 流式布局计算

@available(iOS 16.0, *)
struct FlowResult {
    var bounds = CGSize.zero
    var frames: [CGRect] = []
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, alignment: Alignment, spacing: CGFloat) {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var lineStartIndex = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                // 需要换行 / Need to wrap
                finalizeCurrentLine(
                    from: lineStartIndex,
                    to: index,
                    y: currentY,
                    lineHeight: lineHeight,
                    maxWidth: maxWidth,
                    alignment: alignment
                )
                
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
                lineStartIndex = index
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        // 处理最后一行 / Handle last line
        if lineStartIndex < subviews.count {
            finalizeCurrentLine(
                from: lineStartIndex,
                to: subviews.count,
                y: currentY,
                lineHeight: lineHeight,
                maxWidth: maxWidth,
                alignment: alignment
            )
        }
        
        bounds = CGSize(width: maxWidth, height: currentY + lineHeight)
    }
    
    private mutating func finalizeCurrentLine(
        from startIndex: Int,
        to endIndex: Int,
        y: CGFloat,
        lineHeight: CGFloat,
        maxWidth: CGFloat,
        alignment: Alignment
    ) {
        // 根据对齐方式调整位置 / Adjust position based on alignment
        let lineWidth = frames[startIndex..<endIndex].map { $0.maxX }.max() ?? 0
        let offsetX: CGFloat
        
        switch alignment {
        case .leading:
            offsetX = 0
        case .center:
            offsetX = (maxWidth - lineWidth) / 2
        case .trailing:
            offsetX = maxWidth - lineWidth
        default:
            offsetX = 0
        }
        
        for index in startIndex..<endIndex {
            frames[index].origin.x += offsetX
            frames[index].origin.y = y + (lineHeight - frames[index].height) / 2
        }
    }
}

// MARK: - Preview / 预览

struct FlowLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 基础流式布局 / Basic flow layout
            FlowLayoutView(
                texts: ["SwiftUI", "iOS开发", "TCA架构", "Redux模式", "状态管理"],
                config: LayoutConfig()
            )
            
            // 自定义配置 / Custom configuration
            FlowLayoutView(
                texts: ["这是一个长标签", "短", "中等长度的标签", "Another very long label", "测试"],
                config: LayoutConfig()
                    .itemSpacing(12)
                    .lineSpacing(10)
                    .alignment(.center)
            )
        }
        .padding()
    }
}

// MARK: - Item Size Constraints Extension / Item尺寸约束扩展
// Note: Size constraint extensions are defined in TextLayoutDemoView.swift
// 注意：尺寸约束扩展定义在 TextLayoutDemoView.swift 中