//
//  ReduxPageState.swift
//  ReduxSwiftUIDemo
//
//  Enhanced page state management for network requests
//  增强的网络请求页面状态管理
//

/**
 * 🎯 REDUX PAGE STATE - 页面状态管理核心组件
 * ═══════════════════════════════════════════════════════════════
 * 
 * 🏭 架构定位 / Architecture Position:
 * 
 * ┌─────────────────────────────────────────────┐
 * │              SwiftUI Views                  │
 * ├─────────────────────────────────────────────┤
 * │   TCA (The Composable Architecture)        │
 * ├─────────────────────────────────────────────┤
 * │        ReduxPageState (我们在这里)         │
 * ├─────────────────────────────────────────────┤
 * │          Network Service Layer              │
 * └─────────────────────────────────────────────┘
 * 
 * 🎨 设计模式详解 / Design Patterns Explained:
 * 
 * 1️⃣ STATE PATTERN (状态模式) 🎮
 * ┌─────────────────────────────────────────────┐
 * │ 核心思想:                                    │
 * │ • 将页面状态抽象为有限状态机               │
 * │ • 每个状态封装特定的数据和行为             │
 * │ • 状态转换明确、可预测                    │
 * │                                           │
 * │ 状态转换图:                                │
 * │ idle → loading → loaded/failed           │
 * │   ↑                  ↓                    │
 * │   └───────────────┘                    │
 * └─────────────────────────────────────────────┘
 * 
 * 2️⃣ ALGEBRAIC DATA TYPE (ADT - 代数数据类型) 🧮
 * ┌─────────────────────────────────────────────┐
 * │ 类型安全:                                    │
 * │ • 枚举 (enum) 提供和类型 (Sum Type)         │
 * │ • 关联值提供丰富的上下文信息              │
 * │ • 编译时保证状态完整性                    │
 * │                                           │
 * │ 例子:                                      │
 * │ case loading(LoadingType)  // 带类型信息   │
 * │ case loaded(Content, LoadMoreState)       │
 * │ case failed(FailureType, ErrorInfo)       │
 * └─────────────────────────────────────────────┘
 * 
 * 3️⃣ GENERIC PROGRAMMING (泛型编程) 🔄
 * ┌─────────────────────────────────────────────┐
 * │ 可复用性:                                   │
 * │ • Content 泛型参数适配任何数据类型         │
 * │ • Equatable 约束确保可比较性              │
 * │ • 一套状态管理适用所有页面                │
 * │                                           │
 * │ 使用示例:                                  │
 * │ ReduxPageState<[User]>    // 用户列表     │
 * │ ReduxPageState<Product>   // 产品详情     │
 * │ ReduxPageState<OrderData> // 订单数据     │
 * └─────────────────────────────────────────────┘
 * 
 * 🎯 SOLID 原则应用 / SOLID Principles Applied:
 * 
 * • SRP (单一职责): 只管理页面状态，不涉及具体业务
 * • OCP (开闭原则): 通过泛型对扩展开放，对修改关闭
 * • LSP (里氏替换): 所有子状态可互换使用
 * • ISP (接口隔离): 每个状态只暴露必要的属性
 * • DIP (依赖倒置): 依赖于抽象的 Content 类型
 * 
 * 🔥 核心功能 / Core Features:
 * • 完整的页面状态生命周期管理
 * • 细粒度的加载和错误状态分类
 * • 支持下拉刷新和加载更多
 * • 类型安全的错误处理
 * • 计算属性提供便捷状态查询
 */

import Foundation

// MARK: - Page State

/**
 * 🎯 MAIN PAGE STATE ENUM - 主页面状态枚举
 * 
 * 设计模式 / Design Patterns:
 * • STATE PATTERN: 每个 case 代表一个状态
 * • COMPOSITE PATTERN: 状态内嵌子状态
 * • TYPE SAFETY: 编译时保证状态完整性
 * 
 * 泛型约束 / Generic Constraints:
 * • Content: Equatable - 允许状态比较和 SwiftUI 优化
 * 
 * 状态机图 / State Machine Diagram:
 * 
 *     ┌──────┐
 *     │ idle │ ←─────────────────┐
 *     └───┬──┘              │
 *         │                    │
 *    [首次加载]               [重置]
 *         ↓                    │
 *   ┌─────────┐               │
 *   │ loading │               │
 *   └──┬───┬──┘               │
 *       │   │                  │
 *   [成功] [失败]                │
 *       │   │                  │
 *       ↓   ↓                  │
 *  ┌───────┐ ┌────────┐        │
 *  │ loaded │ │ failed │───────┘
 *  └───────┘ └────────┘
 */
public enum ReduxPageState<Content: Equatable>: Equatable {
    /**
     * 🛋 IDLE STATE - 空闲状态
     * 
     * 含义 / Meaning:
     * • 初始状态，未发起任何请求
     * • 或者是重置后的状态
     * 
     * 何时使用 / When to use:
     * • 页面初次加载前
     * • 用户手动重置页面
     * • 需要清空所有数据
     */
    case idle
    
    /**
     * ⏳ LOADING STATE - 加载状态
     * 
     * 关联值 / Associated Value:
     * • LoadingType: 区分不同的加载场景
     * 
     * 设计思路 / Design Thinking:
     * • 细分加载类型以提供更好的 UX
     * • 不同加载类型可以显示不同 UI
     */
    case loading(LoadingType)
    
    /**
     * ✅ LOADED STATE - 加载成功状态
     * 
     * 关联值 / Associated Values:
     * • Content: 实际加载的数据（泛型）
     * • LoadMoreState: 加载更多的子状态
     * 
     * 复合状态 / Composite State:
     * • 主状态: 数据已加载
     * • 子状态: 是否可以加载更多
     */
    case loaded(Content, LoadMoreState)
    
    /**
     * ❌ FAILED STATE - 加载失败状态
     * 
     * 关联值 / Associated Values:
     * • FailureType: 失败的场景分类
     * • ErrorInfo: 详细的错误信息
     * 
     * 错误处理策略 / Error Handling Strategy:
     * • 区分不同失败场景（初始/刷新/加载更多）
     * • 提供可操作的错误信息
     * • 支持重试机制
     */
    case failed(FailureType, ErrorInfo)

    // MARK: - Loading Type
    
    /**
     * 🔄 LOADING TYPE ENUM - 加载类型枚举
     * 
     * 设计模式 / Design Pattern: STRATEGY PATTERN
     * • 不同加载类型对应不同 UI 策略
     * 
     * UI 对应关系 / UI Mapping:
     * • initial → 全屏加载指示器
     * • refresh → 下拉刷新动画
     * • loadMore → 底部加载指示器
     */
    public enum LoadingType: Equatable {
        /**
         * 🆕 INITIAL LOADING - 首次加载
         * 
         * 场景 / Scenario:
         * • 页面第一次打开
         * • 没有任何缓存数据
         * 
         * UI 建议 / UI Suggestion:
         * • 显示全屏加载动画
         * • 可以显示骨架屏 (Skeleton)
         */
        case initial
        
        /**
         * 🔃 REFRESH LOADING - 下拉刷新
         * 
         * 场景 / Scenario:
         * • 用户主动下拉刷新
         * • 已有数据，需要更新
         * 
         * UI 建议 / UI Suggestion:
         * • 保留现有内容
         * • 顶部显示刷新指示器
         */
        case refresh
        
        /**
         * ⬇️ LOAD MORE - 加载更多
         * 
         * 场景 / Scenario:
         * • 滚动到底部
         * • 分页加载下一页
         * 
         * UI 建议 / UI Suggestion:
         * • 底部显示加载指示器
         * • 保持列表滚动位置
         */
        case loadMore
    }

    // MARK: - Load More State
    // 加载更多状态 / Load More State
    public enum LoadMoreState: Equatable {
        /// 空闲，可以加载更多 / Can load more
        case idle
        /// 正在加载更多 / Currently loading more
        case loading
        /// 没有更多数据 / No more items to load
        case noMore
        /// 加载更多失败 / Load more failed
        case failed(ErrorInfo)
        /// 数据为空 / Empty data
        case empty
    }

    // MARK: - Failure Type
    // 失败类型 / Failure Type
    public enum FailureType: Equatable {
        /// 初始加载失败 / Initial load failed
        case initial
        /// 刷新失败 / Refresh failed
        case refresh
        /// 加载更多失败 / Load more failed
        case loadMore
    }

    // MARK: - Error Info
    // 错误信息 / Error Information
    public struct ErrorInfo: Equatable {
        /// 错误代码 / Error code
        public let code: String
        /// 错误消息 / Error message
        public let message: String

        public init(code: String, message: String) {
            self.code = code
            self.message = message
        }

        // Legacy initializer for backward compatibility / 向后兼容的初始化器
        public init(type: ErrorType, description: String? = nil, code: Int? = nil) {
            self.code = String(code ?? 0)
            self.message = description ?? type.defaultDescription
        }
    }

    // MARK: - Error Type
    // 错误类型枚举 / Error Type Enum
    public enum ErrorType: Equatable {
        /// 网络连接错误 / Network connection error
        case networkConnection
        /// 请求超时 / Request timeout
        case timeout
        /// 服务器错误 / Server error
        case serverError
        /// 数据解析错误 / Data parsing error
        case parsingError
        /// 未知错误 / Unknown error
        case unknown

        /// 默认错误描述 / Default error description
        var defaultDescription: String {
            switch self {
            case .networkConnection:
                return "网络连接失败，请检查网络设置 / Network connection failed, please check your network settings"
            case .timeout:
                return "请求超时，请稍后重试 / Request timed out, please try again later"
            case .serverError:
                return "服务器错误，请稍后重试 / Server error, please try again later"
            case .parsingError:
                return "数据解析失败 / Failed to parse data"
            case .unknown:
                return "未知错误 / Unknown error occurred"
            }
        }
    }

    // MARK: - Computed Properties
    
    /**
     * 🧠 COMPUTED PROPERTIES - 计算属性
     * 
     * 设计模式 / Design Pattern: FACADE PATTERN
     * • 简化复杂状态查询
     * • 提供便捷访问接口
     * 
     * SOLID原则 / SOLID: ISP (接口隔离)
     * • 每个计算属性只暴露一个特定信息
     * • 使用者只需要关心需要的属性
     */
    
    /**
     * ⏳ IS LOADING - 是否正在加载
     * 
     * 逻辑解析 / Logic Analysis:
     * 1. 检查主状态是否为 loading
     * 2. 检查 loaded 状态下的 loadMore 子状态
     * 
     * 使用场景 / Usage Scenario:
     * • 控制加载指示器显示
     * • 禁用用户交互
     * • 防止重复请求
     */
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        if case let .loaded(_, loadMoreState) = self,
           case .loading = loadMoreState {
            return true
        }
        return false
    }

    /// 是否正在刷新 / Is refreshing
    public var isRefreshing: Bool {
        if case .loading(.refresh) = self {
            return true
        }
        return false
    }

    /// 是否正在加载更多 / Is loading more
    public var isLoadingMore: Bool {
        if case .loading(.loadMore) = self {
            return true
        }
        if case let .loaded(_, loadMoreState) = self,
           case .loading = loadMoreState {
            return true
        }
        return false
    }

    /// 是否可以加载更多 / Can load more
    public var canLoadMore: Bool {
        if case let .loaded(_, loadMoreState) = self {
            switch loadMoreState {
            case .idle, .failed:
                return true
            case .loading, .noMore, .empty:
                return false
            }
        }
        return false
    }

    /// 获取错误信息 / Get error information
    public var errorInfo: ErrorInfo? {
        switch self {
        case let .failed(_, errorInfo):
            return errorInfo
        case let .loaded(_, .failed(errorInfo)):
            return errorInfo
        default:
            return nil
        }
    }

    /// 获取错误消息 / Get error message
    public var errorMessage: String? {
        errorInfo?.message
    }
}