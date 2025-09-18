//
//  ECommerceService.swift
//  SwiftUIDemo
//
//  E-commerce service layer with mock APIs
//  电商服务层，包含模拟API
//

/**
 * 🌐 E-COMMERCE SERVICE - 电商服务层
 * ═══════════════════════════════════════════════════════════════
 *
 * 服务架构设计 / Service Architecture Design:
 * 
 * 1. REPOSITORY PATTERN (仓储模式)
 *    • 抽象数据访问逻辑
 *    • 统一的数据接口
 *    • 易于切换数据源
 *
 * 2. DEPENDENCY INJECTION (依赖注入)
 *    • 通过协议定义服务接口
 *    • 便于测试和模拟
 *    • 解耦业务逻辑和数据访问
 *
 * 3. ASYNC/AWAIT + COMBINE
 *    • 现代异步编程模式
 *    • 清晰的错误处理
 *    • 支持并发请求
 *
 * 错误模拟策略 / Error Simulation Strategy:
 * • 随机错误：模拟真实网络环境
 * • 可控错误：通过参数控制错误率
 * • 延迟模拟：模拟网络延迟
 */

import Foundation
import Combine
import ComposableArchitecture

// MARK: - Service Protocol

/**
 * 电商服务协议
 * E-commerce service protocol
 *
 * 定义所有电商相关的API接口
 * Define all e-commerce related API interfaces
 */
protocol ECommerceServiceProtocol {
    // User APIs / 用户API
    func fetchUserProfile() async throws -> UserProfile
    func fetchUserSettings() async throws -> UserSettings
    func fetchUserStatistics() async throws -> UserStatistics
    func fetchUserPermissions() async throws -> UserPermissions
    func fetchUserNotifications() async throws -> UserNotifications
    
    // Component APIs / 组件API
    func fetchBanners() async throws -> [Banner]
    func fetchRecommendedProducts() async throws -> [Product]
    func fetchFlashSales() async throws -> [FlashSale]
    func fetchCategories() async throws -> [Category]
    func fetchOrderStatus() async throws -> UserOrderStatus
}

// MARK: - Mock Service Implementation

/**
 * 模拟电商服务
 * Mock e-commerce service
 *
 * 生成测试数据并模拟网络行为
 * Generate test data and simulate network behavior
 */
class MockECommerceService: ECommerceServiceProtocol {
    
    // Configuration / 配置
    private let errorRate: Double = 0.0  // 0% error rate - disabled for now / 0%错误率 - 暂时禁用
    private let minDelay: UInt64 = 100_000_000  // 0.1 seconds / 0.1秒
    private let maxDelay: UInt64 = 300_000_000  // 0.3 seconds / 0.3秒
    
    // MARK: - User APIs
    
    func fetchUserProfile() async throws -> UserProfile {
        try await simulateNetworkDelay(for: "UserProfile")
        // try simulateRandomError(api: "UserProfile")  // Disabled for normal operation
        
        return UserProfile(
            userId: "user_\(UUID().uuidString.prefix(8))",
            username: "demo_user",
            nickname: "购物达人",
            avatarUrl: "https://picsum.photos/200",
            memberLevel: .gold,
            points: 12580,
            balance: 999.99,
            registrationDate: Date().addingTimeInterval(-365 * 24 * 60 * 60)
        )
    }
    
    func fetchUserSettings() async throws -> UserSettings {
        try await simulateNetworkDelay(for: "UserSettings")
        // try simulateRandomError(api: "UserSettings")  // Disabled for normal operation
        
        return UserSettings(
            userId: "user_123",
            language: "zh-CN",
            currency: "CNY",
            notificationEnabled: true,
            darkModeEnabled: false,
            autoPlayVideo: true,
            showRecommendations: true,
            privacyLevel: .friendsOnly
        )
    }
    
    func fetchUserStatistics() async throws -> UserStatistics {
        try await simulateNetworkDelay(for: "UserStatistics")
        // try simulateRandomError(api: "UserStatistics")  // Disabled for normal operation
        
        return UserStatistics(
            userId: "user_123",
            totalOrders: 156,
            totalSpent: 28956.50,
            itemsPurchased: 423,
            favoriteCount: 89,
            cartItemCount: 5,
            browsingHistory: 1256,
            reviewsWritten: 34,
            couponsAvailable: 12
        )
    }
    
    func fetchUserPermissions() async throws -> UserPermissions {
        try await simulateNetworkDelay(for: "UserPermissions")
        // try simulateRandomError(api: "UserPermissions")  // Disabled for normal operation
        
        return UserPermissions(
            userId: "user_123",
            canCreateOrder: true,
            canWriteReview: true,
            canUseVoucher: true,
            canAccessFlashSale: true,
            canAccessVIPProducts: true,
            maxCreditLimit: 5000.00,
            canRequestRefund: true,
            canContactSupport: true
        )
    }
    
    func fetchUserNotifications() async throws -> UserNotifications {
        try await simulateNetworkDelay(for: "UserNotifications")
        // try simulateRandomError(api: "UserNotifications")  // Disabled for normal operation
        
        return UserNotifications(
            userId: "user_123",
            orderUpdates: true,
            promotions: true,
            priceAlerts: false,
            newProducts: true,
            restockAlerts: true,
            socialUpdates: false,
            systemNotices: true,
            emailFrequency: .weekly
        )
    }
    
    // MARK: - Component APIs
    
    func fetchBanners() async throws -> [Banner] {
        try await simulateNetworkDelay(for: "Banners")
        try simulateRandomError(api: "Banners", rate: 0.3)  // 30% error rate / 30%错误率
        
        return [
            Banner(
                imageUrl: "https://picsum.photos/800/400",
                title: "双11狂欢节",
                subtitle: "全场5折起",
                actionUrl: "/promotion/double11"
            ),
            Banner(
                imageUrl: "https://picsum.photos/800/401",
                title: "新品首发",
                subtitle: "iPhone 15 Pro Max",
                actionUrl: "/product/iphone15"
            ),
            Banner(
                imageUrl: "https://picsum.photos/800/402",
                title: "会员专享",
                subtitle: "黄金会员独享优惠",
                actionUrl: "/member/benefits"
            )
        ]
    }
    
    func fetchRecommendedProducts() async throws -> [Product] {
        try await simulateNetworkDelay(for: "Products")
        try simulateRandomError(api: "Products", rate: 0.3)  // 30% error rate / 30%错误率
        
        return (1...8).map { index in
            Product(
                name: "推荐商品 \(index)",
                description: "这是一个很棒的商品，质量优秀，价格实惠",
                imageUrls: ["https://picsum.photos/300/\(300 + index)"],
                originalPrice: Double.random(in: 100...1000),
                currentPrice: Double.random(in: 50...500),
                category: ["电子产品", "服装", "食品", "图书"].randomElement()!,
                tags: ["热销", "新品", "限量", "特价"].shuffled().prefix(2).map { $0 },
                salesCount: Int.random(in: 100...10000),
                stockCount: Int.random(in: 0...100),
                rating: Double.random(in: 3.5...5.0),
                reviewCount: Int.random(in: 10...1000),
                isNew: Bool.random(),
                isHot: Bool.random()
            )
        }
    }
    
    func fetchFlashSales() async throws -> [FlashSale] {
        try await simulateNetworkDelay(for: "FlashSales")
        try simulateRandomError(api: "FlashSales", rate: 0.3)  // 30% error rate / 30%错误率
        
        let now = Date()
        return (1...4).map { index in
            let product = Product(
                name: "秒杀商品 \(index)",
                description: "限时秒杀，手慢无！",
                imageUrls: ["https://picsum.photos/300/\(400 + index)"],
                originalPrice: Double.random(in: 500...2000),
                currentPrice: Double.random(in: 300...1000),
                category: "秒杀专区",
                tags: ["秒杀", "限时"],
                salesCount: Int.random(in: 1000...5000),
                stockCount: 100,
                rating: 4.5,
                reviewCount: Int.random(in: 100...500),
                isNew: false,
                isHot: true
            )
            
            return FlashSale(
                product: product,
                flashPrice: product.currentPrice * 0.5,
                startTime: now.addingTimeInterval(-3600),
                endTime: now.addingTimeInterval(3600 * Double(index)),
                totalStock: 100,
                soldCount: Int.random(in: 20...80)
            )
        }
    }
    
    func fetchCategories() async throws -> [Category] {
        try await simulateNetworkDelay(for: "Categories")
        try simulateRandomError(api: "Categories", rate: 0.3)  // 30% error rate / 30%错误率
        
        return [
            Category(name: "手机数码", iconName: "iphone", colorHex: "#FF6B6B", priority: 1),
            Category(name: "服装鞋包", iconName: "bag.fill", colorHex: "#4ECDC4", priority: 2),
            Category(name: "美妆个护", iconName: "sparkles", colorHex: "#FFD93D", priority: 3),
            Category(name: "食品生鲜", iconName: "cart.fill", colorHex: "#6BCF7F", priority: 4),
            Category(name: "图书音像", iconName: "book.fill", colorHex: "#A8E6CF", priority: 5),
            Category(name: "家居生活", iconName: "house.fill", colorHex: "#C7CEEA", priority: 6),
            Category(name: "运动户外", iconName: "figure.run", colorHex: "#FFA07A", priority: 7),
            Category(name: "更多分类", iconName: "ellipsis", colorHex: "#B4A7D6", priority: 8)
        ]
    }
    
    func fetchOrderStatus() async throws -> UserOrderStatus {
        try await simulateNetworkDelay(for: "OrderStatus")
        try simulateRandomError(api: "OrderStatus", rate: 0.3)  // 30% error rate / 30%错误率
        
        return UserOrderStatus(
            pendingPayment: Int.random(in: 0...5),
            pendingShipment: Int.random(in: 0...3),
            shipped: Int.random(in: 0...10),
            pendingReview: Int.random(in: 0...8),
            refunding: Int.random(in: 0...2)
        )
    }
    
    // MARK: - Helper Methods
    
    /**
     * 模拟网络延迟
     * Simulate network delay
     * 
     * - Parameter api: API名称，用于确定延迟时间 / API name to determine delay time
     */
    private func simulateNetworkDelay(for api: String? = nil) async throws {
        let delay: UInt64
        
        // 核心API使用更短的延迟 / Core APIs use shorter delays
        if let api = api, ["UserProfile", "UserSettings", "UserStatistics", 
                           "UserPermissions", "UserNotifications"].contains(api) {
            delay = UInt64.random(in: 50_000_000...150_000_000)  // 0.05-0.15秒
        } else {
            // 组件API使用标准延迟 / Component APIs use standard delays
            delay = UInt64.random(in: minDelay...maxDelay)
        }
        
        try await Task.sleep(nanoseconds: delay)
    }
    
    /**
     * 模拟随机错误
     * Simulate random error
     *
     * - Parameters:
     *   - api: API名称 / API name
     *   - rate: 错误率 / Error rate (0.0 to 1.0)
     */
    private func simulateRandomError(api: String, rate: Double? = nil) throws {
        let actualRate = rate ?? errorRate
        guard Double.random(in: 0...1) < actualRate else { return }
        
        let errors: [ECommerceError] = [
            .networkError("网络连接失败 / Network connection failed"),
            .serverError("服务器错误 / Server error"),
            .timeout("请求超时 / Request timeout"),
            .unauthorized("未授权访问 / Unauthorized access")
        ]
        
        throw errors.randomElement() ?? ECommerceError.unknown
    }
}

// MARK: - Error Types

/**
 * 电商服务错误类型
 * E-commerce service error types
 */
enum ECommerceError: LocalizedError, Equatable {
    case networkError(String)
    case serverError(String)
    case timeout(String)
    case unauthorized(String)
    case dataCorrupted(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误 / Network Error: \(message)"
        case .serverError(let message):
            return "服务器错误 / Server Error: \(message)"
        case .timeout(let message):
            return "超时 / Timeout: \(message)"
        case .unauthorized(let message):
            return "未授权 / Unauthorized: \(message)"
        case .dataCorrupted(let message):
            return "数据错误 / Data Error: \(message)"
        case .unknown:
            return "未知错误 / Unknown error"
        }
    }
}

// MARK: - Dependency Injection

/**
 * 依赖注入扩展
 * Dependency injection extension
 */
extension DependencyValues {
    var ecommerceService: any ECommerceServiceProtocol {
        get { self[ECommerceServiceKey.self] }
        set { self[ECommerceServiceKey.self] = newValue }
    }
}

private struct ECommerceServiceKey: DependencyKey {
    static let liveValue: any ECommerceServiceProtocol = MockECommerceService()
}