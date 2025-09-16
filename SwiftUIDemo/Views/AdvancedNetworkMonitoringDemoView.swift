//
//  AdvancedNetworkMonitoringDemoView.swift
//  SwiftUIDemo
//
//  Advanced network monitoring demonstration with custom error simulation
//  高级网络监控演示，包含自定义错误模拟
//

import SwiftUI
import ComposableArchitecture

/**
 * ADVANCED NETWORK MONITORING DEMO VIEW - 高级网络监控演示视图
 *
 * 这是一个完整的网络监控修饰符演示页面，展示了所有最新功能：
 * - 自定义离线消息配置
 * - 模拟各种网络问题
 * - 智能错误分类和处理
 * - 实时网络状态监控
 *
 * This is a comprehensive network monitoring modifier demo page showcasing all latest features:
 * - Custom offline message configuration
 * - Simulation of various network problems
 * - Intelligent error classification and handling
 * - Real-time network status monitoring
 *
 * DESIGN PATTERNS USED / 使用的设计模式:
 *
 * 1. Strategy Pattern (策略模式)
 *    - Why: 不同的网络错误类型需要不同的处理策略
 *    - Benefits: 易于扩展新的错误类型和处理方式
 *    - Implementation: NetworkErrorType 枚举定义不同策略
 *
 * 2. State Pattern (状态模式)
 *    - Why: 页面状态根据网络状态和错误类型变化
 *    - Benefits: 清晰的状态转换逻辑
 *    - Implementation: DemoState 管理不同状态
 *
 * 3. Observer Pattern (观察者模式)
 *    - Why: 实时响应网络状态变化
 *    - Benefits: 自动更新UI，解耦网络监控和视图
 *    - Implementation: 通过网络监控修饰符实现
 *
 * SOLID PRINCIPLES / SOLID 原则:
 *
 * - SRP: 每个组件只负责特定的网络监控功能
 * - OCP: 通过扩展添加新的错误类型，不修改现有代码
 * - LSP: 所有网络状态都可以被相同的修饰符处理
 * - ISP: 提供细粒度的网络监控接口
 * - DIP: 依赖抽象的网络监控协议
 *
 * USAGE EXAMPLES / 使用示例:
 * ```
 * // 导航到高级网络监控演示
 * NavigationLink("高级网络监控 / Advanced Network Monitoring") {
 *     AdvancedNetworkMonitoringDemoView()
 * }
 *
 * // 使用万能网络状态修饰符
 * MyContentView()
 *     .universalNetworkState(
 *         state: viewModel.pageState,
 *         onRetry: { viewModel.reload() }
 *     )
 * ```
 */
struct AdvancedNetworkMonitoringDemoView: View {
    @StateObject private var viewModel = AdvancedNetworkDemoViewModel()
    @State private var selectedErrorType: NetworkErrorType = .offline
    @State private var customMessage = ""
    @State private var showCustomMessageSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section / 头部区域
                    headerSection

                    // Network Status Monitor / 网络状态监控
                    networkStatusSection

                    // Error Simulation Controls / 错误模拟控制
                    errorSimulationSection

                    // Custom Message Configuration / 自定义消息配置
                    customMessageSection

                    // Demo Content Area / 演示内容区域
                    demoContentSection
                }
                .padding()
            }
        }
        .navigationTitle("高级网络监控 / Advanced Network Monitoring")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCustomMessageSheet) {
            customMessageConfigSheet
        }
    }

    // MARK: - Header Section / 头部区域

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolRenderingMode(.hierarchical)

            Text("高级网络监控演示")
                .font(.title2)
                .fontWeight(.bold)

            Text("Advanced Network Monitoring Demo")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("体验最新的网络感知修饰符，包含自定义错误处理和智能重试机制")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Experience the latest network-aware modifiers with custom error handling and intelligent retry mechanisms")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }

    // MARK: - Network Status Section / 网络状态区域

    private var networkStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("实时网络状态 / Real-time Network Status")

            NetworkStatusCard()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }

    // MARK: - Error Simulation Section / 错误模拟区域

    private var errorSimulationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("网络问题模拟 / Network Problem Simulation")

            // Error Type Picker / 错误类型选择器
            VStack(alignment: .leading, spacing: 8) {
                Text("选择错误类型 / Select Error Type:")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(NetworkErrorType.allCases, id: \.self) { errorType in
                            ErrorTypeChip(
                                errorType: errorType,
                                isSelected: selectedErrorType == errorType,
                                action: { selectedErrorType = errorType }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Simulation Controls / 模拟控制
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.simulateNetworkError(selectedErrorType)
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("模拟 \(selectedErrorType.displayName) / Simulate \(selectedErrorType.englishName)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedErrorType.color)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Button(action: {
                    viewModel.resetToNormal()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("恢复正常 / Reset to Normal")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    // MARK: - Custom Message Section / 自定义消息区域

    private var customMessageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("自定义提示消息 / Custom Alert Messages")

            Button(action: {
                showCustomMessageSheet = true
            }) {
                HStack {
                    Image(systemName: "text.bubble")
                    Text("配置自定义消息 / Configure Custom Messages")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            .foregroundColor(.primary)

            if !viewModel.customMessages.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前自定义消息 / Current Custom Messages:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(Array(viewModel.customMessages.keys), id: \.self) { errorType in
                        if let message = viewModel.customMessages[errorType] {
                            HStack {
                                Image(systemName: errorType.icon)
                                    .foregroundColor(errorType.color)
                                Text(message)
                                    .font(.caption)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Demo Content Section / 演示内容区域

    private var demoContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("演示内容区域 / Demo Content Area")

            Text("这个区域展示网络修饰符的实际效果")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("This area demonstrates the actual effects of network modifiers")
                .font(.caption)
                .foregroundColor(.secondary)

            // Demo content with network modifiers / 带网络修饰符的演示内容
            DemoContentView(viewModel: viewModel)
                .frame(minHeight: 200)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
                // 🚀 应用万能网络状态修饰符 / Apply universal network state modifier
                .universalNetworkState(
                    state: viewModel.pageState,
                    onRetry: {
                        viewModel.retry()
                    },
                    autoRetry: true,
                    showIndicators: true
                )
        }
    }

    // MARK: - Custom Message Configuration Sheet / 自定义消息配置弹窗

    private var customMessageConfigSheet: some View {
        NavigationView {
            CustomMessageConfigurationView(viewModel: viewModel)
                .navigationTitle("自定义消息 / Custom Messages")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("取消 / Cancel") {
                        showCustomMessageSheet = false
                    },
                    trailing: Button("完成 / Done") {
                        showCustomMessageSheet = false
                    }
                )
        }
    }

    // MARK: - Helper Views / 辅助视图

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.bottom, 4)
    }
}

// MARK: - Network Status Card / 网络状态卡片

/**
 * Real-time network status display card
 * 实时网络状态显示卡片
 */
struct NetworkStatusCard: View {
    @ObservedObject private var monitor = NetworkMonitor.shared

    var body: some View {
        VStack(spacing: 12) {
            // Connection Status / 连接状态
            HStack {
                Image(systemName: monitor.isConnected ? "wifi" : "wifi.slash")
                    .foregroundColor(monitor.isConnected ? .green : .red)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(monitor.isConnected ? "已连接 / Connected" : "未连接 / Disconnected")
                        .font(.headline)
                        .foregroundColor(monitor.isConnected ? .green : .red)

                    Text(monitor.statusDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Connection quality indicators / 连接质量指示器
                VStack(alignment: .trailing, spacing: 4) {
                    if monitor.isExpensive {
                        Label("昂贵 / Expensive", systemImage: "dollarsign.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }

                    if monitor.isConstrained {
                        Label("受限 / Constrained", systemImage: "tortoise.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }

            // Connection Type Details / 连接类型详情
            if monitor.isConnected {
                Divider()

                HStack {
                    Image(systemName: monitor.connectionType.icon)
                        .foregroundColor(.blue)

                    Text("类型 / Type: \(monitor.connectionType.description)")
                        .font(.caption)

                    Spacer()

                    if !monitor.pendingRequests.isEmpty {
                        Text("待处理: \(monitor.pendingRequests.count) / Pending: \(monitor.pendingRequests.count)")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

// MARK: - Error Type Chip / 错误类型芯片

/**
 * Selectable chip for different network error types
 * 不同网络错误类型的可选择芯片
 */
struct ErrorTypeChip: View {
    let errorType: NetworkErrorType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: errorType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : errorType.color)

                Text(errorType.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 80, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? errorType.color : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorType.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Demo Content View / 演示内容视图

/**
 * Content area that demonstrates network modifier effects
 * 演示网络修饰符效果的内容区域
 */
struct DemoContentView: View {
    @ObservedObject var viewModel: AdvancedNetworkDemoViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Content based on page state / 基于页面状态的内容
            switch viewModel.pageState {
            case .idle:
                idleContent
            case .loading:
                // Loading will be handled by network modifier / 加载状态由网络修饰符处理
                EmptyView()
            case .loaded(let data, _):
                loadedContent(data: data)
            case .failed:
                // Error will be handled by network modifier / 错误状态由网络修饰符处理
                EmptyView()
            }
        }
        .padding()
    }

    private var idleContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.down.circle")
                .font(.largeTitle)
                .foregroundColor(.blue)

            Text("点击上方按钮模拟网络问题")
                .font(.headline)

            Text("Click buttons above to simulate network problems")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                viewModel.loadDemoData()
            }) {
                Text("加载演示数据 / Load Demo Data")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func loadedContent(data: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("数据加载成功! / Data loaded successfully!")
                .font(.headline)
                .foregroundColor(.green)

            ForEach(data, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item)
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            Button(action: {
                viewModel.refreshData()
            }) {
                Text("刷新数据 / Refresh Data")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Custom Message Configuration View / 自定义消息配置视图

/**
 * Configuration view for custom error messages
 * 自定义错误消息的配置视图
 */
struct CustomMessageConfigurationView: View {
    @ObservedObject var viewModel: AdvancedNetworkDemoViewModel
    @State private var editingErrorType: NetworkErrorType?
    @State private var tempMessage = ""

    var body: some View {
        List {
            Section(
                header: Text("为不同错误类型配置自定义消息 / Configure custom messages for different error types")
                    .font(.caption)
            ) {
                ForEach(NetworkErrorType.allCases, id: \.self) { errorType in
                    MessageConfigRow(
                        errorType: errorType,
                        currentMessage: viewModel.customMessages[errorType],
                        onEdit: { message in
                            viewModel.setCustomMessage(for: errorType, message: message)
                        },
                        onClear: {
                            viewModel.clearCustomMessage(for: errorType)
                        }
                    )
                }
            }

            Section(
                header: Text("预览效果 / Preview Effects")
            ) {
                ForEach(NetworkErrorType.allCases, id: \.self) { errorType in
                    if let message = viewModel.customMessages[errorType] {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: errorType.icon)
                                    .foregroundColor(errorType.color)
                                Text(errorType.displayName)
                                    .font(.headline)
                            }

                            Text(message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Message Config Row / 消息配置行

/**
 * Individual row for configuring error messages
 * 配置错误消息的单独行
 */
struct MessageConfigRow: View {
    let errorType: NetworkErrorType
    let currentMessage: String?
    let onEdit: (String) -> Void
    let onClear: () -> Void

    @State private var isEditing = false
    @State private var editingMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: errorType.icon)
                    .foregroundColor(errorType.color)
                    .frame(width: 20)

                VStack(alignment: .leading) {
                    Text(errorType.displayName)
                        .font(.headline)
                    Text(errorType.englishName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if currentMessage != nil {
                    Button("清除 / Clear", action: onClear)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button(currentMessage == nil ? "添加 / Add" : "编辑 / Edit") {
                    editingMessage = currentMessage ?? ""
                    isEditing = true
                }
                .font(.caption)
            }

            if let message = currentMessage {
                Text(message)
                    .font(.caption)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .sheet(isPresented: $isEditing) {
            MessageEditingSheet(
                errorType: errorType,
                initialMessage: editingMessage,
                onSave: { message in
                    onEdit(message)
                    isEditing = false
                },
                onCancel: {
                    isEditing = false
                }
            )
        }
    }
}

// MARK: - Message Editing Sheet / 消息编辑弹窗

/**
 * Sheet for editing custom error messages
 * 编辑自定义错误消息的弹窗
 */
struct MessageEditingSheet: View {
    let errorType: NetworkErrorType
    @State var initialMessage: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @State private var message: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: errorType.icon)
                            .foregroundColor(errorType.color)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("编辑 \(errorType.displayName) 消息")
                                .font(.headline)
                            Text("Edit \(errorType.englishName) message")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("自定义消息 / Custom Message:")
                        .font(.headline)

                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    Text("这个消息将在 \(errorType.displayName) 时显示")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("This message will be shown when \(errorType.englishName) occurs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("编辑消息 / Edit Message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消 / Cancel", action: onCancel),
                trailing: Button("保存 / Save") {
                    onSave(message)
                }
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
        .onAppear {
            message = initialMessage
        }
    }
}

// MARK: - Network Error Types / 网络错误类型

/**
 * Comprehensive network error types for simulation
 * 用于模拟的综合网络错误类型
 */
enum NetworkErrorType: String, CaseIterable {
    case offline = "offline"
    case timeout = "timeout"
    case serverError = "serverError"
    case unauthorized = "unauthorized"
    case notFound = "notFound"
    case badRequest = "badRequest"
    case tooManyRequests = "tooManyRequests"
    case maintenance = "maintenance"

    var displayName: String {
        switch self {
        case .offline: return "离线"
        case .timeout: return "超时"
        case .serverError: return "服务器错误"
        case .unauthorized: return "未授权"
        case .notFound: return "未找到"
        case .badRequest: return "请求错误"
        case .tooManyRequests: return "请求过多"
        case .maintenance: return "维护中"
        }
    }

    var englishName: String {
        switch self {
        case .offline: return "Offline"
        case .timeout: return "Timeout"
        case .serverError: return "Server Error"
        case .unauthorized: return "Unauthorized"
        case .notFound: return "Not Found"
        case .badRequest: return "Bad Request"
        case .tooManyRequests: return "Too Many Requests"
        case .maintenance: return "Maintenance"
        }
    }

    var icon: String {
        switch self {
        case .offline: return "wifi.slash"
        case .timeout: return "clock.badge.exclamationmark"
        case .serverError: return "server.rack"
        case .unauthorized: return "lock.shield"
        case .notFound: return "questionmark.folder"
        case .badRequest: return "exclamationmark.triangle"
        case .tooManyRequests: return "gauge.badge.minus"
        case .maintenance: return "wrench.and.screwdriver"
        }
    }

    var color: Color {
        switch self {
        case .offline: return .red
        case .timeout: return .orange
        case .serverError: return .red
        case .unauthorized: return .purple
        case .notFound: return .blue
        case .badRequest: return .yellow
        case .tooManyRequests: return .pink
        case .maintenance: return .gray
        }
    }

    var errorCode: String {
        switch self {
        case .offline: return "NETWORK_OFFLINE"
        case .timeout: return "TIMEOUT"
        case .serverError: return "500"
        case .unauthorized: return "401"
        case .notFound: return "404"
        case .badRequest: return "400"
        case .tooManyRequests: return "429"
        case .maintenance: return "503"
        }
    }

    var defaultMessage: String {
        switch self {
        case .offline:
            return "网络连接已断开，请检查您的网络设置。\nNetwork connection lost, please check your network settings."
        case .timeout:
            return "请求超时，请稍后重试。\nRequest timeout, please try again later."
        case .serverError:
            return "服务器遇到问题，我们正在修复中。\nServer encountered an issue, we're fixing it."
        case .unauthorized:
            return "您需要登录才能继续操作。\nYou need to log in to continue."
        case .notFound:
            return "请求的资源未找到。\nRequested resource not found."
        case .badRequest:
            return "请求格式有误，请检查后重试。\nInvalid request format, please check and retry."
        case .tooManyRequests:
            return "请求过于频繁，请稍后再试。\nToo many requests, please try again later."
        case .maintenance:
            return "系统正在维护中，请稍后访问。\nSystem under maintenance, please visit later."
        }
    }
}

// MARK: - Advanced Network Demo ViewModel / 高级网络演示视图模型

/**
 * ViewModel for advanced network monitoring demo
 * 高级网络监控演示的视图模型
 */
class AdvancedNetworkDemoViewModel: ObservableObject {
    @Published var pageState: ReduxPageState<[String]> = .idle
    @Published var customMessages: [NetworkErrorType: String] = [:]

    private let mockData = [
        "演示数据项 1 / Demo Data Item 1",
        "演示数据项 2 / Demo Data Item 2",
        "演示数据项 3 / Demo Data Item 3",
        "网络监控测试 / Network Monitoring Test",
        "自定义错误处理 / Custom Error Handling"
    ]

    func loadDemoData() {
        pageState = .loading(.initial)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.pageState = .loaded(self.mockData, .idle)
        }
    }

    func refreshData() {
        loadDemoData()
    }

    func simulateNetworkError(_ errorType: NetworkErrorType) {
        let customMessage = customMessages[errorType] ?? errorType.defaultMessage

        let errorInfo = ReduxPageState<[String]>.ErrorInfo(
            code: errorType.errorCode,
            message: customMessage
        )

        pageState = .failed(.initial, errorInfo)
    }

    func resetToNormal() {
        pageState = .idle
    }

    func retry() {
        loadDemoData()
    }

    func setCustomMessage(for errorType: NetworkErrorType, message: String) {
        customMessages[errorType] = message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func clearCustomMessage(for errorType: NetworkErrorType) {
        customMessages.removeValue(forKey: errorType)
    }
}

// MARK: - Preview / 预览

#Preview {
    AdvancedNetworkMonitoringDemoView()
}