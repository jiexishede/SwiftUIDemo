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
 * 🏗️ NETWORK AWARE MODIFIERS - 网络感知修饰符系统架构详解
 *
 * 📋 核心设计理念 / Core Design Philosophy:
 * ============================================
 * 这是一个将网络监控与页面状态管理完美结合的修饰符系统。
 * 通过链式调用，让视图自动响应网络状态变化，提供优雅的用户体验。
 * 
 * This is a modifier system that perfectly combines network monitoring with page state management.
 * Through chain calls, views automatically respond to network status changes, providing elegant user experience.
 *
 * 🎨 设计模式详解 / Design Patterns In Detail:
 * ============================================
 *
 * 1️⃣ DECORATOR PATTERN (装饰器模式) 📦
 *    ├─ 核心思想: 动态地给对象添加额外的职责，而不改变其接口
 *    ├─ 为什么使用: SwiftUI 的 ViewModifier 本质就是装饰器模式的实现
 *    ├─ 实现方式: 
 *    │  └─ NetworkAwareModifier 包装原始 View
 *    │  └─ 添加网络监控功能而不修改原视图代码
 *    ├─ 优势:
 *    │  └─ ✅ 可组合性: 多个修饰符可以叠加使用
 *    │  └─ ✅ 可重用性: 同一修饰符可应用于任何视图
 *    │  └─ ✅ 关注点分离: 网络逻辑与业务逻辑分离
 *    └─ 代码示例: struct NetworkAwareModifier: ViewModifier
 *
 * 2️⃣ CHAIN OF RESPONSIBILITY PATTERN (责任链模式) ⛓️
 *    ├─ 核心思想: 让多个对象都有机会处理请求，将这些对象连成一条链
 *    ├─ 为什么使用: 不同的网络状态需要不同的处理逻辑
 *    ├─ 实现方式:
 *    │  └─ .networkAware() → .onNetworkConnected() → .autoRetryOnReconnect()
 *    │  └─ 每个修饰符处理特定的网络场景
 *    ├─ 优势:
 *    │  └─ ✅ 灵活组合: 可按需组合不同的修饰符
 *    │  └─ ✅ 易于扩展: 新增修饰符不影响现有代码
 *    │  └─ ✅ 职责单一: 每个修饰符只处理一个场景
 *    └─ 代码示例: View extension 中的链式方法调用
 *
 * 3️⃣ OBSERVER PATTERN (观察者模式) 👁️
 *    ├─ 核心思想: 定义对象间的一对多依赖关系，当一个对象状态改变时，所有依赖者都会收到通知
 *    ├─ 为什么使用: 需要实时响应网络状态变化
 *    ├─ 实现方式:
 *    │  └─ @ObservedObject private var monitor = NetworkMonitor.shared
 *    │  └─ 监听 isConnected、connectionType 等属性变化
 *    ├─ 优势:
 *    │  └─ ✅ 解耦: 视图与网络监控逻辑解耦
 *    │  └─ ✅ 实时响应: 网络状态变化立即更新 UI
 *    │  └─ ✅ 自动更新: 无需手动刷新视图
 *    └─ 代码示例: onChange(of: monitor.isConnected)
 *
 * 4️⃣ STRATEGY PATTERN (策略模式) 🎯
 *    ├─ 核心思想: 定义一系列算法，把它们一个个封装起来，并且使它们可相互替换
 *    ├─ 为什么使用: 不同的错误类型需要不同的处理策略
 *    ├─ 实现方式:
 *    │  └─ analyzeError() 方法根据错误代码选择不同策略
 *    │  └─ 401 → 登录策略, 404 → 返回策略, 500 → 报告策略
 *    └─ 代码示例: UniversalNetworkStateModifier.analyzeError()
 *
 * 5️⃣ TEMPLATE METHOD PATTERN (模板方法模式) 📝
 *    ├─ 核心思想: 定义操作中的算法骨架，将某些步骤延迟到子类中实现
 *    ├─ 为什么使用: 所有网络修饰符都有相似的处理流程
 *    ├─ 实现方式:
 *    │  └─ ViewModifier.body() 定义处理模板
 *    │  └─ 具体修饰符实现各自的处理逻辑
 *    └─ 代码示例: 所有 ViewModifier 的 body 方法
 *
 * 🏛️ SOLID 原则应用 / SOLID Principles Application:
 * ============================================
 *
 * S - Single Responsibility Principle (单一职责原则) 📌
 *     └─ 每个修饰符只负责一个特定的网络状态处理
 *     └─ NetworkAwareModifier: 只负责基础网络监控
 *     └─ OfflineIndicatorModifier: 只负责显示离线指示器
 *     └─ AutoRetryOnReconnectModifier: 只负责自动重试
 *
 * O - Open/Closed Principle (开闭原则) 🔒
 *     └─ 通过 View extension 添加新功能，不修改现有代码
 *     └─ 新增修饰符不需要修改已有修饰符
 *     └─ 示例: 添加 universalNetworkState 不影响其他修饰符
 *
 * L - Liskov Substitution Principle (里氏替换原则) 🔄
 *     └─ 所有修饰符都遵循 ViewModifier 协议
 *     └─ 任何期望 ViewModifier 的地方都可以使用我们的修饰符
 *     └─ 子类型完全遵守父类型的契约
 *
 * I - Interface Segregation Principle (接口隔离原则) ✂️
 *     └─ 提供细粒度的接口，用户只使用需要的功能
 *     └─ 不强制使用所有网络功能
 *     └─ 示例: 可以只用 .networkAware() 而不用其他修饰符
 *
 * D - Dependency Inversion Principle (依赖倒置原则) 🔀
 *     └─ 依赖抽象的 NetworkMonitor 协议，而非具体实现
 *     └─ 高层模块(修饰符)不依赖低层模块(具体网络实现)
 *     └─ 通过依赖注入实现灵活性
 *
 * 🏗️ 架构层次 / Architecture Layers:
 * ============================================
 * 
 * 表现层 (Presentation Layer)
 *     ↓
 * 修饰符层 (Modifier Layer) ← 我们在这里
 *     ↓
 * 状态管理层 (State Management Layer)
 *     ↓
 * 网络监控层 (Network Monitoring Layer)
 *     ↓
 * 系统网络层 (System Network Layer)
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
 * 🔧 BASE NETWORK-AWARE MODIFIER - 基础网络感知修饰符
 * ═══════════════════════════════════════════════════════
 * 
 * 📌 职责定位 / Responsibility:
 * 这是所有网络感知功能的基础构建块，提供最基本的网络状态监控和回调机制。
 * This is the foundation building block of all network-aware features.
 *
 * 🎯 设计模式 / Design Pattern:
 * ┌─────────────────────────────────────────────────────┐
 * │ DECORATOR PATTERN (装饰器模式) 实现                   │
 * ├─────────────────────────────────────────────────────┤
 * │ • 角色: ConcreteDecorator (具体装饰器)               │
 * │ • 职责: 为 View 添加网络监控功能                      │
 * │ • 特点: 不改变原始 View 的接口和行为                  │
 * └─────────────────────────────────────────────────────┘
 *
 * 🔄 数据流 / Data Flow:
 * NetworkMonitor (Subject) 
 *     ↓ [Published 属性变化]
 * @ObservedObject (Observer)
 *     ↓ [触发视图更新]
 * onChange 修饰符
 *     ↓ [执行回调]
 * 用户自定义处理逻辑
 */
struct NetworkAwareModifier: ViewModifier {
    // 🔍 OBSERVER PATTERN (观察者模式) 实现
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 使用 @ObservedObject 属性包装器订阅 NetworkMonitor 的变化
    // 当 NetworkMonitor 的 @Published 属性变化时，自动触发视图更新
    // 💡 设计优势: 实现了视图与网络状态的自动同步，无需手动刷新
    @ObservedObject private var monitor = NetworkMonitor.shared

    // 📞 CALLBACK PATTERN (回调模式) 实现
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 使用可选闭包提供事件通知机制
    // 💡 设计决策: 使用可选类型允许用户按需订阅感兴趣的事件
    
    /// 网络连接成功时的回调 / Callback when network connected
    /// - 触发时机: isConnected 从 false 变为 true
    /// - 使用场景: 恢复数据同步、刷新内容、显示成功提示
    var onConnected: (() -> Void)?
    
    /// 网络断开时的回调 / Callback when network disconnected  
    /// - 触发时机: isConnected 从 true 变为 false
    /// - 使用场景: 暂停操作、保存本地数据、显示离线提示
    var onDisconnected: (() -> Void)?
    
    /// 连接类型变化时的回调 / Callback when connection type changes
    /// - 触发时机: connectionType 属性发生变化
    /// - 使用场景: 调整数据质量、优化传输策略、更新 UI 指示器
    var onConnectionTypeChanged: ((NetworkMonitor.ConnectionType) -> Void)?

    // 🎨 TEMPLATE METHOD PATTERN (模板方法模式) 体现
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ViewModifier 协议的 body 方法定义了修饰符的处理模板
    func body(content: Content) -> some View {
        content
            // 🔔 STATE CHANGE DETECTION (状态变化检测)
            // ─────────────────────────────────────────
            // onChange 是 SwiftUI 的响应式编程核心
            // 监听 @Published 属性的变化并执行相应操作
            .onChange(of: monitor.isConnected) { isConnected in
                // 📊 DECISION TREE (决策树)
                // ┌─ isConnected = true ──→ 执行 onConnected
                // └─ isConnected = false ─→ 执行 onDisconnected
                //
                // 💡 设计优势: 简单的二元状态，逻辑清晰
                // ⚠️ 注意事项: 回调在主线程执行，避免耗时操作
                if isConnected {
                    onConnected?()  // 使用可选链安全调用
                } else {
                    onDisconnected?()
                }
            }
            .onChange(of: monitor.connectionType) { newType in
                // 🔄 CONNECTION TYPE MONITORING (连接类型监控)
                // ─────────────────────────────────────────────
                // 监控网络类型变化 (WiFi ↔ Cellular ↔ Ethernet)
                // 💡 应用场景:
                // • WiFi → Cellular: 可能需要降低视频质量
                // • Cellular → WiFi: 可以恢复高质量传输
                // • 任何变化: 更新 UI 显示当前连接类型
                onConnectionTypeChanged?(newType)
            }
            // 🚀 自动启动说明 / Auto-start Explanation:
            // NetworkMonitor 使用单例模式，在首次访问时自动初始化
            // init() 方法中会自动调用 startMonitoring()
            // 因此这里不需要手动启动监控
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
            .onChange(of: monitor.isConnected) { isConnected in
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
 * 🌟 UNIVERSAL NETWORK STATE MODIFIER - 万能网络状态修饰符
 * ═══════════════════════════════════════════════════════════════
 *
 * 🎯 核心价值 / Core Value:
 * 这是处理所有网络和页面状态的终极解决方案 - "One Modifier to Rule Them All"
 * This is the ultimate solution for handling all network and page states.
 *
 * 🏗️ 架构设计 / Architecture Design:
 * ┌────────────────────────────────────────────────────────────┐
 * │                    用户界面层 (UI Layer)                      │
 * ├────────────────────────────────────────────────────────────┤
 * │              UniversalNetworkStateModifier                  │
 * │                        ↓                                    │
 * │    ┌──────────────┬──────────────┬──────────────┐         │
 * │    │ 网络监控      │ 状态管理      │ 错误处理      │         │
 * │    │ Network      │ State        │ Error        │         │
 * │    │ Monitoring   │ Management   │ Handling     │         │
 * │    └──────────────┴──────────────┴──────────────┘         │
 * └────────────────────────────────────────────────────────────┘
 *
 * 🎨 设计模式组合 / Design Pattern Composition:
 *
 * 1️⃣ FACADE PATTERN (外观模式) 🏛️
 *    └─ 为复杂的网络状态管理系统提供统一的简单接口
 *    └─ 隐藏内部复杂性，用户只需调用一个修饰符
 *    └─ 示例: universalNetworkState() 一个方法搞定所有
 *
 * 2️⃣ STRATEGY PATTERN (策略模式) 🎯
 *    └─ 根据不同的错误类型选择不同的处理策略
 *    └─ analyzeError() 方法实现策略选择
 *    └─ 401 → 登录策略, 404 → 返回策略, 500 → 报告策略
 *
 * 3️⃣ STATE PATTERN (状态模式) 🔄
 *    └─ 根据 ReduxPageState 的不同状态展示不同 UI
 *    └─ idle → 空视图, loading → 加载视图, failed → 错误视图
 *    └─ 状态转换自动触发 UI 更新
 *
 * 4️⃣ TEMPLATE METHOD PATTERN (模板方法模式) 📝
 *    └─ body() 方法定义处理流程模板
 *    └─ 子方法实现具体步骤
 *    └─ 确保处理流程的一致性
 *
 * 🔥 智能特性 / Intelligent Features:
 * ┌─────────────────────────────────────────────────┐
 * │ • 优先级处理: 网络断开 > 服务器错误 > 加载状态    │
 * │ • 自动重试: 网络恢复时自动重试失败的请求          │
 * │ • 智能分类: 根据错误代码自动分类并提供对应操作     │
 * │ • 视觉反馈: 模糊效果、过渡动画、状态指示器        │
 * └─────────────────────────────────────────────────┘
 */
struct UniversalNetworkStateModifier<T: Equatable>: ViewModifier {
    // 📊 STATE MANAGEMENT (状态管理)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    /// Redux 页面状态 - 核心数据源
    /// 遵循单一数据源原则 (Single Source of Truth)
    let state: ReduxPageState<T>
    
    /// 重试操作闭包 - 用户定义的重试逻辑
    /// 设计决策: 使用闭包而非协议，提供更大的灵活性
    let onRetry: () -> Void
    
    /// 自动重试开关 - 网络恢复时是否自动重试
    /// 默认开启，提供更好的用户体验
    let autoRetry: Bool
    
    /// 显示指示器开关 - 是否显示网络状态指示器
    /// 可根据 UI 需求灵活配置
    let showIndicators: Bool

    // 🔍 OBSERVER PATTERN (观察者模式)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    /// 网络监控器 - 实时监控网络状态
    /// 使用单例模式确保全局一致性
    @ObservedObject private var monitor = NetworkMonitor.shared
    
    // 🎛️ LOCAL STATE (本地状态)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━
    /// 重试标记 - 防止重复重试
    /// 使用 @State 确保视图更新时保持状态
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
        .onChange(of: monitor.isConnected) { isConnected in
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
                message: error.message.isEmpty ? "Please log in to continue / 请登录以继续" : error.message,
                primaryAction: ("Login / 登录", {
                    // Navigate to login
                    print("Navigate to login")
                })
            )

        case "NOT_FOUND", "404":
            return ErrorConfig(
                icon: "questionmark.folder",
                title: "Not Found / 未找到",
                message: error.message.isEmpty ? "The requested resource was not found / 请求的资源未找到" : error.message,
                primaryAction: ("Go Back / 返回", {
                    // Navigate back
                    print("Navigate back")
                })
            )

        case "SERVER_ERROR", "500", "502":
            return ErrorConfig(
                icon: "exclamationmark.server",
                title: "Server Error / 服务器错误",
                message: error.message.isEmpty ? "Something went wrong on our end / 服务器出现问题" : error.message,
                primaryAction: ("Report / 报告", {
                    // Report issue
                    print("Report issue")
                })
            )

        case "TIMEOUT":
            return ErrorConfig(
                icon: "clock.badge.exclamationmark",
                title: "Request Timeout / 请求超时",
                message: error.message.isEmpty ? "The request took too long / 请求耗时过长" : error.message,
                primaryAction: nil
            )
            
        case "BAD_REQUEST", "400":
            return ErrorConfig(
                icon: "exclamationmark.triangle",
                title: "Bad Request / 请求错误",
                message: error.message.isEmpty ? "Invalid request parameters / 请求参数无效" : error.message,
                primaryAction: nil
            )
            
        case "TOO_MANY_REQUESTS", "429":
            return ErrorConfig(
                icon: "gauge.badge.minus",
                title: "Too Many Requests / 请求过多",
                message: error.message.isEmpty ? "Please slow down and try again later / 请放慢速度稍后重试" : error.message,
                primaryAction: nil
            )
            
        case "MAINTENANCE", "503":
            return ErrorConfig(
                icon: "wrench.and.screwdriver",
                title: "Under Maintenance / 维护中",
                message: error.message.isEmpty ? "Service temporarily unavailable for maintenance / 服务暂时维护中" : error.message,
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