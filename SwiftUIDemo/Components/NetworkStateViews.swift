//
//  NetworkStateViews.swift
//  SwiftUIDemo
//
//  Reusable network state and error handling views
//  可复用的网络状态和错误处理视图
//

import SwiftUI

/**
 * NETWORK STATE VIEWS LIBRARY
 * 网络状态视图库
 *
 * PURPOSE / 目的:
 * - Handle all network states (loading, error, empty, success)
 * - 处理所有网络状态（加载中、错误、空数据、成功）
 * - Provide consistent error handling UI
 * - 提供一致的错误处理 UI
 * - Support retry and refresh actions
 * - 支持重试和刷新操作
 *
 * USAGE / 使用:
 * ```
 * ContentView()
 *     .networkStateOverlay(state: viewModel.state) {
 *         viewModel.retry()
 *     }
 * ```
 */

// MARK: - Network Error Types / 网络错误类型

/**
 * Common network error types with appropriate messages
 * 常见网络错误类型及相应消息
 */
enum NetworkError: Error, Equatable {
    case noConnection           // No internet / 无网络连接
    case timeout               // Request timeout / 请求超时
    case serverError(Int)      // 5xx errors / 服务器错误
    case clientError(Int)      // 4xx errors / 客户端错误
    case unauthorized          // 401 / 未授权
    case forbidden            // 403 / 禁止访问
    case notFound             // 404 / 未找到
    case dataCorrupted        // Parse error / 解析错误
    case rateLimited          // 429 / 限流
    case badRequest(String)   // 400 / 错误请求
    case httpError(Int, String?) // Generic HTTP error / 通用HTTP错误
    case invalidURL           // Invalid URL / 无效URL
    case unknown              // Unknown error / 未知错误

    var statusCode: Int? {
        switch self {
        case .serverError(let code), .clientError(let code), .httpError(let code, _):
            return code
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .rateLimited: return 429
        case .badRequest: return 400
        default: return nil
        }
    }

    var title: String {
        switch self {
        case .noConnection:
            return "无网络连接 / No Connection"
        case .timeout:
            return "请求超时 / Request Timeout"
        case .serverError:
            return "服务器错误 / Server Error"
        case .clientError:
            return "请求错误 / Request Error"
        case .unauthorized:
            return "未授权 / Unauthorized"
        case .forbidden:
            return "禁止访问 / Forbidden"
        case .notFound:
            return "未找到 / Not Found"
        case .dataCorrupted:
            return "数据错误 / Data Error"
        case .rateLimited:
            return "请求过于频繁 / Rate Limited"
        case .badRequest:
            return "错误请求 / Bad Request"
        case .httpError:
            return "HTTP错误 / HTTP Error"
        case .invalidURL:
            return "无效地址 / Invalid URL"
        case .unknown:
            return "未知错误 / Unknown Error"
        }
    }

    var message: String {
        switch self {
        case .noConnection:
            return "请检查您的网络连接后重试\nPlease check your internet connection and try again"
        case .timeout:
            return "服务器响应超时，请稍后重试\nServer response timeout, please try again later"
        case .serverError(let code):
            return "服务器遇到问题 (错误码: \(code))\nServer encountered an issue (Error: \(code))"
        case .clientError(let code):
            return "请求出现问题 (错误码: \(code))\nRequest issue (Error: \(code))"
        case .unauthorized:
            return "您需要登录才能访问此内容\nYou need to login to access this content"
        case .forbidden:
            return "您没有权限访问此内容\nYou don't have permission to access this content"
        case .notFound:
            return "请求的资源不存在\nThe requested resource does not exist"
        case .dataCorrupted:
            return "数据解析失败，请稍后重试\nFailed to parse data, please try again"
        case .rateLimited:
            return "请求过于频繁，请稍后再试\nToo many requests, please try again later"
        case .badRequest(let detail):
            return "请求参数错误: \(detail)\nBad request: \(detail)"
        case .httpError(let code, let detail):
            return "HTTP错误 \(code): \(detail ?? "未知")\nHTTP Error \(code): \(detail ?? "Unknown")"
        case .invalidURL:
            return "请求地址无效\nInvalid request URL"
        case .unknown:
            return "发生未知错误，请稍后重试\nAn unknown error occurred, please try again"
        }
    }

    var icon: String {
        switch self {
        case .noConnection:
            return "wifi.slash"
        case .timeout:
            return "clock.badge.exclamationmark"
        case .serverError:
            return "server.rack"
        case .unauthorized, .forbidden:
            return "lock.fill"
        case .notFound:
            return "magnifyingglass"
        case .dataCorrupted:
            return "exclamationmark.triangle"
        default:
            return "exclamationmark.circle"
        }
    }

    var iconColor: Color {
        switch self {
        case .noConnection: return .gray
        case .timeout: return .orange
        case .serverError: return .red
        case .unauthorized, .forbidden: return .purple
        case .notFound: return .blue
        case .dataCorrupted: return .yellow
        default: return .red
        }
    }

    var canRetry: Bool {
        switch self {
        case .unauthorized, .forbidden:
            return false
        default:
            return true
        }
    }
}

// MARK: - Network State / 网络状态

/**
 * Comprehensive network state representation
 * 全面的网络状态表示
 */
enum NetworkState<T: Equatable>: Equatable {
    case idle                          // Initial state / 初始状态
    case loading                       // Loading data / 加载中
    case loaded(T)                     // Success with data / 成功加载数据
    case empty                         // Success but no data / 成功但无数据
    case error(NetworkError)           // Error state / 错误状态
    case refreshing(T)                 // Refreshing existing data / 刷新现有数据

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isRefreshing: Bool {
        if case .refreshing = self { return true }
        return false
    }

    var hasError: Bool {
        if case .error = self { return true }
        return false
    }

    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }

    var data: T? {
        switch self {
        case .loaded(let data), .refreshing(let data):
            return data
        default:
            return nil
        }
    }
}

// MARK: - Empty State View / 空状态视图

/**
 * Reusable empty state view for lists with no data
 * 可复用的列表无数据空状态视图
 *
 * USAGE / 使用:
 * ```
 * NetworkEmptyStateView(
 *     style: .noResults,
 *     customAction: { search() }
 * )
 * ```
 */
struct NetworkEmptyStateView: View {
    let style: EmptyStyle
    let customMessage: String?
    let customAction: (() -> Void)?

    enum EmptyStyle {
        case noData         // No data available / 无可用数据
        case noResults      // No search results / 无搜索结果
        case noContent      // No content created / 无创建内容
        case noMessages     // No messages / 无消息
        case noNotifications // No notifications / 无通知
        case custom(icon: String, title: String)

        var icon: String {
            switch self {
            case .noData: return "doc.text"
            case .noResults: return "magnifyingglass"
            case .noContent: return "square.stack"
            case .noMessages: return "bubble.left.and.bubble.right"
            case .noNotifications: return "bell.slash"
            case .custom(let icon, _): return icon
            }
        }

        var title: String {
            switch self {
            case .noData: return "暂无数据 / No Data"
            case .noResults: return "无搜索结果 / No Results"
            case .noContent: return "暂无内容 / No Content"
            case .noMessages: return "暂无消息 / No Messages"
            case .noNotifications: return "暂无通知 / No Notifications"
            case .custom(_, let title): return title
            }
        }

        var defaultMessage: String {
            switch self {
            case .noData:
                return "当前没有可显示的数据\nNo data available to display"
            case .noResults:
                return "尝试调整搜索条件\nTry adjusting your search criteria"
            case .noContent:
                return "创建您的第一个内容开始\nCreate your first content to get started"
            case .noMessages:
                return "开始对话来发送消息\nStart a conversation to send messages"
            case .noNotifications:
                return "有新通知时会显示在这里\nNew notifications will appear here"
            case .custom:
                return ""
            }
        }

        var actionTitle: String? {
            switch self {
            case .noResults: return "清除搜索 / Clear Search"
            case .noContent: return "创建内容 / Create Content"
            case .noMessages: return "开始对话 / Start Chat"
            default: return nil
            }
        }
    }

    init(
        style: EmptyStyle = .noData,
        message: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.style = style
        self.customMessage = message
        self.customAction = action
    }

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: style.icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            // Text
            VStack(spacing: 8) {
                Text(style.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(customMessage ?? style.defaultMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Action button
            if let action = customAction, let title = style.actionTitle {
                Button(action: action) {
                    Text(title)
                        .fontWeight(.medium)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View / 错误状态视图

/**
 * Comprehensive error state view with retry action
 * 带重试操作的综合错误状态视图
 */
struct ErrorStateView: View {
    let error: NetworkError
    let retryAction: (() -> Void)?
    let customAction: (title: String, action: () -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            // Error icon
            Image(systemName: error.icon)
                .font(.system(size: 60))
                .foregroundColor(error.iconColor)

            // Error info
            VStack(spacing: 8) {
                Text(error.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                if let code = error.statusCode {
                    Text("错误代码 / Error Code: \(code)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }

                Text(error.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Actions
            VStack(spacing: 12) {
                if error.canRetry, let retry = retryAction {
                    Button(action: retry) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("重试 / Retry")
                        }
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let custom = customAction {
                    Button(action: custom.action) {
                        Text(custom.title)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State View / 加载状态视图

/**
 * Customizable loading state view
 * 可定制的加载状态视图
 */
struct LoadingStateView: View {
    let message: String?
    let progress: Double?
    let style: LoadingStyle

    enum LoadingStyle {
        case standard
        case skeleton
        case shimmer
        case progress
    }

    init(
        message: String? = "加载中... / Loading...",
        progress: Double? = nil,
        style: LoadingStyle = .standard
    ) {
        self.message = message
        self.progress = progress
        self.style = style
    }

    var body: some View {
        switch style {
        case .standard:
            standardLoadingView
        case .skeleton:
            skeletonLoadingView
        case .shimmer:
            shimmerLoadingView
        case .progress:
            progressLoadingView
        }
    }

    private var standardLoadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var skeletonLoadingView: some View {
        VStack(spacing: 12) {
            ForEach(0..<5) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)

                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 16)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .padding(.trailing, 40)
                    }
                }
                .padding()
            }
        }
    }

    private var shimmerLoadingView: some View {
        VStack(spacing: 12) {
            ForEach(0..<5) { _ in
                ShimmerView()
                    .frame(height: 80)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }

    private var progressLoadingView: some View {
        VStack(spacing: 20) {
            if let progress = progress {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)

                Text("\(Int(progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shimmer Effect View / 闪光效果视图

struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.2)

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 0.3)
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
}

// MARK: - Network State Overlay Modifier / 网络状态遮罩修饰符

/**
 * ViewModifier to handle all network states
 * 处理所有网络状态的视图修饰符
 */
struct NetworkStateOverlay<T: Equatable, ContentView: View>: ViewModifier {
    let state: NetworkState<T>
    let retryAction: (() -> Void)?
    let emptyStyle: NetworkEmptyStateView.EmptyStyle
    let loadingStyle: LoadingStateView.LoadingStyle
    let contentBuilder: (T) -> ContentView

    func body(content: Content) -> some View {
        ZStack {
            switch state {
            case .idle:
                Color.clear

            case .loading:
                LoadingStateView(style: loadingStyle)

            case .loaded(let data):
                contentBuilder(data)

            case .empty:
                NetworkEmptyStateView(style: emptyStyle, action: retryAction)

            case .error(let error):
                ErrorStateView(error: error, retryAction: retryAction, customAction: nil)

            case .refreshing(let data):
                contentBuilder(data)
                    .overlay(
                        VStack {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("刷新中... / Refreshing...")
                                    .font(.caption)
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                            Spacer()
                        }
                    )
            }
        }
    }
}

// MARK: - View Extensions / 视图扩展

extension View {
    /**
     * Apply network state handling to any view
     * 为任何视图应用网络状态处理
     *
     * USAGE / 使用:
     * ```
     * List(items) { item in
     *     ItemView(item: item)
     * }
     * .networkState(
     *     state: viewModel.state,
     *     retry: { viewModel.retry() }
     * ) { data in
     *     // Content view with data
     * }
     * ```
     */
    func networkState<T: Equatable, Content: View>(
        state: NetworkState<T>,
        retry: (() -> Void)? = nil,
        emptyStyle: NetworkEmptyStateView.EmptyStyle = .noData,
        loadingStyle: LoadingStateView.LoadingStyle = .standard,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        modifier(NetworkStateOverlay(
            state: state,
            retryAction: retry,
            emptyStyle: emptyStyle,
            loadingStyle: loadingStyle,
            contentBuilder: content
        ))
    }
}