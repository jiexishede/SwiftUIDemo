# TCA 复杂页面架构设计指南

## 概述

在使用 TCA (The Composable Architecture) 处理复杂页面（如商城首页）的多接口请求时，推荐使用**组合式架构**方案。即将页面拆分成多个子 Reducer，然后组合成一个父 Reducer。这样既保持了模块化，又能统一管理状态。

## 架构设计

### 1. 基础结构设计

主页面采用父 Reducer 组合多个子 Reducer 的方式：

```swift
// 主页面的 Reducer
struct HomeFeature: Reducer {
    struct State: Equatable {
        // 子模块状态
        var banner = BannerFeature.State()
        var categoryList = CategoryFeature.State()
        var productList = ProductFeature.State()
        var userInfo = UserInfoFeature.State()
        
        // 页面级别的状态
        var isRefreshing = false
        var lastRefreshTime: Date?
    }
    
    enum Action: Equatable {
        // 子模块动作
        case banner(BannerFeature.Action)
        case categoryList(CategoryFeature.Action)
        case productList(ProductFeature.Action)
        case userInfo(UserInfoFeature.Action)
        
        // 页面级别的动作
        case onAppear
        case refresh
        case handleDeepLink(URL)
    }
    
    var body: some Reducer<State, Action> {
        // 组合子 Reducer
        Scope(state: \.banner, action: /Action.banner) {
            BannerFeature()
        }
        
        Scope(state: \.categoryList, action: /Action.categoryList) {
            CategoryFeature()
        }
        
        Scope(state: \.productList, action: /Action.productList) {
            ProductFeature()
        }
        
        Scope(state: \.userInfo, action: /Action.userInfo) {
            UserInfoFeature()
        }
        
        // 处理页面级别的逻辑
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    // 并行触发多个接口请求
                    .send(.banner(.loadBanners)),
                    .send(.categoryList(.loadCategories)),
                    .send(.productList(.loadProducts)),
                    .send(.userInfo(.loadUserInfo))
                )
                
            case .refresh:
                state.isRefreshing = true
                return .merge(
                    .send(.banner(.refresh)),
                    .send(.categoryList(.refresh)),
                    .send(.productList(.refresh))
                )
                
            case .banner(.bannersLoaded):
                // 可以在这里处理跨模块的逻辑
                return .none
                
            default:
                return .none
            }
        }
    }
}
```

### 2. 子模块实现示例

每个子模块独立管理自己的状态和业务逻辑：

```swift
// Banner 模块
struct BannerFeature: Reducer {
    struct State: Equatable {
        var banners: [Banner] = []
        var isLoading = false
        var error: String?
        var currentIndex = 0
    }
    
    enum Action: Equatable {
        case loadBanners
        case bannersResponse(TaskResult<[Banner]>)
        case selectBanner(Int)
        case autoScroll
        case refresh
    }
    
    @Dependency(\.bannerClient) var bannerClient
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadBanners:
                state.isLoading = true
                return .run { send in
                    await send(.bannersResponse(
                        TaskResult { try await bannerClient.fetchBanners() }
                    ))
                }
                
            case let .bannersResponse(.success(banners)):
                state.banners = banners
                state.isLoading = false
                // 启动自动轮播
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(3)) {
                        await send(.autoScroll)
                    }
                }
                .cancellable(id: CancelID.autoScroll)
                
            case let .bannersResponse(.failure(error)):
                state.error = error.localizedDescription
                state.isLoading = false
                return .none
                
            case .autoScroll:
                state.currentIndex = (state.currentIndex + 1) % state.banners.count
                return .none
                
            default:
                return .none
            }
        }
    }
    
    enum CancelID { case autoScroll }
}
```

### 3. 跨模块交互处理

处理模块间的复杂交互逻辑：

```swift
// 处理跨模块交互
extension HomeFeature {
    func handleCrossModuleInteractions() -> some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // 当选择分类时，更新商品列表
            case let .categoryList(.selectCategory(categoryId)):
                return .send(.productList(.filterByCategory(categoryId)))
                
            // 当用户登录状态改变时，刷新多个模块
            case .userInfo(.loginStatusChanged):
                return .merge(
                    .send(.productList(.refreshWithUserContext)),
                    .send(.banner(.loadPersonalizedBanners))
                )
                
            // 处理深度链接
            case let .handleDeepLink(url):
                // 解析 URL 并分发到相应模块
                if url.path.contains("product") {
                    return .send(.productList(.openProduct(url)))
                } else if url.path.contains("category") {
                    return .send(.categoryList(.openCategory(url)))
                }
                return .none
                
            default:
                return .none
            }
        }
    }
}
```

### 4. 依赖注入管理

统一管理 API 客户端和其他依赖：

```swift
// 统一管理 API 客户端
struct APIClient {
    var fetchBanners: @Sendable () async throws -> [Banner]
    var fetchCategories: @Sendable () async throws -> [Category]
    var fetchProducts: @Sendable (String?) async throws -> [Product]
    var fetchUserInfo: @Sendable () async throws -> UserInfo
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        fetchBanners: {
            // 实际网络请求实现
            let url = URL(string: "https://api.example.com/banners")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Banner].self, from: data)
        },
        fetchCategories: {
            // 实际网络请求实现
            let url = URL(string: "https://api.example.com/categories")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Category].self, from: data)
        },
        fetchProducts: { categoryId in
            // 实际网络请求实现
            var components = URLComponents(string: "https://api.example.com/products")!
            if let categoryId = categoryId {
                components.queryItems = [URLQueryItem(name: "category", value: categoryId)]
            }
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try JSONDecoder().decode([Product].self, from: data)
        },
        fetchUserInfo: {
            // 实际网络请求实现
            let url = URL(string: "https://api.example.com/user")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(UserInfo.self, from: data)
        }
    )
    
    static let testValue = APIClient(
        fetchBanners: { 
            // 测试数据
            return [.mock] 
        },
        fetchCategories: { 
            // 测试数据
            return [.mock] 
        },
        fetchProducts: { _ in 
            // 测试数据
            return [.mock] 
        },
        fetchUserInfo: { 
            // 测试数据
            return .mock 
        }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
```

## 性能优化策略

### 1. 使用 IdentifiedArray

```swift
struct State: Equatable {
    // 使用 IdentifiedArray 提升性能
    var products: IdentifiedArrayOf<Product> = []
    // 而不是普通数组 [Product]
}
```

### 2. 实现懒加载和分页

```swift
struct ProductListFeature: Reducer {
    struct State: Equatable {
        var products: [Product] = []
        var page = 1
        var pageSize = 20
        var hasMore = true
        var isLoadingMore = false
    }
    
    enum Action: Equatable {
        case loadMore
        case productsAppended(TaskResult<[Product]>)
        case scrolledNearBottom
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .scrolledNearBottom:
                guard !state.isLoadingMore && state.hasMore else { return .none }
                return .send(.loadMore)
                
            case .loadMore:
                state.isLoadingMore = true
                let page = state.page
                let pageSize = state.pageSize
                
                return .run { send in
                    await send(.productsAppended(
                        TaskResult {
                            try await apiClient.fetchProducts(page: page, size: pageSize)
                        }
                    ))
                }
                
            case let .productsAppended(.success(newProducts)):
                state.products.append(contentsOf: newProducts)
                state.page += 1
                state.hasMore = newProducts.count == state.pageSize
                state.isLoadingMore = false
                return .none
                
            case .productsAppended(.failure):
                state.isLoadingMore = false
                return .none
            }
        }
    }
}
```

### 3. 缓存策略实现

```swift
// 缓存管理器
actor CacheManager {
    private var cache: [String: (value: Any, expiry: Date)] = [:]
    
    func get<T>(_ key: String, as type: T.Type) -> T? {
        guard let cached = cache[key],
              cached.expiry > Date() else {
            cache[key] = nil
            return nil
        }
        return cached.value as? T
    }
    
    func set<T>(_ value: T, for key: String, ttl: TimeInterval) {
        cache[key] = (value, Date().addingTimeInterval(ttl))
    }
    
    func clear() {
        cache.removeAll()
    }
}

// 在 API 客户端中使用缓存
struct CachedAPIClient {
    let cache = CacheManager()
    let apiClient: APIClient
    
    func fetchBanners() async throws -> [Banner] {
        let cacheKey = "banners"
        
        if let cached = await cache.get(cacheKey, as: [Banner].self) {
            return cached
        }
        
        let banners = try await apiClient.fetchBanners()
        await cache.set(banners, for: cacheKey, ttl: 300) // 5分钟缓存
        return banners
    }
}
```

## View 层实现

### 主页面 View

```swift
struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Banner 区域
                BannerView(
                    store: store.scope(
                        state: \.banner,
                        action: HomeFeature.Action.banner
                    )
                )
                
                // 分类区域
                CategoryListView(
                    store: store.scope(
                        state: \.categoryList,
                        action: HomeFeature.Action.categoryList
                    )
                )
                
                // 商品列表
                ProductListView(
                    store: store.scope(
                        state: \.productList,
                        action: HomeFeature.Action.productList
                    )
                )
            }
        }
        .refreshable {
            await store.send(.refresh).finish()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
```

### 子模块 View 示例

```swift
struct BannerView: View {
    let store: StoreOf<BannerFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(
                get: \.currentIndex,
                send: BannerFeature.Action.selectBanner
            )) {
                ForEach(Array(viewStore.banners.enumerated()), id: \.offset) { index, banner in
                    AsyncImage(url: URL(string: banner.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 200)
            .overlay(
                Group {
                    if viewStore.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.8))
                    }
                }
            )
        }
    }
}
```

## 最佳实践建议

### 1. 模块化原则
- 每个独立功能封装为一个 Reducer
- 保持单一职责原则
- 模块间通过父 Reducer 协调交互

### 2. 状态管理
- 使用 `Equatable` 协议优化性能
- 合理使用 `IdentifiedArray` 管理列表数据
- 避免在 State 中存储派生状态

### 3. 异步处理
- 使用 `.merge()` 并行触发多个请求
- 合理使用 `.cancellable()` 管理长时间运行的任务
- 实现重试机制和超时处理

### 4. 错误处理
- 每个模块独立处理自己的错误
- 提供统一的错误展示机制
- 实现降级策略，避免单点故障

### 5. 性能优化
- 实现懒加载和分页加载
- 使用缓存减少网络请求
- 合理使用 `@ViewBuilder` 和 `LazyVStack`

### 6. 测试策略
- 每个模块编写独立的单元测试
- 使用 `TestStore` 测试 Reducer 逻辑
- Mock 依赖进行集成测试

## 示例项目结构

```
HomeFeature/
├── HomeFeature.swift           # 主 Reducer
├── HomeView.swift              # 主视图
├── Models/
│   ├── Banner.swift
│   ├── Category.swift
│   ├── Product.swift
│   └── UserInfo.swift
├── Features/
│   ├── Banner/
│   │   ├── BannerFeature.swift
│   │   └── BannerView.swift
│   ├── Category/
│   │   ├── CategoryFeature.swift
│   │   └── CategoryView.swift
│   ├── ProductList/
│   │   ├── ProductListFeature.swift
│   │   └── ProductListView.swift
│   └── UserInfo/
│       ├── UserInfoFeature.swift
│       └── UserInfoView.swift
├── Services/
│   ├── APIClient.swift
│   └── CacheManager.swift
└── Tests/
    ├── HomeFeatureTests.swift
    ├── BannerFeatureTests.swift
    └── ...
```

## 总结

采用组合式架构处理复杂页面的优势：

1. **清晰的代码组织**：每个功能模块独立，易于理解和维护
2. **良好的可测试性**：模块可以独立测试，提高测试效率
3. **灵活的扩展性**：新增功能只需添加新的子 Reducer
4. **统一的状态管理**：通过父 Reducer 协调，避免状态混乱
5. **优秀的性能表现**：通过合理的优化策略，保证页面流畅

这种架构方式特别适合商城首页这类功能复杂、接口众多、交互频繁的页面，能够在保持代码清晰度的同时，有效处理复杂的业务逻辑。