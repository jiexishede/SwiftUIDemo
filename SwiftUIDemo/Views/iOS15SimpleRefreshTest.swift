/**
 * iOS15SimpleRefreshTest.swift
 * iOS 15 下拉刷新测试视图
 * iOS 15 Pull-to-Refresh Test View
 * 
 * 设计思路 / Design Approach:
 * 创建一个最简单的测试视图，验证 iOS 15 的 .refreshable 基本功能
 * Create a minimal test view to verify iOS 15 .refreshable basic functionality
 * 
 * iOS 15 refreshable 关键要求 / iOS 15 refreshable key requirements:
 * 1. 必须使用 List 或 ScrollView
 * 2. List 必须有实际内容（不能为空）
 * 3. async/await 必须正确实现
 * 4. 必须有实际的异步等待时间
 */

import SwiftUI

struct iOS15SimpleRefreshTest: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]
    @State private var isRefreshing = false
    @State private var refreshCount = 0
    
    var body: some View {
        NavigationView {
            // iOS 15 必须使用 List / Must use List for iOS 15
            List {
                // 状态信息 / Status info
                Section {
                    HStack {
                        Text("刷新次数 / Refresh Count:")
                        Spacer()
                        Text("\(refreshCount)")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("刷新状态 / Refresh Status:")
                        Spacer()
                        if isRefreshing {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("刷新中... / Refreshing...")
                                    .foregroundColor(.green)
                            }
                        } else {
                            Text("空闲 / Idle")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 数据列表 / Data list
                Section("数据 / Data") {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(item)
                            Spacer()
                            Text("时间: \(Date().timeIntervalSince1970, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 说明 / Instructions
                Section("说明 / Instructions") {
                    Text("下拉列表以触发刷新 / Pull down the list to refresh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("iOS 版本: \(UIDevice.current.systemVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(InsetGroupedListStyle()) // iOS 15 兼容的样式
            .navigationTitle("iOS 15 刷新测试")
            .refreshable {
                // iOS 15 关键：必须使用 async/await
                await performRefresh()
            }
        }
    }
    
    /**
     * iOS 15 兼容的刷新函数
     * iOS 15 compatible refresh function
     * 
     * 关键点 / Key points:
     * 1. 必须是 async 函数
     * 2. 必须有实际的异步等待
     * 3. 等待时间不能太短（建议至少 1 秒）
     */
    private func performRefresh() async {
        print("🔄 开始刷新 / Starting refresh")
        
        // 标记开始刷新 / Mark refresh started
        isRefreshing = true
        
        // 模拟网络请求 - 重要：必须有实际等待时间
        // Simulate network request - Important: must have actual wait time
        do {
            // iOS 15 使用 Task.sleep(nanoseconds:)
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 秒
        } catch {
            print("❌ 等待被中断 / Wait interrupted: \(error)")
        }
        
        // 更新数据 / Update data
        refreshCount += 1
        
        // 添加新数据 / Add new data
        let newItem = "Item \(items.count + 1) (刷新 #\(refreshCount))"
        items.insert(newItem, at: 0)
        
        // 限制列表长度 / Limit list length
        if items.count > 10 {
            items.removeLast()
        }
        
        // 标记刷新结束 / Mark refresh ended
        isRefreshing = false
        
        print("✅ 刷新完成 / Refresh completed")
    }
}

// MARK: - iOS 15 Refreshable Extension
extension View {
    /**
     * iOS 15 安全的 refreshable 修饰符
     * iOS 15 safe refreshable modifier
     * 
     * 确保只在支持的版本上应用
     * Ensure only applied on supported versions
     */
    @ViewBuilder
    func iOS15SafeRefreshable(action: @escaping () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.refreshable {
                await action()
            }
        } else {
            self
        }
    }
}

// MARK: - Preview
struct iOS15SimpleRefreshTest_Previews: PreviewProvider {
    static var previews: some View {
        iOS15SimpleRefreshTest()
    }
}