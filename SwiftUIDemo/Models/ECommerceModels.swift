//
//  ECommerceModels.swift
//  SwiftUIDemo
//
//  E-commerce domain models for home page
//  电商首页领域模型
//

/**
 * 🛍 E-COMMERCE MODELS - 电商领域模型
 * ═══════════════════════════════════════════════════════════════
 *
 * 设计思路 / Design Philosophy:
 * • 模拟真实电商场景的数据结构
 * • 支持复杂的业务逻辑和状态管理
 * • 类型安全和可扩展性
 *
 * SOLID原则 / SOLID Principles:
 * • SRP: 每个模型只负责一个业务实体
 * • OCP: 通过协议和扩展支持新功能
 * • DIP: 依赖于协议而非具体实现
 */

import Foundation

// MARK: - User Related Models / 用户相关模型

/**
 * 👤 USER PROFILE - 用户资料
 *
 * 核心用户信息 / Core user information
 * 登录后首先加载的数据之一
 */
public struct UserProfile: Equatable, Codable {
    public let userId: String
    public let username: String
    public let nickname: String
    public let avatarUrl: String?
    public let memberLevel: MemberLevel
    public let points: Int
    public let balance: Double
    public let registrationDate: Date
    
    public enum MemberLevel: String, Codable, CaseIterable {
        case normal = "普通会员"
        case silver = "白银会员"
        case gold = "黄金会员"
        case platinum = "铂金会员"
        case diamond = "钻石会员"
    }
    
    public init(
        userId: String,
        username: String,
        nickname: String,
        avatarUrl: String? = nil,
        memberLevel: MemberLevel = .normal,
        points: Int = 0,
        balance: Double = 0,
        registrationDate: Date = Date()
    ) {
        self.userId = userId
        self.username = username
        self.nickname = nickname
        self.avatarUrl = avatarUrl
        self.memberLevel = memberLevel
        self.points = points
        self.balance = balance
        self.registrationDate = registrationDate
    }
}

/**
 * ⚙️ USER SETTINGS - 用户设置
 *
 * 个性化设置 / Personalization settings
 */
public struct UserSettings: Equatable, Codable {
    public let userId: String
    public let language: String
    public let currency: String
    public let notificationEnabled: Bool
    public let darkModeEnabled: Bool
    public let autoPlayVideo: Bool
    public let showRecommendations: Bool
    public let privacyLevel: PrivacyLevel
    
    public enum PrivacyLevel: String, Codable {
        case publicLevel = "公开"
        case friendsOnly = "仅好友"
        case privateLevel = "私密"
    }
    
    public init(
        userId: String,
        language: String = "zh-CN",
        currency: String = "CNY",
        notificationEnabled: Bool = true,
        darkModeEnabled: Bool = false,
        autoPlayVideo: Bool = true,
        showRecommendations: Bool = true,
        privacyLevel: PrivacyLevel = .friendsOnly
    ) {
        self.userId = userId
        self.language = language
        self.currency = currency
        self.notificationEnabled = notificationEnabled
        self.darkModeEnabled = darkModeEnabled
        self.autoPlayVideo = autoPlayVideo
        self.showRecommendations = showRecommendations
        self.privacyLevel = privacyLevel
    }
}

/**
 * 📊 USER STATISTICS - 用户统计
 *
 * 用户行为统计数据 / User behavior statistics
 */
public struct UserStatistics: Equatable, Codable {
    public let userId: String
    public let totalOrders: Int
    public let totalSpent: Double
    public let itemsPurchased: Int
    public let favoriteCount: Int
    public let cartItemCount: Int
    public let browsingHistory: Int
    public let reviewsWritten: Int
    public let couponsAvailable: Int
    
    public init(
        userId: String,
        totalOrders: Int = 0,
        totalSpent: Double = 0,
        itemsPurchased: Int = 0,
        favoriteCount: Int = 0,
        cartItemCount: Int = 0,
        browsingHistory: Int = 0,
        reviewsWritten: Int = 0,
        couponsAvailable: Int = 0
    ) {
        self.userId = userId
        self.totalOrders = totalOrders
        self.totalSpent = totalSpent
        self.itemsPurchased = itemsPurchased
        self.favoriteCount = favoriteCount
        self.cartItemCount = cartItemCount
        self.browsingHistory = browsingHistory
        self.reviewsWritten = reviewsWritten
        self.couponsAvailable = couponsAvailable
    }
}

/**
 * 🔐 USER PERMISSIONS - 用户权限
 *
 * 功能权限控制 / Feature access control
 */
public struct UserPermissions: Equatable, Codable {
    public let userId: String
    public let canCreateOrder: Bool
    public let canWriteReview: Bool
    public let canUseVoucher: Bool
    public let canAccessFlashSale: Bool
    public let canAccessVIPProducts: Bool
    public let maxCreditLimit: Double
    public let canRequestRefund: Bool
    public let canContactSupport: Bool
    
    public init(
        userId: String,
        canCreateOrder: Bool = true,
        canWriteReview: Bool = true,
        canUseVoucher: Bool = true,
        canAccessFlashSale: Bool = false,
        canAccessVIPProducts: Bool = false,
        maxCreditLimit: Double = 0,
        canRequestRefund: Bool = true,
        canContactSupport: Bool = true
    ) {
        self.userId = userId
        self.canCreateOrder = canCreateOrder
        self.canWriteReview = canWriteReview
        self.canUseVoucher = canUseVoucher
        self.canAccessFlashSale = canAccessFlashSale
        self.canAccessVIPProducts = canAccessVIPProducts
        self.maxCreditLimit = maxCreditLimit
        self.canRequestRefund = canRequestRefund
        self.canContactSupport = canContactSupport
    }
}

/**
 * 🔔 USER NOTIFICATIONS - 用户通知配置
 *
 * 通知偏好设置 / Notification preferences
 */
public struct UserNotifications: Equatable, Codable {
    public let userId: String
    public let orderUpdates: Bool
    public let promotions: Bool
    public let priceAlerts: Bool
    public let newProducts: Bool
    public let restockAlerts: Bool
    public let socialUpdates: Bool
    public let systemNotices: Bool
    public let emailFrequency: EmailFrequency
    
    public enum EmailFrequency: String, Codable {
        case realtime = "实时"
        case daily = "每日"
        case weekly = "每周"
        case monthly = "每月"
        case never = "从不"
    }
    
    public init(
        userId: String,
        orderUpdates: Bool = true,
        promotions: Bool = true,
        priceAlerts: Bool = false,
        newProducts: Bool = false,
        restockAlerts: Bool = false,
        socialUpdates: Bool = false,
        systemNotices: Bool = true,
        emailFrequency: EmailFrequency = .weekly
    ) {
        self.userId = userId
        self.orderUpdates = orderUpdates
        self.promotions = promotions
        self.priceAlerts = priceAlerts
        self.newProducts = newProducts
        self.restockAlerts = restockAlerts
        self.socialUpdates = socialUpdates
        self.systemNotices = systemNotices
        self.emailFrequency = emailFrequency
    }
}

// MARK: - E-Commerce Component Models / 电商组件模型

/**
 * 🖼 BANNER - 轮播图
 *
 * 首页轮播广告 / Home page carousel ads
 */
public struct Banner: Equatable, Identifiable, Codable {
    public let id: String
    public let imageUrl: String
    public let title: String
    public let subtitle: String?
    public let actionUrl: String
    public let priority: Int
    public let startTime: Date
    public let endTime: Date
    
    public init(
        id: String = UUID().uuidString,
        imageUrl: String,
        title: String,
        subtitle: String? = nil,
        actionUrl: String,
        priority: Int = 0,
        startTime: Date = Date(),
        endTime: Date = Date().addingTimeInterval(86400)
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.title = title
        self.subtitle = subtitle
        self.actionUrl = actionUrl
        self.priority = priority
        self.startTime = startTime
        self.endTime = endTime
    }
}

/**
 * 📦 PRODUCT - 商品
 *
 * 商品信息 / Product information
 */
public struct Product: Equatable, Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let imageUrls: [String]
    public let originalPrice: Double
    public let currentPrice: Double
    public let discount: Double?
    public let category: String
    public let tags: [String]
    public let salesCount: Int
    public let stockCount: Int
    public let rating: Double
    public let reviewCount: Int
    public let isNew: Bool
    public let isHot: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        imageUrls: [String] = [],
        originalPrice: Double,
        currentPrice: Double,
        discount: Double? = nil,
        category: String = "",
        tags: [String] = [],
        salesCount: Int = 0,
        stockCount: Int = 100,
        rating: Double = 0,
        reviewCount: Int = 0,
        isNew: Bool = false,
        isHot: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrls = imageUrls
        self.originalPrice = originalPrice
        self.currentPrice = currentPrice
        self.discount = discount
        self.category = category
        self.tags = tags
        self.salesCount = salesCount
        self.stockCount = stockCount
        self.rating = rating
        self.reviewCount = reviewCount
        self.isNew = isNew
        self.isHot = isHot
    }
    
    public var discountPercentage: Int {
        guard originalPrice > 0, currentPrice < originalPrice else { return 0 }
        return Int((1 - currentPrice / originalPrice) * 100)
    }
}

/**
 * ⚡ FLASH SALE - 限时秒杀
 *
 * 秒杀活动信息 / Flash sale event
 */
public struct FlashSale: Equatable, Identifiable, Codable {
    public let id: String
    public let product: Product
    public let flashPrice: Double
    public let startTime: Date
    public let endTime: Date
    public let totalStock: Int
    public let soldCount: Int
    
    public init(
        id: String = UUID().uuidString,
        product: Product,
        flashPrice: Double,
        startTime: Date,
        endTime: Date,
        totalStock: Int = 100,
        soldCount: Int = 0
    ) {
        self.id = id
        self.product = product
        self.flashPrice = flashPrice
        self.startTime = startTime
        self.endTime = endTime
        self.totalStock = totalStock
        self.soldCount = soldCount
    }
    
    public var remainingStock: Int {
        max(0, totalStock - soldCount)
    }
    
    public var soldPercentage: Double {
        guard totalStock > 0 else { return 0 }
        return Double(soldCount) / Double(totalStock)
    }
}

/**
 * 📂 CATEGORY - 商品分类
 *
 * 分类导航 / Category navigation
 */
public struct Category: Equatable, Identifiable, Codable {
    public let id: String
    public let name: String
    public let iconName: String
    public let colorHex: String
    public let priority: Int
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        iconName: String,
        colorHex: String = "#000000",
        priority: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.priority = priority
    }
}

/**
 * 📋 USER ORDER STATUS - 用户订单状态
 *
 * 用户订单概览 / User order overview
 */
public struct UserOrderStatus: Equatable, Codable {
    public let pendingPayment: Int
    public let pendingShipment: Int
    public let shipped: Int
    public let pendingReview: Int
    public let refunding: Int
    
    public init(
        pendingPayment: Int = 0,
        pendingShipment: Int = 0,
        shipped: Int = 0,
        pendingReview: Int = 0,
        refunding: Int = 0
    ) {
        self.pendingPayment = pendingPayment
        self.pendingShipment = pendingShipment
        self.shipped = shipped
        self.pendingReview = pendingReview
        self.refunding = refunding
    }
    
    public var hasAnyPending: Bool {
        pendingPayment > 0 || pendingShipment > 0 ||
        shipped > 0 || pendingReview > 0 || refunding > 0
    }
}