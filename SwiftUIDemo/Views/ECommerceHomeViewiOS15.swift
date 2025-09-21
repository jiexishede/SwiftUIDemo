/**
 * ECommerceHomeViewiOS15.swift
 * iOS 15 专用的商城首页视图
 * iOS 15 specific E-Commerce home view
 * 
 * 设计目的 / Design Purpose:
 * 专门为 iOS 15 下拉刷新问题创建的简化版本
 * Simplified version specifically created for iOS 15 pull-to-refresh issues
 * 
 * 关键修复 / Key Fixes:
 * 1. 简化 ScrollView 结构，避免复杂嵌套
 * 2. 优化刷新逻辑，确保 iOS 15 兼容性
 * 3. 移除可能影响触摸事件的覆盖层
 * 4. 使用更稳定的刷新等待机制
 */

import SwiftUI
import ComposableArchitecture

struct ECommerceHomeViewiOS15: View {
    @ObservedObject var viewStore: ViewStore<ECommerceHomeFeature.State, ECommerceHomeFeature.Action>
    let store: StoreOf<ECommerceHomeFeature>
    
    init(store: StoreOf<ECommerceHomeFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        // iOS 15 关键修复：简化结构，移除 ZStack 嵌套
        // iOS 15 key fix: Simplify structure, remove ZStack nesting
        ScrollView {
            VStack(spacing: 20) {
                // 错误横幅在内容顶部 / Error banners at top of content
                errorBannersSection
                
                // 用户头部 / User header
                userHeaderSection
                
                // 主要内容 / Main content
                mainContentSections
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))  // iOS 15 必需
        .refreshable {
            // iOS 15 优化的刷新实现 / iOS 15 optimized refresh implementation
            await performiOS15Refresh()
        }
        .navigationTitle("购物商城 / E-Commerce")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("🛍️ ECommerceHomeViewiOS15.onAppear")
            if case .idle = viewStore.userProfileState {
                store.send(.onAppear)
            }
        }
    }
    
    // MARK: - Error Banners Section
    
    @ViewBuilder
    private var errorBannersSection: some View {
        VStack(spacing: 12) {
            // 蓝色批量重试横幅 / Blue batch retry banner
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
            
            // 粉色错误横幅 / Pink error banner
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
                .padding(.horizontal)
            }
            
            // 橙色警告横幅 / Orange warning banner
            if viewStore.showOrangeFloatingAlert {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("检测到 \(viewStore.coreErrorCount) 个核心服务异常")
                        .font(.caption)
                    Spacer()
                    Button("忽略") {
                        store.send(.dismissOrangeAlert)
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
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
    
    // MARK: - Main Content Sections
    
    private var mainContentSections: some View {
        VStack(spacing: 20) {
            // 轮播图 / Banner carousel
            bannerSection
            
            // 分类网格 / Categories grid
            categoriesSection
            
            // 订单状态 / Order status
            orderStatusSection
            
            // 秒杀商品 / Flash sales
            flashSalesSection
            
            // 推荐商品 / Recommended products
            recommendedProductsSection
        }
    }
    
    // MARK: - iOS 15 Optimized Refresh
    
    /**
     * iOS 15 优化的刷新函数
     * iOS 15 optimized refresh function
     * 
     * 关键改进 / Key improvements:
     * 1. 移除复杂的轮询逻辑 / Remove complex polling logic
     * 2. 使用固定等待时间确保刷新指示器显示 / Use fixed wait time to ensure refresh indicator shows
     * 3. 简化状态检查 / Simplify state checking
     * 4. 更好的错误处理 / Better error handling
     */
    @MainActor
    private func performiOS15Refresh() async {
        print("🔄 [iOS15] Pull-to-refresh triggered / 下拉刷新触发")
        
        // 发送刷新动作 / Send refresh action
        store.send(.resetForRefresh)
        
        // iOS 15 关键：固定等待时间确保刷新指示器显示
        // iOS 15 key: Fixed wait time to ensure refresh indicator shows
        do {
            // 最小刷新时间 2 秒，确保用户看到刷新效果
            // Minimum refresh time 2 seconds to ensure user sees refresh effect
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // 简单的后续检查，但不依赖它来结束刷新
            // Simple follow-up check, but don't rely on it to end refresh
            var additionalWait = 0
            while additionalWait < 10 && 
                  !viewStore.userProfileState.isLoaded && 
                  !viewStore.bannersState.isLoaded {
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                additionalWait += 1
            }
            
        } catch {
            print("⚠️ [iOS15] 刷新等待被中断: \(error)")
        }
        
        print("✅ [iOS15] 刷新完成 / Refresh completed")
    }
    
    // MARK: - Content Sections (Simplified)
    
    private var bannerSection: some View {
        Group {
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                ComponentErrorCard(
                    title: "轮播图 / Banners",
                    error: "加载失败 / Load failed",
                    onRetry: nil
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
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "分类 / Categories",
                hasError: viewStore.categoriesState.errorInfo != nil || 
                         viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(message: "加载失败 / Load failed", onRetry: nil)
            } else {
                switch viewStore.categoriesState {
                case .idle, .loading:
                    CategoryGridSkeleton()
                case let .loaded(categories, _):
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
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
    
    private var orderStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "我的订单 / My Orders",
                hasError: viewStore.orderStatusState.errorInfo != nil || 
                         viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(message: "加载失败 / Load failed", onRetry: nil)
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
    
    private var flashSalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "限时秒杀 / Flash Sale",
                subtitle: "⚡ 手慢无",
                hasError: viewStore.flashSalesState.errorInfo != nil || 
                         viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            .padding(.horizontal)
            
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(message: "加载失败 / Load failed", onRetry: nil)
                    .padding(.horizontal)
            } else {
                switch viewStore.flashSalesState {
                case .idle, .loading:
                    FlashSaleSkeleton()
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
    
    private var recommendedProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "为你推荐 / Recommended",
                hasError: viewStore.recommendedProductsState.errorInfo != nil || 
                         viewStore.errorDisplayMode == .normalPageWithGlobalError
            )
            .padding(.horizontal)
            
            if viewStore.errorDisplayMode == .normalPageWithGlobalError {
                InlineError(message: "加载失败 / Load failed", onRetry: nil)
                    .padding(.horizontal)
            } else {
                switch viewStore.recommendedProductsState {
                case .idle, .loading:
                    ProductGridSkeleton()
                        .padding(.horizontal)
                case let .loaded(products, _):
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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

// MARK: - Extension for State Checking

extension ReduxPageState {
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
}

// MARK: - Preview

struct ECommerceHomeViewiOS15_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ECommerceHomeViewiOS15(
                store: Store(
                    initialState: ECommerceHomeFeature.State(),
                    reducer: { ECommerceHomeFeature() }
                )
            )
        }
    }
}