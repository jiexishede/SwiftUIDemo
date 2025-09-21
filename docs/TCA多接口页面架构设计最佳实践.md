# TCA 多接口页面架构设计最佳实践

## 问题分析 / Problem Analysis

对于商城首页这种复杂页面，通常需要请求多个接口来获取不同模块的数据，如：轮播图、商品分类、推荐商品、热销商品、用户信息等。在使用 The Composable Architecture (TCA) 时，面临的核心问题是如何合理地组织这些多个数据源和交互逻辑。

For complex pages like e-commerce homepages, multiple API calls are typically required to fetch data for different modules such as: banners, product categories, recommended products, hot-selling products, user information, etc. When using The Composable Architecture (TCA), the core challenge is how to properly organize these multiple data sources and interaction logic.

## 架构方案对比 / Architecture Comparison

### 方案一：单一大 Reducer (Monolithic Reducer)

**设计思路** / **Design Approach:**

将整个页面作为一个大的 Feature，所有接口数据和交互逻辑都在一个 Reducer 中处理。

Treat the entire page as one large Feature, handling all API data and interaction logic within a single Reducer.

**优势** / **Advantages:**
- 状态管理集中，数据流清晰
- 减少 Reducer 间的通信复杂度
- 全局 loading 状态容易控制
- 数据依赖关系容易处理

- Centralized state management with clear data flow
- Reduced communication complexity between Reducers
- Easy to control global loading states
- Simple to handle data dependencies

**劣势** / **Disadvantages:**
- Reducer 代码量庞大，难以维护
- 功能耦合严重，测试困难
- 团队协作困难，容易产生代码冲突
- 复用性差，难以在其他页面使用

- Large Reducer code that's hard to maintain
- High coupling between features, difficult to test
- Team collaboration challenges, prone to code conflicts
- Poor reusability, hard to use in other pages

### 方案二：多个小 Reducer 组合 (Composite Small Reducers)

**设计思路** / **Design Approach:**

将页面按功能模块拆分为多个独立的 Feature Reducer，然后通过 Composite Reducer 组合在一起。

Split the page into multiple independent Feature Reducers by functional modules, then combine them using Composite Reducers.

**优势** / **Advantages:**
- 模块化程度高，代码组织清晰
- 每个模块可独立开发、测试、维护
- 复用性强，可在其他页面复用
- 团队协作友好，减少代码冲突

- High modularity with clear code organization
- Each module can be independently developed, tested, and maintained
- Strong reusability for other pages
- Team-friendly collaboration with reduced code conflicts

**劣势** / **Disadvantages:**
- Reducer 间通信需要额外设计
- 全局状态协调复杂
- 学习成本相对较高
- 初期架构设计工作量大

- Inter-Reducer communication requires additional design
- Complex global state coordination
- Higher learning curve
- More upfront architectural design work

## 推荐方案：混合模式 (Recommended: Hybrid Approach)

基于实际项目经验和 TCA 最佳实践，我们推荐采用**混合模式**：页面级 Reducer + 功能模块 Reducer 的组合。

Based on practical project experience and TCA best practices, we recommend a **Hybrid Approach**: Page-level Reducer + Feature Module Reducers combination.

### 架构设计原则 / Architecture Design Principles

1. **单一职责原则** / **Single Responsibility Principle**
   - 每个 Reducer 只负责一个明确的功能域
   - Each Reducer is responsible for one clear functional domain

2. **最小化跨模块依赖** / **Minimize Cross-Module Dependencies**
   - 优先使用组合而非继承
   - Prefer composition over inheritance

3. **可测试性优先** / **Testability First**
   - 每个模块都可以独立测试
   - Each module can be tested independently

4. **性能优化考虑** / **Performance Optimization Considerations**
   - 避免不必要的状态更新和 UI 重绘
   - Avoid unnecessary state updates and UI redraws

## 具体实现方案 / Implementation Details

### 第一步：定义页面整体架构 / Step 1: Define Overall Page Architecture

```swift
/**
 * ECommerceHomeFeature.swift
 * 商城首页主 Feature，负责协调各个子模块
 * 
 * E-commerce homepage main Feature responsible for coordinating sub-modules
 * 
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Composite Pattern (组合模式)
 *    - Why: 将多个子模块组合成复杂页面 / Combine multiple sub-modules into complex page
 *    - Benefits: 模块化、可复用、易测试 / Modularity, reusability, testability
 *    - Implementation: 使用 TCA 的 Scope 和 Reducer 组合 / Using TCA's Scope and Reducer composition
 * 
 * 2. Coordinator Pattern (协调器模式)
 *    - Why: 协调各子模块间的数据流和状态同步 / Coordinate data flow and state sync between sub-modules
 *    - Benefits: 解耦模块间依赖、集中控制页面逻辑 / Decouple module dependencies, centralize page logic
 *    - Implementation: 页面级 Reducer 作为协调器 / Page-level Reducer as coordinator
 * 
 * SOLID PRINCIPLES / SOLID 原则:
 * - SRP: 页面 Reducer 只负责协调，不处理具体业务逻辑 / Page Reducer only coordinates, doesn't handle specific business logic
 * - OCP: 可通过添加新的子模块扩展功能 / Can extend functionality by adding new sub-modules
 * - LSP: 所有子模块都遵循相同的 Feature 协议 / All sub-modules follow the same Feature protocol
 * - ISP: 每个模块只依赖它需要的接口 / Each module only depends on interfaces it needs
 * - DIP: 依赖抽象的 API 服务，不依赖具体实现 / Depend on abstract API services, not concrete implementations
 * 
 * USAGE EXAMPLES / 使用示例:
 * ```
 * // 在 ContentView 中使用 / Usage in ContentView
 * struct ContentView: View {
 *     let store = Store(initialState: ECommerceHomeFeature.State()) {
 *         ECommerceHomeFeature()
 *     }
 *     
 *     var body: some View {
 *         ECommerceHomeView(store: store)
 *     }
 * }
 * 
 * // 发送页面加载动作 / Send page load action
 * store.send(.onAppear)
 * 
 * // 处理下拉刷新 / Handle pull-to-refresh
 * store.send(.pullToRefresh)
 * ```
 */
import ComposableArchitecture
import Foundation

@Reducer
struct ECommerceHomeFeature {
    @ObservableState
    struct State: Equatable {
        // 页面级状态 / Page-level state
        var isPageLoading = false
        var pageError: String?
        var lastRefreshTime: Date?
        
        // 子模块状态 / Sub-module states
        var bannerState = BannerFeature.State()
        var categoryState = CategoryFeature.State()
        var recommendedProductsState = RecommendedProductsFeature.State()
        var hotSalesState = HotSalesFeature.State()
        var userProfileState = UserProfileFeature.State()
        
        // 计算属性：页面是否正在加载 / Computed property: is page loading
        var isAnyModuleLoading: Bool {
            return bannerState.isLoading || 
                   categoryState.isLoading || 
                   recommendedProductsState.isLoading || 
                   hotSalesState.isLoading ||
                   userProfileState.isLoading
        }
        
        // 计算属性：是否所有模块都加载完成 / Computed property: are all modules loaded
        var areAllModulesLoaded: Bool {
            return bannerState.isLoaded && 
                   categoryState.isLoaded && 
                   recommendedProductsState.isLoaded && 
                   hotSalesState.isLoaded &&
                   userProfileState.isLoaded
        }
    }
    
    enum Action: Equatable {
        // 页面级动作 / Page-level actions
        case onAppear
        case pullToRefresh
        case pageLoadingStarted
        case pageLoadingCompleted
        case pageErrorOccurred(String)
        
        // 子模块动作 / Sub-module actions
        case banner(BannerFeature.Action)
        case category(CategoryFeature.Action)
        case recommendedProducts(RecommendedProductsFeature.Action)
        case hotSales(HotSalesFeature.Action)
        case userProfile(UserProfileFeature.Action)
        
        // 模块间通信动作 / Inter-module communication actions
        case categorySelected(CategoryModel)
        case productTapped(ProductModel)
        case userLoginStatusChanged(Bool)
    }
    
    var body: some ReducerOf<Self> {
        // 组合所有子模块 Reducer / Compose all sub-module Reducers
        Scope(state: \.bannerState, action: \.banner) {
            BannerFeature()
        }
        
        Scope(state: \.categoryState, action: \.category) {
            CategoryFeature()
        }
        
        Scope(state: \.recommendedProductsState, action: \.recommendedProducts) {
            RecommendedProductsFeature()
        }
        
        Scope(state: \.hotSalesState, action: \.hotSales) {
            HotSalesFeature()
        }
        
        Scope(state: \.userProfileState, action: \.userProfile) {
            UserProfileFeature()
        }
        
        // 页面级 Reducer 逻辑 / Page-level Reducer logic
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 页面首次出现，触发所有模块加载 / Page first appears, trigger all module loading
                state.isPageLoading = true
                state.pageError = nil
                
                return .run { send in
                    // 并发加载所有模块数据 / Concurrently load all module data
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask { await send(.banner(.loadData)) }
                        group.addTask { await send(.category(.loadData)) }
                        group.addTask { await send(.recommendedProducts(.loadData)) }
                        group.addTask { await send(.hotSales(.loadData)) }
                        group.addTask { await send(.userProfile(.loadData)) }
                    }
                    
                    await send(.pageLoadingCompleted)
                }
                
            case .pullToRefresh:
                // 下拉刷新，重新加载所有数据 / Pull-to-refresh, reload all data
                state.lastRefreshTime = Date()
                
                return .run { send in
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask { await send(.banner(.refresh)) }
                        group.addTask { await send(.category(.refresh)) }
                        group.addTask { await send(.recommendedProducts(.refresh)) }
                        group.addTask { await send(.hotSales(.refresh)) }
                        group.addTask { await send(.userProfile(.refresh)) }
                    }
                }
                
            case .pageLoadingStarted:
                state.isPageLoading = true
                return .none
                
            case .pageLoadingCompleted:
                state.isPageLoading = false
                return .none
                
            case .pageErrorOccurred(let error):
                state.pageError = error
                state.isPageLoading = false
                return .none
                
            // 处理模块间通信 / Handle inter-module communication
            case .categorySelected(let category):
                // 当用户选择分类时，更新推荐商品 / Update recommended products when category is selected
                return .send(.recommendedProducts(.filterByCategory(category)))
                
            case .productTapped(let product):
                // 处理商品点击，可能影响多个模块 / Handle product tap, may affect multiple modules
                return .run { send in
                    // 记录用户行为，可能影响推荐算法 / Log user behavior, may affect recommendation algorithm
                    await send(.userProfile(.recordProductView(product)))
                    await send(.recommendedProducts(.updateRecommendations))
                }
                
            case .userLoginStatusChanged(let isLoggedIn):
                // 用户登录状态变化，影响多个模块 / User login status changed, affects multiple modules
                return .run { send in
                    if isLoggedIn {
                        await send(.userProfile(.loadUserData))
                        await send(.recommendedProducts(.loadPersonalizedRecommendations))
                    } else {
                        await send(.userProfile(.clearUserData))
                        await send(.recommendedProducts(.loadDefaultRecommendations))
                    }
                }
                
            // 子模块动作处理 / Sub-module action handling
            case .banner, .category, .recommendedProducts, .hotSales, .userProfile:
                // 这些动作由相应的 Scope 处理 / These actions are handled by corresponding Scopes
                return .none
            }
        }
    }
}
```

### 第二步：定义各个功能模块 / Step 2: Define Feature Modules

```swift
/**
 * BannerFeature.swift
 * 轮播图模块，负责首页banner展示和交互
 * 
 * Banner module responsible for homepage banner display and interaction
 */
@Reducer
struct BannerFeature {
    @ObservableState
    struct State: Equatable {
        var banners: [BannerModel] = []
        var isLoading = false
        var isLoaded = false
        var error: String?
        var currentIndex = 0
    }
    
    enum Action: Equatable {
        case loadData
        case refresh
        case dataLoaded([BannerModel])
        case loadingFailed(String)
        case bannerTapped(BannerModel)
        case autoScrollToNext
    }
    
    @Dependency(\.bannerService) var bannerService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadData, .refresh:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        let banners = try await bannerService.fetchBanners()
                        await send(.dataLoaded(banners))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
                
            case .dataLoaded(let banners):
                state.banners = banners
                state.isLoading = false
                state.isLoaded = true
                state.error = nil
                return .none
                
            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none
                
            case .bannerTapped(let banner):
                // 处理banner点击事件 / Handle banner tap event
                return .run { _ in
                    // 跳转到对应页面或处理相关业务逻辑
                    // Navigate to corresponding page or handle related business logic
                }
                
            case .autoScrollToNext:
                if !state.banners.isEmpty {
                    state.currentIndex = (state.currentIndex + 1) % state.banners.count
                }
                return .none
            }
        }
    }
}

/**
 * RecommendedProductsFeature.swift
 * 推荐商品模块，支持个性化推荐和分类筛选
 * 
 * Recommended products module supporting personalized recommendations and category filtering
 */
@Reducer
struct RecommendedProductsFeature {
    @ObservableState
    struct State: Equatable {
        var products: [ProductModel] = []
        var isLoading = false
        var isLoaded = false
        var error: String?
        var currentCategory: CategoryModel?
        var isPersonalized = false
    }
    
    enum Action: Equatable {
        case loadData
        case refresh
        case loadPersonalizedRecommendations
        case loadDefaultRecommendations
        case filterByCategory(CategoryModel)
        case dataLoaded([ProductModel])
        case loadingFailed(String)
        case productTapped(ProductModel)
        case updateRecommendations
    }
    
    @Dependency(\.productService) var productService
    @Dependency(\.userService) var userService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadData:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    // 根据用户登录状态决定加载个性化还是默认推荐
                    // Load personalized or default recommendations based on user login status
                    let isLoggedIn = await userService.isUserLoggedIn()
                    if isLoggedIn {
                        await send(.loadPersonalizedRecommendations)
                    } else {
                        await send(.loadDefaultRecommendations)
                    }
                }
                
            case .loadPersonalizedRecommendations:
                state.isPersonalized = true
                
                return .run { send in
                    do {
                        let products = try await productService.fetchPersonalizedRecommendations()
                        await send(.dataLoaded(products))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
                
            case .loadDefaultRecommendations:
                state.isPersonalized = false
                
                return .run { send in
                    do {
                        let products = try await productService.fetchDefaultRecommendations()
                        await send(.dataLoaded(products))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
                
            case .filterByCategory(let category):
                state.currentCategory = category
                state.isLoading = true
                
                return .run { send in
                    do {
                        let products = try await productService.fetchProductsByCategory(category.id)
                        await send(.dataLoaded(products))
                    } catch {
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
                
            case .dataLoaded(let products):
                state.products = products
                state.isLoading = false
                state.isLoaded = true
                state.error = nil
                return .none
                
            case .loadingFailed(let error):
                state.error = error
                state.isLoading = false
                return .none
                
            case .productTapped(let product):
                // 处理商品点击 / Handle product tap
                return .run { _ in
                    // 跳转到商品详情页面
                    // Navigate to product detail page
                }
                
            case .updateRecommendations:
                // 更新推荐算法 / Update recommendation algorithm
                return .run { send in
                    if state.isPersonalized {
                        await send(.loadPersonalizedRecommendations)
                    }
                }
                
            case .refresh:
                return .send(.loadData)
            }
        }
    }
}
```

### 第三步：处理页面加载状态协调 / Step 3: Handle Page Loading State Coordination

```swift
/**
 * ECommerceHomeView.swift
 * 商城首页视图，展示所有模块并协调加载状态
 * 
 * E-commerce homepage view displaying all modules and coordinating loading states
 */
import SwiftUI
import ComposableArchitecture

struct ECommerceHomeView: View {
    let store: StoreOf<ECommerceHomeFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                // 主要内容 / Main content
                mainContent(viewStore)
                
                // 全局加载状态覆盖层 / Global loading state overlay
                if viewStore.isPageLoading {
                    LoadingOverlayView(message: "正在加载首页数据...")
                }
            }
            .refreshable {
                // iOS 15+ 下拉刷新支持 / iOS 15+ pull-to-refresh support
                await viewStore.send(.pullToRefresh).finish()
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .alert(
                "加载失败",
                isPresented: .constant(viewStore.pageError != nil),
                actions: {
                    Button("重试") {
                        viewStore.send(.onAppear)
                    }
                    Button("取消", role: .cancel) { }
                },
                message: {
                    Text(viewStore.pageError ?? "")
                }
            )
        }
    }
    
    @ViewBuilder
    private func mainContent(_ viewStore: ViewStoreOf<ECommerceHomeFeature>) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Banner 轮播图模块 / Banner carousel module
                BannerView(
                    store: store.scope(
                        state: \.bannerState,
                        action: \.banner
                    )
                )
                .frame(height: 200)
                
                // 商品分类模块 / Product category module
                CategoryView(
                    store: store.scope(
                        state: \.categoryState,
                        action: \.category
                    )
                )
                
                // 推荐商品模块 / Recommended products module
                RecommendedProductsView(
                    store: store.scope(
                        state: \.recommendedProductsState,
                        action: \.recommendedProducts
                    )
                )
                
                // 热销商品模块 / Hot sales module
                HotSalesView(
                    store: store.scope(
                        state: \.hotSalesState,
                        action: \.hotSales
                    )
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

/**
 * 全局加载覆盖层视图 / Global loading overlay view
 * 当页面首次加载或全量刷新时显示
 * Displayed during initial page load or full refresh
 */
struct LoadingOverlayView: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
        }
    }
}
```

### 第四步：处理各模块独立加载状态 / Step 4: Handle Independent Module Loading States

```swift
/**
 * RecommendedProductsView.swift
 * 推荐商品视图，支持独立的加载状态展示
 * 
 * Recommended products view with independent loading state display
 */
struct RecommendedProductsView: View {
    let store: StoreOf<RecommendedProductsFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 12) {
                // 模块标题 / Module title
                HStack {
                    Text("推荐商品")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if viewStore.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                // 内容区域 / Content area
                contentView(viewStore)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private func contentView(_ viewStore: ViewStoreOf<RecommendedProductsFeature>) -> some View {
        if viewStore.isLoading && viewStore.products.isEmpty {
            // 首次加载占位视图 / Initial loading placeholder
            VStack {
                ProgressView("正在加载推荐商品...")
                    .font(.caption)
            }
            .frame(height: 150)
            
        } else if let error = viewStore.error, viewStore.products.isEmpty {
            // 错误状态视图 / Error state view
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("加载失败")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("重试") {
                    viewStore.send(.loadData)
                }
                .buttonStyle(.bordered)
            }
            .frame(height: 150)
            
        } else if viewStore.products.isEmpty && viewStore.isLoaded {
            // 空状态视图 / Empty state view
            VStack(spacing: 12) {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("暂无推荐商品")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(height: 150)
            
        } else {
            // 商品列表 / Products list
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 12) {
                ForEach(viewStore.products) { product in
                    ProductCardView(product: product) {
                        viewStore.send(.productTapped(product))
                    }
                }
            }
        }
    }
}

/**
 * 模块级加载状态管理扩展 / Module-level loading state management extension
 */
extension View {
    /**
     * 为模块添加独立的加载状态支持
     * Add independent loading state support for modules
     */
    func moduleLoading(
        _ isLoading: Bool,
        message: String = "加载中...",
        allowInteraction: Bool = true
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            self
                .disabled(isLoading && !allowInteraction)
            
            if isLoading {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                    
                    Text(message)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .offset(x: -8, y: 8)
            }
        }
    }
}
```

## 最佳实践总结 / Best Practices Summary

### 1. 数据加载策略 / Data Loading Strategy

**并发加载** / **Concurrent Loading:**
使用 Swift 的 `TaskGroup` 实现多个接口的并发调用，提高页面加载速度。

Use Swift's `TaskGroup` to implement concurrent API calls for faster page loading.

**渐进式加载** / **Progressive Loading:**
允许已加载完成的模块优先展示，而不是等待所有模块都加载完成。

Allow loaded modules to display first without waiting for all modules to complete.

**错误隔离** / **Error Isolation:**
单个模块的加载失败不应影响其他模块的正常展示。

A single module's loading failure should not affect other modules' normal display.

### 2. 状态管理策略 / State Management Strategy

**分层状态设计** / **Layered State Design:**
- 页面级状态：控制整体页面的加载和错误状态
- 模块级状态：管理各自模块的业务数据和交互状态

- Page-level state: Control overall page loading and error states
- Module-level state: Manage individual module business data and interaction states

**状态同步机制** / **State Synchronization Mechanism:**
通过页面级 Reducer 协调模块间的状态同步和数据共享。

Coordinate inter-module state synchronization and data sharing through page-level Reducer.

### 3. 用户体验优化 / User Experience Optimization

**加载状态可视化** / **Loading State Visualization:**
- 全局加载：页面首次加载或完整刷新时
- 局部加载：单个模块刷新或更新时
- 骨架屏：为重要模块提供骨架屏加载效果

- Global loading: During initial page load or complete refresh
- Local loading: During individual module refresh or updates
- Skeleton screens: Provide skeleton loading effects for important modules

**错误处理用户友好** / **User-Friendly Error Handling:**
提供明确的错误信息和重试机制，允许用户针对特定模块进行重试。

Provide clear error messages and retry mechanisms, allowing users to retry specific modules.

### 4. 性能优化建议 / Performance Optimization Recommendations

**懒加载实现** / **Lazy Loading Implementation:**
使用 `LazyVStack` 和 `LazyVGrid` 优化长列表的渲染性能。

Use `LazyVStack` and `LazyVGrid` to optimize long list rendering performance.

**内存管理** / **Memory Management:**
及时清理不再需要的状态数据，避免内存泄漏。

Clean up state data that's no longer needed to avoid memory leaks.

**网络请求优化** / **Network Request Optimization:**
- 实现请求去重，避免重复请求
- 使用缓存机制减少不必要的网络调用
- 实现请求优先级，优先加载用户可见区域的数据

- Implement request deduplication to avoid duplicate requests
- Use caching mechanisms to reduce unnecessary network calls
- Implement request prioritization to load visible area data first

### 5. 测试策略 / Testing Strategy

**单元测试** / **Unit Testing:**
每个 Reducer 都应该有完整的单元测试覆盖，测试各种状态转换和边界情况。

Each Reducer should have complete unit test coverage for various state transitions and edge cases.

**集成测试** / **Integration Testing:**
测试页面级 Reducer 与各子模块的协调工作是否正确。

Test whether page-level Reducer coordinates correctly with sub-modules.

**UI 测试** / **UI Testing:**
使用 XCUITest 测试完整的用户交互流程，确保多模块页面的用户体验。

Use XCUITest to test complete user interaction flows and ensure multi-module page user experience.

## 总结 / Conclusion

对于商城首页这种复杂的多接口页面，推荐采用**混合模式**的 TCA 架构：

For complex multi-API pages like e-commerce homepages, we recommend using a **Hybrid TCA Architecture**:

1. **页面级 Reducer**：负责协调和全局状态管理
2. **功能模块 Reducer**：负责具体的业务逻辑和数据处理
3. **组合式设计**：通过 Scope 将模块组合成完整页面
4. **渐进式加载**：支持模块独立加载和错误处理

1. **Page-level Reducer**: Responsible for coordination and global state management
2. **Feature Module Reducers**: Handle specific business logic and data processing
3. **Composite Design**: Combine modules into complete pages through Scope
4. **Progressive Loading**: Support independent module loading and error handling

这种架构既保持了 TCA 的优势（可测试性、可预测性、可组合性），又能有效应对复杂页面的开发和维护挑战。

This architecture maintains TCA's advantages (testability, predictability, composability) while effectively addressing the development and maintenance challenges of complex pages.

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "\u5206\u6790 TCA \u591a\u63a5\u53e3\u9875\u9762\u67b6\u6784\u8bbe\u8ba1\u95ee\u9898", "status": "completed", "activeForm": "\u5206\u6790 TCA \u591a\u63a5\u53e3\u9875\u9762\u67b6\u6784\u8bbe\u8ba1\u95ee\u9898"}, {"content": "\u7814\u7a76\u5546\u57ce\u9996\u9875\u591a\u63a5\u53e3\u6570\u636e\u83b7\u53d6\u7684\u6700\u4f73\u5b9e\u8df5", "status": "completed", "activeForm": "\u7814\u7a76\u5546\u57ce\u9996\u9875\u591a\u63a5\u53e3\u6570\u636e\u83b7\u53d6\u7684\u6700\u4f73\u5b9e\u8df5"}, {"content": "\u8bbe\u8ba1 TCA \u67b6\u6784\u65b9\u6848\u5bf9\u6bd4\u5206\u6790", "status": "completed", "activeForm": "\u8bbe\u8ba1 TCA \u67b6\u6784\u65b9\u6848\u5bf9\u6bd4\u5206\u6790"}, {"content": "\u7f16\u5199\u8be6\u7ec6\u7684\u6280\u672f\u6587\u6863\u548c\u5b9e\u73b0\u793a\u4f8b", "status": "completed", "activeForm": "\u7f16\u5199\u8be6\u7ec6\u7684\u6280\u672f\u6587\u6863\u548c\u5b9e\u73b0\u793a\u4f8b"}]