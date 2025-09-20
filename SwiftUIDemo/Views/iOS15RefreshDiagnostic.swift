/**
 * iOS15RefreshDiagnostic.swift
 * iOS 15 下拉刷新诊断测试视图
 * iOS 15 Pull-to-Refresh Diagnostic Test View
 * 
 * 设计目的 / Design Purpose:
 * 专门用于诊断 iOS 15 下拉刷新问题的最小化测试视图
 * Minimal test view specifically for diagnosing iOS 15 pull-to-refresh issues
 * 
 * 关键测试要点 / Key Test Points:
 * 1. List 必须有足够的内容来支持滚动
 * 2. 内容不能是透明或空的
 * 3. List 样式必须正确
 * 4. 不能有复杂的容器嵌套
 * 
 * iOS 15 refreshable 的严格要求 / iOS 15 refreshable strict requirements:
 * - List 内容高度 > 屏幕高度才能触发刷新 / List content height > screen height to trigger refresh
 * - 必须使用正确的 List 样式 / Must use correct List style  
 * - 异步函数必须有实际等待时间 / Async function must have actual wait time
 * - 不能在 ScrollView 或其他滚动容器中嵌套 / Cannot nest in ScrollView or other scroll containers
 */

import SwiftUI

struct iOS15RefreshDiagnostic: View {
    @State private var items: [DiagnosticItem] = []
    @State private var refreshCount = 0
    @State private var lastRefreshTime = Date()
    @State private var isManualRefreshing = false
    
    var body: some View {
        NavigationView {
            // 关键：使用最简单的 List，确保有足够内容
            // Key: Use simplest List with enough content
            List {
                // 状态信息部分 / Status info section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🔄 刷新次数:")
                            Spacer()
                            Text("\(refreshCount)")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("⏰ 最后刷新:")
                            Spacer()
                            Text(timeFormatter.string(from: lastRefreshTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("📱 iOS 版本:")
                            Spacer()
                            Text(UIDevice.current.systemVersion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if isManualRefreshing {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在刷新...")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("刷新状态 / Refresh Status")
                }
                
                // 测试数据部分 / Test data section  
                Section {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: item.icon)
                                    .foregroundColor(item.color)
                                    .frame(width: 20)
                                
                                Text(item.title)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("#\(item.id)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    // 确保有足够内容支持滚动 / Ensure enough content to support scrolling
                    if items.count < 20 {
                        ForEach(0..<(20-items.count), id: \.self) { index in
                            HStack {
                                Image(systemName: "star.circle")
                                    .foregroundColor(.gray)
                                Text("占位项目 \(index + 1) / Placeholder item \(index + 1)")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } header: {
                    Text("测试数据 (\(items.count) 项) / Test Data (\(items.count) items)")
                } footer: {
                    Text("下拉此列表以测试刷新功能 / Pull down this list to test refresh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 说明部分 / Instructions section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        instructionRow(
                            icon: "hand.draw.fill",
                            title: "如何测试 / How to test",
                            subtitle: "在列表顶部向下拖拽，应该看到刷新指示器"
                        )
                        
                        instructionRow(
                            icon: "checkmark.circle.fill",
                            title: "正常现象 / Expected behavior", 
                            subtitle: "下拉时出现圆形加载指示器，松手后自动刷新"
                        )
                        
                        instructionRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "异常现象 / Abnormal behavior",
                            subtitle: "下拉时没有任何反应，或者无法触发刷新"
                        )
                        
                        instructionRow(
                            icon: "gear.circle.fill", 
                            title: "技术要求 / Technical requirements",
                            subtitle: "iOS 15.0+, List 必须有内容，必须支持滚动"
                        )
                    }
                } header: {
                    Text("使用说明 / Instructions")
                }
            }
            .listStyle(PlainListStyle()) // 关键：使用 PlainListStyle
            .navigationTitle("iOS 15 刷新诊断")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("手动刷新") {
                        Task {
                            await manualRefresh()
                        }
                    }
                }
            }
            .refreshable {
                // iOS 15 关键实现 / iOS 15 key implementation
                await performRefresh()
            }
        }
        .onAppear {
            initializeData()
        }
    }
    
    // MARK: - Helper Views
    
    private func instructionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Data Management
    
    private func initializeData() {
        items = DiagnosticItem.sampleData()
    }
    
    // MARK: - Refresh Functions
    
    /**
     * iOS 15 兼容的刷新实现
     * iOS 15 compatible refresh implementation
     * 
     * 关键要求 / Key requirements:
     * 1. 必须是 async 函数 / Must be async function
     * 2. 必须有实际等待时间（至少 1 秒）/ Must have actual wait time (at least 1 second)
     * 3. 等待时间不能太短，否则刷新指示器闪现 / Wait time cannot be too short
     * 4. 必须更新实际数据 / Must update actual data
     */
    private func performRefresh() async {
        print("🔄 [iOS15RefreshDiagnostic] 开始刷新 / Starting refresh")
        
        // 标记刷新开始 / Mark refresh started
        isManualRefreshing = true
        
        // 关键：等待足够长的时间 / Key: Wait long enough
        do {
            // iOS 15 必须使用 Task.sleep(nanoseconds:)
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2秒
        } catch {
            print("❌ [iOS15RefreshDiagnostic] 等待被中断: \(error)")
        }
        
        // 更新数据 / Update data
        await MainActor.run {
            refreshCount += 1
            lastRefreshTime = Date()
            
            // 添加新数据项 / Add new data item
            let newItem = DiagnosticItem(
                id: items.count + 1,
                title: "刷新项目 #\(refreshCount) / Refresh item #\(refreshCount)",
                subtitle: "在 \(timeFormatter.string(from: Date())) 通过下拉刷新添加",
                icon: "arrow.clockwise.circle.fill",
                color: .green
            )
            
            items.insert(newItem, at: 0)
            
            // 限制数据量 / Limit data count
            if items.count > 50 {
                items = Array(items.prefix(50))
            }
            
            isManualRefreshing = false
        }
        
        print("✅ [iOS15RefreshDiagnostic] 刷新完成 / Refresh completed")
    }
    
    private func manualRefresh() async {
        await performRefresh()
    }
    
    // MARK: - Formatters
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
}

// MARK: - Diagnostic Item Model

struct DiagnosticItem: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    static func sampleData() -> [DiagnosticItem] {
        return [
            DiagnosticItem(
                id: 1,
                title: "初始数据项 1 / Initial data item 1", 
                subtitle: "这是用于测试 iOS 15 下拉刷新的初始数据",
                icon: "1.circle.fill",
                color: .blue
            ),
            DiagnosticItem(
                id: 2,
                title: "初始数据项 2 / Initial data item 2",
                subtitle: "确保 List 有足够内容来支持滚动和刷新",
                icon: "2.circle.fill", 
                color: .purple
            ),
            DiagnosticItem(
                id: 3,
                title: "初始数据项 3 / Initial data item 3",
                subtitle: "iOS 15 需要实际的、可见的 List 内容", 
                icon: "3.circle.fill",
                color: .orange
            ),
            DiagnosticItem(
                id: 4,
                title: "初始数据项 4 / Initial data item 4",
                subtitle: "测试 PlainListStyle 是否支持刷新控件",
                icon: "4.circle.fill",
                color: .red
            ),
            DiagnosticItem(
                id: 5,
                title: "初始数据项 5 / Initial data item 5",
                subtitle: "验证异步刷新函数的正确实现",
                icon: "5.circle.fill",
                color: .green
            )
        ]
    }
}

// MARK: - Preview

struct iOS15RefreshDiagnostic_Previews: PreviewProvider {
    static var previews: some View {
        iOS15RefreshDiagnostic()
            .previewDevice("iPhone 13")
    }
}