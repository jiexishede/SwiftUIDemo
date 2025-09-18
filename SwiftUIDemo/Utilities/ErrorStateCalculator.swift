//
//  ErrorStateCalculator.swift
//  SwiftUIDemo
//
//  Pure functions for error state calculation
//  用于错误状态计算的纯函数
//

/**
 * ERROR STATE CALCULATOR - 错误状态计算器
 * ═══════════════════════════════════════════════════════════════
 *
 * 设计理念 / Design Philosophy:
 * 
 * 1. 纯函数设计 / Pure Function Design
 *    • 无副作用，输入决定输出
 *    • 易于测试和理解
 *    • 支持函数组合
 *
 * 2. MVP 核心功能 / MVP Core Features
 *    • 错误计数和分类
 *    • 显示模式决策
 *    • 重试策略计算
 *
 * 3. 预留扩展点 / Extension Points
 *    • Extension 1: 错误优先级排序
 *    • Extension 2: 智能重试策略
 *    • Extension 3: 错误分析和报告
 *
 * SOLID 原则 / SOLID Principles:
 * • SRP: 只负责错误状态计算
 * • OCP: 通过枚举扩展新的错误类型
 * • LSP: 所有错误状态遵循统一接口
 * • ISP: 细分错误处理接口
 * • DIP: 依赖抽象的错误类型
 */

import Foundation

// MARK: - Error Types / 错误类型

/**
 * API错误分类
 * API error classification
 */
enum APIErrorType: Equatable {
    case coreUser      // 核心用户接口 / Core user API
    case component     // 组件接口 / Component API
}

/**
 * 错误严重程度
 * Error severity level
 */
enum ErrorSeverity: Int, Comparable {
    case low = 0       // 低：不影响使用 / Low: doesn't affect usage
    case medium = 1    // 中：部分功能受限 / Medium: partial limitation
    case high = 2      // 高：主要功能受限 / High: major limitation
    case critical = 3  // 关键：完全不可用 / Critical: completely unusable
    
    static func < (lhs: ErrorSeverity, rhs: ErrorSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Error Display Mode / 错误显示模式

/**
 * 错误显示模式
 * Error display mode
 */
enum ErrorDisplayMode: Equatable {
    case none                          // 无错误 / No error
    case blankPageWithAlerts           // 空白页面带提示 / Blank page with alerts
    case normalPageWithGlobalError     // 正常页面带全局错误 / Normal page with global error
    case normalPageWithComponentErrors // 正常页面带组件错误 / Normal page with component errors
    
    // Extension 1: Priority-based display / 扩展1：基于优先级的显示
    // case prioritizedDisplay(priority: ErrorPriority)
    
    // Extension 2: Adaptive display / 扩展2：自适应显示
    // case adaptive(context: DisplayContext)
}

/**
 * 重试策略
 * Retry strategy
 */
enum RetryStrategy: Equatable {
    case none                      // 无重试 / No retry
    case individual([String])      // 单个重试 / Individual retry
    case batch([String])          // 批量重试 / Batch retry
    case smart(SmartRetryConfig)  // 智能重试 / Smart retry
    
    struct SmartRetryConfig: Equatable {
        let maxAttempts: Int
        let backoffMultiplier: Double
        let priorityAPIs: [String]
    }
}

// MARK: - Pure Functions / 纯函数

/**
 * ERROR STATE CALCULATOR
 * 错误状态计算器 - 所有函数都是纯函数
 */
enum ErrorStateCalculator {
    
    // MARK: - Core Error Counting / 核心错误计数
    
    /**
     * 计算核心API错误数量
     * Count core API errors
     * 
     * - Parameter states: 5个核心API的状态 / States of 5 core APIs
     * - Returns: 错误数量 / Error count
     */
    static func countCoreErrors(_ states: [Bool]) -> Int {
        // 纯函数：输入决定输出 / Pure function: input determines output
        states.filter { $0 }.count
    }
    
    /**
     * 计算组件错误数量
     * Count component errors
     */
    static func countComponentErrors(_ states: [Bool]) -> Int {
        states.filter { $0 }.count
    }
    
    // MARK: - Display Mode Decision / 显示模式决策
    
    /**
     * 决定错误显示模式
     * Determine error display mode
     * 
     * MVP实现：基于错误数量的简单规则
     * MVP: Simple rules based on error count
     */
    static func determineDisplayMode(
        coreErrors: Int,
        componentErrors: Int,
        totalCoreAPIs: Int = 5,
        totalComponentAPIs: Int = 5
    ) -> ErrorDisplayMode {
        // 规则1：任一核心API错误 -> 空白页面
        // Rule 1: Any core API error -> blank page
        if coreErrors > 0 {
            return .blankPageWithAlerts
        }
        
        // 规则2：超过1个组件错误 -> 全局错误
        // Rule 2: More than 1 component error -> global error
        if componentErrors > 1 {
            return .normalPageWithGlobalError
        }
        
        // 规则3：单个组件错误 -> 组件级错误
        // Rule 3: Single component error -> component-level error
        if componentErrors == 1 {
            return .normalPageWithComponentErrors
        }
        
        // 规则4：无错误
        // Rule 4: No errors
        return .none
    }
    
    // MARK: - Retry Strategy / 重试策略
    
    /**
     * 计算重试策略
     * Calculate retry strategy
     * 
     * MVP：基于错误类型和数量
     * MVP: Based on error type and count
     */
    static func calculateRetryStrategy(
        failedCoreAPIs: [String],
        failedComponentAPIs: [String]
    ) -> RetryStrategy {
        // 有核心API失败：批量重试所有核心API
        // Core API failed: batch retry all core APIs
        if !failedCoreAPIs.isEmpty {
            return .batch(failedCoreAPIs)
        }
        
        // 多个组件失败：批量重试
        // Multiple components failed: batch retry
        if failedComponentAPIs.count > 1 {
            return .batch(failedComponentAPIs)
        }
        
        // 单个组件失败：单独重试
        // Single component failed: individual retry
        if failedComponentAPIs.count == 1 {
            return .individual(failedComponentAPIs)
        }
        
        // 无需重试
        // No retry needed
        return .none
    }
    
    // MARK: - Error Message Generation / 错误消息生成
    
    /**
     * 生成错误消息
     * Generate error message
     * 
     * 纯函数：基于输入生成消息
     * Pure function: generate message based on input
     */
    static func generateErrorMessage(
        errorType: APIErrorType,
        apiName: String,
        errorCode: String?
    ) -> String {
        let baseMessage: String
        
        switch errorType {
        case .coreUser:
            baseMessage = "核心服务异常 / Core service error"
        case .component:
            baseMessage = "组件加载失败 / Component load failed"
        }
        
        if let code = errorCode {
            return "\(baseMessage): \(apiName) (\(code))"
        } else {
            return "\(baseMessage): \(apiName)"
        }
    }
    
    // MARK: - Severity Calculation / 严重度计算
    
    /**
     * 计算错误严重度
     * Calculate error severity
     */
    static func calculateSeverity(
        coreErrors: Int,
        componentErrors: Int
    ) -> ErrorSeverity {
        // 任何核心错误都是关键级别
        // Any core error is critical
        if coreErrors > 0 {
            return .critical
        }
        
        // 基于组件错误数量判断
        // Based on component error count
        switch componentErrors {
        case 0:
            return .low
        case 1:
            return .medium
        case 2...3:
            return .high
        default:
            return .critical
        }
    }
    
    // MARK: - Validation Functions / 验证函数
    
    /**
     * 验证是否应该显示重试按钮
     * Validate if retry button should be shown
     */
    static func shouldShowRetryButton(
        displayMode: ErrorDisplayMode,
        componentIndex: Int?,
        failedComponents: [Int]
    ) -> Bool {
        switch displayMode {
        case .blankPageWithAlerts:
            // 空白页面：顶部蓝色横幅有重试
            // Blank page: blue banner has retry
            return false
            
        case .normalPageWithGlobalError:
            // 全局错误：顶部有重试，组件内无
            // Global error: top has retry, components don't
            return false
            
        case .normalPageWithComponentErrors:
            // 组件错误：只有失败的组件显示重试
            // Component error: only failed component shows retry
            if let index = componentIndex {
                return failedComponents.contains(index)
            }
            return false
            
        case .none:
            return false
        }
    }
}

// MARK: - Extension Points / 扩展点

/**
 * Extension 1: Priority-based error handling
 * 扩展1：基于优先级的错误处理
 */
extension ErrorStateCalculator {
    // TODO: Implement priority-based error sorting
    // static func sortErrorsByPriority(_ errors: [APIError]) -> [APIError]
}

/**
 * Extension 2: Smart retry with exponential backoff
 * 扩展2：智能重试与指数退避
 */
extension ErrorStateCalculator {
    // TODO: Implement smart retry strategy
    // static func calculateSmartRetryDelay(attempt: Int) -> TimeInterval
}

/**
 * Extension 3: Error analytics and reporting
 * 扩展3：错误分析和报告
 */
extension ErrorStateCalculator {
    // TODO: Implement error analytics
    // static func generateErrorReport(_ errors: [APIError]) -> ErrorReport
}