//
//  ECommerceHomeFeature.swift
//  SwiftUIDemo
//
//  E-commerce home page feature with complex state management
//  电商首页功能，包含复杂的状态管理
//

/**
 * 🏠 E-COMMERCE HOME FEATURE - 电商首页功能
 * ═══════════════════════════════════════════════════════════════
 *
 * 核心设计思路 / Core Design Philosophy:
 * 
 * 1. 并发请求管理 / Concurrent Request Management
 *    • 5个用户信息接口并行请求
 *    • 使用Combine的merge和zip操作符
 *    • 任一失败触发全局错误状态
 *
 * 2. 分层错误处理 / Layered Error Handling
 *    • 全局错误：影响整个页面的错误
 *    • 组件错误：只影响单个组件的错误
 *    • 独立重试机制
 *
 * 3. 状态机设计 / State Machine Design
 *    • 使用ReduxPageState管理每个接口状态
 *    • 清晰的状态转换路径
 *    • 类型安全的错误处理
 *
 * SOLID原则应用 / SOLID Principles Applied:
 * • SRP: 每个组件管理自己的状态
 * • OCP: 通过协议扩展新的数据源
 * • LSP: 所有API服务遵循统一接口
 * • ISP: 组件只依赖需要的数据
 * • DIP: 依赖于抽象的服务协议
 */

import ComposableArchitecture
import Foundation
import Combine

@Reducer
struct ECommerceHomeFeature {
    
    // MARK: - State
    
    /**
     * 首页状态定义
     * Home page state definition
     *
     * 包含5个核心用户数据状态和各组件状态
     * Contains 5 core user data states and component states
     */
    @ObservableState
    struct State: Equatable {
        // MARK: Core User Data States / 核心用户数据状态
        var userProfileState: ReduxPageState<UserProfile> = .idle
        var userSettingsState: ReduxPageState<UserSettings> = .idle
        var userStatisticsState: ReduxPageState<UserStatistics> = .idle
        var userPermissionsState: ReduxPageState<UserPermissions> = .idle
        var userNotificationsState: ReduxPageState<UserNotifications> = .idle
        
        // MARK: Component Data States / 组件数据状态
        var bannersState: ReduxPageState<[Banner]> = .idle
        var recommendedProductsState: ReduxPageState<[Product]> = .idle
        var flashSalesState: ReduxPageState<[FlashSale]> = .idle
        var categoriesState: ReduxPageState<[Category]> = .idle
        var orderStatusState: ReduxPageState<UserOrderStatus> = .idle
        
        // MARK: UI States / UI状态
        var showGlobalErrorBanner: Bool = false
        var globalErrorMessage: String = ""
        var isInitialLoadComplete: Bool = false
        
        // MARK: Computed Properties / 计算属性
        
        /**
         * 是否有任何核心接口失败
         * Whether any core API failed
         */
        var hasAnyCoreError: Bool {
            if case .failed = userProfileState { return true }
            if case .failed = userSettingsState { return true }
            if case .failed = userStatisticsState { return true }
            if case .failed = userPermissionsState { return true }
            if case .failed = userNotificationsState { return true }
            return false
        }
        
        /**
         * 获取所有核心错误消息
         * Get all core error messages
         */
        var coreErrorMessages: [String] {
            var messages: [String] = []
            
            if case let .failed(_, error) = userProfileState {
                messages.append("用户资料加载失败 / Profile failed: \(error.message)")
            }
            if case let .failed(_, error) = userSettingsState {
                messages.append("设置加载失败 / Settings failed: \(error.message)")
            }
            if case let .failed(_, error) = userStatisticsState {
                messages.append("统计加载失败 / Statistics failed: \(error.message)")
            }
            if case let .failed(_, error) = userPermissionsState {
                messages.append("权限加载失败 / Permissions failed: \(error.message)")
            }
            if case let .failed(_, error) = userNotificationsState {
                messages.append("通知配置加载失败 / Notifications failed: \(error.message)")
            }
            
            return messages
        }
        
        /**
         * 是否正在加载核心数据
         * Whether core data is loading
         */
        var isLoadingCoreData: Bool {
            if case .loading = userProfileState { return true }
            if case .loading = userSettingsState { return true }
            if case .loading = userStatisticsState { return true }
            if case .loading = userPermissionsState { return true }
            if case .loading = userNotificationsState { return true }
            return false
        }
    }
    
    // MARK: - Action
    
    /**
     * 首页动作定义
     * Home page action definition
     */
    enum Action {
        // MARK: Lifecycle / 生命周期
        case onAppear
        case loadInitialData
        
        // MARK: Core Data Actions / 核心数据动作
        case loadUserProfile
        case userProfileResponse(Result<UserProfile, ECommerceError>)
        
        case loadUserSettings
        case userSettingsResponse(Result<UserSettings, ECommerceError>)
        
        case loadUserStatistics
        case userStatisticsResponse(Result<UserStatistics, ECommerceError>)
        
        case loadUserPermissions
        case userPermissionsResponse(Result<UserPermissions, ECommerceError>)
        
        case loadUserNotifications
        case userNotificationsResponse(Result<UserNotifications, ECommerceError>)
        
        // MARK: Component Data Actions / 组件数据动作
        case loadBanners
        case bannersResponse(Result<[Banner], ECommerceError>)
        
        case loadRecommendedProducts
        case recommendedProductsResponse(Result<[Product], ECommerceError>)
        
        case loadFlashSales
        case flashSalesResponse(Result<[FlashSale], ECommerceError>)
        
        case loadCategories
        case categoriesResponse(Result<[Category], ECommerceError>)
        
        case loadOrderStatus
        case orderStatusResponse(Result<UserOrderStatus, ECommerceError>)
        
        // MARK: Error Handling / 错误处理
        case retryAllCoreAPIs
        case retryFailedCoreAPIs  // 只重试失败的核心API / Only retry failed core APIs
        case retryComponentAPI(ComponentType)
        case dismissGlobalError
        
        // MARK: Navigation / 导航
        case productTapped(Product)
        case categoryTapped(Category)
        case flashSaleTapped(FlashSale)
        case bannerTapped(Banner)
        
        enum ComponentType {
            case banners
            case recommendedProducts
            case flashSales
            case categories
            case orderStatus
        }
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.ecommerceService) var service
    // continuousClock is iOS 16.0+, removed for iOS 15 compatibility
    // continuousClock 是 iOS 16.0+，为了 iOS 15 兼容性已移除
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // MARK: Lifecycle
            case .onAppear:
                guard !state.isInitialLoadComplete else { return .none }
                return .send(.loadInitialData)
                
            case .loadInitialData:
                // Load all core APIs in parallel / 并行加载所有核心API
                return .merge(
                    .send(.loadUserProfile),
                    .send(.loadUserSettings),
                    .send(.loadUserStatistics),
                    .send(.loadUserPermissions),
                    .send(.loadUserNotifications),
                    // Also load component data / 同时加载组件数据
                    .send(.loadBanners),
                    .send(.loadRecommendedProducts),
                    .send(.loadFlashSales),
                    .send(.loadCategories),
                    .send(.loadOrderStatus)
                )
                
            // MARK: User Profile
            case .loadUserProfile:
                state.userProfileState = .loading(.initial)
                return .run { send in
                    do {
                        let profile = try await service.fetchUserProfile()
                        await send(.userProfileResponse(.success(profile)))
                    } catch let error as ECommerceError {
                        await send(.userProfileResponse(.failure(error)))
                    } catch {
                        await send(.userProfileResponse(.failure(.unknown)))
                    }
                }
                
            case let .userProfileResponse(.success(profile)):
                state.userProfileState = .loaded(profile, .idle)
                checkAndUpdateGlobalError(&state)
                return .none
                
            case let .userProfileResponse(.failure(error)):
                state.userProfileState = .failed(
                    .initial,
                    ReduxPageState<UserProfile>.ErrorInfo(
                        code: "PROFILE_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateGlobalError(&state)
                return .none
                
            // MARK: User Settings
            case .loadUserSettings:
                state.userSettingsState = .loading(.initial)
                return .run { send in
                    do {
                        let settings = try await service.fetchUserSettings()
                        await send(.userSettingsResponse(.success(settings)))
                    } catch let error as ECommerceError {
                        await send(.userSettingsResponse(.failure(error)))
                    } catch {
                        await send(.userSettingsResponse(.failure(.unknown)))
                    }
                }
                
            case let .userSettingsResponse(.success(settings)):
                state.userSettingsState = .loaded(settings, .idle)
                checkAndUpdateGlobalError(&state)
                return .none
                
            case let .userSettingsResponse(.failure(error)):
                state.userSettingsState = .failed(
                    .initial,
                    ReduxPageState<UserSettings>.ErrorInfo(
                        code: "SETTINGS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateGlobalError(&state)
                return .none
                
            // MARK: User Statistics
            case .loadUserStatistics:
                state.userStatisticsState = .loading(.initial)
                return .run { send in
                    do {
                        let statistics = try await service.fetchUserStatistics()
                        await send(.userStatisticsResponse(.success(statistics)))
                    } catch let error as ECommerceError {
                        await send(.userStatisticsResponse(.failure(error)))
                    } catch {
                        await send(.userStatisticsResponse(.failure(.unknown)))
                    }
                }
                
            case let .userStatisticsResponse(.success(statistics)):
                state.userStatisticsState = .loaded(statistics, .idle)
                checkAndUpdateGlobalError(&state)
                return .none
                
            case let .userStatisticsResponse(.failure(error)):
                state.userStatisticsState = .failed(
                    .initial,
                    ReduxPageState<UserStatistics>.ErrorInfo(
                        code: "STATISTICS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateGlobalError(&state)
                return .none
                
            // MARK: User Permissions
            case .loadUserPermissions:
                state.userPermissionsState = .loading(.initial)
                return .run { send in
                    do {
                        let permissions = try await service.fetchUserPermissions()
                        await send(.userPermissionsResponse(.success(permissions)))
                    } catch let error as ECommerceError {
                        await send(.userPermissionsResponse(.failure(error)))
                    } catch {
                        await send(.userPermissionsResponse(.failure(.unknown)))
                    }
                }
                
            case let .userPermissionsResponse(.success(permissions)):
                state.userPermissionsState = .loaded(permissions, .idle)
                checkAndUpdateGlobalError(&state)
                return .none
                
            case let .userPermissionsResponse(.failure(error)):
                state.userPermissionsState = .failed(
                    .initial,
                    ReduxPageState<UserPermissions>.ErrorInfo(
                        code: "PERMISSIONS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateGlobalError(&state)
                return .none
                
            // MARK: User Notifications
            case .loadUserNotifications:
                state.userNotificationsState = .loading(.initial)
                return .run { send in
                    do {
                        let notifications = try await service.fetchUserNotifications()
                        await send(.userNotificationsResponse(.success(notifications)))
                    } catch let error as ECommerceError {
                        await send(.userNotificationsResponse(.failure(error)))
                    } catch {
                        await send(.userNotificationsResponse(.failure(.unknown)))
                    }
                }
                
            case let .userNotificationsResponse(.success(notifications)):
                state.userNotificationsState = .loaded(notifications, .idle)
                checkAndUpdateGlobalError(&state)
                state.isInitialLoadComplete = true
                return .none
                
            case let .userNotificationsResponse(.failure(error)):
                state.userNotificationsState = .failed(
                    .initial,
                    ReduxPageState<UserNotifications>.ErrorInfo(
                        code: "NOTIFICATIONS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateGlobalError(&state)
                state.isInitialLoadComplete = true
                return .none
                
            // MARK: Component Data - Banners
            case .loadBanners:
                state.bannersState = .loading(.initial)
                return .run { send in
                    do {
                        let banners = try await service.fetchBanners()
                        await send(.bannersResponse(.success(banners)))
                    } catch let error as ECommerceError {
                        await send(.bannersResponse(.failure(error)))
                    } catch {
                        await send(.bannersResponse(.failure(.unknown)))
                    }
                }
                
            case let .bannersResponse(.success(banners)):
                state.bannersState = .loaded(banners, .idle)
                return .none
                
            case let .bannersResponse(.failure(error)):
                state.bannersState = .failed(
                    .initial,
                    ReduxPageState<[Banner]>.ErrorInfo(
                        code: "BANNERS_ERROR",
                        message: error.localizedDescription
                    )
                )
                return .none
                
            // MARK: Component Data - Products
            case .loadRecommendedProducts:
                state.recommendedProductsState = .loading(.initial)
                return .run { send in
                    do {
                        let products = try await service.fetchRecommendedProducts()
                        await send(.recommendedProductsResponse(.success(products)))
                    } catch let error as ECommerceError {
                        await send(.recommendedProductsResponse(.failure(error)))
                    } catch {
                        await send(.recommendedProductsResponse(.failure(.unknown)))
                    }
                }
                
            case let .recommendedProductsResponse(.success(products)):
                state.recommendedProductsState = .loaded(products, .idle)
                return .none
                
            case let .recommendedProductsResponse(.failure(error)):
                state.recommendedProductsState = .failed(
                    .initial,
                    ReduxPageState<[Product]>.ErrorInfo(
                        code: "PRODUCTS_ERROR",
                        message: error.localizedDescription
                    )
                )
                return .none
                
            // MARK: Component Data - Flash Sales
            case .loadFlashSales:
                state.flashSalesState = .loading(.initial)
                return .run { send in
                    do {
                        let sales = try await service.fetchFlashSales()
                        await send(.flashSalesResponse(.success(sales)))
                    } catch let error as ECommerceError {
                        await send(.flashSalesResponse(.failure(error)))
                    } catch {
                        await send(.flashSalesResponse(.failure(.unknown)))
                    }
                }
                
            case let .flashSalesResponse(.success(sales)):
                state.flashSalesState = .loaded(sales, .idle)
                return .none
                
            case let .flashSalesResponse(.failure(error)):
                state.flashSalesState = .failed(
                    .initial,
                    ReduxPageState<[FlashSale]>.ErrorInfo(
                        code: "FLASH_SALES_ERROR",
                        message: error.localizedDescription
                    )
                )
                return .none
                
            // MARK: Component Data - Categories
            case .loadCategories:
                state.categoriesState = .loading(.initial)
                return .run { send in
                    do {
                        let categories = try await service.fetchCategories()
                        await send(.categoriesResponse(.success(categories)))
                    } catch let error as ECommerceError {
                        await send(.categoriesResponse(.failure(error)))
                    } catch {
                        await send(.categoriesResponse(.failure(.unknown)))
                    }
                }
                
            case let .categoriesResponse(.success(categories)):
                state.categoriesState = .loaded(categories, .idle)
                return .none
                
            case let .categoriesResponse(.failure(error)):
                state.categoriesState = .failed(
                    .initial,
                    ReduxPageState<[Category]>.ErrorInfo(
                        code: "CATEGORIES_ERROR",
                        message: error.localizedDescription
                    )
                )
                return .none
                
            // MARK: Component Data - Order Status
            case .loadOrderStatus:
                state.orderStatusState = .loading(.initial)
                return .run { send in
                    do {
                        let status = try await service.fetchOrderStatus()
                        await send(.orderStatusResponse(.success(status)))
                    } catch let error as ECommerceError {
                        await send(.orderStatusResponse(.failure(error)))
                    } catch {
                        await send(.orderStatusResponse(.failure(.unknown)))
                    }
                }
                
            case let .orderStatusResponse(.success(status)):
                state.orderStatusState = .loaded(status, .idle)
                return .none
                
            case let .orderStatusResponse(.failure(error)):
                state.orderStatusState = .failed(
                    .initial,
                    ReduxPageState<UserOrderStatus>.ErrorInfo(
                        code: "ORDER_STATUS_ERROR",
                        message: error.localizedDescription
                    )
                )
                return .none
                
            // MARK: Error Handling
            case .retryAllCoreAPIs:
                state.showGlobalErrorBanner = false
                return .merge(
                    .send(.loadUserProfile),
                    .send(.loadUserSettings),
                    .send(.loadUserStatistics),
                    .send(.loadUserPermissions),
                    .send(.loadUserNotifications)
                )
                
            case .retryFailedCoreAPIs:
                // 只重试失败的接口 / Only retry failed APIs
                var effects: [Effect<Action>] = []
                
                if case .failed = state.userProfileState {
                    effects.append(.send(.loadUserProfile))
                }
                if case .failed = state.userSettingsState {
                    effects.append(.send(.loadUserSettings))
                }
                if case .failed = state.userStatisticsState {
                    effects.append(.send(.loadUserStatistics))
                }
                if case .failed = state.userPermissionsState {
                    effects.append(.send(.loadUserPermissions))
                }
                if case .failed = state.userNotificationsState {
                    effects.append(.send(.loadUserNotifications))
                }
                
                return .merge(effects)
                
            case let .retryComponentAPI(component):
                switch component {
                case .banners:
                    return .send(.loadBanners)
                case .recommendedProducts:
                    return .send(.loadRecommendedProducts)
                case .flashSales:
                    return .send(.loadFlashSales)
                case .categories:
                    return .send(.loadCategories)
                case .orderStatus:
                    return .send(.loadOrderStatus)
                }
                
            case .dismissGlobalError:
                state.showGlobalErrorBanner = false
                return .none
                
            // MARK: Navigation
            case .productTapped, .categoryTapped, .flashSaleTapped, .bannerTapped:
                // Handle navigation / 处理导航
                return .none
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     * 更新全局错误状态
     * Update global error state
     */
    private func updateGlobalError(_ state: inout State) {
        if state.hasAnyCoreError {
            state.showGlobalErrorBanner = true
            state.globalErrorMessage = state.coreErrorMessages.first ?? "加载失败 / Load failed"
        }
    }
    
    /**
     * 检查并更新全局错误
     * Check and update global error
     */
    private func checkAndUpdateGlobalError(_ state: inout State) {
        if !state.hasAnyCoreError {
            state.showGlobalErrorBanner = false
            state.globalErrorMessage = ""
        }
    }
}