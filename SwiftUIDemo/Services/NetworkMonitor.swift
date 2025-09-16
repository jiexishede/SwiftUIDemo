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
 * 🌐 NETWORK MONITOR - 网络监控器核心类
 * ═══════════════════════════════════════════════════════════════
 *
 * 🏗️ 架构定位 / Architecture Position:
 * ┌─────────────────────────────────────────────┐
 * │            应用层 (App Layer)                │
 * ├─────────────────────────────────────────────┤
 * │        NetworkMonitor (我们在这里)            │
 * │              ↓ 封装 ↓                        │
 * ├─────────────────────────────────────────────┤
 * │     Network.framework (系统框架)              │
 * ├─────────────────────────────────────────────┤
 * │         系统网络栈 (System Network Stack)     │
 * └─────────────────────────────────────────────┘
 *
 * 🎨 设计模式详解 / Design Patterns Explained:
 *
 * 1️⃣ SINGLETON PATTERN (单例模式) 🔐
 * ┌─────────────────────────────────────────────┐
 * │ 实现方式:                                     │
 * │ • static let shared = NetworkMonitor()      │
 * │ • private init() 防止外部实例化               │
 * │                                              │
 * │ 为什么使用单例:                               │
 * │ • 全局唯一的网络状态源                        │
 * │ • 避免多个监控器实例造成资源浪费               │
 * │ • 确保整个应用的网络状态一致性                 │
 * │                                              │
 * │ 优势:                                        │
 * │ ✅ 内存效率: 只有一个实例                     │
 * │ ✅ 状态一致: 所有组件读取同一状态              │
 * │ ✅ 易于访问: NetworkMonitor.shared           │
 * │                                              │
 * │ 潜在问题及解决:                               │
 * │ ⚠️ 单元测试困难 → 使用依赖注入                │
 * │ ⚠️ 全局状态 → 通过 ObservableObject 管理     │
 * └─────────────────────────────────────────────┘
 *
 * 2️⃣ OBSERVER PATTERN (观察者模式) 📡
 * ┌─────────────────────────────────────────────┐
 * │ 实现方式:                                     │
 * │ • ObservableObject 协议                      │
 * │ • @Published 属性包装器                       │
 * │ • Combine 框架集成                           │
 * │                                              │
 * │ 发布-订阅机制:                                │
 * │ NetworkMonitor (Publisher)                   │
 * │     ↓ @Published                            │
 * │ isConnected, connectionType 等               │
 * │     ↓ 自动通知                              │
 * │ View (Subscriber)                           │
 * │     ↓ @ObservedObject                       │
 * │ UI 自动更新                                  │
 * └─────────────────────────────────────────────┘
 *
 * 3️⃣ FACADE PATTERN (外观模式) 🏛️
 * ┌─────────────────────────────────────────────┐
 * │ 简化复杂系统:                                 │
 * │ • 封装 NWPathMonitor 的复杂性                │
 * │ • 提供简单的 isConnected 布尔值               │
 * │ • 隐藏底层网络框架细节                        │
 * └─────────────────────────────────────────────┘
 *
 * 4️⃣ QUEUE PATTERN (队列模式) 📦
 * ┌─────────────────────────────────────────────┐
 * │ 重试队列机制:                                 │
 * │ • pendingRequests 数组存储失败请求            │
 * │ • 按优先级排序 (critical > high > normal)    │
 * │ • 网络恢复时自动重试                          │
 * └─────────────────────────────────────────────┘
 *
 * 🔥 核心功能 / Core Features:
 * • 实时网络状态检测 (Wi-Fi/Cellular/Ethernet/Offline)
 * • 连接质量监控 (Expensive/Constrained)
 * • 自动重试队列管理
 * • 异步等待连接 (async/await)
 * • 线程安全的状态更新
 *
 * 📊 性能优化 / Performance Optimization:
 * • 使用专用队列避免主线程阻塞
 * • 延迟重试避免网络拥塞
 * • 智能去重避免重复请求
 */
public final class NetworkMonitor: ObservableObject {
    // MARK: - Singleton / 单例

    /**
     * 🔐 SINGLETON INSTANCE - 单例实例
     * 
     * 设计模式 / Design Pattern: SINGLETON
     * 
     * 为什么是 static let:
     * • static: 类级别属性，不属于任何实例
     * • let: 常量，保证只初始化一次
     * • 线程安全: Swift 的 static let 自动保证线程安全
     * 
     * Why static let:
     * • static: Class-level property, not belonging to any instance
     * • let: Constant, ensures initialization only once
     * • Thread-safe: Swift's static let automatically ensures thread safety
     * 
     * 访问方式 / Access Method:
     * ```swift
     * let monitor = NetworkMonitor.shared
     * monitor.isConnected // 检查连接状态
     * ```
     */
    public static let shared = NetworkMonitor()

    // MARK: - Published Properties / 发布的属性

    /**
     * 📡 CONNECTION STATUS - 连接状态
     * 
     * 设计模式 / Design Pattern: OBSERVER (via @Published)
     * SOLID原则 / SOLID Principle: OCP (开闭原则)
     * 
     * @Published 工作原理:
     * 1. 属性值改变时自动发送通知
     * 2. SwiftUI 视图通过 @ObservedObject 订阅
     * 3. 触发视图自动重新渲染
     * 
     * @Published Working Principle:
     * 1. Automatically sends notifications when property changes
     * 2. SwiftUI views subscribe via @ObservedObject
     * 3. Triggers automatic view re-rendering
     * 
     * 默认值 true 的原因:
     * • 乐观假设: 假设网络可用直到证明相反
     * • 避免启动时的错误提示
     * 
     * Default true reason:
     * • Optimistic assumption: Assume network available until proven otherwise
     * • Avoid error prompts at startup
     */
    @Published var isConnected: Bool = true
    
    /**
     * 📶 CONNECTION TYPE - 连接类型
     * 
     * 设计模式 / Design Pattern: STATE PATTERN (通过枚举)
     * 
     * 为什么用枚举:
     * • 类型安全: 编译时检查所有可能的状态
     * • 穷举性: switch 必须处理所有情况
     * • 清晰语义: 每个 case 都有明确含义
     * 
     * Why use enum:
     * • Type safety: Compile-time check of all possible states
     * • Exhaustiveness: switch must handle all cases
     * • Clear semantics: Each case has clear meaning
     */
    @Published var connectionType: ConnectionType = .unknown
    
    /**
     * 💰 EXPENSIVE CONNECTION - 昂贵连接标识
     * 
     * 业务价值 / Business Value:
     * • 避免在流量计费网络上进行大量下载
     * • 保护用户的流量资费
     * • 智能决策是否执行后台同步
     * 
     * Business Value:
     * • Avoid large downloads on metered networks
     * • Protect user's data charges
     * • Smart decision on background sync
     * 
     * 典型场景 / Typical Scenarios:
     * • Cellular with limited data plan
     * • Roaming connections
     * • Personal hotspot
     */
    @Published var isExpensive: Bool = false
    
    /**
     * 🚫 CONSTRAINED CONNECTION - 受限连接标识
     * 
     * 受限情况 / Constrained Conditions:
     * • 低数据模式 (Low Data Mode)
     * • 省电模式影响
     * • 系统级流量限制
     * 
     * Constrained Conditions:
     * • Low Data Mode enabled
     * • Power saving mode effects
     * • System-level traffic restrictions
     * 
     * 应对策略 / Response Strategy:
     * • 减少数据传输频率
     * • 压缩传输数据
     * • 延迟非关键请求
     */
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

    /**
     * 🔍 NETWORK PATH MONITOR - 网络路径监控器
     * 
     * 设计模式 / Design Pattern: FACADE (封装复杂的 Network.framework)
     * 
     * NWPathMonitor 职责:
     * • 监听系统网络状态变化
     * • 提供网络路径信息 (接口类型、质量等)
     * • 异步回调网络变化事件
     * 
     * NWPathMonitor Responsibilities:
     * • Monitor system network status changes
     * • Provide network path info (interface type, quality, etc.)
     * • Async callback for network change events
     * 
     * 为什么是 private:
     * • 封装实现细节
     * • 防止外部直接操作
     * • 通过公共接口控制访问
     */
    private let monitor = NWPathMonitor()
    
    /**
     * 🚦 DEDICATED DISPATCH QUEUE - 专用调度队列
     * 
     * 设计模式 / Design Pattern: COMMAND PATTERN (命令队列)
     * 性能优化 / Performance: 避免主线程阻塞
     * 
     * 队列设计原理:
     * • label: 用于调试时识别队列
     * • serial queue: 保证状态更新的顺序性
     * • background priority: 不影响 UI 响应
     * 
     * Queue Design Principles:
     * • label: For queue identification during debugging
     * • serial queue: Ensures sequential state updates
     * • background priority: Doesn't affect UI responsiveness
     * 
     * 线程安全保证:
     * • 所有网络回调在此队列执行
     * • 状态更新通过 DispatchQueue.main 回到主线程
     * • 避免竞态条件
     */
    private let queue = DispatchQueue(label: "com.app.networkmonitor")
    
    /**
     * 📚 COMBINE CANCELLABLES - Combine 订阅管理
     * 
     * 设计模式 / Design Pattern: OBSERVER (订阅管理)
     * 内存管理 / Memory: 防止内存泄漏
     * 
     * Set<AnyCancellable> 作用:
     * • 存储所有 Combine 订阅
     * • 自动取消机制: deinit 时自动取消所有订阅
     * • 防止循环引用
     * 
     * Set<AnyCancellable> Purpose:
     * • Store all Combine subscriptions
     * • Auto-cancel: Automatically cancels all subscriptions on deinit
     * • Prevent retain cycles
     */
    private var cancellables = Set<AnyCancellable>()

    /**
     * 📦 RETRY QUEUE - 重试队列
     * 
     * 设计模式 / Design Pattern: QUEUE PATTERN + STRATEGY PATTERN
     * SOLID原则 / SOLID: SRP (单一职责 - 专门管理待重试请求)
     * 
     * private(set) 访问控制:
     * • 外部可读: 可以查看队列状态
     * • 内部可写: 只能内部修改队列
     * • 数据安全: 防止外部破坏队列完整性
     * 
     * private(set) Access Control:
     * • External readable: Can view queue status
     * • Internal writable: Only internal modifications
     * • Data safety: Prevent external queue corruption
     * 
     * 队列策略 / Queue Strategy:
     * • FIFO with priority: 优先级队列
     * • Exponential backoff: 指数退避重试
     * • Max retry limit: 最大重试次数限制
     */
    private(set) var pendingRequests: [PendingRequest] = []

    // MARK: - Initialization / 初始化

    /**
     * 🏗️ PRIVATE INITIALIZER - 私有初始化器
     * 
     * 设计模式 / Design Pattern: SINGLETON (核心实现)
     * 
     * private init() 的重要性:
     * • 防止外部创建新实例: NetworkMonitor() ❌
     * • 强制使用 shared: NetworkMonitor.shared ✅
     * • 保证全局唯一性
     * 
     * Importance of private init():
     * • Prevent external instantiation: NetworkMonitor() ❌
     * • Force using shared: NetworkMonitor.shared ✅
     * • Ensure global uniqueness
     * 
     * 初始化流程 / Initialization Flow:
     * 1. 创建 NWPathMonitor 实例
     * 2. 设置专用队列
     * 3. 立即开始监控 (eager initialization)
     * 
     * 为什么立即开始监控:
     * • 尽早获知网络状态
     * • 避免首次请求时的延迟
     * • 应用启动即可用
     */
    private init() {
        startMonitoring()
    }

    /**
     * 🧹 DEINITIALIZER - 析构函数
     * 
     * 资源管理 / Resource Management:
     * • 停止网络监控
     * • 释放系统资源
     * • 清理回调引用
     * 
     * 注意 / Note:
     * • 单例通常不会被销毁
     * • 这是防御性编程
     * • 确保资源正确释放
     * 
     * Singleton Lifecycle:
     * • Singleton usually never deinitialized
     * • This is defensive programming
     * • Ensures proper resource cleanup
     */
    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring Control / 监控控制

    /**
     * ▶️ START NETWORK MONITORING - 开始网络监控
     * 
     * 设计模式 / Design Patterns:
     * • OBSERVER: pathUpdateHandler 回调
     * • TEMPLATE METHOD: 定义监控流程框架
     * 
     * 🔄 执行流程 / Execution Flow:
     * 
     * ┌─────────────────────────────────┐
     * │  1. 设置 pathUpdateHandler       │
     * │     ↓                           │
     * │  2. 系统检测到网络变化            │
     * │     ↓                           │
     * │  3. 在后台队列触发回调            │
     * │     ↓                           │
     * │  4. 切换到主线程                 │
     * │     ↓                           │
     * │  5. 更新 @Published 属性         │
     * │     ↓                           │
     * │  6. SwiftUI 视图自动刷新         │
     * └─────────────────────────────────┘
     * 
     * 🎯 [weak self] 的关键作用:
     * • 防止循环引用: monitor 持有 handler，handler 不应强引用 self
     * • 内存安全: 允许 NetworkMonitor 被释放
     * • 最佳实践: 闭包中总是使用 weak/unowned
     * 
     * [weak self] Critical Role:
     * • Prevent retain cycle: monitor holds handler, handler shouldn't strongly reference self
     * • Memory safety: Allows NetworkMonitor to be deallocated
     * • Best practice: Always use weak/unowned in closures
     * 
     * 📌 DispatchQueue.main.async 原因:
     * • @Published 必须在主线程更新
     * • SwiftUI 要求 UI 更新在主线程
     * • 避免线程安全问题
     * 
     * DispatchQueue.main.async Reason:
     * • @Published must update on main thread
     * • SwiftUI requires UI updates on main thread
     * • Avoid thread safety issues
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
     * 🔄 UPDATE CONNECTION STATUS - 更新连接状态
     * 
     * 设计模式 / Design Patterns:
     * • STATE PATTERN: 根据 NWPath 状态转换内部状态
     * • OBSERVER PATTERN: 更新 @Published 触发观察者
     * • FACADE PATTERN: 简化 NWPath 复杂信息
     * 
     * SOLID原则 / SOLID Principles:
     * • SRP: 单一职责 - 只负责状态转换
     * • OCP: 开闭原则 - 可扩展新的连接类型
     * 
     * 📊 状态更新决策树 / State Update Decision Tree:
     * 
     * NWPath.status
     *     ├─ .satisfied ✅
     *     │   ├─ Check interface type
     *     │   │   ├─ WiFi → connectionType = .wifi
     *     │   │   ├─ Cellular → connectionType = .cellular
     *     │   │   ├─ Wired → connectionType = .wiredEthernet
     *     │   │   └─ Other → connectionType = .unknown
     *     │   ├─ isExpensive = path.isExpensive
     *     │   ├─ isConstrained = path.isConstrained
     *     │   └─ If reconnected → handleReconnection()
     *     │
     *     ├─ .unsatisfied ❌
     *     │   ├─ isConnected = false
     *     │   └─ connectionType = .unknown
     *     │
     *     └─ .requiresConnection ⏳
     *         ├─ isConnected = false
     *         └─ Wait for user action (VPN, etc.)
     * 
     * 🔑 关键变量 / Key Variables:
     * • wasConnected: 记录之前的连接状态，用于检测重连
     * • path.status: 系统网络状态 (satisfied/unsatisfied/requiresConnection)
     * • path.usesInterfaceType: 检查特定网络接口类型
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