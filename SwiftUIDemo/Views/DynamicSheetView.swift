/**
 * DynamicSheetView.swift
 * 动态高度的 Sheet 视图 / Dynamic Height Sheet View
 * 
 * 🎯 设计目标 / Design Goals:
 * 
 * 这个视图展示了如何创建一个根据内容动态调整高度的 Sheet 弹窗。
 * 通过组合随机文字、表格视图和智能高度计算，实现了一个灵活的弹窗系统。
 * 
 * This view demonstrates how to create a Sheet popup with dynamic height based on content.
 * By combining random text, table views, and intelligent height calculation, it implements a flexible popup system.
 * 
 * 🏗️ 架构设计 / Architecture Design:
 * 
 * ┌─────────────────────────────────────┐
 * │         DynamicSheetView            │
 * │                                     │
 * │  ┌─────────────────────────────┐  │
 * │  │   Top Random Text (3 para)  │  │
 * │  └─────────────────────────────┘  │
 * │                                     │
 * │  ┌─────────────────────────────┐  │
 * │  │    Excel-like Table View    │  │
 * │  │  ┌─────────┬─────────────┐ │  │
 * │  │  │ Column1 │   Column2    │ │  │
 * │  │  ├─────────┼─────────────┤ │  │
 * │  │  │  Data   │     Data     │ │  │
 * │  │  └─────────┴─────────────┘ │  │
 * │  └─────────────────────────────┘  │
 * │                                     │
 * │  ┌─────────────────────────────┐  │
 * │  │  Bottom Random Text (2 para) │  │
 * │  └─────────────────────────────┘  │
 * └─────────────────────────────────────┘
 * 
 * 🎨 设计模式 / Design Patterns:
 * 
 * 1. BUILDER PATTERN (建造者模式)
 *    - RandomTextGenerator 构建随机文字内容
 *    - 分步骤构建复杂对象
 *    - 提供灵活的内容生成
 * 
 * 2. COMPOSITE PATTERN (组合模式)
 *    - 将视图组件组合成树形结构
 *    - 统一处理单个对象和组合对象
 *    - 实现灵活的视图层次
 * 
 * 3. OBSERVER PATTERN (观察者模式)
 *    - 使用 @State 监听内容变化
 *    - 自动更新视图高度
 *    - 响应式 UI 更新
 * 
 * 🔧 技术实现 / Technical Implementation:
 * 
 * • GeometryReader: 动态计算内容尺寸
 * • PreferenceKey: 传递尺寸信息
 * • ViewModifier: 封装可复用的样式
 * • iOS 版本适配: 兼容 iOS 15 和 16+
 * 
 * 📱 iOS 版本兼容性 / iOS Version Compatibility:
 * 
 * iOS 15.0+: 
 * - 使用 .sheet(isPresented:)
 * - 手动计算内容高度
 * - 使用 presentationDetents 替代方案
 * 
 * iOS 16.0+:
 * - 原生支持 .presentationDetents
 * - 更流畅的高度动画
 * - 更好的手势交互
 */

import SwiftUI
import ComposableArchitecture

// MARK: - Content Size Type / 内容大小类型

/**
 * Sheet 内容大小类型
 * 
 * 定义不同的内容量级别，用于展示不同高度的 Sheet。
 * 
 * Sheet content size types for demonstrating different sheet heights.
 */
enum SheetContentSize {
    case random  // 随机内容 / Random content
    case small   // 小内容（表格≤5行）/ Small content (table ≤5 rows)
    case large   // 大内容（表格>10行）/ Large content (table >10 rows)
}

// MARK: - Random Text Generator / 随机文字生成器

/**
 * 随机文字生成工具
 * 
 * 用于生成测试用的随机文字内容，模拟真实的动态内容场景。
 * 
 * Random text generator utility for creating test content that simulates real dynamic content scenarios.
 */
enum RandomTextGenerator {
    // 随机词库 / Random word pool
    private static let words = [
        "Swift", "iOS", "开发", "设计", "架构", "模式", "视图", "组件", "数据", "状态",
        "Development", "Design", "Architecture", "Pattern", "View", "Component", "Data", "State",
        "功能", "实现", "优化", "性能", "体验", "交互", "动画", "布局", "自适应", "响应式",
        "Feature", "Implementation", "Optimization", "Performance", "Experience", "Interaction", 
        "Animation", "Layout", "Adaptive", "Responsive", "代码", "测试", "调试", "部署", "发布"
    ]
    
    // 短词库（用于小内容）/ Short word pool (for small content)
    private static let shortWords = [
        "iOS", "Swift", "UI", "API", "App", "View", "Data", "Code", "Test", "Beta"
    ]
    
    /**
     * 生成随机段落
     * Generate random paragraph
     * 
     * - Parameters:
     *   - wordCount: 段落字数 / Number of words in paragraph
     *   - useShortWords: 是否使用短词 / Whether to use short words
     * - Returns: 随机生成的段落文字 / Randomly generated paragraph text
     */
    static func generateParagraph(wordCount: Int = 20, useShortWords: Bool = false) -> String {
        let sourceWords = useShortWords ? shortWords : words
        let actualCount = useShortWords ? 
            Int.random(in: max(wordCount/2, 5)...wordCount) :
            Int.random(in: max(wordCount - 5, 10)...wordCount + 5)
        
        return (0..<actualCount)
            .map { _ in sourceWords.randomElement()! }
            .joined(separator: " ")
            .appending("。")
    }
    
    /**
     * 生成多个随机段落
     * Generate multiple random paragraphs
     * 
     * - Parameters:
     *   - count: 段落数量 / Number of paragraphs
     *   - size: 内容大小类型 / Content size type
     * - Returns: 随机段落数组 / Array of random paragraphs
     */
    static func generateParagraphs(count: Int, size: SheetContentSize = .random) -> [String] {
        switch size {
        case .small:
            return (0..<count).map { _ in generateParagraph(wordCount: 8, useShortWords: true) }
        case .large:
            return (0..<count).map { _ in generateParagraph(wordCount: Int.random(in: 25...40)) }
        case .random:
            return (0..<count).map { _ in generateParagraph(wordCount: Int.random(in: 15...30)) }
        }
    }
    
    /**
     * 生成表格数据
     * Generate table data
     * 
     * - Parameters:
     *   - rows: 行数 / Number of rows
     *   - size: 内容大小类型 / Content size type
     * - Returns: 表格数据二维数组 / 2D array of table data
     */
    static func generateTableData(rows: Int, size: SheetContentSize = .random) -> [[String]] {
        (0..<rows).map { index in
            let content = switch size {
            case .small:
                generateParagraph(wordCount: 5, useShortWords: true)
            case .large:
                generateParagraph(wordCount: Int.random(in: 15...25))
            case .random:
                generateParagraph(wordCount: Int.random(in: 8...15))
            }
            
            return [
                "项目 \(index + 1)",
                content
            ]
        }
    }
}

// MARK: - Height Preference Key / 高度偏好键

/**
 * 用于传递视图高度的 PreferenceKey
 * 
 * 这个 PreferenceKey 用于从子视图向父视图传递计算后的高度值，
 * 实现动态高度调整。
 * 
 * PreferenceKey for passing view height from child to parent views,
 * enabling dynamic height adjustment.
 */
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/**
 * 高度读取视图修饰符
 * 
 * 用于读取视图的实际高度并通过 PreferenceKey 传递。
 * 
 * Height reader view modifier for reading actual view height and passing via PreferenceKey.
 */
struct HeightReader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                }
            )
    }
}

// MARK: - Excel-like Table View / Excel 样式表格视图

/**
 * Excel 样式的表格视图组件
 * 
 * 创建一个带边框的两列表格，模拟 Excel 的视觉效果。
 * 支持动态行数和自适应内容。
 * 
 * Excel-style table view component with borders,
 * supporting dynamic row count and adaptive content.
 */
struct ExcelTableView: View {
    let data: [[String]]
    
    var body: some View {
        VStack(spacing: 0) {
            // 表头 / Table header
            headerRow
            
            // 数据行 / Data rows
            ForEach(Array(data.enumerated()), id: \.offset) { index, row in
                dataRow(row, isLast: index == data.count - 1)
            }
        }
        .background(Color(UIColor.systemBackground))
        .overlay(
            // 外边框 / Outer border
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var headerRow: some View {
        HStack(spacing: 0) {
            headerCell("列 1 / Column 1")
            Divider()
                .frame(width: 1)
                .background(Color.gray.opacity(0.3))
            headerCell("列 2 / Column 2")
        }
        .frame(height: 44)
        .background(Color.gray.opacity(0.1))
    }
    
    private func headerCell(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
    }
    
    private func dataRow(_ row: [String], isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                dataCell(row[0])
                Divider()
                    .frame(width: 1)
                    .background(Color.gray.opacity(0.3))
                dataCell(row[1])
            }
            .padding(.vertical, 8)
            
            if !isLast {
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
    
    private func dataCell(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Dynamic Sheet Content View / 动态 Sheet 内容视图

/**
 * Sheet 弹窗的主要内容视图
 * 
 * 包含随机文字、表格和动态高度计算逻辑。
 * 实现精确的高度计算，避免过多空白。
 * 
 * Main content view for the Sheet popup,
 * containing random text, table, and dynamic height calculation logic.
 * Implements precise height calculation to avoid excessive whitespace.
 */
struct DynamicSheetContentView: View {
    // 随机生成的内容 / Randomly generated content
    @State private var topParagraphs: [String] = []
    @State private var bottomParagraphs: [String] = []
    @State private var tableData: [[String]] = []
    @State private var contentHeight: CGFloat = 0
    
    // 内容大小类型 / Content size type
    let contentSize: SheetContentSize
    
    // 关闭回调 / Dismiss callback
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏 / Top bar
            topBar
                .padding(.horizontal)
                .padding(.top, 16)
            
            // 内容区域 / Content area
            VStack(alignment: .leading, spacing: 16) {
                // 上方随机文字 / Top random text
                topTextSection
                
                // Excel 样式表格 / Excel-style table  
                tableSection
                
                // 下方随机文字 / Bottom random text
                bottomTextSection
            }
            .padding(.horizontal)
            .padding(.bottom, 40) // 固定底部间距为40 / Fixed bottom padding of 40
            
            Spacer(minLength: 0)
        }
        .modifier(HeightReader())
        .background(Color(UIColor.systemBackground))
        .onAppear {
            generateRandomContent()
        }
    }
    
    private var topBar: some View {
        HStack {
            Text("动态内容展示 / Dynamic Content Display")
                .font(.headline)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var topTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("上方文字区域 / Top Text Section")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(Array(topParagraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var tableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("数据表格 / Data Table")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ExcelTableView(data: tableData)
        }
    }
    
    private var bottomTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("下方文字区域 / Bottom Text Section")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(Array(bottomParagraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    /**
     * 生成随机内容
     * Generate random content
     */
    private func generateRandomContent() {
        switch contentSize {
        case .small:
            // 小内容：短文字，表格5行或更少 / Small content: short text, table with 5 or fewer rows
            topParagraphs = RandomTextGenerator.generateParagraphs(count: 2, size: .small)
            bottomParagraphs = RandomTextGenerator.generateParagraphs(count: 1, size: .small)
            let rowCount = Int.random(in: 3...5)
            tableData = RandomTextGenerator.generateTableData(rows: rowCount, size: .small)
            
        case .large:
            // 大内容：长文字，表格10行以上 / Large content: long text, table with more than 10 rows
            topParagraphs = RandomTextGenerator.generateParagraphs(count: 3, size: .large)
            bottomParagraphs = RandomTextGenerator.generateParagraphs(count: 2, size: .large)
            let rowCount = Int.random(in: 11...20)
            tableData = RandomTextGenerator.generateTableData(rows: rowCount, size: .large)
            
        case .random:
            // 随机内容 / Random content
            topParagraphs = RandomTextGenerator.generateParagraphs(count: 3, size: .random)
            bottomParagraphs = RandomTextGenerator.generateParagraphs(count: 2, size: .random)
            let rowCount = Int.random(in: 5...15)
            tableData = RandomTextGenerator.generateTableData(rows: rowCount, size: .random)
        }
    }
}

// MARK: - Dynamic Sheet View Modifier / 动态 Sheet 视图修饰符

/**
 * 自定义 ViewModifier 用于展示动态高度的 Sheet
 * 
 * 实现智能高度计算：
 * - 内容高度 < 屏幕85%：使用实际内容高度
 * - 内容高度 >= 屏幕85%：限制为屏幕85%
 * 
 * Custom ViewModifier for presenting dynamic height Sheet with intelligent height calculation:
 * - Content height < 85% screen: Use actual content height
 * - Content height >= 85% screen: Limit to 85% screen height
 */
struct DynamicSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let contentSize: SheetContentSize
    @State private var sheetHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SheetContentWrapper(
                    contentSize: contentSize,
                    isPresented: $isPresented,
                    sheetHeight: $sheetHeight
                )
            }
    }
}

/**
 * Sheet 内容包装器
 * 
 * 处理高度计算和适配不同 iOS 版本。
 * 
 * Sheet content wrapper handling height calculation and iOS version adaptation.
 */
struct SheetContentWrapper: View {
    let contentSize: SheetContentSize
    @Binding var isPresented: Bool
    @Binding var sheetHeight: CGFloat
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let maxHeight = screenHeight * 0.85
            
            if #available(iOS 16.0, *) {
                // iOS 16+ 版本
                DynamicSheetContentView(
                    contentSize: contentSize,
                    onDismiss: {
                        isPresented = false
                    }
                )
                .onPreferenceChange(HeightPreferenceKey.self) { height in
                    // 计算实际需要的高度
                    let finalHeight = min(height, maxHeight)
                    if finalHeight != contentHeight {
                        contentHeight = finalHeight
                    }
                }
                .presentationDetents(
                    contentHeight > 0 ? [.height(contentHeight)] : [.fraction(0.85)]
                )
                .presentationDragIndicator(.visible)
            } else {
                // iOS 15 版本
                VStack {
                    ScrollView {
                        DynamicSheetContentView(
                            contentSize: contentSize,
                            onDismiss: {
                                isPresented = false
                            }
                        )
                        .onPreferenceChange(HeightPreferenceKey.self) { height in
                            let finalHeight = min(height, maxHeight)
                            if finalHeight != contentHeight {
                                contentHeight = finalHeight
                            }
                        }
                    }
                    .frame(height: contentHeight > 0 ? contentHeight : nil)
                    .frame(maxHeight: maxHeight)
                    
                    if contentHeight > 0 && contentHeight < screenHeight * 0.5 {
                        Spacer()
                    }
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}

// MARK: - View Extension / 视图扩展

extension View {
    /**
     * 便捷方法：展示动态高度 Sheet
     * Convenience method: Present dynamic height Sheet
     * 
     * 使用示例 / Usage Example:
     * ```
     * struct ContentView: View {
     *     @State private var showSheet = false
     *     
     *     var body: some View {
     *         Button("Show Sheet") {
     *             showSheet = true
     *         }
     *         .dynamicSheet(isPresented: $showSheet, contentSize: .random)
     *     }
     * }
     * ```
     */
    func dynamicSheet(isPresented: Binding<Bool>, contentSize: SheetContentSize = .random) -> some View {
        self.modifier(DynamicSheetModifier(isPresented: isPresented, contentSize: contentSize))
    }
}

// MARK: - Demo View / 演示视图

/**
 * 动态 Sheet 演示视图
 * 
 * 展示如何使用动态高度的 Sheet 组件，包含三个按钮展示不同内容量。
 * 
 * Dynamic Sheet demo view showing how to use the dynamic height Sheet component 
 * with three buttons for different content sizes.
 */
struct DynamicSheetDemoView: View {
    @State private var showRandomSheet = false
    @State private var showSmallSheet = false
    @State private var showLargeSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题部分 / Title section
            VStack(spacing: 8) {
                Text("动态 Sheet 演示")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Dynamic Sheet Demo")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 说明文字 / Description text
            VStack(spacing: 12) {
                Text("点击不同按钮展示不同内容量的 Sheet")
                    .font(.headline)
                Text("Tap different buttons to show Sheets with varying content")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("最大高度限制为屏幕高度的 85%")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("Max height limited to 85% of screen height")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            Spacer()
            
            // 按钮组 / Button group
            VStack(spacing: 16) {
                // 随机内容按钮 / Random content button
                Button(action: {
                    showRandomSheet = true
                }) {
                    HStack {
                        Image(systemName: "shuffle")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("随机内容 / Random Content")
                                .font(.headline)
                            Text("表格 5-15 行 / Table 5-15 rows")
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                // 小内容按钮 / Small content button
                Button(action: {
                    showSmallSheet = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.compress.vertical")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("小内容 / Small Content")
                                .font(.headline)
                            Text("短文字，表格 ≤5 行 / Short text, table ≤5 rows")
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                
                // 大内容按钮 / Large content button
                Button(action: {
                    showLargeSheet = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.expand.vertical")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("大内容 / Large Content")
                                .font(.headline)
                            Text("长文字，表格 >10 行 / Long text, table >10 rows")
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.purple)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("Dynamic Sheet")
        .navigationBarTitleDisplayMode(.inline)
        // 三个不同的 Sheet / Three different sheets
        .dynamicSheet(isPresented: $showRandomSheet, contentSize: .random)
        .dynamicSheet(isPresented: $showSmallSheet, contentSize: .small)
        .dynamicSheet(isPresented: $showLargeSheet, contentSize: .large)
    }
}

// MARK: - Preview / 预览

struct DynamicSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DynamicSheetDemoView()
        }
    }
}