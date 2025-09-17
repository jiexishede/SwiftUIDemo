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

struct ECommerceHomeView: View {
    let store: StoreOf<ECommerceHomeFeature>
    
    // Layout constants / 布局常量
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let categoryColumns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        ZStack {
            // Main content / 主内容
            mainContent
            
            // Global error banner / 全局错误横幅
            if store.showGlobalErrorBanner {
                globalErrorBanner
            }
        }
        .navigationTitle("购物商城 / E-Commerce")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User header section / 用户头部区域
                userHeaderSection
                
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
            .padding(.bottom, store.showGlobalErrorBanner ? 100 : 20)
        }
        .refreshable {
            await store.send(.loadInitialData).finish()
        }
    }
    
    // MARK: - User Header Section
    
    private var userHeaderSection: some View {
        Group {
            switch store.userProfileState {
            case .idle, .loading:
                userHeaderSkeleton
                
            case let .loaded(profile, _):
                UserHeaderView(profile: profile, statistics: store.userStatisticsState)
                
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
            switch store.bannersState {
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
        .padding(.horizontal)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "分类 / Categories",
                hasError: store.categoriesState.errorInfo != nil
            )
            
            switch store.categoriesState {
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
        .padding(.horizontal)
    }
    
    // MARK: - Order Status Section
    
    private var orderStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "我的订单 / My Orders",
                hasError: store.orderStatusState.errorInfo != nil
            )
            
            switch store.orderStatusState {
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
        .padding(.horizontal)
    }
    
    // MARK: - Flash Sales Section
    
    private var flashSalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "限时秒杀 / Flash Sale",
                subtitle: "⚡ 手慢无",
                hasError: store.flashSalesState.errorInfo != nil
            )
            
            switch store.flashSalesState {
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
    
    // MARK: - Recommended Products Section
    
    private var recommendedProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "为你推荐 / Recommended",
                hasError: store.recommendedProductsState.errorInfo != nil
            )
            .padding(.horizontal)
            
            switch store.recommendedProductsState {
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
    
    // MARK: - Global Error Banner
    
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
                        Text("加载用户信息失败 / Failed to load user info")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(store.globalErrorMessage)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                // Retry button / 重试按钮
                Button(action: { store.send(.retryAllCoreAPIs) }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("重试所有 / Retry All")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.orange.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
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
            if case let .loaded(statistics, _) = store.userStatisticsState,
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
    let onRetry: () -> Void
    
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
            
            Button("重试 / Retry", action: onRetry)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Inline Error / 内联错误
struct InlineError: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            Button("重试", action: onRetry)
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.mini)
        }
        .padding(8)
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