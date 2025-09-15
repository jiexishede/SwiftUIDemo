//
//  NetworkErrorDemoFeature.swift
//  SwiftUIDemo
//
//  Network error handling demo with TCA reducer
//  网络错误处理演示与 TCA reducer
//

import ComposableArchitecture
import Foundation

/**
 * NETWORK ERROR DEMO FEATURE - 网络错误演示功能
 * 
 * PURPOSE / 目的:
 * - Demonstrate comprehensive network error handling
 * - 演示全面的网络错误处理
 * - Show different error states and recovery options
 * - 展示不同的错误状态和恢复选项
 * - Integrate with existing ReduxPageState pattern
 * - 与现有的 ReduxPageState 模式集成
 * 
 * FEATURES / 功能:
 * 1. Simulate various HTTP error codes (404, 401, 500, etc.)
 *    模拟各种 HTTP 错误代码（404、401、500 等）
 * 2. Handle successful but empty responses (200 with empty list)
 *    处理成功但空的响应（200 但列表为空）
 * 3. Provide retry and refresh functionality
 *    提供重试和刷新功能
 * 4. Network timeout simulation
 *    网络超时模拟
 * 
 * DESIGN PATTERN / 设计模式:
 * - Uses TCA (The Composable Architecture) pattern
 * - 使用 TCA（可组合架构）模式
 * - State management with ReduxPageState
 * - 使用 ReduxPageState 进行状态管理
 */

@Reducer
struct NetworkErrorDemoFeature {
    // MARK: - State / 状态
    
    struct State: Equatable {
        var pageState: ReduxPageState<ListData<MockItem>> = .idle
        var errorType: NetworkError?
        var selectedScenario: NetworkScenario = .success
        var retryCount: Int = 0
        var lastRequestTime: Date?
        
        // Mock data structure / 模拟数据结构
        struct MockItem: Equatable, Identifiable {
            let id: UUID
            let title: String
            let subtitle: String
            let imageUrl: String?
            
            init(title: String, subtitle: String, imageUrl: String? = nil) {
                self.id = UUID()
                self.title = title
                self.subtitle = subtitle
                self.imageUrl = imageUrl
            }
        }
        
        // Computed properties / 计算属性
        var items: [MockItem] {
            if case let .loaded(data, _) = pageState {
                return data.items
            }
            return []
        }
        
        var isRefreshing: Bool {
            pageState.isRefreshing
        }
    }
    
    // MARK: - Action / 动作
    
    enum Action: Equatable {
        // User actions / 用户动作
        case selectScenario(NetworkScenario)
        case fetchData
        case refresh
        case retry
        case clearError
        
        // System responses / 系统响应
        case dataResponse(Result<ListData<State.MockItem>, NetworkError>)
        case updatePageState(ReduxPageState<ListData<State.MockItem>>)
    }
    
    // MARK: - Network Scenarios / 网络场景
    
    enum NetworkScenario: String, CaseIterable, Equatable {
        case success = "Success with Data / 成功有数据"
        case successEmpty = "Success but Empty / 成功但空"
        case notFound = "404 Not Found / 404 未找到"
        case unauthorized = "401 Unauthorized / 401 未授权"
        case forbidden = "403 Forbidden / 403 禁止访问"
        case serverError = "500 Server Error / 500 服务器错误"
        case timeout = "Network Timeout / 网络超时"
        case noConnection = "No Connection / 无连接"
        case rateLimited = "429 Rate Limited / 429 限流"
        case badRequest = "400 Bad Request / 400 错误请求"
        
        var description: String {
            return self.rawValue
        }
        
        // Convert scenario to network error / 将场景转换为网络错误
        var toError: NetworkError? {
            switch self {
            case .success, .successEmpty:
                return nil
            case .notFound:
                return .notFound
            case .unauthorized:
                return .unauthorized
            case .forbidden:
                return .forbidden
            case .serverError:
                return .serverError(500)
            case .timeout:
                return .timeout
            case .noConnection:
                return .noConnection
            case .rateLimited:
                return .rateLimited
            case .badRequest:
                return .badRequest("Invalid request parameters")
            }
        }
    }
    
    // MARK: - Dependencies / 依赖
    
    @Dependency(\.continuousClock) var clock
    
    // MARK: - Reducer Body / Reducer 主体
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // MARK: Select Scenario / 选择场景
            case let .selectScenario(scenario):
                state.selectedScenario = scenario
                state.errorType = nil
                state.pageState = .idle
                state.retryCount = 0
                return .none
                
            // MARK: Fetch Data / 获取数据
            case .fetchData:
                state.pageState = .loading(.initial)
                state.lastRequestTime = Date()
                
                return .run { [scenario = state.selectedScenario] send in
                    // Simulate network delay / 模拟网络延迟
                    try await clock.sleep(for: .seconds(1.5))
                    
                    // Generate response based on scenario / 根据场景生成响应
                    let result = await NetworkErrorDemoFeature.simulateNetworkRequest(scenario: scenario)
                    await send(.dataResponse(result))
                }
                
            // MARK: Refresh / 刷新
            case .refresh:
                state.pageState = .loading(.refresh)
                state.errorType = nil
                
                return .run { [scenario = state.selectedScenario] send in
                    // Simulate refresh delay / 模拟刷新延迟
                    try await clock.sleep(for: .seconds(1))
                    
                    // Generate response / 生成响应
                    let result = await NetworkErrorDemoFeature.simulateNetworkRequest(scenario: scenario)
                    await send(.dataResponse(result))
                }
                
            // MARK: Retry / 重试
            case .retry:
                state.retryCount += 1
                state.errorType = nil
                state.pageState = .loading(.initial)
                
                // Simulate retry with potential success after 3 attempts
                // 模拟重试，3 次尝试后可能成功
                let shouldSucceed = state.retryCount >= 3
                
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    
                    if shouldSucceed {
                        // Success after retries / 重试后成功
                        let items = NetworkErrorDemoFeature.generateMockItems(count: 5)
                        let data = ListData(items: items, currentPage: 0, hasMorePages: false)
                        await send(.dataResponse(.success(data)))
                    } else {
                        // Continue failing / 继续失败
                        await send(.dataResponse(.failure(.serverError(500))))
                    }
                }
                
            // MARK: Clear Error / 清除错误
            case .clearError:
                state.errorType = nil
                state.pageState = .idle
                return .none
                
            // MARK: Data Response / 数据响应
            case let .dataResponse(result):
                switch result {
                case let .success(data):
                    state.errorType = nil
                    // Set loaded state with load more state
                    // 设置加载状态和加载更多状态
                    let loadMoreState: ReduxPageState<ListData<State.MockItem>>.LoadMoreState = 
                        data.hasMorePages ? .idle : .noMore
                    state.pageState = .loaded(data, loadMoreState)
                    
                case let .failure(error):
                    state.errorType = error
                    // Determine failure type based on current state
                    // 根据当前状态确定失败类型
                    let failureType: ReduxPageState<ListData<State.MockItem>>.FailureType
                    if case .loading(.refresh) = state.pageState {
                        failureType = .refresh
                    } else {
                        failureType = .initial
                    }
                    
                    let errorInfo = ReduxPageState<ListData<State.MockItem>>.ErrorInfo(
                        type: NetworkErrorDemoFeature.mapNetworkErrorToPageError(error),
                        description: error.message,
                        code: error.statusCode
                    )
                    state.pageState = .failed(failureType, errorInfo)
                }
                
                return .none
                
            // MARK: Update Page State / 更新页面状态
            case let .updatePageState(pageState):
                state.pageState = pageState
                return .none
            }
        }
    }
    
    // MARK: - Helper Methods / 辅助方法
    
    /**
     * Simulate network request based on scenario
     * 根据场景模拟网络请求
     * 
     * This method simulates different network responses
     * 此方法模拟不同的网络响应
     */
    private static func simulateNetworkRequest(scenario: NetworkScenario) async -> Result<ListData<State.MockItem>, NetworkError> {
        switch scenario {
        case .success:
            // Return mock data / 返回模拟数据
            let items = generateMockItems(count: 10)
            let data = ListData(items: items, currentPage: 0, hasMorePages: true)
            return .success(data)
            
        case .successEmpty:
            // Return empty array (200 OK but no data) / 返回空数组（200 OK 但无数据）
            let data = ListData(items: [State.MockItem](), currentPage: 0, hasMorePages: false)
            return .success(data)
            
        case .notFound:
            return .failure(.notFound)
            
        case .unauthorized:
            return .failure(.unauthorized)
            
        case .forbidden:
            return .failure(.forbidden)
            
        case .serverError:
            return .failure(.serverError(500))
            
        case .timeout:
            return .failure(.timeout)
            
        case .noConnection:
            return .failure(.noConnection)
            
        case .rateLimited:
            return .failure(.rateLimited)
            
        case .badRequest:
            return .failure(.badRequest("Invalid request parameters"))
        }
    }
    
    /**
     * Map NetworkError to ReduxPageState ErrorType
     * 将 NetworkError 映射到 ReduxPageState ErrorType
     */
    private static func mapNetworkErrorToPageError(_ error: NetworkError) -> ReduxPageState<ListData<State.MockItem>>.ErrorType {
        switch error {
        case .noConnection:
            return .networkConnection
        case .timeout:
            return .timeout
        case .serverError:
            return .serverError
        case .dataCorrupted:
            return .parsingError
        default:
            return .unknown
        }
    }
    
    /**
     * Generate mock items for successful responses
     * 为成功响应生成模拟项目
     */
    private static func generateMockItems(count: Int) -> [State.MockItem] {
        (1...count).map { index in
            State.MockItem(
                title: "Item \(index) / 项目 \(index)",
                subtitle: "Description for item \(index) / 项目 \(index) 的描述",
                imageUrl: "https://picsum.photos/100/100?random=\(index)"
            )
        }
    }
}

