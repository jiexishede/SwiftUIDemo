//
//  RefreshableListFeature.swift
//  ReduxSwiftUIDemo
//
//  Feature for list with pull-to-refresh and load-more
//  支持下拉刷新和加载更多的列表功能
//

/**
 * 🎯 TCA (THE COMPOSABLE ARCHITECTURE) FEATURE - TCA 功能模块
 * ═══════════════════════════════════════════════════════════════
 * 
 * 🏭 TCA 架构解析 / TCA Architecture Analysis:
 * 
 * ┌─────────────────────────────────────────────┐
 * │                  VIEW                       │
 * │             (SwiftUI View)                  │
 * │                   ↓ ↑                       │
 * │            Send    Observe                  │
 * │            Action  State                    │
 * ├─────────────────────────────────────────────┤
 * │                 STORE                       │
 * │         (State Container)                   │
 * │                   ↓ ↑                       │
 * ├─────────────────────────────────────────────┤
 * │               REDUCER                       │
 * │         (Business Logic)                    │
 * │     State + Action → State + Effect        │
 * ├─────────────────────────────────────────────┤
 * │               EFFECTS                       │
 * │         (Side Effects)                      │
 * │     API Calls, Timers, etc.                │
 * └─────────────────────────────────────────────┘
 * 
 * 🎨 设计模式详解 / Design Patterns Explained:
 * 
 * 1️⃣ REDUX PATTERN (Redux 模式) 🔄
 * ┌─────────────────────────────────────────────┐
 * │ 核心原则:                                    │
 * │ • 单一数据源 (Single Source of Truth)      │
 * │ • State 是只读的 (State is Read-only)      │
 * │ • 纯函数修改 (Changes via Pure Functions) │
 * │                                           │
 * │ 数据流:                                    │
 * │ Action → Reducer → New State → View      │
 * │    ↑                            ↓         │
 * │    └──────── User Input ←─────┘         │
 * └─────────────────────────────────────────────┘
 * 
 * 2️⃣ COMMAND PATTERN (命令模式) 🎮
 * ┌─────────────────────────────────────────────┐
 * │ Action 封装:                               │
 * │ • 每个 Action 是一个命令                    │
 * │ • 封装了用户意图和数据                    │
 * │ • 可以被记录、撤销、重放                │
 * │                                           │
 * │ 例子:                                      │
 * │ case pullToRefresh  // 下拉刷新命令        │
 * │ case loadMore       // 加载更多命令        │
 * └─────────────────────────────────────────────┘
 * 
 * 3️⃣ OBSERVER PATTERN (观察者模式) 👀
 * ┌─────────────────────────────────────────────┐
 * │ @ObservableState:                         │
 * │ • State 变化自动通知视图                   │
 * │ • 视图订阅并自动更新                      │
 * │ • 实现响应式 UI                          │
 * └─────────────────────────────────────────────┘
 * 
 * 4️⃣ FUNCTIONAL PROGRAMMING (函数式编程) λ
 * ┌─────────────────────────────────────────────┐
 * │ Reducer 纯函数:                           │
 * │ • 相同输入总是产生相同输出                 │
 * │ • 没有副作用 (Side Effects 被隔离)      │
 * │ • 不依赖外部状态                        │
 * │ • 可测试、可预测、可调试                │
 * └─────────────────────────────────────────────┘
 * 
 * 🎯 SOLID 原则应用 / SOLID Principles Applied:
 * 
 * • SRP (单一职责): Reducer 只负责状态转换
 * • OCP (开闭原则): 通过添加新 Action 扩展功能
 * • LSP (里氏替换): 所有 Reducer 遵循相同协议
 * • ISP (接口隔离): State 和 Action 分离
 * • DIP (依赖倒置): 依赖于 TCA 抽象
 * 
 * 🔥 核心功能 / Core Features:
 * • 下拉刷新 (Pull-to-refresh)
 * • 加载更多 (Load more pagination)
 * • 错误处理 (Error handling)
 * • 空数据状态 (Empty state)
 * • 筛选功能 (Filter functionality)
 * • 加载遮罩 (Loading overlay)
 */

import ComposableArchitecture
import Foundation

// MARK: - Order Filter Option
// 订单筛选选项 / Order Filter Option
enum OrderFilterOption: Equatable {
    case all                      // 全部 / All
    case status(OrderStatus)      // 特定状态 / Specific status
    case noOrders                 // 无订单（特殊状态）/ No orders (special state)

    var displayName: String {
        switch self {
        case .all:
            return "全部订单 / All Orders"
        case .status(let status):
            return "\(status.rawValue) / \(status.englishName)"
        case .noOrders:
            return "无订单 / No Orders"
        }
    }
}

/**
 * 🎮 REDUCER MACRO - Reducer 宏标注
 * 
 * 设计模式 / Design Pattern: DECORATOR PATTERN
 * • @Reducer 宏自动生成必要的样板代码
 * • 简化 Reducer 协议实现
 * • 提供编译时类型检查
 * 
 * 生成的代码 / Generated Code:
 * • typealias State
 * • typealias Action  
 * • Reducer 协议实现
 */
@Reducer
struct RefreshableListFeature {
    /**
     * 📁 STATE DEFINITION - 状态定义
     * 
     * 设计模式 / Design Pattern: VALUE TYPE + IMMUTABILITY
     * • struct 确保值语义
     * • Equatable 支持状态比较和 SwiftUI 优化
     * • @ObservableState 实现自动观察
     * 
     * SOLID原则 / SOLID: SRP (单一职责)
     * • State 只存储数据，不包含业务逻辑
     * • 所有逻辑在 Reducer 中处理
     */
    @ObservableState
    struct State: Equatable {
        /// 页面状态 / Page state
        var pageState: ReduxPageState<ListData<MockItem>> = .idle
        /// 是否模拟错误 / Simulate error flag
        var simulateError: Bool = false
        /// 是否模拟空数据 / Simulate empty data flag
        var simulateEmpty: Bool = false
        /// 刷新错误信息（用于显示错误提示条）/ Refresh error info (for error banner)
        var refreshErrorInfo: ReduxPageState<ListData<MockItem>>.ErrorInfo?
        /// 当前选择的筛选选项 / Current selected filter option
        var selectedFilter: OrderFilterOption = .all
        /// 是否显示筛选下拉菜单 / Show filter dropdown
        var showFilterDropdown: Bool = false
        /// 是否正在切换筛选 / Is changing filter
        var isChangingFilter: Bool = false
        /// 是否显示全屏加载遮罩 / Show full screen loading overlay
        var showLoadingOverlay: Bool = false

        // MARK: - Computed Properties
        // 计算属性 / Computed Properties

        /// 获取列表项 / Get list items
        var items: [MockItem] {
            if case let .loaded(data, _) = pageState {
                return data.items
            }
            return []
        }

        /// 是否显示空视图 / Should show empty view
        var showEmptyView: Bool {
            if case let .loaded(data, _) = pageState {
                return data.isEmpty
            }
            return false
        }

        /// 是否显示初始加载 / Should show initial loading
        var showInitialLoading: Bool {
            if case .loading(.initial) = pageState {
                return true
            }
            return false
        }

        /// 是否显示初始错误 / Should show initial error
        var showInitialError: Bool {
            if case .failed(.initial, _) = pageState {
                return true
            }
            return false
        }
    }

    /**
     * 🎮 ACTION ENUM - 动作枚举
     * 
     * 设计模式 / Design Patterns:
     * • COMMAND PATTERN: 每个 case 是一个命令
     * • ALGEBRAIC DATA TYPE: 关联值携带上下文
     * • TYPE SAFETY: 编译时保证完整性
     * 
     * Action 分类 / Action Categories:
     * 1. 生命周期动作: onAppear
     * 2. 用户交互动作: pullToRefresh, loadMore, retry
     * 3. 数据响应动作: dataResponse
     * 4. UI 状态动作: toggleFilterDropdown
     * 5. 调试动作: toggleErrorSimulation, toggleEmptySimulation
     */
    enum Action {
        /**
         * 🚀 ON APPEAR - 页面出现
         * 触发时机: View.onAppear
         * 职责: 初始化加载数据
         */
        case onAppear
        
        /**
         * 🔃 PULL TO REFRESH - 下拉刷新
         * 触发时机: 用户下拉手势
         * 职责: 重新加载第一页数据
         */
        case pullToRefresh
        
        /**
         * ⬇️ LOAD MORE - 加载更多
         * 触发时机: 滚动到底部
         * 职责: 加载下一页数据
         */
        case loadMore
        
        /**
         * 📡 DATA RESPONSE - 数据响应
         * 
         * 关联值 / Associated Values:
         * • Result: 成功或失败的数据
         * • isLoadMore: 是否是加载更多
         * • previousData: 之前的数据（用于回退）
         * 
         * 设计思路:
         * • 封装异步结果
         * • 区分不同加载场景
         * • 支持错误恢复
         */
        case dataResponse(Result<ListData<MockItem>, Error>, isLoadMore: Bool, previousData: ListData<MockItem>?)
        
        /**
         * 🔄 TOGGLE ERROR SIMULATION - 切换错误模拟
         * 用途: 测试错误处理
         */
        case toggleErrorSimulation
        
        /**
         * 💭 TOGGLE EMPTY SIMULATION - 切换空数据模拟
         * 用途: 测试空状态 UI
         */
        case toggleEmptySimulation
        
        /**
         * 🔁 RETRY - 重试
         * 触发时机: 错误页面的重试按钮
         * 职责: 重新发起失败的请求
         */
        case retry
        
        /**
         * 📂 TOGGLE FILTER DROPDOWN - 切换筛选下拉菜单
         * UI 状态管理
         */
        case toggleFilterDropdown
        
        /**
         * 🎯 SELECT FILTER - 选择筛选项
         * 关联值: 选中的筛选选项
         */
        case selectFilter(OrderFilterOption)
    }

    // 移除 @Dependency 以支持 iOS 15 / Remove @Dependency for iOS 15 support

    /**
     * 🎭 REDUCER BODY - Reducer 主体
     * 
     * 设计模式 / Design Patterns:
     * • PURE FUNCTION: Reducer 是纯函数
     * • PATTERN MATCHING: switch 穷举所有 Action
     * • EFFECT PATTERN: 副作用被封装为 Effect
     * 
     * 函数签名 / Function Signature:
     * (inout State, Action) -> Effect<Action>
     * 
     * 工作流程 / Workflow:
     * 1. 接收 Action
     * 2. 根据 Action 更新 State
     * 3. 返回 Effect (副作用)
     * 4. Effect 完成后发送新 Action
     * 
     * SOLID原则应用:
     * • SRP: 每个 case 处理单一职责
     * • OCP: 添加新 Action 不影响现有代码
     * • DIP: 依赖 NetworkRequestManager 抽象
     */
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                /**
                 * 🚀 INITIAL LOAD LOGIC - 初始加载逻辑
                 * 
                 * 状态机转换 / State Machine:
                 * idle → loading(initial) → loaded/failed
                 * 
                 * 防御性编程 / Defensive Programming:
                 * • guard 确保只在 idle 状态加载
                 * • 避免重复加载
                 * 
                 * 副作用处理 / Side Effects:
                 * • .run 创建异步 Effect
                 * • 捕获必要的 state 值避免循环引用
                 */
                // 仅在空闲状态时加载 / Only load when idle
                guard case .idle = state.pageState else { return .none }
                state.pageState = .loading(.initial)
                // 初始加载时显示遮罩层 / Show overlay during initial load
                state.showLoadingOverlay = true

                return .run { [simulateEmpty = state.simulateEmpty, simulateError = state.simulateError, filter = state.selectedFilter] send in
                    let requestType: NetworkRequestManager.RequestResult = simulateError ? .failure : (simulateEmpty ? .successWithEmpty : .success)

                    do {
                        let data = try await NetworkRequestManager.simulateListRequest(
                            page: 0,
                            requestType: requestType,
                            filterOption: filter
                        )
                        await send(.dataResponse(.success(data), isLoadMore: false, previousData: nil))
                    } catch {
                        await send(.dataResponse(.failure(error), isLoadMore: false, previousData: nil))
                    }
                }

            case .pullToRefresh:
                // 如果正在加载，不处理 / Don't handle if already loading
                guard !state.pageState.isLoading else { return .none }

                // 下拉刷新时显示遮罩层 / Show overlay during pull-to-refresh
                state.showLoadingOverlay = true

                // 清除之前的刷新错误信息 / Clear previous refresh error info
                state.refreshErrorInfo = nil

                // 保存当前数据（如果有）/ Save current data (if any)
                var previousData: ListData<MockItem>? = nil
                if case let .loaded(data, _) = state.pageState {
                    previousData = data
                }

                // 刷新时重置为loading状态，这样会从第一页开始 / Reset to loading state for refresh, starting from page 1
                // 如果之前有数据，设置为refresh类型 / If had data before, set as refresh type
                if previousData != nil {
                    state.pageState = .loading(.refresh)
                } else if case .failed = state.pageState {
                    state.pageState = .loading(.refresh)
                } else {
                    state.pageState = .loading(.initial)
                }

                return .run { [simulateEmpty = state.simulateEmpty, simulateError = state.simulateError, previousData, filter = state.selectedFilter] send in
                    let requestType: NetworkRequestManager.RequestResult = simulateError ? .failure : (simulateEmpty ? .successWithEmpty : .success)

                    do {
                        // 刷新时始终从第0页开始 / Always start from page 0 when refreshing
                        let data = try await NetworkRequestManager.simulateListRequest(
                            page: 0,
                            requestType: requestType,
                            filterOption: filter
                        )
                        await send(.dataResponse(.success(data), isLoadMore: false, previousData: previousData))
                    } catch {
                        await send(.dataResponse(.failure(error), isLoadMore: false, previousData: previousData))
                    }
                }

            case .loadMore:
                // 检查是否可以加载更多 / Check if can load more
                guard case let .loaded(data, loadMoreState) = state.pageState,
                      data.hasMorePages else {
                    return .none
                }

                // 允许从idle和failed状态加载更多 / Allow load more from idle and failed states
                switch loadMoreState {
                case .idle, .failed:
                    state.pageState = .loaded(data, .loading)
                    // 加载更多时显示遮罩层 / Show overlay during load more
                    state.showLoadingOverlay = true
                case .loading, .noMore, .empty:
                    return .none
                }

                return .run { [nextPage = data.currentPage + 1, simulateError = state.simulateError, filter = state.selectedFilter] send in
                    let requestType: NetworkRequestManager.RequestResult = simulateError ? .failure : .success

                    do {
                        let newData = try await NetworkRequestManager.simulateListRequest(
                            page: nextPage,
                            requestType: requestType,
                            filterOption: filter
                        )
                        await send(.dataResponse(.success(newData), isLoadMore: true, previousData: nil))
                    } catch {
                        await send(.dataResponse(.failure(error), isLoadMore: true, previousData: nil))
                    }
                }

            case let .dataResponse(result, isLoadMore, _):
                // 数据响应后隐藏遮罩层 / Hide overlay after data response
                state.showLoadingOverlay = false
                state.isChangingFilter = false

                switch result {
                case let .success(newData):
                    // 清除刷新错误信息 / Clear refresh error info
                    state.refreshErrorInfo = nil

                    if isLoadMore {
                        // 追加新数据 / Append new items for load more
                        if case let .loaded(existingData, _) = state.pageState {
                            var combinedData = existingData
                            combinedData.items.append(contentsOf: newData.items)
                            combinedData.currentPage = newData.currentPage
                            combinedData.hasMorePages = newData.hasMorePages

                            let loadMoreState: ReduxPageState<ListData<MockItem>>.LoadMoreState =
                                newData.hasMorePages ? .idle : .noMore
                            state.pageState = .loaded(combinedData, loadMoreState)
                        }
                    } else {
                        // 替换数据（初始加载或刷新）/ Replace data for initial load or refresh
                        // 刷新会重置所有数据，从第一页开始 / Refresh resets all data, starting from page 1
                        let loadMoreState: ReduxPageState<ListData<MockItem>>.LoadMoreState =
                            newData.hasMorePages ? .idle : .noMore
                        state.pageState = .loaded(newData, loadMoreState)
                    }

                case let .failure(error):
                    // 创建错误信息 / Create error info
                    let errorInfo = ReduxPageState<ListData<MockItem>>.ErrorInfo(
                        type: .networkConnection,
                        description: error.localizedDescription
                    )

                    if isLoadMore {
                        // 保留现有数据，显示加载更多错误 / Keep existing data, show load more error
                        if case let .loaded(data, _) = state.pageState {
                            state.pageState = .loaded(data, .failed(errorInfo))
                        }
                    } else {
                        // 根据当前状态确定失败类型 / Determine failure type based on current state
                        // 检查是否是刷新操作 / Check if it's a refresh operation
                        let wasRefreshing = if case .loading(.refresh) = state.pageState { true } else { false }

                        if wasRefreshing {
                            // 刷新失败时清空数据，显示错误视图 / Clear data on refresh failure, show error view
                            state.pageState = .failed(.refresh, errorInfo)
                            state.refreshErrorInfo = errorInfo
                        } else {
                            // 初始加载失败 / Initial load failed
                            state.pageState = .failed(.initial, errorInfo)
                        }
                    }
                }
                return .none

            case .toggleErrorSimulation:
                state.simulateError.toggle()
                return .none

            case .toggleEmptySimulation:
                state.simulateEmpty.toggle()
                state.simulateError = false  // 重置错误模拟 / Reset error simulation
                return .none

            case .retry:
                // 重试初始加载失败的情况 / Retry for initial load failure
                if case .failed(.initial, _) = state.pageState {
                    state.pageState = .idle
                    // 重试时也显示遮罩层 / Show overlay during retry
                    state.showLoadingOverlay = true
                    return .send(.onAppear)
                } else if case .failed(.refresh, _) = state.pageState {
                    // 刷新失败后重试 / Retry after refresh failure
                    state.pageState = .idle
                    state.showLoadingOverlay = true
                    return .send(.onAppear)
                }
                return .none

            case .toggleFilterDropdown:
                state.showFilterDropdown.toggle()
                return .none

            case let .selectFilter(filter):
                // 选择新的筛选条件 / Select new filter
                state.selectedFilter = filter
                state.showFilterDropdown = false

                // 切换筛选时显示加载遮罩 / Show loading overlay when changing filter
                state.isChangingFilter = true
                state.showLoadingOverlay = true  // 使用主遮罩层 / Use main loading overlay

                // 重新加载数据 / Reload data with new filter
                state.pageState = .idle
                return .send(.onAppear)
            }
        }
    }
}