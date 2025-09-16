//
//  NetworkAwareDemoView.swift
//  SwiftUIDemo
//
//  Demo view showing network-aware modifiers in action
//  展示网络感知修饰符实际应用的演示视图
//

import SwiftUI
import ComposableArchitecture

/**
 * NETWORK AWARE DEMO VIEW - 网络感知演示视图
 *
 * 这个视图展示了如何使用网络感知修饰符系统。
 * 它演示了所有主要功能：网络状态监控、自动重试、离线指示器等。
 *
 * This view demonstrates how to use the network-aware modifier system.
 * It showcases all major features: network status monitoring, auto-retry, offline indicators, etc.
 *
 * KEY FEATURES DEMONSTRATED / 演示的关键功能:
 * 1. Network state monitoring / 网络状态监控
 * 2. Auto-retry on reconnect / 重连时自动重试
 * 3. Offline mode handling / 离线模式处理
 * 4. Network speed indicators / 网络速度指示器
 * 5. Page state integration / 页面状态集成
 *
 * USAGE PATTERNS / 使用模式:
 * - Simple network awareness / 简单的网络感知
 * - Complex state management / 复杂的状态管理
 * - Chain modifier composition / 链式修饰符组合
 */
struct NetworkAwareDemoView: View {
    @StateObject private var viewModel = NetworkAwareDemoViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Simple Network Awareness / 简单网络感知
            simpleNetworkAwareView
                .tabItem {
                    Label("简单示例 / Simple", systemImage: "wifi")
                }
                .tag(0)

            // Tab 2: Page State Integration / 页面状态集成
            pageStateIntegrationView
                .tabItem {
                    Label("页面状态 / Page State", systemImage: "doc.text")
                }
                .tag(1)

            // Tab 3: Advanced Features / 高级功能
            advancedFeaturesView
                .tabItem {
                    Label("高级功能 / Advanced", systemImage: "gearshape.2")
                }
                .tag(2)
        }
        .navigationTitle("网络感知演示 / Network Aware Demo")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Simple Network Awareness / 简单网络感知

    private var simpleNetworkAwareView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Example 1: Basic network monitoring / 基础网络监控
                exampleCard(
                    title: "基础网络监控 / Basic Monitoring",
                    description: "自动检测网络连接状态\nAutomatically detects network connection status"
                ) {
                    Text("当前内容 / Current Content")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        // Apply network awareness / 应用网络感知
                        .networkAware()
                        .onNetworkConnected {
                            viewModel.log("网络已连接 / Network Connected")
                        }
                        .onNetworkDisconnected {
                            viewModel.log("网络已断开 / Network Disconnected")
                        }
                }

                // Example 2: Offline indicator / 离线指示器
                exampleCard(
                    title: "离线指示器 / Offline Indicator",
                    description: "断网时显示优雅的提示\nShows elegant hint when offline"
                ) {
                    Text("带离线提示的内容 / Content with Offline Hint")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        // Show offline indicator / 显示离线指示器
                        .showOfflineIndicator(position: .top)
                }

                // Example 3: Network type indicator / 网络类型指示器
                exampleCard(
                    title: "网络类型指示器 / Network Type Indicator",
                    description: "显示当前网络类型和质量\nShows current network type and quality"
                ) {
                    Text("带网络信息的内容 / Content with Network Info")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(10)
                        // Show network speed indicator / 显示网络速度指示器
                        .showNetworkSpeedIndicator(always: true)
                }

                // Logs display / 日志显示
                if !viewModel.logs.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("事件日志 / Event Logs")
                            .font(.headline)

                        ForEach(viewModel.logs, id: \.self) { log in
                            Text(log)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    // MARK: - Page State Integration / 页面状态集成

    private var pageStateIntegrationView: some View {
        VStack {
            // Control buttons / 控制按钮
            HStack {
                Button("加载 / Load") {
                    viewModel.loadData()
                }
                .buttonStyle(.bordered)

                Button("失败 / Fail") {
                    viewModel.simulateError()
                }
                .buttonStyle(.bordered)

                Button("清空 / Clear") {
                    viewModel.clearData()
                }
                .buttonStyle(.bordered)
            }
            .padding()

            // Content with network page state / 带网络页面状态的内容
            contentListView
                // Apply network page state modifier / 应用网络页面状态修饰符
                .networkPageState(
                    state: viewModel.pageState,
                    onRetry: {
                        viewModel.retry()
                    }
                )
                .onNetworkRetry {
                    viewModel.retry()
                }
                .autoRetryOnReconnect {
                    viewModel.retry()
                }
        }
    }

    private var contentListView: some View {
        List(viewModel.items, id: \.self) { item in
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                Text(item)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }

    private var customLoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("正在加载数据...\nLoading data...")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func customErrorView(error: ReduxPageState<[String]>.ErrorInfo) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.octagon")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text("自定义错误视图 / Custom Error View")
                .font(.headline)

            Text(error.message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("重试 / Retry") {
                viewModel.retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Advanced Features / 高级功能

    private var advancedFeaturesView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Complete network awareness / 完整网络感知
                exampleCard(
                    title: "完整配置 / Complete Configuration",
                    description: "所有功能的组合使用\nCombination of all features"
                ) {
                    advancedContentView
                        // Apply complete network awareness / 应用完整网络感知
                        .withNetworkAwareness(
                            pageState: viewModel.pageState,
                            onRetry: { viewModel.retry() },
                            autoRetry: true,
                            showIndicators: true
                        )
                }

                // Chain modifiers example / 链式修饰符示例
                exampleCard(
                    title: "链式调用 / Chain Calls",
                    description: "多个修饰符的优雅组合\nElegant combination of multiple modifiers"
                ) {
                    Text("链式修饰符示例 / Chain Modifiers Example")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        // Chain multiple modifiers / 链式调用多个修饰符
                        .networkAware()
                        .showOfflineIndicator()
                        .showNetworkSpeedIndicator()
                        .onNetworkConnected {
                            print("Connected! 已连接!")
                        }
                        .onNetworkDisconnected {
                            print("Disconnected! 已断开!")
                        }
                        .onNetworkTypeChanged { type in
                            print("Network type: \(type)")
                        }
                        .autoRetryOnReconnect {
                            print("Auto retrying... 自动重试中...")
                        }
                }
            }
            .padding()
        }
    }

    private var advancedContentView: some View {
        VStack(spacing: 15) {
            ForEach(0..<3) { index in
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("高级功能项目 \(index + 1) / Advanced Item \(index + 1)")
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }

    // MARK: - Helper Views / 辅助视图

    private func exampleCard<Content: View>(
        title: String,
        description: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)

            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - View Model / 视图模型

/**
 * View model for the demo
 * 演示的视图模型
 */
class NetworkAwareDemoViewModel: ObservableObject {
    @Published var pageState: ReduxPageState<[String]> = .idle
    @Published var items: [String] = []
    @Published var logs: [String] = []

    func loadData() {
        pageState = .loading(.initial)

        // Simulate network request / 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            let mockData = [
                "数据项 1 / Data Item 1",
                "数据项 2 / Data Item 2",
                "数据项 3 / Data Item 3",
                "数据项 4 / Data Item 4",
                "数据项 5 / Data Item 5"
            ]
            self?.items = mockData
            self?.pageState = .loaded(mockData, .idle)
        }
    }

    func simulateError() {
        pageState = .failed(
            .initial,
            ReduxPageState<[String]>.ErrorInfo(
                type: .serverError,
                description: "模拟的网络错误\nSimulated network error",
                code: 500
            )
        )
    }

    func clearData() {
        items = []
        pageState = .idle
    }

    func retry() {
        log("重试操作 / Retry operation")
        loadData()
    }

    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .none,
            timeStyle: .medium
        )
        logs.append("[\(timestamp)] \(message)")

        // Keep only last 5 logs / 只保留最近5条日志
        if logs.count > 5 {
            logs.removeFirst()
        }
    }
}

// MARK: - Preview / 预览

struct NetworkAwareDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NetworkAwareDemoView()
        }
    }
}