//
//  NetworkAwareModifiersFix.swift
//  SwiftUIDemo
//
//  Fixed and enhanced network aware modifiers with customizable icons and messages
//  修复并增强的网络感知修饰符，支持自定义图标和消息
//

import SwiftUI
import Combine

/**
 * ENHANCED UNIVERSAL NETWORK STATE MODIFIER - 增强的万能网络状态修饰符
 *
 * 现在支持完全自定义的错误处理！
 * Now supports fully customizable error handling!
 *
 * NEW FEATURES / 新功能:
 * ✅ Custom icons for each error type / 每种错误类型的自定义图标
 * ✅ Custom messages / 自定义消息
 * ✅ Custom primary and secondary actions / 自定义主要和次要操作
 * ✅ Error mapping configuration / 错误映射配置
 */

// MARK: - Error Display Configuration / 错误显示配置

/**
 * Configuration for how to display errors
 * 错误显示的配置
 *
 * This allows complete customization of error UI
 * 这允许完全自定义错误 UI
 */
public struct ErrorDisplayConfig {
    let icon: String
    let title: String
    let message: String
    let primaryActionTitle: String?
    let primaryAction: (() -> Void)?
    let secondaryActionTitle: String?
    let secondaryAction: (() -> Void)?
    let iconColor: Color

    public init(
        icon: String,
        title: String,
        message: String,
        primaryActionTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryActionTitle: String? = "Retry / 重试",
        secondaryAction: (() -> Void)? = nil,
        iconColor: Color = .red
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.primaryActionTitle = primaryActionTitle
        self.primaryAction = primaryAction
        self.secondaryActionTitle = secondaryActionTitle
        self.secondaryAction = secondaryAction
        self.iconColor = iconColor
    }
}

// MARK: - Enhanced Universal Network State Modifier / 增强的万能网络状态修饰符

public struct EnhancedUniversalNetworkStateModifier<T: Equatable>: ViewModifier {
    let state: ReduxPageState<T>
    let onRetry: () -> Void
    let autoRetry: Bool
    let showIndicators: Bool
    let customLoadingView: AnyView?
    let customEmptyView: AnyView?

    // NEW: Custom error configurations / 新增：自定义错误配置
    let customErrorConfigs: [String: ErrorDisplayConfig]  // Map error codes to configs / 将错误代码映射到配置
    let customOfflineConfig: ErrorDisplayConfig?

    @ObservedObject private var monitor = NetworkMonitor.shared
    @State private var hasRetried = false

    public func body(content: Content) -> some View {
        ZStack {
            // Original content / 原始内容
            content
                .disabled(!monitor.isConnected || isLoading)
                .blur(radius: shouldBlur ? 2 : 0)

            // State-based overlay / 基于状态的覆盖层
            stateOverlay
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100)

            // Network indicators / 网络指示器
            if showIndicators && !monitor.isConnected {
                VStack {
                    networkStatusBar
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: state)
        .animation(.easeInOut(duration: 0.2), value: monitor.isConnected)
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
            if let config = customOfflineConfig {
                CustomizableErrorView(config: config)
            } else {
                CustomizableErrorView(config: ErrorDisplayConfig(
                    icon: "wifi.slash",
                    title: "No Internet Connection / 无网络连接",
                    message: "Please check your network settings / 请检查您的网络设置",
                    primaryActionTitle: "Settings / 设置",
                    primaryAction: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryActionTitle: "Retry / 重试",
                    secondaryAction: onRetry
                ))
            }
        }
        // PRIORITY 2: Check page state / 优先级2：检查页面状态
        else {
            switch state {
            case .idle:
                EmptyView()

            case .loading(.initial):
                if let custom = customLoadingView {
                    custom
                } else {
                    EnhancedLoadingView()
                }

            case .loaded(_, let subState):
                if case .noMore = subState {
                    if let custom = customEmptyView {
                        custom
                    } else {
                        EnhancedEmptyView(onRefresh: onRetry)
                    }
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

    @ViewBuilder
    private func intelligentErrorView(for error: ReduxPageState<T>.ErrorInfo) -> some View {
        // Check if custom config exists for this error code
        // 检查是否存在此错误代码的自定义配置
        if let customConfig = customErrorConfigs[error.code] {
            CustomizableErrorView(config: customConfig)
        } else {
            // Use default intelligent error analysis
            // 使用默认的智能错误分析
            let defaultConfig = analyzeError(error)
            CustomizableErrorView(config: defaultConfig)
        }
    }

    private func analyzeError(_ error: ReduxPageState<T>.ErrorInfo) -> ErrorDisplayConfig {
        switch error.code {
        case "NETWORK_OFFLINE", "NETWORK_CONNECTION":
            return ErrorDisplayConfig(
                icon: "wifi.slash",
                title: "Connection Lost / 连接丢失",
                message: error.message,
                primaryActionTitle: "Check Network / 检查网络",
                primaryAction: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryAction: onRetry
            )

        case "UNAUTHORIZED", "401":
            return ErrorDisplayConfig(
                icon: "lock.shield",
                title: "Authentication Required / 需要认证",
                message: error.message,
                primaryActionTitle: "Login / 登录",
                primaryAction: {
                    print("Navigate to login")
                },
                secondaryAction: onRetry
            )

        case "NOT_FOUND", "404":
            return ErrorDisplayConfig(
                icon: "questionmark.folder",
                title: "Not Found / 未找到",
                message: error.message,
                primaryActionTitle: "Go Back / 返回",
                primaryAction: {
                    print("Navigate back")
                },
                secondaryAction: onRetry
            )

        case "SERVER_ERROR", "500", "502", "503":
            return ErrorDisplayConfig(
                icon: "exclamationmark.icloud",
                title: "Server Error / 服务器错误",
                message: error.message,
                primaryActionTitle: "Report / 报告",
                primaryAction: {
                    print("Report issue")
                },
                secondaryAction: onRetry
            )

        case "TIMEOUT":
            return ErrorDisplayConfig(
                icon: "clock.badge.exclamationmark",
                title: "Request Timeout / 请求超时",
                message: error.message,
                secondaryAction: onRetry,
                iconColor: .orange
            )

        case "DECODING_ERROR", "PARSING_ERROR":
            return ErrorDisplayConfig(
                icon: "doc.badge.ellipsis",
                title: "Data Error / 数据错误",
                message: error.message,
                secondaryAction: onRetry,
                iconColor: .purple
            )

        default:
            return ErrorDisplayConfig(
                icon: "questionmark.circle",
                title: "Unknown Error / 未知错误",
                message: error.message,
                secondaryAction: onRetry,
                iconColor: .gray
            )
        }
    }
}

// MARK: - Customizable Error View / 可自定义错误视图

struct CustomizableErrorView: View {
    let config: ErrorDisplayConfig

    var body: some View {
        VStack(spacing: 24) {
            // Icon / 图标
            Image(systemName: config.icon)
                .font(.system(size: 60))
                .foregroundColor(config.iconColor)
                .symbolRenderingMode(.hierarchical)

            // Title / 标题
            Text(config.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Message / 消息
            Text(config.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Actions / 操作
            VStack(spacing: 12) {
                if let primaryTitle = config.primaryActionTitle,
                   let primaryAction = config.primaryAction {
                    Button(action: primaryAction) {
                        Text(primaryTitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if let secondaryTitle = config.secondaryActionTitle,
                   let secondaryAction = config.secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
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

// MARK: - Enhanced Loading View / 增强的加载视图

struct EnhancedLoadingView: View {
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

// MARK: - Enhanced Empty View / 增强的空视图

struct EnhancedEmptyView: View {
    let onRefresh: (() -> Void)?

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

            if let onRefresh = onRefresh {
                Button(action: onRefresh) {
                    Label("Refresh / 刷新", systemImage: "arrow.clockwise")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - View Extension for Enhanced Universal Network State / 增强万能网络状态的视图扩展

public extension View {
    /**
     * 🚀 ENHANCED UNIVERSAL NETWORK STATE - 增强的万能网络状态
     *
     * 现在支持完全自定义！
     * Now supports full customization!
     *
     * BASIC USAGE / 基础用法:
     * ```swift
     * MyView()
     *     .enhancedUniversalNetworkState(
     *         state: viewModel.pageState,
     *         onRetry: { viewModel.refresh() }
     *     )
     * ```
     *
     * CUSTOM ICONS AND MESSAGES / 自定义图标和消息:
     * ```swift
     * MyView()
     *     .enhancedUniversalNetworkState(
     *         state: viewModel.pageState,
     *         onRetry: { viewModel.refresh() },
     *         customErrorConfigs: [
     *             "NETWORK_OFFLINE": ErrorDisplayConfig(
     *                 icon: "airplane.slash",
     *                 title: "飞行模式 / Airplane Mode",
     *                 message: "请关闭飞行模式 / Please turn off airplane mode",
     *                 iconColor: .orange
     *             ),
     *             "SERVER_ERROR": ErrorDisplayConfig(
     *                 icon: "server.rack",
     *                 title: "服务器维护 / Server Maintenance",
     *                 message: "系统正在维护，请稍后再试 / System under maintenance",
     *                 iconColor: .purple
     *             )
     *         ],
     *         customOfflineConfig: ErrorDisplayConfig(
     *             icon: "moon.stars.fill",
     *             title: "离线模式 / Offline Mode",
     *             message: "您当前处于离线模式 / You are currently offline",
     *             iconColor: .indigo
     *         )
     *     )
     * ```
     */
    func enhancedUniversalNetworkState<T: Equatable>(
        state: ReduxPageState<T>,
        onRetry: @escaping () -> Void,
        autoRetry: Bool = true,
        showIndicators: Bool = true,
        customLoadingView: AnyView? = nil,
        customEmptyView: AnyView? = nil,
        customErrorConfigs: [String: ErrorDisplayConfig] = [:],
        customOfflineConfig: ErrorDisplayConfig? = nil
    ) -> some View {
        modifier(EnhancedUniversalNetworkStateModifier(
            state: state,
            onRetry: onRetry,
            autoRetry: autoRetry,
            showIndicators: showIndicators,
            customLoadingView: customLoadingView,
            customEmptyView: customEmptyView,
            customErrorConfigs: customErrorConfigs,
            customOfflineConfig: customOfflineConfig
        ))
    }

    /**
     * SIMPLE VERSION - 简单版本
     *
     * For when you just want the basics
     * 当你只需要基础功能时
     */
    func simpleNetworkState<T: Equatable>(
        state: ReduxPageState<T>,
        onRetry: @escaping () -> Void
    ) -> some View {
        enhancedUniversalNetworkState(
            state: state,
            onRetry: onRetry,
            autoRetry: true,
            showIndicators: true
        )
    }
}