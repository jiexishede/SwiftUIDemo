import SwiftUI

/**
 * 智能滚动演示视图 - 展示嵌套滚动的实现
 *
 * Smart Scroll Demo View - Demonstrates nested scrolling implementation
 *
 * 本文件展示了不同类型的滚动视图如何协同工作。通过将复杂的视图分解为小的计算属性，
 * 我们避免了编译器类型检查超时的问题，同时提高了代码的可读性。
 *
 * This file shows how different types of scroll views work together. By breaking down complex views 
 * into small computed properties, we avoid compiler type-checking timeout issues while improving code readability.
 */

struct SmartScrollDemoView: View {
    @State private var debugInfo: String = "滑动方向: 无"
    @State private var verticalScrollOffset: CGFloat = 0
    @State private var isVerticalScrolling: Bool = false
    @State private var showDebugInfo: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // 调试信息头部
            // Debug info header
            debugHeader
            
            // 主滚动内容
            // Main scroll content
            mainScrollContent
        }
        .navigationTitle("智能滚动演示")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Debug Header / 调试头部
    
    /**
     * 调试信息显示区域 - 显示当前滚动状态
     *
     * Debug info display area - Shows current scroll status
     */
    private var debugHeader: some View {
        VStack(spacing: 5) {
            HStack {
                Text("调试信息")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Toggle("", isOn: $showDebugInfo)
                    .labelsHidden()
            }
            .padding(.horizontal)
            
            if showDebugInfo {
                HStack {
                    Text(debugInfo)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
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
     * 主要滚动视图内容 - 包含多个不同类型的部分
     *
     * Main scroll view content - Contains multiple different types of sections
     */
    private var mainScrollContent: some View {
        SmartVerticalScrollView(
            verticalScrollOffset: $verticalScrollOffset,
            isVerticalScrolling: $isVerticalScrolling,
            debugInfo: $debugInfo
        ) {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    sectionContent(for: index)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Section Content / 部分内容
    
    /**
     * 根据索引返回不同类型的内容部分
     *
     * Returns different types of content sections based on index
     *
     * 通过将每个部分提取为独立的方法，我们避免了编译器类型推断的复杂性。
     *
     * By extracting each section as an independent method, we avoid compiler type inference complexity.
     */
    @ViewBuilder
    private func sectionContent(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Section \(index + 1)")
                .font(.headline)
                .padding(.horizontal)
            
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
     * 横向滚动区域 - 展示卡片式内容
     *
     * Horizontal scroll area - Displays card-style content
     */
    private func horizontalScrollSection() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("横向滚动区域 - 上下滑动会触发页面滚动")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            SmartHorizontalScrollView(
                parentVerticalScrollOffset: $verticalScrollOffset,
                isParentScrolling: $isVerticalScrolling,
                debugInfo: $debugInfo
            ) {
                HStack(spacing: 15) {
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
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.05))
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Vertical Only Scroll Section / 仅垂直滚动部分
    
    /**
     * 仅垂直滚动区域 - 阻止横向手势
     *
     * Vertical only scroll area - Blocks horizontal gestures
     */
    private func verticalOnlyScrollSection() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("智能竖向滚动区域 - 只能上下滚动")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            SmartVerticalOnlyScrollView(
                debugInfo: $debugInfo
            ) {
                gridContent()
            }
            .frame(height: 250)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple.opacity(0.05))
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Grid Content / 网格内容
    
    /**
     * 网格布局内容 - 用于垂直滚动区域
     *
     * Grid layout content - Used in vertical scroll area
     */
    private func gridContent() -> some View {
        VStack(spacing: 10) {
            ForEach(0..<5) { subIndex in
                HStack(spacing: 10) {
                    ForEach(0..<3) { colIndex in
                        gridItem(row: subIndex, col: colIndex)
                    }
                }
            }
        }
        .padding()
    }
    
    /**
     * 单个网格项 - 简化的视图构建
     *
     * Single grid item - Simplified view construction
     */
    private func gridItem(row: Int, col: Int) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.purple.opacity(0.3))
            .frame(height: 80)
            .overlay(
                VStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.white)
                    Text("项目 \(row)-\(col)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            )
    }
    
    // MARK: - Regular Content Section / 常规内容部分
    
    /**
     * 常规内容区域 - 简单的垂直布局
     *
     * Regular content area - Simple vertical layout
     */
    private func regularContentSection(index: Int) -> some View {
        VStack(spacing: 10) {
            Text("普通内容区域")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ForEach(0..<3) { subIndex in
                regularContentItem(section: index, item: subIndex)
            }
        }
    }
    
    /**
     * 常规内容项 - 单个内容卡片
     *
     * Regular content item - Single content card
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
 * 可复用的卡片组件 - 用于横向滚动
 *
 * Reusable card component - Used for horizontal scrolling
 *
 * 简化的卡片设计，避免复杂的渐变和动画，提高编译速度。
 *
 * Simplified card design, avoiding complex gradients and animations to improve compilation speed.
 */
struct CardView: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 150, height: 180)
            .overlay(
                VStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            )
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview / 预览

#Preview {
    NavigationView {
        SmartScrollDemoView()
    }
}