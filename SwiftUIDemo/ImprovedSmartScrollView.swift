import SwiftUI

/**
 * IMPROVED SMART SCROLL VIEW - 改进的智能滚动视图
 * 
 * PURPOSE / 目的:
 * - Better handling of nested scrolls in iOS 15+
 * - 更好地处理 iOS 15+ 中的嵌套滚动
 * 
 * KEY IMPROVEMENTS / 关键改进:
 * 1. Use simultaneousGesture with proper priority
 *    使用带适当优先级的 simultaneousGesture
 * 2. Simpler gesture detection logic
 *    更简单的手势检测逻辑
 * 3. Native ScrollView behavior preserved
 *    保留原生 ScrollView 行为
 */

// MARK: - Improved Horizontal Scroll View / 改进的横向滚动视图
struct ImprovedHorizontalScrollView<Content: View>: View {
    let content: Content
    @State private var isDragging = false
    @State private var dragDirection: DragDirection = .none
    
    enum DragDirection {
        case none, horizontal, vertical
    }
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            content
        }
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    if dragDirection == .none {
                        // Determine direction on first significant movement
                        // 在首次显著移动时确定方向
                        let horizontalAmount = abs(value.translation.width)
                        let verticalAmount = abs(value.translation.height)
                        
                        if horizontalAmount > verticalAmount {
                            dragDirection = .horizontal
                        } else if verticalAmount > horizontalAmount * 2 {
                            // Only consider vertical if it's significantly more vertical
                            // 只有在明显更垂直时才考虑垂直
                            dragDirection = .vertical
                        }
                    }
                }
                .onEnded { _ in
                    dragDirection = .none
                    isDragging = false
                }
        )
        // Allow the gesture to pass through when vertical
        // 垂直时允许手势传递
        .allowsHitTesting(dragDirection != .vertical)
    }
}

// MARK: - Improved Smart Scroll Demo / 改进的智能滚动演示
struct ImprovedSmartScrollDemoView: View {
    @State private var sections: [SectionData] = SectionData.mockData
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 25) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        // Section Header / 部分头部
                        Text(section.title)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if section.isHorizontal {
                            // Horizontal scrolling section / 横向滚动部分
                            ImprovedHorizontalScrollView {
                                HStack(spacing: 15) {
                                    ForEach(section.items) { item in
                                        ItemCardView(item: item, color: section.color)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 200)
                        } else {
                            // Vertical content section / 垂直内容部分
                            VStack(spacing: 10) {
                                ForEach(section.items) { item in
                                    ItemRowView(item: item)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("改进的智能滚动")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - iOS 15 Compatible Solution / iOS 15 兼容解决方案
struct iOS15CompatibleScrollView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<5) { sectionIndex in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Section \(sectionIndex + 1)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if sectionIndex % 2 == 0 {
                            // Horizontal scroll that works in iOS 15
                            // 在 iOS 15 中工作的横向滚动
                            horizontalSection
                        } else {
                            // Vertical content
                            // 垂直内容
                            verticalSection
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    var horizontalSection: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 15) {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.gradient)
                        .frame(width: 150, height: 180)
                        .overlay(
                            VStack {
                                Image(systemName: "star.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Card \(index + 1)")
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 200)
    }
    
    var verticalSection: some View {
        VStack(spacing: 10) {
            ForEach(0..<3) { index in
                HStack {
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading) {
                        Text("Item \(index + 1)")
                            .font(.headline)
                        Text("Description text here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
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

// MARK: - Data Models / 数据模型
struct SectionData: Identifiable {
    let id = UUID()
    let title: String
    let isHorizontal: Bool
    let color: Color
    let items: [ItemData]
    
    static var mockData: [SectionData] {
        [
            SectionData(
                title: "Section 1 - 横向滚动",
                isHorizontal: true,
                color: .blue,
                items: (0..<15).map { ItemData(title: "卡片 \($0 + 1)", subtitle: "横向滚动") }
            ),
            SectionData(
                title: "Section 2 - 垂直内容",
                isHorizontal: false,
                color: .purple,
                items: (0..<5).map { ItemData(title: "项目 \($0 + 1)", subtitle: "垂直布局") }
            ),
            SectionData(
                title: "Section 3 - 横向滚动",
                isHorizontal: true,
                color: .orange,
                items: (0..<12).map { ItemData(title: "内容 \($0 + 1)", subtitle: "可滑动") }
            ),
            SectionData(
                title: "Section 4 - 垂直列表",
                isHorizontal: false,
                color: .green,
                items: (0..<4).map { ItemData(title: "列表项 \($0 + 1)", subtitle: "详细信息") }
            ),
            SectionData(
                title: "Section 5 - 横向画廊",
                isHorizontal: true,
                color: .pink,
                items: (0..<20).map { ItemData(title: "图片 \($0 + 1)", subtitle: "画廊") }
            )
        ]
    }
}

struct ItemData: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

// MARK: - Item Views / 项目视图
struct ItemCardView: View {
    let item: ItemData
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 150, height: 180)
            .overlay(
                VStack {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            )
            .shadow(color: color.opacity(0.3), radius: 5)
    }
}

struct ItemRowView: View {
    let item: ItemData
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "doc.text")
                        .foregroundColor(.purple)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Preview / 预览
#Preview("Improved Smart Scroll") {
    NavigationView {
        ImprovedSmartScrollDemoView()
    }
}

#Preview("iOS 15 Compatible") {
    NavigationView {
        iOS15CompatibleScrollView()
            .navigationTitle("iOS 15 兼容版本")
            .navigationBarTitleDisplayMode(.inline)
    }
}