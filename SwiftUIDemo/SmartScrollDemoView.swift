import SwiftUI

struct SmartScrollDemoView: View {
    @State private var debugInfo: String = "滑动方向: 无"
    @State private var verticalScrollOffset: CGFloat = 0
    @State private var isVerticalScrolling: Bool = false
    @State private var showDebugInfo: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
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
            
            SmartVerticalScrollView(
                verticalScrollOffset: $verticalScrollOffset,
                isVerticalScrolling: $isVerticalScrolling,
                debugInfo: $debugInfo
            ) {
                VStack(spacing: 20) {
                    ForEach(0..<10) { index in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Section \(index + 1)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if index % 3 == 0 {
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
                            } else if index % 3 == 1 {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("智能竖向滚动区域 - 只能上下滚动")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    SmartVerticalOnlyScrollView(
                                        debugInfo: $debugInfo
                                    ) {
                                        VStack(spacing: 10) {
                                            ForEach(0..<5) { subIndex in
                                                HStack(spacing: 10) {
                                                    ForEach(0..<3) { colIndex in
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.purple.opacity(0.3))
                                                            .frame(height: 80)
                                                            .overlay(
                                                                VStack {
                                                                    Image(systemName: "arrow.up.arrow.down")
                                                                        .foregroundColor(.white)
                                                                    Text("项目 \(subIndex)-\(colIndex)")
                                                                        .font(.caption)
                                                                        .foregroundColor(.white)
                                                                }
                                                            )
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                    }
                                    .frame(height: 250)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.purple.opacity(0.05))
                                    )
                                    .padding(.horizontal)
                                }
                            } else {
                                VStack(spacing: 10) {
                                    Text("普通内容区域")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(0..<3) { subIndex in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 60)
                                            .overlay(
                                                Text("竖向内容 \(index)-\(subIndex + 1)")
                                            )
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("智能滚动演示")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CardView: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(color.gradient)
            .frame(width: 150, height: 180)
            .overlay(
                VStack {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text(title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            )
            .shadow(radius: 5)
    }
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0.3...0.9),
            green: Double.random(in: 0.3...0.9),
            blue: Double.random(in: 0.3...0.9)
        )
    }
}

#Preview {
    NavigationView {
        SmartScrollDemoView()
    }
}