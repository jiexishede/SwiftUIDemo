//
//  NetworkMonitor.swift
//  SwiftUIDemo
//
//  Network connectivity monitoring service
//  网络连接监控服务
//

import Network
import Combine
import Foundation
import SwiftUI

/**
 * NETWORK MONITOR - 网络监控器
 *
 * PURPOSE / 目的:
 * - Real-time network connectivity detection
 * - 实时网络连接检测
 * - Centralized network status management
 * - 集中式网络状态管理
 * - Automatic retry queue for failed requests
 * - 失败请求的自动重试队列
 *
 * DESIGN PATTERN / 设计模式:
 * - Singleton Pattern: Global network state management
 * - 单例模式：全局网络状态管理
 * - Observer Pattern: Publish network changes
 * - 观察者模式：发布网络变化
 *
 * USAGE / 使用:
 * ```
 * // Check current status / 检查当前状态
 * if NetworkMonitor.shared.isConnected {
 *     // Make network request / 发起网络请求
 * }
 *
 * // Subscribe to changes / 订阅变化
 * NetworkMonitor.shared.$isConnected
 *     .sink { isConnected in
 *         // Handle connectivity change / 处理连接变化
 *     }
 * ```
 */
public final class NetworkMonitor: ObservableObject {
    // MARK: - Singleton / 单例

    public static let shared = NetworkMonitor()

    // MARK: - Published Properties / 发布的属性

    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive: Bool = false
    @Published var isConstrained: Bool = false

    // MARK: - Connection Type / 连接类型

    public enum ConnectionType {
        case wifi
        case cellular
        case wiredEthernet
        case unknown

        var description: String {
            switch self {
            case .wifi:
                return "Wi-Fi"
            case .cellular:
                return "Cellular / 蜂窝网络"
            case .wiredEthernet:
                return "Ethernet / 以太网"
            case .unknown:
                return "Unknown / 未知"
            }
        }

        var icon: String {
            switch self {
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

    // MARK: - Private Properties / 私有属性

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.app.networkmonitor")
    private var cancellables = Set<AnyCancellable>()

    // Retry queue for failed requests / 失败请求的重试队列
    private(set) var pendingRequests: [PendingRequest] = []

    // MARK: - Initialization / 初始化

    private init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring Control / 监控控制

    /**
     * Start network monitoring
     * 开始网络监控
     */
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }

        monitor.start(queue: queue)
    }

    /**
     * Stop network monitoring
     * 停止网络监控
     */
    func stopMonitoring() {
        monitor.cancel()
    }

    /**
     * Update connection status based on network path
     * 基于网络路径更新连接状态
     */
    private func updateConnectionStatus(_ path: NWPath) {
        // Update connection status / 更新连接状态
        let wasConnected = isConnected
        isConnected = path.status == .satisfied

        // Update connection type / 更新连接类型
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else {
            connectionType = .unknown
        }

        // Update connection properties / 更新连接属性
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        // Handle reconnection / 处理重新连接
        if !wasConnected && isConnected {
            handleReconnection()
        }

        // Log status change / 记录状态变化
        #if DEBUG
        print("""
        📡 Network Status Changed / 网络状态变化:
        - Connected / 已连接: \(isConnected)
        - Type / 类型: \(connectionType.description)
        - Expensive / 昂贵: \(isExpensive)
        - Constrained / 受限: \(isConstrained)
        """)
        #endif
    }

    // MARK: - Retry Queue Management / 重试队列管理

    /**
     * Pending request structure
     * 待处理请求结构
     */
    struct PendingRequest {
        let id: UUID
        let request: URLRequest
        let priority: RequestPriority
        let retryCount: Int
        let maxRetries: Int
        let completion: (Result<Data, Error>) -> Void
        let timestamp: Date

        enum RequestPriority: Int, Comparable {
            case low = 0
            case normal = 1
            case high = 2
            case critical = 3

            static func < (lhs: RequestPriority, rhs: RequestPriority) -> Bool {
                lhs.rawValue < rhs.rawValue
            }
        }
    }

    /**
     * Add request to retry queue
     * 添加请求到重试队列
     */
    func addToPendingQueue(
        request: URLRequest,
        priority: PendingRequest.RequestPriority = .normal,
        maxRetries: Int = 3,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let pendingRequest = PendingRequest(
            id: UUID(),
            request: request,
            priority: priority,
            retryCount: 0,
            maxRetries: maxRetries,
            completion: completion,
            timestamp: Date()
        )

        pendingRequests.append(pendingRequest)

        // Sort by priority / 按优先级排序
        pendingRequests.sort { $0.priority > $1.priority }

        #if DEBUG
        print("📝 Added request to pending queue. Total pending: \(pendingRequests.count)")
        #endif
    }

    /**
     * Handle reconnection - retry pending requests
     * 处理重新连接 - 重试待处理的请求
     */
    private func handleReconnection() {
        guard !pendingRequests.isEmpty else { return }

        #if DEBUG
        print("🔄 Network reconnected. Retrying \(pendingRequests.count) pending requests...")
        #endif

        let requestsToRetry = pendingRequests
        pendingRequests.removeAll()

        // Retry requests with delay / 延迟重试请求
        for (index, request) in requestsToRetry.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.retryRequest(request)
            }
        }
    }

    /**
     * Retry a single request
     * 重试单个请求
     */
    private func retryRequest(_ pendingRequest: PendingRequest) {
        URLSession.shared.dataTask(with: pendingRequest.request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Check if should retry / 检查是否应该重试
                    if pendingRequest.retryCount < pendingRequest.maxRetries {
                        var updatedRequest = pendingRequest
                        updatedRequest = PendingRequest(
                            id: pendingRequest.id,
                            request: pendingRequest.request,
                            priority: pendingRequest.priority,
                            retryCount: pendingRequest.retryCount + 1,
                            maxRetries: pendingRequest.maxRetries,
                            completion: pendingRequest.completion,
                            timestamp: pendingRequest.timestamp
                        )
                        self.pendingRequests.append(updatedRequest)
                    } else {
                        pendingRequest.completion(.failure(error))
                    }
                } else if let data = data {
                    pendingRequest.completion(.success(data))
                }
            }
        }.resume()
    }

    // MARK: - Utility Methods / 实用方法

    /**
     * Check if network is available for expensive operations
     * 检查网络是否可用于昂贵操作
     */
    var canPerformExpensiveOperation: Bool {
        isConnected && !isConstrained && (!isExpensive || connectionType == .wifi)
    }

    /**
     * Get human-readable connection status
     * 获取人类可读的连接状态
     */
    var statusDescription: String {
        if !isConnected {
            return "No Connection / 无连接"
        }

        var status = "\(connectionType.description)"

        if isExpensive {
            status += " (Expensive / 昂贵)"
        }

        if isConstrained {
            status += " (Constrained / 受限)"
        }

        return status
    }

    /**
     * Wait for connection with timeout
     * 等待连接（带超时）
     */
    func waitForConnection(timeout: TimeInterval = 30) async throws {
        if isConnected { return }

        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                cancellable?.cancel()
                continuation.resume(throwing: NetworkError.timeout)
            }

            cancellable = $isConnected
                .filter { $0 }
                .first()
                .sink { _ in
                    timeoutTask.cancel()
                    continuation.resume()
                }
        }
    }
}

// MARK: - Network Monitor View Modifier / 网络监控视图修饰符

/**
 * View modifier for network-aware UI
 * 网络感知 UI 的视图修饰符
 */
struct NetworkMonitorModifier: ViewModifier {
    @ObservedObject private var monitor = NetworkMonitor.shared
    let showBanner: Bool
    let autoRetry: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .disabled(!monitor.isConnected && autoRetry)

            if showBanner && !monitor.isConnected {
                NetworkStatusBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: monitor.isConnected)
    }
}

/**
 * Network status banner view
 * 网络状态横幅视图
 */
struct NetworkStatusBanner: View {
    @ObservedObject private var monitor = NetworkMonitor.shared

    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)

            Text("No Internet Connection / 无网络连接")
                .font(.caption)
                .foregroundColor(.white)

            Spacer()

            if !monitor.pendingRequests.isEmpty {
                Text("\(monitor.pendingRequests.count) pending")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.red)
        .shadow(radius: 4)
    }
}

// MARK: - View Extension / 视图扩展

extension View {
    /**
     * Make view network-aware
     * 使视图具有网络感知能力
     *
     * USAGE / 使用:
     * ```
     * ContentView()
     *     .networkAware(showBanner: true, autoRetry: true)
     * ```
     */
    func networkAware(showBanner: Bool = true, autoRetry: Bool = false) -> some View {
        modifier(NetworkMonitorModifier(showBanner: showBanner, autoRetry: autoRetry))
    }
}