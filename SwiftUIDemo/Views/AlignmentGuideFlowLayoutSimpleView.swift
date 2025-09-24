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
                itemView(for: texts[index], at: index, in: geometry)
            }
        }
    }
    
    /// 🏷️ 创建单个 item 视图 / Create single item view
    private func itemView(for text: String, at index: Int, in geometry: GeometryProxy) -> some View {
        Text(text)
            // 🎨 样式：自适应模式的紧凑样式 / Style: Compact style for adaptive mode
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.blue)
            // 📏 文字截断：单行显示，末尾省略 / Text truncation: Single line, ellipsis at end
            .lineLimit(1)
            .truncationMode(.tail)
            // 🔧 宽度限制逻辑 / Width constraint logic
            .modifier(WidthConstraintModifier(maxWidth: itemMaxWidth))
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
            // 💾 记录尺寸供后续计算使用 / Record size for subsequent calculations
            .background(
                GeometryReader { itemGeometry in
                    Color.clear.onAppear {
                        if itemSizes.count <= index {
                            itemSizes.append(itemGeometry.size)
                        } else {
                            itemSizes[index] = itemGeometry.size
                        }
                    }
                }
            )
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

// MARK: - 🔧 宽度约束修饰符 / Width Constraint Modifier

/**
 * 📏 宽度约束修饰符
 * Width constraint modifier
 * 
 * 处理 item 的最大宽度限制，支持文字截断。
 * Handles item max width constraint with text truncation support.
 */
struct WidthConstraintModifier: ViewModifier {
    let maxWidth: CGFloat?
    
    func body(content: Content) -> some View {
        if let maxWidth = maxWidth {
            // 🔒 有宽度限制：应用框架宽度，允许文字截断 / With constraint: Apply frame width, allow text truncation
            content
                .frame(minWidth: 0, maxWidth: maxWidth)  // 设置宽度范围 / Set width range
                .fixedSize(horizontal: false, vertical: true)  // 垂直固定，水平可变 / Fixed vertically, flexible horizontally
        } else {
            // 🔓 无宽度限制：保持原有的固定尺寸 / No constraint: Keep original fixed size
            content
                .fixedSize()
        }
    }
}

// MARK: - 预览 / Preview

struct AlignmentGuideFlowLayoutSimpleView_Previews: PreviewProvider {
    static var previews: some View {
        AlignmentGuideFlowLayoutSimpleView()
    }
}