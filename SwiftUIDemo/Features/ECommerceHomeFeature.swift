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
        
        // MARK: New Error Display States / 新的错误显示状态
        var errorDisplayMode: ErrorDisplayMode = .none
        var showPinkErrorBanner: Bool = false
        var showOrangeFloatingAlert: Bool = false
        var showBlueRetryBanner: Bool = false
        var failedCoreAPIs: [String] = []
        var failedComponentAPIs: [String] = []
        
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
         * 核心API错误数量（使用纯函数）
         * Core API error count (using pure function)
         */
        var coreErrorCount: Int {
            let states = [
                userProfileState.isFailed,
                userSettingsState.isFailed,
                userStatisticsState.isFailed,
                userPermissionsState.isFailed,
                userNotificationsState.isFailed
            ]
            return ErrorStateCalculator.countCoreErrors(states)
        }
        
        /**
         * 组件错误数量（使用纯函数）
         * Component error count (using pure function)
         */
        var componentErrorCount: Int {
            let states = [
                bannersState.isFailed,
                recommendedProductsState.isFailed,
                flashSalesState.isFailed,
                categoriesState.isFailed,
                orderStatusState.isFailed
            ]
            return ErrorStateCalculator.countComponentErrors(states)
        }
        
        /**
         * 计算当前错误显示模式（使用纯函数）
         * Calculate current error display mode (using pure function)
         */
        var calculatedDisplayMode: ErrorDisplayMode {
            ErrorStateCalculator.determineDisplayMode(
                coreErrors: coreErrorCount,
                componentErrors: componentErrorCount
            )
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
        case resetForRefresh  // 重置状态以进行刷新 / Reset states for refresh
        
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
        case retryBatchAPIs([String])  // 批量重试指定的API / Batch retry specified APIs
        case dismissGlobalError
        case dismissPinkBanner
        case dismissOrangeAlert
        case dismissBlueBanner
        
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
                print("🏪 ECommerceHomeFeature.onAppear called")
                let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
                print("📱 iOS Version: \(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)")
                print("📊 isInitialLoadComplete: \(state.isInitialLoadComplete)")
                print("📊 userProfileState: \(state.userProfileState)")
                print("📊 bannersState: \(state.bannersState)")
                
                // Always load data if states are idle / 如果状态是 idle 则总是加载数据
                if case .idle = state.userProfileState {
                    print("⚡ User profile is idle, need to load data")
                    return .send(.loadInitialData)
                }
                
                // If data already loaded, don't reload / 如果数据已加载，不要重新加载
                if state.isInitialLoadComplete {
                    print("✅ Data already loaded, skipping reload")
                    return .none
                }
                
                print("🚀 Sending loadInitialData action")
                return .send(.loadInitialData)
                
            case .loadInitialData:
                print("📋 Loading initial data...")
                let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
                print("📱 iOS Version: \(systemVersion.majorVersion).\(systemVersion.minorVersion)")
                
                // Don't set complete until data actually loads / 不要在数据实际加载前设置完成
                // This was causing iOS 15.0 skeleton issue / 这导致了 iOS 15.0 骨架图问题
                // state.isInitialLoadComplete = true  // REMOVED / 已移除
                
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
                print("👤 Loading user profile...")
                state.userProfileState = .loading(.initial)
                return .run { send in
                    do {
                        let profile = try await service.fetchUserProfile()
                        print("✅ User profile loaded successfully")
                        await send(.userProfileResponse(.success(profile)))
                    } catch let error as ECommerceError {
                        print("❌ User profile failed: \(error)")
                        await send(.userProfileResponse(.failure(error)))
                    } catch {
                        print("❌ User profile failed with unknown error")
                        await send(.userProfileResponse(.failure(.unknown)))
                    }
                }
                
            case let .userProfileResponse(.success(profile)):
                print("✅ User profile state set to loaded")
                state.userProfileState = .loaded(profile, .idle)
                checkAndUpdateGlobalError(&state)
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
                
                // Mark initial load complete when user profile loads successfully
                // 当用户资料加载成功时标记初始加载完成
                if !state.isInitialLoadComplete {
                    print("🎆 Setting isInitialLoadComplete = true")
                    state.isInitialLoadComplete = true
                }
                return .none
                
            case let .userProfileResponse(.failure(error)):
                print("❌ User profile state set to failed: \(error)")
                state.userProfileState = .failed(
                    .initial,
                    ReduxPageState<UserProfile>.ErrorInfo(
                        code: "PROFILE_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateGlobalError(&state)
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
                return .none
                
            case let .bannersResponse(.failure(error)):
                state.bannersState = .failed(
                    .initial,
                    ReduxPageState<[Banner]>.ErrorInfo(
                        code: "BANNERS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
                return .none
                
            case let .recommendedProductsResponse(.failure(error)):
                state.recommendedProductsState = .failed(
                    .initial,
                    ReduxPageState<[Product]>.ErrorInfo(
                        code: "PRODUCTS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
                return .none
                
            case let .flashSalesResponse(.failure(error)):
                state.flashSalesState = .failed(
                    .initial,
                    ReduxPageState<[FlashSale]>.ErrorInfo(
                        code: "FLASH_SALES_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
                return .none
                
            case let .categoriesResponse(.failure(error)):
                state.categoriesState = .failed(
                    .initial,
                    ReduxPageState<[Category]>.ErrorInfo(
                        code: "CATEGORIES_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
                return .none
                
            case let .orderStatusResponse(.failure(error)):
                state.orderStatusState = .failed(
                    .initial,
                    ReduxPageState<UserOrderStatus>.ErrorInfo(
                        code: "ORDER_STATUS_ERROR",
                        message: error.localizedDescription
                    )
                )
                updateErrorDisplayState(&state)  // 更新错误显示状态 / Update error display state
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
                
            case let .retryBatchAPIs(apis):
                // 批量重试指定的API / Batch retry specified APIs
                var effects: [Effect<Action>] = []
                
                for api in apis {
                    if api.contains("Profile") || api.contains("资料") {
                        effects.append(.send(.loadUserProfile))
                    }
                    if api.contains("Settings") || api.contains("设置") {
                        effects.append(.send(.loadUserSettings))
                    }
                    if api.contains("Statistics") || api.contains("统计") {
                        effects.append(.send(.loadUserStatistics))
                    }
                    if api.contains("Permissions") || api.contains("权限") {
                        effects.append(.send(.loadUserPermissions))
                    }
                    if api.contains("Notifications") || api.contains("通知") {
                        effects.append(.send(.loadUserNotifications))
                    }
                    if api.contains("Banners") || api.contains("轮播") {
                        effects.append(.send(.loadBanners))
                    }
                    if api.contains("Products") || api.contains("商品") {
                        effects.append(.send(.loadRecommendedProducts))
                    }
                    if api.contains("Flash") || api.contains("秒杀") {
                        effects.append(.send(.loadFlashSales))
                    }
                    if api.contains("Categories") || api.contains("分类") {
                        effects.append(.send(.loadCategories))
                    }
                    if api.contains("Orders") || api.contains("订单") {
                        effects.append(.send(.loadOrderStatus))
                    }
                }
                
                return .merge(effects)
                
            case .dismissGlobalError:
                state.showGlobalErrorBanner = false
                return .none
                
            case .dismissPinkBanner:
                state.showPinkErrorBanner = false
                return .none
                
            case .dismissOrangeAlert:
                state.showOrangeFloatingAlert = false
                return .none
                
            case .dismissBlueBanner:
                state.showBlueRetryBanner = false
                return .none
                
            // MARK: Refresh
            case .resetForRefresh:
                print("♻️ Resetting states for refresh...")
                // Reset all states to loading to show refresh is happening
                // 重置所有状态为加载中以显示正在刷新
                state.userProfileState = .loading(.initial)
                state.userSettingsState = .loading(.initial)
                state.userStatisticsState = .loading(.initial)
                state.userPermissionsState = .loading(.initial)
                state.userNotificationsState = .loading(.initial)
                state.bannersState = .loading(.initial)
                state.recommendedProductsState = .loading(.initial)
                state.flashSalesState = .loading(.initial)
                state.categoriesState = .loading(.initial)
                state.orderStatusState = .loading(.initial)
                
                // Clear error states / 清除错误状态
                state.showGlobalErrorBanner = false
                state.globalErrorMessage = ""
                state.errorDisplayMode = .none
                state.showPinkErrorBanner = false
                state.showOrangeFloatingAlert = false
                state.showBlueRetryBanner = false
                state.failedCoreAPIs = []
                state.failedComponentAPIs = []
                
                // Reset initial load flag to ensure fresh load
                // 重置初始加载标志以确保重新加载
                state.isInitialLoadComplete = false
                
                print("✅ States reset, triggering loadInitialData")
                return .send(.loadInitialData)
                
            // MARK: Navigation
            case .productTapped, .categoryTapped, .flashSaleTapped, .bannerTapped:
                // Handle navigation / 处理导航
                return .none
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     * 更新错误显示状态（使用纯函数）
     * Update error display state (using pure functions)
     */
    private func updateErrorDisplayState(_ state: inout State) {
        // 收集失败的API名称 / Collect failed API names
        state.failedCoreAPIs = []
        state.failedComponentAPIs = []
        
        // 核心API失败检查 / Core API failure check
        if case .failed = state.userProfileState {
            state.failedCoreAPIs.append("用户资料 / Profile")
        }
        if case .failed = state.userSettingsState {
            state.failedCoreAPIs.append("用户设置 / Settings")
        }
        if case .failed = state.userStatisticsState {
            state.failedCoreAPIs.append("用户统计 / Statistics")
        }
        if case .failed = state.userPermissionsState {
            state.failedCoreAPIs.append("用户权限 / Permissions")
        }
        if case .failed = state.userNotificationsState {
            state.failedCoreAPIs.append("通知配置 / Notifications")
        }
        
        // 组件API失败检查 / Component API failure check
        if case .failed = state.bannersState {
            state.failedComponentAPIs.append("轮播图 / Banners")
        }
        if case .failed = state.recommendedProductsState {
            state.failedComponentAPIs.append("推荐商品 / Products")
        }
        if case .failed = state.flashSalesState {
            state.failedComponentAPIs.append("限时秒杀 / Flash Sales")
        }
        if case .failed = state.categoriesState {
            state.failedComponentAPIs.append("分类 / Categories")
        }
        if case .failed = state.orderStatusState {
            state.failedComponentAPIs.append("订单状态 / Orders")
        }
        
        // 使用纯函数计算显示模式 / Calculate display mode using pure function
        state.errorDisplayMode = ErrorStateCalculator.determineDisplayMode(
            coreErrors: state.coreErrorCount,
            componentErrors: state.componentErrorCount
        )
        
        // 根据显示模式设置UI状态 / Set UI states based on display mode
        switch state.errorDisplayMode {
        case .none:
            state.showPinkErrorBanner = false
            state.showOrangeFloatingAlert = false
            state.showBlueRetryBanner = false
            
        case .blankPageWithAlerts:
            // 空白页面：显示粉色和橙色提示 / Blank page: show pink and orange alerts
            state.showPinkErrorBanner = true
            state.showOrangeFloatingAlert = true
            state.showBlueRetryBanner = true  // 蓝色横幅用于批量重试 / Blue banner for batch retry
            
        case .normalPageWithGlobalError:
            // 正常页面但有全局错误：显示蓝色批量重试 / Normal page with global error: show blue batch retry
            state.showPinkErrorBanner = false
            state.showOrangeFloatingAlert = false
            state.showBlueRetryBanner = true
            
        case .normalPageWithComponentErrors:
            // 正常页面但有组件错误：组件内显示错误 / Normal page with component errors: show errors in components
            state.showPinkErrorBanner = false
            state.showOrangeFloatingAlert = false
            state.showBlueRetryBanner = false
        }
        
        print("🔍 Error Display State Updated:")
        print("  - Display Mode: \(state.errorDisplayMode)")
        print("  - Core Errors: \(state.coreErrorCount)")
        print("  - Component Errors: \(state.componentErrorCount)")
        print("  - Failed Core APIs: \(state.failedCoreAPIs)")
        print("  - Failed Component APIs: \(state.failedComponentAPIs)")
    }
    
    /**
     * 旧的更新全局错误状态方法（保留兼容性）
     * Legacy update global error state (keep for compatibility)
     */
    private func updateGlobalError(_ state: inout State) {
        updateErrorDisplayState(&state)
        
        if state.hasAnyCoreError {
            state.showGlobalErrorBanner = true
            state.globalErrorMessage = state.coreErrorMessages.first ?? "加载失败 / Load failed"
        }
    }
    
    /**
     * 旧的检查并更新全局错误方法（保留兼容性）
     * Legacy check and update global error (keep for compatibility)
     */
    private func checkAndUpdateGlobalError(_ state: inout State) {
        updateErrorDisplayState(&state)
        
        print("🔍 Checking global error state...")
        print("  - hasAnyCoreError: \(state.hasAnyCoreError)")
        print("  - userProfileState: \(String(describing: state.userProfileState))")
        print("  - userSettingsState: \(String(describing: state.userSettingsState))")
        
        if !state.hasAnyCoreError {
            print("✅ No core errors, hiding global error banner")
            state.showGlobalErrorBanner = false
            state.globalErrorMessage = ""
        } else {
            print("⚠️ Core errors detected, showing global error banner")
        }
    }
}