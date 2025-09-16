//
//  NetworkErrorType.swift
//  SwiftUIDemo
//
//  Shared network error type enum for all network-related features
//  所有网络相关功能共享的网络错误类型枚举
//

/**
 * 🎯 NETWORK ERROR TYPE - 网络错误类型
 * ═══════════════════════════════════════════════════════════════
 * 
 * 🏗️ 设计思路 / Design Philosophy:
 * 这是一个共享的网络错误类型枚举，用于整个应用中的网络错误处理。
 * 通过集中定义错误类型，确保错误处理的一致性和可维护性。
 * 
 * This is a shared network error type enum for network error handling throughout the app.
 * By centralizing error type definitions, we ensure consistency and maintainability in error handling.
 * 
 * 🎨 设计模式 / Design Patterns:
 * • ENUM PATTERN: 使用枚举定义有限的错误类型集合
 * • FACADE PATTERN: 为复杂的错误处理提供简单接口
 * 
 * 📋 SOLID 原则 / SOLID Principles:
 * • SRP: 只负责定义网络错误类型及其属性
 * • OCP: 通过扩展枚举 case 添加新错误类型
 * • DIP: 其他模块依赖这个抽象定义
 * 
 * 🔧 技术实现 / Technical Implementation:
 * • 使用 Swift 枚举的 RawValue 和 CaseIterable
 * • 提供多语言支持（中英文）
 * • 包含视觉属性（图标、颜色）
 * • 提供默认错误消息
 * 
 * ⚠️ 易错点 / Common Pitfalls:
 * • 确保所有 case 都有对应的属性实现
 * • 默认消息应该是双语的
 * • 错误代码应该与后端保持一致
 * 
 * 🔑 关键点 / Key Points:
 * • 这是整个应用的单一真相源（Single Source of Truth）
 * • 所有网络相关功能都应使用这个枚举
 * • 添加新错误类型时需要更新所有计算属性
 */

import SwiftUI

/**
 * 网络错误类型枚举
 * Network error type enumeration
 * 
 * 包含应用中所有可能的网络错误类型
 * Contains all possible network error types in the application
 */
public enum NetworkErrorType: String, CaseIterable, Equatable {
    case offline = "offline"
    case timeout = "timeout"
    case serverError = "serverError"
    case unauthorized = "unauthorized"
    case notFound = "notFound"
    case badRequest = "badRequest"
    case tooManyRequests = "tooManyRequests"
    case maintenance = "maintenance"
    
    // MARK: - Display Names / 显示名称
    
    /// 中文显示名称
    /// Chinese display name
    public var displayName: String {
        switch self {
        case .offline: return "离线"
        case .timeout: return "超时"
        case .serverError: return "服务器错误"
        case .unauthorized: return "未授权"
        case .notFound: return "未找到"
        case .badRequest: return "请求错误"
        case .tooManyRequests: return "请求过多"
        case .maintenance: return "维护中"
        }
    }
    
    /// 英文显示名称
    /// English display name
    public var englishName: String {
        switch self {
        case .offline: return "Offline"
        case .timeout: return "Timeout"
        case .serverError: return "Server Error"
        case .unauthorized: return "Unauthorized"
        case .notFound: return "Not Found"
        case .badRequest: return "Bad Request"
        case .tooManyRequests: return "Too Many Requests"
        case .maintenance: return "Maintenance"
        }
    }
    
    // MARK: - Visual Properties / 视觉属性
    
    /// SF Symbol 图标名称
    /// SF Symbol icon name
    public var icon: String {
        switch self {
        case .offline: return "wifi.slash"
        case .timeout: return "clock.badge.exclamationmark"
        case .serverError: return "server.rack"
        case .unauthorized: return "lock.shield"
        case .notFound: return "questionmark.folder"
        case .badRequest: return "exclamationmark.triangle"
        case .tooManyRequests: return "gauge.badge.minus"
        case .maintenance: return "wrench.and.screwdriver"
        }
    }
    
    /// 错误类型的主题颜色
    /// Theme color for error type
    public var color: Color {
        switch self {
        case .offline: return .red
        case .timeout: return .orange
        case .serverError: return .red
        case .unauthorized: return .purple
        case .notFound: return .blue
        case .badRequest: return .yellow
        case .tooManyRequests: return .pink
        case .maintenance: return .gray
        }
    }
    
    // MARK: - Error Codes / 错误代码
    
    /// 错误代码（与后端对应）
    /// Error code (corresponding to backend)
    public var errorCode: String {
        switch self {
        case .offline: return "NETWORK_OFFLINE"
        case .timeout: return "TIMEOUT"
        case .serverError: return "500"
        case .unauthorized: return "401"
        case .notFound: return "404"
        case .badRequest: return "400"
        case .tooManyRequests: return "429"
        case .maintenance: return "503"
        }
    }
    
    // MARK: - Default Messages / 默认消息
    
    /// 默认错误消息（双语）
    /// Default error message (bilingual)
    public var defaultMessage: String {
        switch self {
        case .offline:
            return """
            网络连接已断开，请检查您的网络设置。
            Network connection lost, please check your network settings.
            """
            
        case .timeout:
            return """
            请求超时，请稍后重试。
            Request timeout, please try again later.
            """
            
        case .serverError:
            return """
            服务器遇到问题，我们正在修复中。
            Server encountered an issue, we're fixing it.
            """
            
        case .unauthorized:
            return """
            您需要登录才能继续。
            You need to login to continue.
            """
            
        case .notFound:
            return """
            请求的资源未找到。
            The requested resource was not found.
            """
            
        case .badRequest:
            return """
            请求参数有误，请检查后重试。
            Bad request parameters, please check and retry.
            """
            
        case .tooManyRequests:
            return """
            请求过于频繁，请稍后再试。
            Too many requests, please try again later.
            """
            
        case .maintenance:
            return """
            系统维护中，请稍后访问。
            System under maintenance, please visit later.
            """
        }
    }
}