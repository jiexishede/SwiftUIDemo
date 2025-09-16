//
//  MultiComponentNetworkErrorFeature.swift
//  SwiftUIDemo
//
//  TCA Feature for multiple components with different network error messages
//  多组件网络错误消息的 TCA 功能模块
//

/**
 * 🎯 MULTI-COMPONENT NETWORK ERROR FEATURE - 多组件网络错误功能
 * ═══════════════════════════════════════════════════════════════
 * 
 * 🏗️ TCA 架构实现 / TCA Architecture Implementation:
 * ┌─────────────────────────────────────────────┐
 * │              View (SwiftUI)                 │
 * │                   ↓ ↑                       │
 * │            Send    Observe                  │
 * │            Action  State                    │
 * ├─────────────────────────────────────────────┤
 * │              Store (TCA)                    │
 * ├─────────────────────────────────────────────┤
 * │             Reducer (Logic)                 │
 * │     State + Action → State + Effect         │
 * └─────────────────────────────────────────────┘
 * 
 * 🎨 设计模式 / Design Patterns:
 * • REDUX PATTERN: 单向数据流
 * • COMMAND PATTERN: Action 封装命令
 * • STATE PATTERN: 状态机管理
 * • COMPOSITE PATTERN: 多个子组件状态
 * 
 * 📋 SOLID 原则应用 / SOLID Principles Applied:
 * • SRP: Reducer 只负责状态转换
 * • OCP: 通过新 Action 扩展功能
 * • LSP: 所有组件遵循相同状态协议
 * • ISP: Action 分类清晰
 * • DIP: 依赖 TCA 抽象
 */

import ComposableArchitecture
import Foundation

// MARK: - Component ID / 组件标识

/**
 * 组件标识枚举
 * Component identifier enum
 */
enum ComponentID: String, CaseIterable, Equatable {
    case component1 = "component1"
    case component2 = "component2"
    case component3 = "component3"
    
    var displayName: String {
        switch self {
        case .component1: return "组件 1"
        case .component2: return "组件 2"
        case .component3: return "组件 3"
        }
    }
    
    var englishName: String {
        switch self {
        case .component1: return "Component 1"
        case .component2: return "Component 2"
        case .component3: return "Component 3"
        }
    }
    
    var icon: String {
        switch self {
        case .component1: return "1.square.fill"
        case .component2: return "2.square.fill"
        case .component3: return "3.square.fill"
        }
    }
}

// MARK: - Component Data Model / 组件数据模型

/**
 * 组件数据结构
 * Component data structure
 */
struct ComponentData: Equatable {
    let title: String
    let description: String
    let items: [String]
    
    static func mock(for componentId: ComponentID) -> ComponentData {
        ComponentData(
            title: "\(componentId.displayName) 数据",
            description: "这是 \(componentId.englishName) 的演示数据",
            items: [
                "数据项 1 / Data Item 1",
                "数据项 2 / Data Item 2", 
                "数据项 3 / Data Item 3"
            ]
        )
    }
}

// NetworkErrorType is now imported from Models/NetworkErrorType.swift
// NetworkErrorType 现在从 Models/NetworkErrorType.swift 导入

// MARK: - TCA Reducer / TCA Reducer

/**
 * 🎮 MULTI-COMPONENT REDUCER - 多组件 Reducer
 * 
 * 设计模式 / Design Pattern: REDUX PATTERN
 * • 单一数据源 (Single Source of Truth)
 * • State 不可变 (Immutable State)
 * • 纯函数更新 (Pure Function Updates)
 */
@Reducer
struct MultiComponentNetworkErrorFeature {
    
    // MARK: - State / 状态
    
    /**
     * 📊 STATE DEFINITION - 状态定义
     * 
     * 设计原则 / Design Principle:
     * • 所有组件状态集中管理
     * • 使用字典存储多个组件状态
     * • 保持状态不可变性
     */
    @ObservableState
    struct State: Equatable {
        // Component states / 组件状态
        var componentStates: [ComponentID: ReduxPageState<ComponentData>] = {
            var states: [ComponentID: ReduxPageState<ComponentData>] = [:]
            for componentId in ComponentID.allCases {
                states[componentId] = .idle
            }
            return states
        }()
        
        // Error configurations / 错误配置
        var componentErrors: [ComponentID: NetworkErrorType] = [:]
        
        // Custom messages / 自定义消息
        var customMessages: [ComponentID: String] = [:]
        
        // UI state / UI 状态
        var selectedComponent: ComponentID = .component1
        
        // MARK: - Computed Properties / 计算属性
        
        /// Get page state for component / 获取组件页面状态
        func getPageState(for componentId: ComponentID) -> ReduxPageState<ComponentData> {
            return componentStates[componentId] ?? .idle
        }
        
        /// Get error type for component / 获取组件错误类型
        func getErrorType(for componentId: ComponentID) -> NetworkErrorType? {
            return componentErrors[componentId]
        }
        
        /// Get custom message for component / 获取组件自定义消息
        func getCustomMessage(for componentId: ComponentID) -> String? {
            return customMessages[componentId]
        }
    }
    
    // MARK: - Action / 动作
    
    /**
     * 🎮 ACTION ENUM - 动作枚举
     * 
     * 设计模式 / Design Pattern: COMMAND PATTERN
     * • 每个 case 封装一个用户意图
     * • 携带必要的数据
     * • 清晰的语义
     */
    enum Action {
        // Component selection / 组件选择
        case selectComponent(ComponentID)
        
        // Error configuration / 错误配置
        case setErrorType(ComponentID, NetworkErrorType)
        case setCustomMessage(ComponentID, String)
        case clearCustomMessage(ComponentID)
        case useDefaultMessage(ComponentID)
        
        // Component actions / 组件操作
        case loadData(ComponentID)
        case triggerError(ComponentID)
        case retry(ComponentID)
        case reset(ComponentID)
        
        // Batch actions / 批量操作
        case loadAllData
        case triggerAllErrors
        case resetAll
        case randomizeErrors
        
        // Data response / 数据响应
        case dataResponse(ComponentID, Result<ComponentData, Error>)
    }
    
    // MARK: - Reducer Body / Reducer 主体
    
    /**
     * 🎭 REDUCER IMPLEMENTATION - Reducer 实现
     * 
     * 核心职责 / Core Responsibilities:
     * • 处理 Action，更新 State
     * • 返回 Effect 处理副作用
     * • 保持纯函数特性
     */
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // MARK: Component Selection / 组件选择
                
            case let .selectComponent(componentId):
                state.selectedComponent = componentId
                return .none
                
            // MARK: Error Configuration / 错误配置
                
            case let .setErrorType(componentId, errorType):
                state.componentErrors[componentId] = errorType
                return .none
                
            case let .setCustomMessage(componentId, message):
                state.customMessages[componentId] = message.trimmingCharacters(in: .whitespacesAndNewlines)
                return .none
                
            case let .clearCustomMessage(componentId):
                state.customMessages.removeValue(forKey: componentId)
                return .none
                
            case let .useDefaultMessage(componentId):
                if let errorType = state.componentErrors[componentId] {
                    state.customMessages[componentId] = errorType.defaultMessage
                }
                return .none
                
            // MARK: Component Actions / 组件操作
                
            case let .loadData(componentId):
                state.componentStates[componentId] = .loading(.initial)
                
                return .run { send in
                    // Simulate network request / 模拟网络请求
                    try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                    
                    let data = ComponentData.mock(for: componentId)
                    await send(.dataResponse(componentId, .success(data)))
                } catch: { error, send in
                    await send(.dataResponse(componentId, .failure(error)))
                }
                
            case let .triggerError(componentId):
                guard let errorType = state.componentErrors[componentId] else {
                    return .none
                }
                
                let message = state.customMessages[componentId] ?? errorType.defaultMessage
                let errorInfo = ReduxPageState<ComponentData>.ErrorInfo(
                    code: errorType.errorCode,
                    message: message
                )
                
                state.componentStates[componentId] = .failed(.initial, errorInfo)
                return .none
                
            case let .retry(componentId):
                return .send(.loadData(componentId))
                
            case let .reset(componentId):
                state.componentStates[componentId] = .idle
                state.componentErrors.removeValue(forKey: componentId)
                state.customMessages.removeValue(forKey: componentId)
                return .none
                
            // MARK: Batch Actions / 批量操作
                
            case .loadAllData:
                return .merge(
                    ComponentID.allCases.map { componentId in
                        .send(.loadData(componentId))
                    }
                )
                
            case .triggerAllErrors:
                // Set default error if not configured / 如果未配置则设置默认错误
                for componentId in ComponentID.allCases {
                    if state.componentErrors[componentId] == nil {
                        state.componentErrors[componentId] = NetworkErrorType.allCases.randomElement()
                    }
                }
                
                return .merge(
                    ComponentID.allCases.map { componentId in
                        .send(.triggerError(componentId))
                    }
                )
                
            case .resetAll:
                return .merge(
                    ComponentID.allCases.map { componentId in
                        .send(.reset(componentId))
                    }
                )
                
            case .randomizeErrors:
                for componentId in ComponentID.allCases {
                    let randomError = NetworkErrorType.allCases.randomElement()!
                    state.componentErrors[componentId] = randomError
                    
                    // 50% chance to use custom message / 50% 概率使用自定义消息
                    if Bool.random() {
                        state.customMessages[componentId] = """
                        自定义: \(randomError.displayName) 错误发生在 \(componentId.displayName)
                        Custom: \(randomError.englishName) occurred in \(componentId.englishName)
                        """
                    }
                }
                
                return .send(.triggerAllErrors)
                
            // MARK: Data Response / 数据响应
                
            case let .dataResponse(componentId, result):
                switch result {
                case let .success(data):
                    state.componentStates[componentId] = .loaded(data, .idle)
                    
                case let .failure(error):
                    let errorInfo = ReduxPageState<ComponentData>.ErrorInfo(
                        code: "UNKNOWN",
                        message: error.localizedDescription
                    )
                    state.componentStates[componentId] = .failed(.initial, errorInfo)
                }
                return .none
            }
        }
    }
}