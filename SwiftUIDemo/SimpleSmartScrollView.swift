import SwiftUI

/**
 * SIMPLE SMART SCROLL VIEW - 简单智能滚动视图
 * 
 * PURPOSE / 目的:
 * - Handle nested scroll views in iOS 15+ using native SwiftUI
 * - 使用原生 SwiftUI 在 iOS 15+ 中处理嵌套滚动视图
 * 
 * DESIGN APPROACH / 设计方法:
 * - Use LazyVStack with pinned headers for sections
 * - 使用带固定头部的 LazyVStack 作为区块
 * - Horizontal ScrollViews naturally work within vertical ScrollView
 * - 横向 ScrollView 在垂直 ScrollView 中自然工作
 * - No complex gesture handling needed
 * - 无需复杂的手势处理
 * 
 * COMPATIBLE WITH / 兼容性:
 * - iOS 15.0+
 */

// MARK: - Main Demo View / 主演示视图
struct SimpleSmartScrollDemoView: View {
    @State private var refreshID = UUID()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                // Section with horizontal scroll / 带横向滚动的部分
                Section {
                    SimpleHorizontalScrollSection()
                } header: {
                    SectionHeaderView(title: "Section 1 - 横向滚动区域")
                }
                
                // Section with vertical grid / 带垂直网格的部分
                Section {
                    VerticalGridSection()
                } header: {
                    SectionHeaderView(title: "Section 2 - 网格布局")
                }
                
                // Section with horizontal scroll / 带横向滚动的部分
                Section {
                    SimpleHorizontalScrollSection(color: .purple)
                } header: {
                    SectionHeaderView(title: "Section 3 - 另一个横向滚动")
                }
                
                // Regular content section / 常规内容部分
                Section {
                    RegularContentSection()
                } header: {
                    SectionHeaderView(title: "Section 4 - 常规内容")
                }
                
                // More sections / 更多部分
                ForEach(5..<10) { index in
                    Section {
                        if index % 2 == 0 {
                            SimpleHorizontalScrollSection(color: [.blue, .purple, .orange, .green, .pink][index % 5])
                        } else {
                            RegularContentSection()
                        }
                    } header: {
                        SectionHeaderView(title: "Section \(index)")
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            // Pull to refresh support in iOS 15+ / iOS 15+ 下拉刷新支持
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            refreshID = UUID()
        }
        .navigationTitle("智能滚动 (iOS 15+)")
        .navigationBarTitleDisplayMode(.inline)
        .id(refreshID)
    }
}

// MARK: - Section Header / 部分头部
struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            Color(UIColor.systemBackground)
                .opacity(0.95)
        )
    }
}

// MARK: - Horizontal Scroll Section / 横向滚动部分
struct SimpleHorizontalScrollSection: View {
    var color: Color = .blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("左右滑动查看更多内容 →")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 15) {
                    ForEach(0..<15) { index in
                        CardItemView(
                            index: index,
                            color: color
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            .frame(height: 200)
        }
    }
}

// MARK: - Card Item View / 卡片项视图
struct CardItemView: View {
    let index: Int
    let color: Color
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
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
                        
                        Text("卡片 \(index + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("横向滚动")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                )
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: index)
    }
}

// MARK: - Vertical Grid Section / 垂直网格部分
struct VerticalGridSection: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("网格布局内容")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(0..<9) { index in
                    GridItemView(index: index)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Grid Item View / 网格项视图
struct GridItemView: View {
    let index: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.purple.opacity(0.2))
            .frame(height: 100)
            .overlay(
                VStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("Item \(index + 1)")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            )
    }
}

// MARK: - Regular Content Section / 常规内容部分
struct RegularContentSection: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { index in
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.gray)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("标题 \(index + 1)")
                            .font(.headline)
                        Text("这是一段描述文字，展示常规的垂直滚动内容。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Alternative Solution for iOS 15 / iOS 15 的替代方案
/**
 * ALTERNATIVE APPROACH FOR iOS 15 - iOS 15 替代方案
 * 
 * If you need more control over scroll behavior:
 * 如果需要更多滚动行为控制：
 * 
 * 1. Use ScrollViewReader for programmatic scrolling
 *    使用 ScrollViewReader 进行程序化滚动
 * 2. Use PreferenceKey to track scroll positions
 *    使用 PreferenceKey 跟踪滚动位置
 * 3. Use GeometryReader sparingly for performance
 *    谨慎使用 GeometryReader 以保证性能
 */

struct AlternativeSmartScrollView: View {
    @State private var verticalOffset: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            // Section header / 部分头部
                            Text("Section \(section + 1)")
                                .font(.headline)
                                .padding(.horizontal)
                                .id(section)
                            
                            if section % 2 == 0 {
                                // Horizontal scroll with explicit frame
                                // 带明确框架的横向滚动
                                ScrollView(.horizontal) {
                                    HStack(spacing: 15) {
                                        ForEach(0..<10) { item in
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.blue.gradient)
                                                .frame(width: 120, height: 150)
                                                .overlay(
                                                    Text("Item \(item)")
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(height: 160)
                            } else {
                                // Regular vertical content
                                // 常规垂直内容
                                VStack(spacing: 10) {
                                    ForEach(0..<3) { item in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 60)
                                            .overlay(
                                                Text("Content \(item)")
                                            )
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: SimpleScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(SimpleScrollOffsetPreferenceKey.self) { value in
                verticalOffset = value
            }
            .overlay(
                // Debug info / 调试信息
                Text("Offset: \(Int(verticalOffset))")
                    .font(.caption)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(),
                alignment: .topTrailing
            )
        }
    }
}

// MARK: - Preference Key / 偏好键
struct SimpleScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview / 预览
#Preview("Simple Smart Scroll") {
    NavigationView {
        SimpleSmartScrollDemoView()
    }
}

#Preview("Alternative Approach") {
    NavigationView {
        AlternativeSmartScrollView()
            .navigationTitle("Alternative")
            .navigationBarTitleDisplayMode(.inline)
    }
}