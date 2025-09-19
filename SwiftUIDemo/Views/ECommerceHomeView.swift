//
//  ECommerceHomeView.swift
//  SwiftUIDemo
//
//  E-commerce home page with complex error handling
//  电商首页，包含复杂的错误处理
//

/**
 * 🏠 E-COMMERCE HOME VIEW - 电商首页视图
 * ═══════════════════════════════════════════════════════════════
 *
 * 视图架构设计 / View Architecture Design:
 * 
 * 1. 分层错误处理 / Layered Error Handling
 *    • 全局错误横幅：底部橙色提示
 *    • 组件级错误：各组件内部显示
 *    • 独立重试机制
 *
 * 2. 组件化设计 / Component-based Design
 *    • 轮播图组件
 *    • 分类入口组件
 *    • 秒杀组件
 *    • 推荐商品组件
 *    • 订单状态组件
 *
 * 3. 响应式布局 / Responsive Layout
 *    • 适配不同屏幕尺寸
 *    • 流式布局
 *    • 动态网格
 *
 * ViewModifier应用 / ViewModifier Usage:
 * • 错误状态处理
 * • 加载状态显示
 * • 统一样式管理
 */

import SwiftUI
import ComposableArchitecture

/**
 * 主视图结构体 - 电商首页视图
 * Main View Structure - E-Commerce Home View
 * 
 * 技术栈 / Tech Stack:
 * - SwiftUI: 声明式UI框架
 * - TCA (The Composable Architecture): 状态管理
 * - Combine: 响应式编程
 * 
 * 关键技术点 / Key Technical Points:
 * 1. ViewStore: TCA的核心概念，用于观察状态变化并触发视图更新
 * 2. @ObservedObject: SwiftUI属性包装器，确保视图响应状态变化
 * 3. Store: TCA的状态容器，管理所有业务逻辑
 */
struct ECommerceHomeView: View {
    // MARK: - Properties / 属性
    
    /**
     * ViewStore - TCA的视图状态观察器
     * ViewStore - TCA's view state observer
     * 
     * 作用 / Purpose:
     * - 观察状态变化并自动更新UI
     * - 提供类型安全的状态访问
     * - 优化性能，只在相关状态变化时更新
     */
    @ObservedObject var viewStore: ViewStore<ECommerceHomeFeature.State, ECommerceHomeFeature.Action>
    
    /**
     * Store - TCA的核心状态容器
     * Store - TCA's core state container
     * 
     * 职责 / Responsibilities:
     * - 持有应用状态
     * - 处理动作（Actions）
     * - 执行副作用（Effects）
     */
    let store: StoreOf<ECommerceHomeFeature>
    
    // MARK: - Layout Constants / 布局常量
    
    /**
     * 网格列定义 - 用于推荐商品的两列布局
     * Grid columns definition - Two column layout for recommended products
     * 
     * 使用场景 / Use case:
     * LazyVGrid 中展示商品卡片
     */
    private let gridColumns = [
        GridItem(.flexible()),  // 第一列，自适应宽度 / First column, flexible width
        GridItem(.flexible())   // 第二列，自适应宽度 / Second column, flexible width
    ]
    
    /**
     * 分类网格列定义 - 四列布局
     * Category grid columns - Four column layout
     * 
     * 设计考虑 / Design consideration:
     * - 4列适合展示图标类分类
     * - 在小屏幕上仍能保持良好可读性
     */
    private let categoryColumns = Array(repeating: GridItem(.flexible()), count: 4)
    
    // MARK: - Initialization / 初始化
    
    /**
     * 视图初始化器
     * View Initializer
     * 
     * 关键步骤 / Key steps:
     * 1. 保存store引用
     * 2. 创建ViewStore用于状态观察
     * 3. observe: { $0 } 表示观察所有状态变化
     * 
     * 注意 / Note:
     * ViewStore的创建是性能优化的关键
     * 只有通过ViewStore访问的状态变化才会触发视图更新
     */
    init(store: StoreOf<ECommerceHomeFeature>) {
        self.store = store
        // 创建ViewStore，观察所有状态变化
        // Create ViewStore, observe all state changes
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    // MARK: - Body / 主体视图
    
    /**
     * SwiftUI视图主体
     * SwiftUI View Body
     * 
     * 架构设计 / Architecture Design:
     * - 使用Group包装以支持条件编译
     * - iOS版本适配策略
     * - 响应式布局设计
     * 
     * 性能优化 / Performance Optimization:
     * - 使用计算属性分解复杂视图
     * - 避免body中的复杂逻辑
     * - 利用SwiftUI的视图重用机制
     */
    var body: some View {
        /**
         * Group容器的作用 / Purpose of Group container:
         * 1. 允许在不同iOS版本间切换实现
         * 2. 确保refreshable修饰符正确应用
         * 3. 避免条件编译导致的视图类型不一致
         * 
         * iOS兼容性策略 / iOS Compatibility Strategy:
         * - iOS 15: 基础refreshable支持
         * - iOS 16+: 增强的refreshable功能
         */
        Group {
            if #available(iOS 16.0, *) {
                // iOS 16+: 使用现代实现，支持更多特性
                // iOS 16+: Use modern implementation with more features
                contentWithOverlay
            } else {
                // iOS 15: 确保基础功能正常工作
                // iOS 15: Ensure basic functionality works
                contentWithOverlay
            }
        }
        .navigationTitle("购物商城 / E-Commerce")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            // Ensure data is loaded when view appears / 确保视图出现时数据已加载
            print("🛍️ ECommerceHomeView.onAppear")
            print("📱 Running on iOS \(ProcessInfo.processInfo.operatingSystemVersion.majorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)")
            print("📊 Current userProfileState: \(viewStore.userProfileState)")
            print("📊 Current bannersState: \(viewStore.bannersState)")
            
            // If data not loaded, trigger loading / 如果数据未加载，触发加载
            if case .idle = viewStore.userProfileState {
                print("🔄 Data not loaded, sending onAppear action")
                store.send(.onAppear)
            }
        }
    }
    
    /**
     * 内容与覆盖层组合视图
     * Content with Overlay Combined View
     * 
     * 设计模式 / Design Pattern:
     * - 使用ZStack实现分层架构
     * - 主内容层：ScrollView包含所有业务组件
     * - 覆盖层：错误提示和通知横幅
     * 
     * 为什么使用ZStack / Why use ZStack:
     * 1. 允许错误横幅浮动在内容之上
     * 2. 不影响主内容的滚动行为
     * 3. 提供更好的视觉层次
     * 
     * 渲染顺序 / Rendering Order:
     * 1. mainContent (底层)
     * 2. errorBannersOverlay (顶层)
     */
    private var contentWithOverlay: some View {
        ZStack {
            // 主内容层 - 包含所有业务组件
            // Main content layer - Contains all business components
            mainContent
            
            // 错误横幅覆盖层 - 浮动显示错误信息
            // Error banners overlay - Floating error messages
            errorBannersOverlay
        }
    }
    
    // MARK: - Main Content / 主内容视图
    
    /**
     * 主内容ScrollView
     * Main Content ScrollView
     * 
     * 架构设计 / Architecture Design:
     * - ScrollView作为容器，支持垂直滚动
     * - VStack组织内容的垂直布局
     * - 响应式padding适应不同状态
     * 
     * 性能优化 / Performance Optimization:
     * - 使用计算属性分解复杂视图
     * - 条件渲染减少不必要的视图构建
     * - 背景色设置优化iOS 15刷新体验
     */
    private var mainContent: some View {
        ScrollView {
            /**
             * 内容垂直堆栈
             * Content Vertical Stack
             * 
             * spacing: 20 - 组件间的统一间距
             * 设计原则: 保持视觉一致性和呼吸感
             */
            VStack(spacing: 20) {
                /**
                 * 蓝色批量重试横幅
                 * Blue Batch Retry Banner
                 * 
                 * 显示条件 / Display Condition:
                 * - 多个API失败时显示
                 * - 提供批量重试功能
                 * 
                 * 用户体验设计 / UX Design:
                 * - 蓝色表示信息提示，非严重错误
                 * - 支持全部重试或选择性重试
                 */
                if viewStore.showBlueRetryBanner {
                    BlueErrorBanner(
                        errorCount: viewStore.coreErrorCount + viewStore.componentErrorCount,
                        failedAPIs: viewStore.failedCoreAPIs + viewStore.failedComponentAPIs,
                        onRetryAll: {
                            store.send(.retryBatchAPIs(viewStore.failedCoreAPIs + viewStore.failedComponentAPIs))
                        },
                        onRetrySelected: { apis in
                            store.send(.retryBatchAPIs(apis))
                        },
                        isExpanded: .constant(false)
                    )
                    .padding(.horizontal)
                }
                
                // User header section / 用户头部区域
                userHeaderSection
                
                // 总是显示正常内容，让各组件自己处理错误 / Always show normal content, let components handle their own errors
                // Always show normal content regardless of error state
                // 始终显示正常内容，不管错误状态如何
                normalContent
            }
            .padding(.bottom, viewStore.showOrangeFloatingAlert ? 100 : 20)
        }
        /**
         * iOS 15 刷新功能修复
         * iOS 15 Refresh Functionality Fix
         * 
         * 关键修复点 / Key Fixes:
         * 1. background: 必须设置背景色，否则iOS 15无法显示刷新指示器
         * 2. refreshable: 直接应用在ScrollView上，不能嵌套过深
         * 3. await: 必须等待异步操作完成，否则刷新立即结束
         * 
         * 兼容性说明 / Compatibility Note:
         * - iOS 15.0: 基础refreshable支持
         * - iOS 16.0+: 增强的refreshable功能
         */
        .background(Color(.systemGroupedBackground))  // 关键: iOS 15必需
        .refreshable {
            // 执行异步刷新操作
            await performRefresh()
        }
    }
    
    // MARK: - Refresh Implementation / 刷新实现
    
    /**
     * 执行下拉刷新的异步函数
     * Async function to perform pull-to-refresh
     * 
     * 技术实现 / Technical Implementation:
     * 1. 使用 @MainActor 确保UI更新在主线程
     * 2. async/await 处理异步操作
     * 3. 轮询检查数据加载状态
     * 
     * 为什么需要这个函数 / Why this function is needed:
     * - iOS 15 的 .refreshable 需要明确的异步处理
     * - 需要等待数据实际加载完成才能结束刷新
     * - 提供更好的用户体验反馈
     * 
     * 关键技术点 / Key Technical Points:
     * - Task.sleep: iOS 15兼容的等待方式
     * - ViewStore状态检查: 确保数据更新
     * - 错误状态处理: 适时停止刷新
     */
    @MainActor
    private func performRefresh() async {
        print("🔄 Pull-to-refresh triggered / 下拉刷新触发")
        let version = ProcessInfo.processInfo.operatingSystemVersion
        print("📱 iOS Version: \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)")
        print("⏰ Refresh started at: \(Date())")
        
        /**
         * 步骤1: 发送重置动作
         * Step 1: Send reset action
         * 
         * 这个action会:
         * - 将所有数据状态重置为.loading
         * - 清除所有错误状态
         * - 触发loadInitialData重新加载数据
         */
        store.send(.resetForRefresh)
        
        /**
         * 步骤2: 等待数据加载
         * Step 2: Wait for data to load
         * 
         * 轮询策略 / Polling Strategy:
         * - 每100ms检查一次状态
         * - 最多等待3秒
         * - 检测到数据加载或错误时立即停止
         * 
         * iOS 15特殊处理 / iOS 15 Special Handling:
         * - iOS 15的refreshable需要明确的等待时间
         * - 否则刷新指示器可能立即消失
         */
        var waitTime = 0
        let maxWaitTime = 30 // 3秒最大等待时间 / 3 seconds max wait time
        
        /**
         * 轮询循环 - 检查数据加载状态
         * Polling Loop - Check data loading status
         * 
         * 退出条件 / Exit Conditions:
         * 1. 核心数据加载成功 (userProfile + banners)
         * 2. 出现错误状态
         * 3. 超过最大等待时间
         */
        while waitTime < maxWaitTime {
            // 使用Task.sleep实现非阻塞等待
            // Use Task.sleep for non-blocking wait
            // 100_000_000纳秒 = 0.1秒
            try? await Task.sleep(nanoseconds: 100_000_000)
            waitTime += 1
            
            /**
             * 成功条件检查
             * Success condition check
             * 
             * 为什么检查这两个状态 / Why check these two states:
             * - userProfileState: 核心用户数据，必须加载
             * - bannersState: 首屏展示内容，用户可见
             */
            if case .loaded = viewStore.userProfileState,
               case .loaded = viewStore.bannersState {
                print("✅ Data loaded, stopping refresh")
                break
            }
            
            /**
             * 错误条件检查
             * Error condition check
             * 
             * 即使有错误也要停止刷新，避免无限等待
             * Stop refresh even on error to avoid infinite waiting
             */
            if viewStore.errorDisplayMode != .none {
                print("⚠️ Errors detected, stopping refresh")
                break
            }
        }
        
        print("✅ Refresh completed at: \(Date())")
        print("📊 States after refresh:")
        print("  - userProfileState: \(viewStore.userProfileState)")
        print("  - bannersState: \(viewStore.bannersState)")
        print("  - errorDisplayMode: \(viewStore.errorDisplayMode)")
    }
    
    // MARK: - Error Banners Overlay
    
    private var errorBannersOverlay: some View {
        VStack {
            // Pink error banner at top / 顶部粉色错误横幅
            if viewStore.showPinkErrorBanner {
                PinkErrorBanner(
                    message: viewStore.coreErrorMessages.first ?? "核心服务加载失败",
                    onRetry: {
                        store.send(.retryFailedCoreAPIs)
                    },
                    isVisible: Binding(
                        get: { viewStore.showPinkErrorBanner },
                        set: { _ in store.send(.dismissPinkBanner) }
                    )
                )
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
            
            // Orange floating alert at bottom / 底部橙色悬浮提示
            if viewStore.showOrangeFloatingAlert {
                OrangeFloatingAlert(
                    message: "检测到 \(viewStore.coreErrorCount) 个核心服务异常，页面功能受限",
                    onDismiss: {
                        store.send(.dismissOrangeAlert)
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewStore.showPinkErrorBanner)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewStore.showOrangeFloatingAlert)
    }
    
    // MARK: - Normal Content
    
    private var normalContent: some View {
        VStack(spacing: 20) {
            // Banner carousel / 轮播图
            bannerSection
            
            // Categories grid / 分类网格
            categoriesSection
            
            // Order status / 订单状态
            orderStatusSection
            
            // Flash sales / 限时秒杀
            flashSalesSection
            
            // Recommended products / 推荐商品
            recommendedProductsSection
        }
    }
    
    // MARK: - Blank Page Content
    
    private var blankPageContent: some View {
        VStack(spacing: 30) {
            // Empty state icon / 空状态图标
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            // Error message / 错误消息
            VStack(spacing: 10) {
                Text("无法加载页面内容")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Page content cannot be loaded")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("请检查网络连接并重试")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("Please check your network and retry")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            
            Spacer(minLength: 100)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error State Content
    
    private var errorStateContent: some View {
        VStack(spacing: 20) {
            // 轮播图区域 - 只显示标题和错误 / Banner area - show only title and error
            sectionWithError(
                title: "轮播图 / Banners",
                message: "需要先加载用户信息 / User info required"
            )
            
            // 分类区域 - 只显示标题和错误 / Categories area - show only title and error
            sectionWithError(
                title: "分类 / Categories",
                message: "需要先加载用户信息 / User info required"
            )
            
            // 订单状态区域 - 只显示标题和错误 / Order status area - show only title and error
            sectionWithError(
                title: "我的订单 / My Orders",
                message: "需要先加载用户信息 / User info required"
            )
            
            // 秒杀区域 - 只显示标题和错误 / Flash sale area - show only title and error
            sectionWithError(
                title: "限时秒杀 / Flash Sale",
                message: "需要先加载用户信息 / User info required"
            )
            
            // 推荐商品区域 - 只显示标题和错误 / Recommended area - show only title and error
            sectionWithError(
                title: "为你推荐 / Recommended",
                message: "需要先加载用户信息 / User info required"
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - User Header Section
    
    private var userHeaderSection: some View {
        Group {
            switch viewStore.userProfileState {
            case .idle, .loading:
                userHeaderSkeleton
                
            case let .loaded(profile, _):
                UserHeaderView(profile: profile, statistics: viewStore.userStatisticsState)
                
            case .failed:
                errorPlaceholder(
                    message: "用户信息加载失败 / Failed to load user info",
                    action: { store.send(.loadUserProfile) }
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Banner Section
    
    private var bannerSection: some View {
        Group {
            // When global error (>1 component errors), show error without retry
            // 当全局错误（>1个组件错误）时，显示无重试按钮的错误
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                ComponentErrorCard(
                    title: "轮播图 / Banners",
                    error: "加载失败 / Load failed",
                    onRetry: nil  // No retry button when global error / 全局错误时无重试按钮
                )
            } else {
                switch viewStore.bannersState {
                case .idle, .loading:
                    BannerSkeleton()
                    
                case let .loaded(banners, _):
                    BannerCarousel(banners: banners) { banner in
                        store.send(.bannerTapped(banner))
                    }
                    
                case let .failed(_, error):
                    ComponentErrorCard(
                        title: "轮播图 / Banners",
                        error: error.message,
                        onRetry: { store.send(.loadBanners) }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "分类 / Categories",
                hasError: viewStore.categoriesState.errorInfo != nil || viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            
            // When global error, show error without retry / 全局错误时显示无重试按钮的错误
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(
                    message: "加载失败 / Load failed",
                    onRetry: nil  // No retry button / 无重试按钮
                )
            } else {
                switch viewStore.categoriesState {
                case .idle, .loading:
                    CategoryGridSkeleton()
                    
                case let .loaded(categories, _):
                    LazyVGrid(columns: categoryColumns, spacing: 16) {
                        ForEach(categories) { category in
                            CategoryItem(category: category) {
                                store.send(.categoryTapped(category))
                            }
                        }
                    }
                    
                case let .failed(_, error):
                    InlineError(
                        message: error.message,
                        onRetry: { store.send(.loadCategories) }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Order Status Section
    
    private var orderStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "我的订单 / My Orders",
                hasError: viewStore.orderStatusState.errorInfo != nil || viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            
            // When global error, show error without retry / 全局错误时显示无重试按钮的错误
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(
                    message: "加载失败 / Load failed",
                    onRetry: nil  // No retry button / 无重试按钮
                )
            } else {
                switch viewStore.orderStatusState {
                case .idle, .loading:
                    OrderStatusSkeleton()
                    
                case let .loaded(status, _):
                    OrderStatusCard(status: status)
                    
                case let .failed(_, error):
                    InlineError(
                        message: error.message,
                        onRetry: { store.send(.loadOrderStatus) }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Flash Sales Section
    
    private var flashSalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "限时秒杀 / Flash Sale",
                subtitle: "⚡ 手慢无",
                hasError: viewStore.flashSalesState.errorInfo != nil || viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            .padding(.horizontal)  // 添加水平边距 / Add horizontal padding
            
            // When global error, show error without retry / 全局错误时显示无重试按钮的错误
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(
                    message: "加载失败 / Load failed",
                    onRetry: nil  // No retry button / 无重试按钮
                )
                .padding(.horizontal)
            } else {
                switch viewStore.flashSalesState {
                case .idle, .loading:
                    FlashSaleSkeleton()
                    // 骨架屏已经包含padding / Skeleton already includes padding
                    
                case let .loaded(sales, _):
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sales) { sale in
                                FlashSaleCard(sale: sale) {
                                    store.send(.flashSaleTapped(sale))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                case let .failed(_, error):
                    InlineError(
                        message: error.message,
                        onRetry: { store.send(.loadFlashSales) }
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Recommended Products Section
    
    private var recommendedProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "为你推荐 / Recommended",
                hasError: viewStore.recommendedProductsState.errorInfo != nil || viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            .padding(.horizontal)
            
            // When global error, show error without retry / 全局错误时显示无重试按钮的错误
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(
                    message: "加载失败 / Load failed",
                    onRetry: nil  // No retry button / 无重试按钮
                )
                .padding(.horizontal)
            } else {
                switch viewStore.recommendedProductsState {
                case .idle, .loading:
                    ProductGridSkeleton()
                        .padding(.horizontal)
                    
                case let .loaded(products, _):
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(products) { product in
                            ProductCard(product: product) {
                                store.send(.productTapped(product))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                case let .failed(_, error):
                    InlineError(
                        message: error.message,
                        onRetry: { store.send(.loadRecommendedProducts) }
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Pink Error Banner (Top)
    
    /**
     * 粉红色错误横幅 - 顶部显示
     * Pink error banner - shown at top
     * 
     * 特点 / Features:
     * - 只重试失败的接口 / Only retry failed APIs
     * - 显示具体错误信息 / Show specific error messages
     * - 温和的粉红色背景 / Soft pink background
     */
    private var pinkErrorBanner: some View {
        VStack(spacing: 12) {
            // Error icon and title / 错误图标和标题
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("用户信息加载失败 / User info failed")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Show which APIs failed / 显示哪些API失败了
                    Text(failedAPIsDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // Smart retry button / 智能重试按钮
            Button(action: { store.send(.retryFailedCoreAPIs) }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("重试失败项 / Retry Failed")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.pink.opacity(0.9), Color.pink.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // 获取失败的API描述 / Get failed APIs description
    private var failedAPIsDescription: String {
        var failed: [String] = []
        if case .failed = viewStore.userProfileState { failed.append("用户资料") }
        if case .failed = viewStore.userSettingsState { failed.append("设置") }
        if case .failed = viewStore.userStatisticsState { failed.append("统计") }
        if case .failed = viewStore.userPermissionsState { failed.append("权限") }
        if case .failed = viewStore.userNotificationsState { failed.append("通知") }
        
        if failed.isEmpty {
            return ""
        }
        return "失败: \(failed.joined(separator: ", ")) / Failed: \(failed.count) items"
    }
    
    // MARK: - Section With Error
    
    /**
     * 带错误的区域组件
     * Section component with error
     * 
     * 用于核心API失败时显示 / Used when core APIs fail
     */
    private func sectionWithError(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title / 区域标题
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            // Error message box / 错误消息框
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Global Error Banner (Bottom)
    
    /**
     * 橙色全局错误横幅 - 底部悬浮
     * Orange global error banner - floating at bottom
     * 
     * 特点 / Features:
     * - 重试所有5个核心接口 / Retry all 5 core APIs
     * - 悬浮在底部 / Floating at bottom
     * - 醒目的橙色背景 / Eye-catching orange background
     */
    private var globalErrorBanner: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 12) {
                // Error message / 错误消息
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("核心服务加载失败 / Core services failed")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("部分用户信息无法加载，功能受限 / Some features limited")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Retry all button / 重试所有按钮
                Button(action: { store.send(.retryAllCoreAPIs) }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.body)
                        Text("重新加载所有信息 / Reload All Info")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.orange.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: -5)
            .padding()
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - Toolbar
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "cart")
                            .overlay(
                                cartBadge,
                                alignment: .topTrailing
                            )
                    }
                }
            }
        }
    }
    
    private var cartBadge: some View {
        Group {
            if case let .loaded(statistics, _) = viewStore.userStatisticsState,
               statistics.cartItemCount > 0 {
                Text("\(statistics.cartItemCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(
        title: String,
        subtitle: String? = nil,
        hasError: Bool = false
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if hasError {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
    }
    
    private func errorPlaceholder(
        message: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("重试 / Retry", action: action)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var userHeaderSkeleton: some View {
        HStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 12)
            }
            
            Spacer()
        }
        .padding()
        .shimmering()
    }
}

// MARK: - Component Views

/**
 * 用户头部组件
 * User header component
 */
struct UserHeaderView: View {
    let profile: UserProfile
    let statistics: ReduxPageState<UserStatistics>
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar / 头像
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Text(profile.nickname.prefix(1))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // User info / 用户信息
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(profile.nickname)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Member badge / 会员徽章
                    Text(profile.memberLevel.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(memberLevelColor(profile.memberLevel))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 16) {
                    Label("\(profile.points)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if case let .loaded(stats, _) = statistics {
                        Label("\(stats.couponsAvailable) 优惠券", systemImage: "ticket.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            // Balance / 余额
            VStack(alignment: .trailing) {
                Text("¥\(profile.balance, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("余额 / Balance")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private func memberLevelColor(_ level: UserProfile.MemberLevel) -> Color {
        switch level {
        case .normal: return .gray
        case .silver: return .init(white: 0.7)
        case .gold: return .orange
        case .platinum: return .purple
        case .diamond: return .cyan
        }
    }
}

/**
 * 其他组件视图的占位实现
 * Placeholder implementations for other component views
 */

struct BannerCarousel: View {
    let banners: [Banner]
    let onTap: (Banner) -> Void
    
    var body: some View {
        TabView {
            ForEach(banners) { banner in
                BannerCard(banner: banner, onTap: onTap)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 180)
    }
}

struct BannerCard: View {
    let banner: Banner
    let onTap: (Banner) -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                VStack(alignment: .leading) {
                    Text(banner.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let subtitle = banner.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .padding()
            )
            .onTapGesture { onTap(banner) }
    }
}

struct CategoryItem: View {
    let category: Category
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color(hex: category.colorHex).opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: category.iconName)
                        .font(.title2)
                        .foregroundColor(Color(hex: category.colorHex))
                )
            
            Text(category.name)
                .font(.caption2)
                .lineLimit(1)
        }
        .onTapGesture(perform: onTap)
    }
}

struct OrderStatusCard: View {
    let status: UserOrderStatus
    
    var body: some View {
        HStack(spacing: 0) {
            statusItem("待付款", count: status.pendingPayment, icon: "creditcard")
            statusItem("待发货", count: status.pendingShipment, icon: "shippingbox")
            statusItem("待收货", count: status.shipped, icon: "truck")
            statusItem("待评价", count: status.pendingReview, icon: "star")
            statusItem("退款/售后", count: status.refunding, icon: "arrow.uturn.left")
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func statusItem(_ title: String, count: Int, icon: String) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(3)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FlashSaleCard: View {
    let sale: FlashSale
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 120)
            
            Text(sale.product.name)
                .font(.caption)
                .lineLimit(2)
            
            HStack {
                Text("¥\(sale.flashPrice, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("¥\(sale.product.originalPrice, specifier: "%.0f")")
                    .font(.caption2)
                    .strikethrough()
                    .foregroundColor(.secondary)
            }
            
            // Progress bar / 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red)
                        .frame(width: geometry.size.width * sale.soldPercentage)
                }
            }
            .frame(height: 4)
            
            Text("已抢\(Int(sale.soldPercentage * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3)
        .onTapGesture(perform: onTap)
    }
}

struct ProductCard: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Group {
                        if product.isNew {
                            Text("NEW")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(4)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        } else if product.isHot {
                            Text("HOT")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    },
                    alignment: .topLeading
                )
            
            Text(product.name)
                .font(.subheadline)
                .lineLimit(2)
            
            HStack {
                Text("¥\(product.currentPrice, specifier: "%.0f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                if product.discountPercentage > 0 {
                    Text("-\(product.discountPercentage)%")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
            }
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                
                Text("\(product.rating, specifier: "%.1f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("(\(product.reviewCount))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(product.salesCount)已售")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3)
        .onTapGesture(perform: onTap)
    }
}

// Component Error Card / 组件错误卡片
struct ComponentErrorCard: View {
    let title: String
    let error: String
    let onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.orange)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let onRetry = onRetry {
                Button("重试 / Retry", action: onRetry)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Inline Error / 内联错误
struct InlineError: View {
    let message: String
    let onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            // Error message row / 错误消息行
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Retry button row / 重试按钮行
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("重试 / Retry")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// Skeleton views / 骨架屏视图
struct BannerSkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(height: 180)
            .shimmering()
    }
}

struct CategoryGridSkeleton: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
            ForEach(0..<8) { _ in
                VStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                }
            }
        }
        .shimmering()
    }
}

struct OrderStatusSkeleton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(height: 80)
            .shimmering()
    }
}

struct FlashSaleSkeleton: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 120, height: 180)
                }
            }
            .padding(.horizontal)
        }
        .shimmering()
    }
}

struct ProductGridSkeleton: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(0..<4) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(0.7, contentMode: .fit)
            }
        }
        .shimmering()
    }
}

// Shimmer effect / 闪烁效果
struct ShimmeringView: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase * 200 - 100)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmeringView())
    }
}