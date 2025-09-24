/**
 * AlignmentGuideFlowLayoutSimpleView.swift
 * 极简版 AlignmentGuide 流式布局演示页面 - 带有基础配置
 * 
 * Minimal AlignmentGuide Flow Layout Demo - With Basic Configuration
 * 
 * 设计目标：
 * 这是 AlignmentGuide 流式布局的精简版本，仅保留最基础的配置选项：
 * - 容器内边距调整
 * - item 最大宽度限制
 * 
 * Design Goals:
 * This is a simplified version of AlignmentGuide flow layout, keeping only basic configuration:
 * - Container padding adjustment
 * - Item max width constraint
 * 
 * 核心特点：
 * - 极简代码：仅保留必要的布局逻辑
 * - 基础配置：容器边距和宽度限制
 * - 默认自适应：item 宽度自动跟随文字内容
 * - 智能截断：超过宽度显示省略号
 * 
 * Core Features:
 * - Minimal code: Only essential layout logic
 * - Basic config: Container padding and width constraint
 * - Default adaptive: Item width automatically follows text content
 * - Smart truncation: Show ellipsis when exceeding width
 * 
 * 使用示例：
 * ```swift
 * // 直接使用 / Direct usage
 * AlignmentGuideFlowLayoutSimpleView()
 * ```
 */

import SwiftUI

// MARK: - 极简主视图 / Minimal Main View

/**
 * 🎯 极简版流式布局演示视图
 * Minimal flow layout demo view
 * 
 * 这个视图展示了带有基础配置的 AlignmentGuide 流式布局实现。
 * 仅包含容器边距和宽度限制两个核心配置项。
 * 
 * This view demonstrates AlignmentGuide flow layout with basic configuration.
 * Only includes container padding and width constraint as core config items.
 */
struct AlignmentGuideFlowLayoutSimpleView: View {
    
    // MARK: - 📝 状态属性 / State Properties
    
    /// 文字数组 - 演示用的文字内容 / Text array - Demo text content
    @State private var texts: [String] = [
        "SwiftUI", "iOS", "TCA", "自适应", "流式布局",
        "极简", "演示", "AlignmentGuide", "这是一个比较长的文字标签用于测试截断效果", "标签"
    ]
    
    /// 🔧 容器内边距配置 / Container padding configuration
    @State private var containerPadding: CGFloat = 16
    
    /// 📏 item 最大宽度限制 / Item max width constraint
    @State private var itemMaxWidth: CGFloat? = nil
    @State private var enableMaxWidth: Bool = false
    @State private var maxWidthValue: CGFloat = 100
    
    /// 📐 间距配置 / Spacing configuration
    @State private var itemSpacing: CGFloat = 8      // item 之间的水平间距 / Horizontal spacing between items
    @State private var lineSpacing: CGFloat = 8      // 行之间的垂直间距 / Vertical spacing between lines
    
    // MARK: - 🎨 视图主体 / View Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 🎛️ 控制栏 / Control bar
                controlBar
                
                // 🔧 基础配置面板 / Basic configuration panel
                configPanel
                    .padding(.horizontal)
                
                // 📦 流式布局展示区域 / Flow layout display area
                ScrollView {
                    SimpleFlowLayout(
                        texts: texts,
                        containerPadding: containerPadding,
                        itemMaxWidth: enableMaxWidth ? maxWidthValue : nil,
                        itemSpacing: itemSpacing,
                        lineSpacing: lineSpacing
                    )
                    .padding(containerPadding)  // 应用容器内边距 / Apply container padding
                }
                .background(Color(.systemGroupedBackground))
                
                Spacer()
            }
            .navigationTitle("极简流式布局")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 🎛️ 控制栏 / Control Bar
    
    private var controlBar: some View {
        HStack {
            // ➕ 添加按钮 - 添加随机长度的文字 / Add button - Add random length text
            Button("添加") {
                addRandomText()
            }
            .foregroundColor(.green)
            
            Spacer()
            
            // 🗑️ 清除按钮 - 清空所有文字 / Clear button - Clear all text
            Button("清除") {
                texts.removeAll()
            }
            .foregroundColor(.red)
        }
        .padding(.horizontal)
    }
    
    // MARK: - ⚙️ 配置面板 / Configuration Panel
    
    private var configPanel: some View {
        VStack(spacing: 12) {
            // 📏 容器内边距调整 / Container padding adjustment
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("容器内边距")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(containerPadding))pt")
                        .font(.caption.monospaced())
                        .foregroundColor(.blue)
                }
                
                Slider(value: $containerPadding, in: 0...40, step: 1)
                    .accentColor(.blue)
            }
            
            Divider()
            
            // 🔄 间距调整 / Spacing adjustment
            VStack(alignment: .leading, spacing: 8) {
                // 水平间距 / Horizontal spacing
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("水平间距")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(itemSpacing))pt")
                            .font(.caption.monospaced())
                            .foregroundColor(.green)
                    }
                    
                    Slider(value: $itemSpacing, in: 0...20, step: 1)
                        .accentColor(.green)
                }
                
                // 垂直间距 / Vertical spacing
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("垂直间距")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(lineSpacing))pt")
                            .font(.caption.monospaced())
                            .foregroundColor(.purple)
                    }
                    
                    Slider(value: $lineSpacing, in: 0...20, step: 1)
                        .accentColor(.purple)
                }
            }
            
            Divider()
            
            // 📐 最大宽度限制 / Max width constraint
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Toggle("限制最大宽度", isOn: $enableMaxWidth)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if enableMaxWidth {
                        Text("\(Int(maxWidthValue))pt")
                            .font(.caption.monospaced())
                            .foregroundColor(.orange)
                    }
                }
                
                if enableMaxWidth {
                    Slider(value: $maxWidthValue, in: 50...200, step: 10)
                        .accentColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - 🔧 辅助方法 / Helper Methods
    
    /// 添加随机文字 / Add random text
    private func addRandomText() {
        // 📏 生成随机长度 / Generate random length
        let randomType = Int.random(in: 0...2)
        let randomText: String
        
        switch randomType {
        case 0:  // 短文字 / Short text
            let length = Int.random(in: 1...3)
            let characters = "SwiftUI开发iOS"
            randomText = String((0..<length).compactMap { _ in
                characters.randomElement()
            })
            
        case 1:  // 中等文字 / Medium text
            let words = ["SwiftUI", "iOS开发", "TCA架构", "流式布局", "响应式", "组件化"]
            randomText = words.randomElement() ?? "默认"
            
        default:  // 长文字 / Long text
            let longTexts = [
                "这是一个很长的文字标签用于测试截断",
                "SwiftUI is a modern UI framework",
                "测试超长文字的显示效果和省略号",
                "The Composable Architecture Pattern"
            ]
            randomText = longTexts.randomElement() ?? "长文字"
        }
        
        texts.append(randomText)
    }
}

// MARK: - 🏗️ 简化的流式布局组件 / Simplified Flow Layout Component

/**
 * 🌊 简化版流式布局实现
 * Simplified flow layout implementation
 * 
 * 支持容器边距和宽度限制两个核心配置项。
 * Supports container padding and width constraint as core config items.
 */
struct SimpleFlowLayout: View {
    
    // MARK: - 📥 输入参数 / Input Parameters
    
    let texts: [String]                     // 要显示的文字数组 / Text array to display
    let containerPadding: CGFloat           // 容器内边距 / Container padding
    let itemMaxWidth: CGFloat?              // item 最大宽度 / Item max width
    let itemSpacing: CGFloat                // item 之间的水平间距 / Horizontal spacing between items
    let lineSpacing: CGFloat                // 行之间的垂直间距 / Vertical spacing between lines
    
    // MARK: - 🏗️ 内部状态 / Internal State
    
    /// 布局计算状态 - 记录每个 item 的尺寸 / Layout calculation state - Record size of each item
    @State private var itemSizes: [CGSize] = []
    
    // MARK: - 🎨 视图构建 / View Construction
    
    var body: some View {
        // 📐 使用 GeometryReader 获取容器宽度 / Use GeometryReader to get container width
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        // 🔧 根据内容计算实际高度 / Calculate actual height based on content
        .frame(height: calculateHeight(in: UIScreen.main.bounds.width - containerPadding * 2))
    }
    
    /// 🏗️ 生成布局内容 / Generate layout content
    private func generateContent(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<texts.count, id: \.self) { index in
                // 🏷️ 创建文字标签 / Create text label
                ItemView(
                    text: texts[index],
                    index: index,
                    maxWidth: itemMaxWidth,
                    onSizeCalculated: { size in
                        // 💾 记录实际尺寸 / Record actual size
                        DispatchQueue.main.async {
                            if itemSizes.count <= index {
                                itemSizes.append(size)
                            } else {
                                itemSizes[index] = size
                            }
                        }
                    }
                )
                // 📍 使用 alignmentGuide 计算位置 / Use alignmentGuide to calculate position
                .alignmentGuide(.leading) { dimension in
                    calculateLeadingAlignment(
                        index: index,
                        dimension: dimension,
                        containerWidth: geometry.size.width
                    )
                }
                .alignmentGuide(.top) { dimension in
                    calculateTopAlignment(
                        index: index,
                        dimension: dimension,
                        containerWidth: geometry.size.width
                    )
                }
            }
        }
    }
    
    // MARK: - 📐 布局计算方法 / Layout Calculation Methods
    
    /// 📏 计算水平对齐位置 / Calculate horizontal alignment position
    private func calculateLeadingAlignment(
        index: Int,
        dimension: ViewDimensions,
        containerWidth: CGFloat
    ) -> CGFloat {
        // 如果是第一个 item，从左边开始 / If first item, start from left
        guard index > 0 else { return 0 }
        
        // 计算当前行已使用的宽度 / Calculate used width of current row
        var currentRowWidth: CGFloat = 0
        
        for i in 0..<index {
            guard i < itemSizes.count else { continue }
            
            let itemWidth = itemSizes[i].width + itemSpacing  // 加上间距 / Add spacing
            
            // 检查是否需要换行 / Check if need to wrap line
            if currentRowWidth + itemWidth > containerWidth {
                currentRowWidth = 0  // 新行从头开始 / New line starts from beginning
            }
            
            // 如果是当前 item 的前一个 / If it's the previous item
            if i == index - 1 {
                // 检查当前 item 是否需要换行 / Check if current item needs to wrap
                if currentRowWidth + itemWidth + dimension.width > containerWidth {
                    return 0  // 换行，从左边开始 / Wrap line, start from left
                } else {
                    return -(currentRowWidth + itemWidth)  // 继续在当前行 / Continue on current line
                }
            }
            
            currentRowWidth += itemWidth
        }
        
        return 0
    }
    
    /// 📐 计算垂直对齐位置 / Calculate vertical alignment position
    private func calculateTopAlignment(
        index: Int,
        dimension: ViewDimensions,
        containerWidth: CGFloat
    ) -> CGFloat {
        // 第一个 item 在顶部 / First item at top
        guard index > 0 else { return 0 }
        
        var currentRowWidth: CGFloat = 0
        var currentRowTop: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        
        for i in 0..<index {
            guard i < itemSizes.count else { continue }
            
            let itemSize = itemSizes[i]
            let itemWidth = itemSize.width + itemSpacing  // 加上间距 / Add spacing
            
            // 检查是否需要换行 / Check if need to wrap line
            if currentRowWidth + itemWidth > containerWidth {
                // 换行：更新顶部位置 / Wrap line: Update top position
                currentRowTop += maxHeightInRow + lineSpacing  // 加上行间距 / Add line spacing
                currentRowWidth = itemWidth
                maxHeightInRow = itemSize.height
            } else {
                // 同一行：更新宽度和最大高度 / Same line: Update width and max height
                currentRowWidth += itemWidth
                maxHeightInRow = max(maxHeightInRow, itemSize.height)
            }
        }
        
        // 检查当前 item 是否需要换行 / Check if current item needs to wrap
        if currentRowWidth + dimension.width > containerWidth {
            currentRowTop += maxHeightInRow + lineSpacing  // 换行 / Wrap line
        }
        
        return -currentRowTop
    }
    
    /// 📏 计算总高度 / Calculate total height
    private func calculateHeight(in width: CGFloat) -> CGFloat {
        guard !itemSizes.isEmpty else { return 100 }  // 默认最小高度 / Default minimum height
        
        var currentRowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        
        for size in itemSizes {
            let itemWidth = size.width + itemSpacing
            
            if currentRowWidth + itemWidth > width {
                // 换行 / Wrap line
                totalHeight += maxHeightInRow + lineSpacing
                currentRowWidth = itemWidth
                maxHeightInRow = size.height
            } else {
                currentRowWidth += itemWidth
                maxHeightInRow = max(maxHeightInRow, size.height)
            }
        }
        
        // 加上最后一行的高度 / Add height of last row
        totalHeight += maxHeightInRow
        
        return max(totalHeight + 16, 100)  // 确保最小高度 / Ensure minimum height
    }
}

// MARK: - 🏷️ 单个 Item 视图 / Single Item View

/**
 * 📦 单个 item 的视图组件
 * Single item view component
 * 
 * 负责渲染单个文字标签，并计算实际尺寸。
 * Responsible for rendering single text label and calculating actual size.
 */
struct ItemView: View {
    let text: String
    let index: Int
    let maxWidth: CGFloat?
    let onSizeCalculated: (CGSize) -> Void
    
    var body: some View {
        // 🎯 根据是否有宽度限制创建不同的视图 / Create different views based on width constraint
        if let maxWidth = maxWidth {
            // 有宽度限制：先限制文字宽度，再添加内边距 / With width constraint: Limit text width first, then add padding
            Text(text)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                // 🔧 先限制文字宽度（考虑内边距） / Limit text width first (considering padding)
                .frame(maxWidth: maxWidth - 16, alignment: .leading) // 减去水平内边距 16 = 8 * 2
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.opacity(0.1))
                )
                .foregroundColor(.blue)
                .fixedSize() // 固定尺寸，防止拉伸 / Fix size to prevent stretching
                // 📏 测量实际尺寸 / Measure actual size
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: SizePreferenceKey.self,
                            value: SizeData(index: index, size: geo.size)
                        )
                    }
                )
                .onPreferenceChange(SizePreferenceKey.self) { sizeData in
                    if let data = sizeData, data.index == index {
                        onSizeCalculated(data.size)
                    }
                }
        } else {
            // 无宽度限制：完全自适应 / No width constraint: Fully adaptive
            Text(text)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.opacity(0.1))
                )
                .foregroundColor(.blue)
                .fixedSize() // 完全固定到理想尺寸 / Fully fixed to ideal size
                // 📏 测量实际尺寸 / Measure actual size
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: SizePreferenceKey.self,
                            value: SizeData(index: index, size: geo.size)
                        )
                    }
                )
                .onPreferenceChange(SizePreferenceKey.self) { sizeData in
                    if let data = sizeData, data.index == index {
                        onSizeCalculated(data.size)
                    }
                }
        }
    }
}

// MARK: - 📐 尺寸偏好键 / Size Preference Key

/**
 * 📏 尺寸数据结构
 * Size data structure
 */
struct SizeData: Equatable {
    let index: Int
    let size: CGSize
}

/**
 * 🔑 尺寸偏好键
 * Size preference key
 * 
 * 用于从子视图传递尺寸信息到父视图。
 * Used to pass size information from child view to parent view.
 */
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: SizeData? = nil
    
    static func reduce(value: inout SizeData?, nextValue: () -> SizeData?) {
        value = nextValue() ?? value
    }
}

// MARK: - 预览 / Preview

struct AlignmentGuideFlowLayoutSimpleView_Previews: PreviewProvider {
    static var previews: some View {
        AlignmentGuideFlowLayoutSimpleView()
    }
}

/*
 
 ⏺ Looking at the conversation history and the current state of the code, I can see that all the requested features have been successfully implemented in the AlignmentGuide flow layout:

   ✅ Completed Features

   1. Container Padding Adjustment - Added a slider to control the padding inside the flow layout container (0-40pt)
   2. Item Max Width Constraint - Added a toggle and slider to limit item maximum width (50-200pt), with text showing ellipsis when truncated
   3. Item Spacing Controls - Added sliders to adjust:
     - Horizontal spacing between items (0-20pt) with green accent
     - Vertical spacing between lines (0-20pt) with purple accent
   4. Fixed Spacing Issues - Resolved the problem where items had excessive spacing when max width was enabled
   5. Adaptive Width Behavior - Ensured that items only get constrained when they exceed max width; shorter items maintain their natural width
   6. Text Truncation - Fixed the issue where text wasn't being properly truncated with ellipsis when max width was applied

   Current Implementation Status

   The final implementation in AlignmentGuideFlowLayoutSimpleView.swift correctly handles all these requirements:

   - Lines 453-466: Properly applies frame(maxWidth:) directly to the Text widget before padding, ensuring correct truncation
   - Line 458: Subtracts padding from maxWidth calculation (maxWidth - 16) to account for horizontal padding
   - Lines 451-509: Uses conditional rendering to handle cases with and without max width constraints
   - Lines 67-70: Maintains separate state for itemSpacing and lineSpacing with dynamic updates

   The implementation now provides a fully functional, minimal flow layout with essential configuration options while maintaining clean, readable code.
 */
