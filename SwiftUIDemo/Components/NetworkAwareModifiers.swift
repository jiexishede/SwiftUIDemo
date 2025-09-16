//
//  NetworkAwareModifiers.swift
//  SwiftUIDemo
//
//  Network-aware view modifiers combining NetworkMonitor and ReduxPageState
//  结合 NetworkMonitor 和 ReduxPageState 的网络感知视图修饰符
//

import SwiftUI
import Combine

/**
 * NETWORK AWARE MODIFIERS - 网络感知修饰符系统
 *
 * 这是一个将网络监控与页面状态管理完美结合的修饰符系统。
 * 通过链式调用，让视图自动响应网络状态变化，提供优雅的用户体验。
 *
 * This is a modifier system that perfectly combines network monitoring with page state management.
 * Through chain calls, views automatically respond to network status changes, providing elegant user experience.
 *
 * DESIGN PATTERNS USED / 使用的设计模式:
 *
 * 1. Decorator Pattern (装饰器模式)
 *    - Why: 通过 ViewModifier 为视图添加网络感知能力，不改变原视图结构
 *    - Benefits: 可组合、可重用、关注点分离
 *    - Implementation: 每个修饰符处理特定的网络状态场景
 *
 * 2. Chain of Responsibility Pattern (责任链模式)
 *    - Why: 多个修饰符可以链式调用，每个处理特定职责
 *    - Benefits: 灵活组合、易于扩展、职责单一
 *    - Implementation: 通过 View 扩展方法实现链式调用
 *
 * 3. Observer Pattern (观察者模式)
 *    - Why: 自动响应网络状态变化
 *    - Benefits: 解耦、实时响应、自动更新
 *    - Implementation: 使用 @ObservedObject 监听 NetworkMonitor
 *
 * SOLID PRINCIPLES / SOLID 原则:
 *
 * - SRP: 每个修饰符只负责一个特定的网络状态处理
 * - OCP: 通过扩展添加新功能，不修改现有代码
 * - LSP: 所有修饰符都遵循 ViewModifier 协议
 * - ISP: 提供细粒度的接口，用户只使用需要的功能
 * - DIP: 依赖抽象的 NetworkMonitor 协议，而非具体实现
 *
 * USAGE EXAMPLES / 使用示例:
 * ```
 * // Basic network awareness / 基础网络感知
 * ContentView()
 *     .networkAware()
 *     .onNetworkLost {
 *         // Handle network lost / 处理网络丢失
 *     }
 *
 * // With Redux page state / 配合 Redux 页面状态
 * ListView()
 *     .networkPageState(state: viewModel.pageState)
 *     .onNetworkRetry {
 *         viewModel.retry()
 *     }
 *
 * // Chain multiple modifiers / 链式调用多个修饰符
 * DetailView()
 *     .networkAware()
 *     .showOfflineIndicator()
 *     .autoRetryOnReconnect {
 *         fetchData()
 *     }
 * ```
 */

// MARK: - Network Aware Base Modifier / 网络感知基础修饰符

/**
 * Base network-aware modifier that monitors connectivity
 * 监控连接性的基础网络感知修饰符
 *
 * 这是所有网络感知功能的基础，提供网络状态监控和回调。
 * This is the foundation of all network-aware features, providing network status monitoring and callbacks.
 */
struct NetworkAwareModifier: ViewModifier {
    @ObservedObject private var monitor = NetworkMonitor.shared

    // Callbacks / 回调
    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onConnectionTypeChanged: ((NetworkMonitor.ConnectionType) -> Void)?

    func body(content: Content) -> some View {
        content
            // NetworkMonitor automatically starts monitoring on init / NetworkMonitor 在初始化时自动开始监控
            // No need to manually start it / 无需手动启动
            .onChange(of: monitor.isConnected) { _, isConnected in
                // Handle connection state change / 处理连接状态变化
                if isConnected {
                    onConnected?()
                } else {
                    onDisconnected?()
                }
            }
            .onChange(of: monitor.connectionType) { _, newType in
                // Handle connection type change / 处理连接类型变化
                onConnectionTypeChanged?(newType)
            }
    }
}

// MARK: - Network Page State Modifier / 网络页面状态修饰符

/**
 * Combines ReduxPageState with network monitoring
 * 结合 ReduxPageState 与网络监控
 *
 * 根据网络状态和页面状态自动显示相应的 UI。
 * Automatically displays appropriate UI based on network status and page state.
 */
struct NetworkPageStateModifier<T: Equatable>: ViewModifier {
    let pageState: ReduxPageState<T>
    @ObservedObject private var monitor = NetworkMonitor.shared

    // Callbacks / 回调
    var onRetry: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content

            // Show appropriate overlay based on state / 根据状态显示适当的覆盖层
            overlayView
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        // Network disconnected takes priority / 网络断开优先级最高
        if !monitor.isConnected {
            offlineOverlay
        } else {
            // Handle page state when connected / 连接时处理页面状态
            switch pageState {
            case .idle:
                EmptyView()

            case .loading(let type):
                loadingOverlay(type: type)

            case .loaded(_, let loadMoreState):
                loadMoreOverlay(state: loadMoreState)

            case .failed(let failureType, let error):
                errorOverlay(failureType: failureType, error: error)
            }
        }
    }

    @ViewBuilder
    private var offlineOverlay: some View {
        // Default offline view / 默认离线视图
        NetworkOfflineView(onRetry: onRetry)
    }

    @ViewBuilder
    private func loadingOverlay(type: ReduxPageState<T>.LoadingType) -> some View {
        if case .initial = type {
            // Default loading view / 默认加载视图
            UniversalLoadingView()
        }
    }

    @ViewBuilder
    private func loadMoreOverlay(state: ReduxPageState<T>.LoadMoreState) -> some View {
        if case .loading = state {
            VStack {
                Spacer()
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("加载更多... / Loading more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    private func errorOverlay(
        failureType: ReduxPageState<T>.FailureType,
        error: ReduxPageState<T>.ErrorInfo
    ) -> some View {
        if case .initial = failureType {
            // Default error view / 默认错误视图
            NetworkErrorView(
                error: error,
                onRetry: onRetry
            )
        }
    }
}

// MARK: - Offline Indicator Modifier / 离线指示器修饰符

/**
 * Shows a subtle offline indicator when disconnected
 * 断开连接时显示微妙的离线指示器
 */
public struct OfflineIndicatorModifier: ViewModifier {
    @ObservedObject private var monitor = NetworkMonitor.shared
    var position: IndicatorPosition = .top

    public enum IndicatorPosition {
        case top, bottom
    }

    public func body(content: Content) -> some View {
        ZStack {
            content

            if !monitor.isConnected {
                VStack {
                    if position == .bottom {
                        Spacer()
                    }

                    HStack {
                        Image(systemName: "wifi.slash")
                            .font(.caption)
                        Text("离线模式 / Offline Mode")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .transition(.move(edge: position == .top ? .top : .bottom).combined(with: .opacity))

                    if position == .top {
                        Spacer()
                    }
                }
                .padding()
                .animation(.spring(), value: monitor.isConnected)
            }
        }
    }
}

// MARK: - Auto Retry Modifier / 自动重试修饰符

/**
 * Automatically retries action when network reconnects
 * 网络重连时自动重试操作
 */
struct AutoRetryOnReconnectModifier: ViewModifier {
    @ObservedObject private var monitor = NetworkMonitor.shared
    @State private var wasDisconnected = false

    let retryAction: () -> Void
    var showNotification: Bool = true

    func body(content: Content) -> some View {
        content
            .onChange(of: monitor.isConnected) { _, isConnected in
                if !isConnected {
                    wasDisconnected = true
                } else if wasDisconnected {
                    // Network reconnected, trigger retry / 网络重连，触发重试
                    wasDisconnected = false

                    if showNotification {
                        // Show retry notification / 显示重试通知
                        withAnimation {
                            retryAction()
                        }
                    } else {
                        retryAction()
                    }
                }
            }
    }
}

// MARK: - Network Speed Indicator / 网络速度指示器

/**
 * Shows network connection type and quality
 * 显示网络连接类型和质量
 */
struct NetworkSpeedIndicatorModifier: ViewModifier {
    @ObservedObject private var monitor = NetworkMonitor.shared
    var showAlways: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if showAlways || !monitor.isConnected || monitor.isConstrained {
                            networkIndicator
                        }
                    }
                    Spacer()
                }
                .padding()
            )
    }

    @ViewBuilder
    private var networkIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: connectionIcon)
                .font(.caption2)

            if monitor.isExpensive {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }

            if monitor.isConstrained {
                Image(systemName: "tortoise.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(8)
    }

    private var connectionIcon: String {
        switch monitor.connectionType {
        case .wifi:
            return "wifi"
        case .cellular:
            return "antenna.radiowaves.left.and.right"
        case .wiredEthernet:
            return "cable.connector"
        case .unknown:
            return "questionmark.circle"
        }
    }
}

// MARK: - Enhanced Network Offline View / 增强的网络离线视图

/**
 * Network offline view with custom styling
 * 带自定义样式的网络离线视图
 */
struct NetworkOfflineView: View {
    let onRetry: (() -> Void)?
    var customMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text(customMessage ?? "No Internet Connection / 无网络连接")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Please check your network settings / 请检查您的网络设置")
                .font(.caption)
                .foregroundColor(.secondary)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry / 重试")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Universal Network State Modifier / 万能网络状态修饰符

/**
 * 🌟 THE ULTIMATE MODIFIER - 终极修饰符
 *
 * 这是处理所有网络和页面状态的终极解决方案。
 * 一个修饰符，搞定所有场景！
 *
 * This is the ultimate solution for handling all network and page states.
 * One modifier to rule them all!
 *
 * INTELLIGENT ERROR HANDLING / 智能错误处理:
 * - Automatically detects error types / 自动检测错误类型
 * - Shows appropriate UI for each error / 为每种错误显示合适的 UI
 * - Provides context-aware retry options / 提供上下文感知的重试选项
 */
struct UniversalNetworkStateModifier<T: Equatable>: ViewModifier {
    let state: ReduxPageState<T>
    let onRetry: () -> Void
    let autoRetry: Bool
    let showIndicators: Bool

    @ObservedObject private var monitor = NetworkMonitor.shared
    @State private var hasRetried = false

    func body(content: Content) -> some View {
        ZStack {
            // Original content / 原始内容
            content
                // Disable when offline or loading / 离线或加载时禁用
                .disabled(!monitor.isConnected || isLoading)
                .blur(radius: shouldBlur ? 2 : 0)

            // State-based overlay / 基于状态的覆盖层
            stateOverlay
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100)

            // Network indicators / 网络指示器
            if showIndicators {
                VStack {
                    if !monitor.isConnected {
                        networkStatusBar
                    }
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: state)
        .animation(.easeInOut(duration: 0.2), value: monitor.isConnected)
        // Auto-retry on reconnect / 重连时自动重试
        .onChange(of: monitor.isConnected) { _, isConnected in
            if autoRetry && isConnected && !hasRetried {
                hasRetried = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onRetry()
                    hasRetried = false
                }
            }
        }
    }

    // MARK: - Computed Properties / 计算属性

    private var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    private var shouldBlur: Bool {
        !monitor.isConnected || isLoading
    }

    @ViewBuilder
    private var stateOverlay: some View {
        // PRIORITY 1: Network offline / 优先级1：网络离线
        if !monitor.isConnected {
            UniversalErrorView(
                icon: "wifi.slash",
                title: "No Internet Connection / 无网络连接",
                message: "Please check your network settings / 请检查您的网络设置",
                primaryAction: ("Settings / 设置", {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryAction: ("Retry / 重试", onRetry)
            )
        }
        // PRIORITY 2: Check page state / 优先级2：检查页面状态
        else {
            switch state {
            case .idle:
                EmptyView()

            case .loading(.initial):
                UniversalLoadingView()

            case .loaded(_, let subState):
                if subState == .empty {
                    UniversalEmptyView(onRefresh: onRetry)
                } else {
                    EmptyView() // Normal loaded state, no overlay needed
                }

            case .failed(_, let error):
                intelligentErrorView(for: error)

            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var networkStatusBar: some View {
        HStack {
            Image(systemName: "wifi.slash")
            Text("Offline Mode / 离线模式")
                .font(.caption)
            Spacer()
            if autoRetry {
                Text("Will retry when connected / 连接后将重试")
                    .font(.caption2)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.red)
        .shadow(radius: 2)
    }

    /**
     * Intelligent error view based on error code
     * 基于错误代码的智能错误视图
     */
    @ViewBuilder
    private func intelligentErrorView(for error: ReduxPageState<T>.ErrorInfo) -> some View {
        let errorConfig = analyzeError(error)

        UniversalErrorView(
            icon: errorConfig.icon,
            title: errorConfig.title,
            message: errorConfig.message,
            primaryAction: errorConfig.primaryAction,
            secondaryAction: ("Retry / 重试", onRetry)
        )
    }

    /**
     * Analyze error and provide appropriate UI config
     * 分析错误并提供合适的 UI 配置
     */
    private func analyzeError(_ error: ReduxPageState<T>.ErrorInfo) -> ErrorConfig {
        switch error.code {
        case "NETWORK_OFFLINE":
            return ErrorConfig(
                icon: "wifi.slash",
                title: "Connection Lost / 连接丢失",
                message: error.message,
                primaryAction: ("Check Network / 检查网络", {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                })
            )

        case "UNAUTHORIZED", "401":
            return ErrorConfig(
                icon: "lock.shield",
                title: "Authentication Required / 需要认证",
                message: "Please log in to continue / 请登录以继续",
                primaryAction: ("Login / 登录", {
                    // Navigate to login
                    print("Navigate to login")
                })
            )

        case "NOT_FOUND", "404":
            return ErrorConfig(
                icon: "questionmark.folder",
                title: "Not Found / 未找到",
                message: "The requested resource was not found / 请求的资源未找到",
                primaryAction: ("Go Back / 返回", {
                    // Navigate back
                    print("Navigate back")
                })
            )

        case "SERVER_ERROR", "500", "502", "503":
            return ErrorConfig(
                icon: "exclamationmark.server",
                title: "Server Error / 服务器错误",
                message: "Something went wrong on our end / 服务器出现问题",
                primaryAction: ("Report / 报告", {
                    // Report issue
                    print("Report issue")
                })
            )

        case "TIMEOUT":
            return ErrorConfig(
                icon: "clock.badge.exclamationmark",
                title: "Request Timeout / 请求超时",
                message: "The request took too long / 请求耗时过长",
                primaryAction: nil
            )

        default:
            return ErrorConfig(
                icon: "exclamationmark.triangle",
                title: "Error / 错误",
                message: error.message,
                primaryAction: nil
            )
        }
    }

    // Error configuration struct / 错误配置结构
    private struct ErrorConfig {
        let icon: String
        let title: String
        let message: String
        let primaryAction: (String, () -> Void)?
    }
}

/**
 * Universal Error View - 通用错误视图
 * Handles all types of errors with appropriate UI
 * 用合适的 UI 处理所有类型的错误
 */
struct UniversalErrorView: View {
    let icon: String
    let title: String
    let message: String
    let primaryAction: (String, () -> Void)?
    let secondaryAction: (String, () -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            // Icon / 图标
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.red)
                .symbolRenderingMode(.hierarchical)

            // Title / 标题
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Message / 消息
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Actions / 操作
            VStack(spacing: 12) {
                if let primary = primaryAction {
                    Button(action: primary.1) {
                        Text(primary.0)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if let secondary = secondaryAction {
                    Button(action: secondary.1) {
                        Text(secondary.0)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

/**
 * Universal Loading View - 通用加载视图
 */
struct UniversalLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }

            Text("Loading... / 加载中...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.95))
        .onAppear {
            isAnimating = true
        }
    }
}

/**
 * Universal Empty View - 通用空视图
 */
struct UniversalEmptyView: View {
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Data / 暂无数据")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Pull to refresh or tap below / 下拉刷新或点击下方按钮")
                .font(.body)
                .foregroundColor(.secondary)

            Button(action: onRefresh) {
                Label("Refresh / 刷新", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Priority-Based Network Page State Modifier / 基于优先级的网络页面状态修饰符

/**
 * Enhanced page state modifier with network priority
 * 带网络优先级的增强页面状态修饰符
 *
 * PRIORITY ORDER / 优先级顺序:
 * 1. Network offline (highest) / 网络离线（最高）
 * 2. Network errors / 网络错误
 * 3. Server errors / 服务器错误
 * 4. Loading states / 加载状态
 * 5. Empty states / 空状态
 */
struct PriorityNetworkPageStateModifier<T: Equatable>: ViewModifier {
    let state: ReduxPageState<T>
    let onRetry: (() -> Void)?
    @ObservedObject private var monitor = NetworkMonitor.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            // PRIORITY 1: Check network connectivity first
            // 优先级1：首先检查网络连接
            if !monitor.isConnected {
                NetworkOfflineView(
                    onRetry: onRetry,
                    customMessage: "Network Required / 需要网络连接"
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100) // Highest z-index / 最高层级
            }
            // PRIORITY 2: Check for network-related errors in state
            // 优先级2：检查状态中的网络相关错误
            else if case .failed(_, let error) = state,
                    error.code == "NETWORK_OFFLINE" || error.code == "NETWORK_ERROR" {
                NetworkOfflineView(
                    onRetry: onRetry,
                    customMessage: error.message
                )
                .transition(.opacity)
                .zIndex(99)
            }
            // PRIORITY 3: Handle other states normally
            // 优先级3：正常处理其他状态
            else {
                switch state {
                case .idle:
                    EmptyView()

                case .loading:
                    UniversalLoadingView()
                        .zIndex(50)

                case .loaded(_, let subState):
                    if subState == .empty {
                        UniversalEmptyView(onRefresh: onRetry ?? {})
                            .zIndex(40)
                    }

                case .failed(_, let error):
                    NetworkErrorView(error: error, onRetry: onRetry)
                        .zIndex(60)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: state)
        .animation(.easeInOut(duration: 0.2), value: monitor.isConnected)
    }
}

// MARK: - View Extension for Chain Calls / 链式调用的视图扩展

public extension View {
    /**
     * Makes view network-aware with callbacks
     * 使视图具有网络感知能力并提供回调
     *
     * USAGE / 使用:
     * ```
     * ContentView()
     *     .networkAware()
     *     .onNetworkConnected {
     *         print("Connected")
     *     }
     *     .onNetworkDisconnected {
     *         print("Disconnected")
     *     }
     * ```
     */
    func networkAware() -> some View {
        modifier(NetworkAwareModifier())
    }

    /**
     * Adds callbacks for network state changes
     * 添加网络状态变化的回调
     */
    func onNetworkConnected(_ action: @escaping () -> Void) -> some View {
        modifier(NetworkAwareModifier(onConnected: action))
    }

    func onNetworkDisconnected(_ action: @escaping () -> Void) -> some View {
        modifier(NetworkAwareModifier(onDisconnected: action))
    }

    func onNetworkTypeChanged(_ action: @escaping (NetworkMonitor.ConnectionType) -> Void) -> some View {
        modifier(NetworkAwareModifier(onConnectionTypeChanged: action))
    }

    /**
     * Combines page state with network monitoring
     * 将页面状态与网络监控结合
     *
     * USAGE / 使用:
     * ```
     * ListView()
     *     .networkPageState(state: viewModel.pageState)
     *     .onNetworkRetry {
     *         viewModel.loadData()
     *     }
     * ```
     */
    func networkPageState<T: Equatable>(
        state: ReduxPageState<T>,
        onRetry: (() -> Void)? = nil
    ) -> some View {
        modifier(NetworkPageStateModifier(
            pageState: state,
            onRetry: onRetry
        ))
    }

    /**
     * Adds retry action for network errors
     * 为网络错误添加重试操作
     */
    func onNetworkRetry(_ action: @escaping () -> Void) -> some View {
        modifier(NetworkPageStateModifier<String>(
            pageState: .idle,
            onRetry: action
        ))
    }

    /**
     * Shows offline indicator when disconnected
     * 断开连接时显示离线指示器
     */
    func showOfflineIndicator(position: OfflineIndicatorModifier.IndicatorPosition = .top) -> some View {
        modifier(OfflineIndicatorModifier(position: position))
    }

    /**
     * Auto-retries action when network reconnects
     * 网络重连时自动重试操作
     *
     * USAGE / 使用:
     * ```
     * DetailView()
     *     .autoRetryOnReconnect {
     *         viewModel.reload()
     *     }
     * ```
     */
    func autoRetryOnReconnect(
        showNotification: Bool = true,
        _ action: @escaping () -> Void
    ) -> some View {
        modifier(AutoRetryOnReconnectModifier(
            retryAction: action,
            showNotification: showNotification
        ))
    }

    /**
     * Shows network speed/type indicator
     * 显示网络速度/类型指示器
     */
    func showNetworkSpeedIndicator(always: Bool = false) -> some View {
        modifier(NetworkSpeedIndicatorModifier(showAlways: always))
    }

    /**
     * Complete network-aware configuration
     * 完整的网络感知配置
     *
     * USAGE / 使用:
     * ```
     * ContentView()
     *     .withNetworkAwareness(
     *         pageState: viewModel.state,
     *         onRetry: { viewModel.retry() },
     *         autoRetry: true,
     *         showIndicators: true
     *     )
     * ```
     */
    @ViewBuilder
    func withNetworkAwareness<T: Equatable>(
        pageState: ReduxPageState<T>,
        onRetry: @escaping () -> Void,
        autoRetry: Bool = true,
        showIndicators: Bool = true
    ) -> some View {
        let baseView = self
            .networkAware()
            .networkPageState(state: pageState)
            .onNetworkRetry(onRetry)

        if autoRetry {
            if showIndicators {
                baseView
                    .autoRetryOnReconnect(onRetry)
                    .showOfflineIndicator()
                    .showNetworkSpeedIndicator()
            } else {
                baseView
                    .autoRetryOnReconnect(onRetry)
            }
        } else {
            if showIndicators {
                baseView
                    .showOfflineIndicator()
                    .showNetworkSpeedIndicator()
            } else {
                baseView
            }
        }
    }

    /**
     * Priority-based network page state
     * 基于优先级的网络页面状态
     *
     * HIGHEST PRIORITY TO OFFLINE DETECTION / 离线检测具有最高优先级
     *
     * This modifier ensures network offline state is shown immediately
     * without waiting for network timeout, providing better UX.
     *
     * 此修饰符确保网络离线状态立即显示，无需等待网络超时，提供更好的用户体验。
     *
     * USAGE / 使用:
     * ```swift
     * ListView()
     *     .priorityNetworkPageState(
     *         state: viewModel.pageState,
     *         onRetry: { viewModel.retry() }
     *     )
     * ```
     */
    func priorityNetworkPageState<T: Equatable>(
        state: ReduxPageState<T>,
        onRetry: (() -> Void)? = nil
    ) -> some View {
        modifier(PriorityNetworkPageStateModifier(
            state: state,
            onRetry: onRetry
        ))
    }

    /**
     * 🚀 UNIVERSAL NETWORK STATE HANDLER - 万能网络状态处理器
     *
     * 一个修饰符搞定所有网络和页面状态！
     * One modifier to handle all network and page states!
     *
     * FEATURES / 功能:
     * ✅ 自动处理断网状态 / Auto-handle offline state
     * ✅ 自动处理各种错误 / Auto-handle all errors
     * ✅ 自动处理加载状态 / Auto-handle loading state
     * ✅ 自动处理空数据 / Auto-handle empty data
     * ✅ 自动重连重试 / Auto-retry on reconnect
     * ✅ 智能错误分类 / Smart error classification
     *
     * USAGE - SUPER SIMPLE / 使用 - 超级简单:
     * ```swift
     * // That's it! Just one line! / 就这样！只需一行！
     * MyListView()
     *     .universalNetworkState(
     *         state: viewModel.pageState,
     *         onRetry: { viewModel.refresh() }
     *     )
     *
     * // Or with custom configuration / 或者自定义配置
     * MyDetailView()
     *     .universalNetworkState(
     *         state: viewModel.pageState,
     *         onRetry: { viewModel.reload() },
     *         autoRetry: true,
     *         showIndicators: true
     *     )
     * ```
     *
     * HANDLES EVERYTHING / 处理所有情况:
     * 1. Network offline → Shows offline UI with retry
     * 2. 401 Error → Shows authentication required
     * 3. 404 Error → Shows not found message
     * 4. 500 Error → Shows server error
     * 5. Loading → Shows loading indicator
     * 6. Empty data → Shows empty state
     * 7. Success → Shows your content
     *
     * NO MORE BOILERPLATE / 不再需要样板代码:
     * - No need to check network status / 无需检查网络状态
     * - No need to handle different errors / 无需处理不同错误
     * - No need to manage loading states / 无需管理加载状态
     * - Everything is automatic! / 一切都是自动的！
     */
    func universalNetworkState<T: Equatable>(
        state: ReduxPageState<T>,
        onRetry: @escaping () -> Void,
        autoRetry: Bool = true,
        showIndicators: Bool = true
    ) -> some View {
        modifier(UniversalNetworkStateModifier(
            state: state,
            onRetry: onRetry,
            autoRetry: autoRetry,
            showIndicators: showIndicators
        ))
    }

    // Removed duplicate `if` modifier - already defined in ReusableUIComponents.swift
    // 删除重复的 `if` 修饰符 - 已在 ReusableUIComponents.swift 中定义
}

// MARK: - Default Network Views / 默认网络视图


/**
 * Default network error view
 * 默认网络错误视图
 */
struct NetworkErrorView<T: Equatable>: View {
    let error: ReduxPageState<T>.ErrorInfo
    let onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("加载失败 / Load Failed")
                .font(.title3)
                .fontWeight(.semibold)

            Text(error.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("重试 / Retry")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}