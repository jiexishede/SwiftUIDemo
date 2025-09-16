//
//  CounterFeatureDetailed.swift
//  SwiftUIDemo
//
//  TCA (The Composable Architecture) 详细学习示例 - 计数器功能
//  TCA Detailed Learning Example - Counter Feature
//

/**
 * 🎯 TCA COUNTER FEATURE - 计数器功能详解
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * 📚 学习目标 / Learning Objectives:
 * 1. 理解 TCA 的核心概念：State、Action、Reducer
 * 2. 掌握副作用（Side Effects）的处理方式
 * 3. 学习定时器和网络请求的实现
 * 4. 理解状态管理和单向数据流
 * 
 * Understand TCA core concepts: State, Action, Reducer
 * Master side effects handling
 * Learn timer and network request implementation
 * Understand state management and unidirectional data flow
 * 
 * 🏗️ TCA 架构模式 / TCA Architecture Pattern:
 * 
 *     用户交互 (User Interaction)
 *          ↓
 *     View 发送 Action
 *          ↓
 *     Store 接收 Action
 *          ↓
 *     Reducer 处理 Action
 *          ↓
 *     State 更新
 *          ↓
 *     View 重新渲染
 * 
 * ⚠️ 易错点提醒 / Common Pitfalls:
 * 1. 忘记使用 @ObservableState 标记 State
 * 2. 副作用没有正确返回 Effect
 * 3. 忘记取消长时间运行的 Effect
 * 4. State 不符合 Equatable 协议
 * 5. 在 Reducer 中直接进行 UI 操作
 * 
 * 🔑 关键概念 / Key Concepts:
 * • State: 应用的状态数据（不可变）
 * • Action: 用户操作或系统事件
 * • Reducer: 纯函数，根据 Action 更新 State
 * • Effect: 副作用，如网络请求、定时器等
 * • Store: 连接 View 和 Reducer 的容器
 */

import ComposableArchitecture
import Foundation

// MARK: - ⭐ Reducer 定义 / Reducer Definition

/**
 * @Reducer 宏的作用 / Purpose of @Reducer Macro:
 * 
 * 1. 自动生成 TCA 需要的样板代码
 * 2. 提供类型安全的 Reducer 协议实现
 * 3. 支持 Reducer 组合和作用域
 * 
 * Auto-generates TCA boilerplate code
 * Provides type-safe Reducer protocol implementation
 * Supports reducer composition and scoping
 * 
 * ⚠️ 重要：必须使用 @Reducer 宏，否则无法正常工作
 * ⚠️ Important: Must use @Reducer macro, otherwise it won't work
 */
@Reducer
struct CounterFeatureDetailed {
    
    // MARK: - 📊 State 定义 / State Definition
    
    /**
     * State 设计原则 / State Design Principles:
     * 
     * 1. ✅ 必须是 struct（值类型）
     * 2. ✅ 必须遵循 Equatable 协议
     * 3. ✅ 必须使用 @ObservableState 标记
     * 4. ✅ 只包含 UI 需要的数据
     * 5. ✅ 保持扁平化，避免深层嵌套
     * 
     * Must be a struct (value type)
     * Must conform to Equatable protocol
     * Must be marked with @ObservableState
     * Only include data needed by UI
     * Keep it flat, avoid deep nesting
     * 
     * ⚠️ 易错点 / Common Mistakes:
     * ❌ 不要在 State 中存储 View 组件
     * ❌ 不要存储派生数据（使用计算属性）
     * ❌ 不要存储临时的 UI 状态（如键盘高度）
     * 
     * Don't store View components in State
     * Don't store derived data (use computed properties)
     * Don't store temporary UI state (like keyboard height)
     */
    @ObservableState
    struct State: Equatable {
        // 核心业务数据 / Core business data
        var count: Int = 0
        
        // UI 控制状态 / UI control state
        var isTimerActive: Bool = false
        
        // Alert 展示状态 / Alert display state
        var randomFactAlert: String? = nil
        
        // 🎯 学习点：可以添加计算属性 / Learning Point: Can add computed properties
        var countDescription: String {
            """
            当前计数：\(count)
            Current count: \(count)
            """
        }
        
        // 🎯 学习点：可以添加业务逻辑判断 / Learning Point: Can add business logic
        var canDecrement: Bool {
            count > 0
        }
    }
    
    // MARK: - 🎬 Action 定义 / Action Definition
    
    /**
     * Action 设计原则 / Action Design Principles:
     * 
     * 1. 每个用户交互对应一个 Action
     * 2. 命名要清晰表达意图
     * 3. 使用过去式表示已发生的事件
     * 4. 可以携带关联数据
     * 
     * One Action per user interaction
     * Clear naming expressing intent
     * Use past tense for events that occurred
     * Can carry associated data
     * 
     * 命名规范 / Naming Convention:
     * • 用户操作：xxxButtonTapped, xxxSwiped
     * • 系统事件：xxxResponse, xxxReceived
     * • 生命周期：onAppear, onDisappear
     * 
     * ⚠️ 易错点 / Common Mistakes:
     * ❌ 不要在 Action 中包含闭包或函数
     * ❌ 不要包含不可序列化的数据
     * ❌ 避免 Action 名称过于通用（如 update）
     * 
     * Don't include closures or functions in Actions
     * Don't include non-serializable data
     * Avoid overly generic Action names (like 'update')
     */
    enum Action {
        // 用户交互 Actions / User interaction Actions
        case incrementButtonTapped      // 增加按钮点击
        case decrementButtonTapped      // 减少按钮点击
        case resetButtonTapped          // 重置按钮点击
        case toggleTimerButtonTapped    // 切换定时器按钮点击
        
        // 系统事件 Actions / System event Actions
        case timerTick                  // 定时器触发
        
        // 网络请求 Actions / Network request Actions
        case getRandomFactButtonTapped  // 获取随机事实按钮点击
        case randomFactResponse(String) // 随机事实响应（携带数据）
        
        // UI 控制 Actions / UI control Actions
        case dismissRandomFactAlert     // 关闭随机事实弹窗
    }
    
    // MARK: - 🔖 CancelID 定义 / CancelID Definition
    
    /**
     * CancelID 的作用 / Purpose of CancelID:
     * 
     * 用于标识和管理可取消的 Effect（副作用）
     * 比如定时器、网络请求、长时间运行的任务
     * 
     * Used to identify and manage cancellable Effects
     * Such as timers, network requests, long-running tasks
     * 
     * 🎯 学习点 / Learning Point:
     * 使用 enum 确保 ID 的唯一性和类型安全
     * Using enum ensures ID uniqueness and type safety
     */
    private enum CancelID {
        case timer      // 定时器的取消标识
        case network    // 网络请求的取消标识（示例）
    }
    
    // MARK: - 🎮 Reducer 实现 / Reducer Implementation
    
    /**
     * Reducer 核心职责 / Core Responsibilities:
     * 
     * 1. 接收 Action，更新 State
     * 2. 返回 Effect 处理副作用
     * 3. 保持纯函数特性（相同输入产生相同输出）
     * 
     * Receive Action, update State
     * Return Effect to handle side effects
     * Maintain pure function property
     * 
     * 🔑 重要概念 - Effect 类型 / Important Concept - Effect Types:
     * 
     * • .none: 无副作用，只更新 State
     * • .run: 执行异步操作
     * • .cancel: 取消正在运行的 Effect
     * • .merge: 合并多个 Effect
     * • .concatenate: 顺序执行多个 Effect
     */
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            // MARK: 简单状态更新 / Simple State Update
                
            case .incrementButtonTapped:
                /**
                 * 🎯 学习点：最简单的 Action 处理
                 * Learning Point: Simplest Action handling
                 * 
                 * 1. 直接修改 state（会自动触发 UI 更新）
                 * 2. 返回 .none 表示没有副作用
                 * 
                 * Directly modify state (triggers UI update)
                 * Return .none for no side effects
                 */
                state.count += 1
                return .none
                
            case .decrementButtonTapped:
                /**
                 * 🎯 学习点：可以添加业务逻辑
                 * Learning Point: Can add business logic
                 */
                // 示例：可以添加边界检查
                // Example: Can add boundary check
                if state.count > 0 {
                    state.count -= 1
                }
                return .none
                
            case .resetButtonTapped:
                /**
                 * 🎯 学习点：复合操作
                 * Learning Point: Compound operations
                 * 
                 * 1. 更新多个 state 属性
                 * 2. 取消正在运行的 Effect
                 * 
                 * Update multiple state properties
                 * Cancel running Effects
                 * 
                 * ⚠️ 重要：重置时要清理所有相关状态
                 * ⚠️ Important: Clean all related state when resetting
                 */
                state.count = 0
                state.isTimerActive = false
                // 取消定时器 / Cancel timer
                return .cancel(id: CancelID.timer)
                
            // MARK: 定时器处理 / Timer Handling
                
            case .toggleTimerButtonTapped:
                /**
                 * 🎯 学习点：长时间运行的 Effect
                 * Learning Point: Long-running Effects
                 * 
                 * 关键技术点 / Key Technical Points:
                 * 1. 使用 .run 创建异步 Effect
                 * 2. 使用 .cancellable 使其可取消
                 * 3. 使用 while 循环实现持续运行
                 * 4. 使用 Task.sleep 实现延迟
                 * 
                 * ⚠️ 易错点 / Common Mistakes:
                 * ❌ 忘记添加 .cancellable
                 * ❌ 忘记处理取消逻辑
                 * ❌ 在循环中忘记 await
                 */
                state.isTimerActive.toggle()
                
                if state.isTimerActive {
                    // 启动定时器 / Start timer
                    return .run { send in
                        /**
                         * 🔑 关键：这里是在 Effect 的异步上下文中
                         * Key: This is in Effect's async context
                         * 
                         * send 是一个函数，用于发送新的 Action
                         * send is a function to dispatch new Actions
                         */
                        while true {
                            // 等待 1 秒 / Wait for 1 second
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            
                            // 发送 timerTick Action / Send timerTick Action
                            await send(.timerTick)
                            
                            /**
                             * ⚠️ 注意：这里必须使用 await send
                             * ⚠️ Note: Must use await send here
                             * 
                             * 因为 send 是异步函数
                             * Because send is an async function
                             */
                        }
                    }
                    .cancellable(id: CancelID.timer)
                    /**
                     * 🔑 .cancellable 的作用：
                     * Purpose of .cancellable:
                     * 
                     * 1. 给 Effect 分配一个 ID
                     * 2. 允许通过 .cancel(id:) 取消
                     * 3. 自动处理任务取消
                     * 
                     * Assign an ID to the Effect
                     * Allow cancellation via .cancel(id:)
                     * Auto-handle task cancellation
                     */
                } else {
                    // 停止定时器 / Stop timer
                    return .cancel(id: CancelID.timer)
                }
                
            case .timerTick:
                /**
                 * 🎯 学习点：定时器触发的 Action
                 * Learning Point: Timer-triggered Action
                 * 
                 * 这个 Action 是由定时器 Effect 发送的
                 * This Action is sent by timer Effect
                 */
                state.count += 1
                return .none
                
            // MARK: 网络请求处理 / Network Request Handling
                
            case .getRandomFactButtonTapped:
                /**
                 * 🎯 学习点：网络请求 Effect
                 * Learning Point: Network request Effect
                 * 
                 * 关键技术点 / Key Technical Points:
                 * 1. 使用 .run 执行异步网络请求
                 * 2. 捕获当前 state 值避免竞态条件
                 * 3. 请求完成后发送响应 Action
                 * 
                 * ⚠️ 重要：捕获值而非引用
                 * ⚠️ Important: Capture value not reference
                 */
                return .run { [count = state.count] send in
                    /**
                     * 🔑 [count = state.count] 的作用：
                     * Purpose of [count = state.count]:
                     * 
                     * 捕获当前的 count 值，避免竞态条件
                     * 如果不捕获，用户快速点击时可能获取错误的数字
                     * 
                     * Capture current count value to avoid race condition
                     * Without capture, rapid clicks may fetch wrong number
                     * 
                     * ⚠️ 这是一个常见的错误点！
                     * ⚠️ This is a common mistake!
                     */
                    
                    // 执行异步网络请求 / Execute async network request
                    let fact = await getNumberFact(for: count)
                    
                    // 发送响应 Action / Send response Action
                    await send(.randomFactResponse(fact))
                }
                
            case let .randomFactResponse(fact):
                /**
                 * 🎯 学习点：处理异步响应
                 * Learning Point: Handle async response
                 * 
                 * 使用 case let 解构关联值
                 * Use case let to destructure associated value
                 */
                state.randomFactAlert = fact
                return .none
                
            case .dismissRandomFactAlert:
                /**
                 * 🎯 学习点：清理 UI 状态
                 * Learning Point: Clean UI state
                 */
                state.randomFactAlert = nil
                return .none
            }
        }
    }
    
    // MARK: - 🌐 网络请求方法 / Network Request Method
    
    /**
     * 私有辅助方法 / Private Helper Method
     * 
     * 🎯 学习点 / Learning Points:
     * 1. 可以在 Reducer 中定义辅助方法
     * 2. 使用 async/await 处理异步操作
     * 3. 错误处理很重要
     * 
     * Can define helper methods in Reducer
     * Use async/await for async operations
     * Error handling is important
     * 
     * ⚠️ 注意：这个方法是纯函数，不直接修改 state
     * ⚠️ Note: This is a pure function, doesn't directly modify state
     */
    private func getNumberFact(for number: Int) async -> String {
        do {
            // 构建 URL / Build URL
            guard let url = URL(string: "http://numbersapi.com/\(number)") else {
                return "Invalid URL"
            }
            
            // 发起网络请求 / Make network request
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 解析响应 / Parse response
            return String(data: data, encoding: .utf8) ?? "Could not decode response"
            
        } catch {
            // 错误处理 / Error handling
            return "Error: \(error.localizedDescription)"
        }
    }
}

// MARK: - 📚 学习总结 / Learning Summary

/**
 * 🎓 TCA 学习路径建议 / TCA Learning Path:
 * 
 * 第一步：理解基础概念
 * Step 1: Understand Basic Concepts
 * ────────────────────────────────
 * 1. State - 状态数据
 * 2. Action - 用户操作
 * 3. Reducer - 状态更新逻辑
 * 4. Store - 连接器
 * 5. Effect - 副作用
 * 
 * 第二步：掌握数据流
 * Step 2: Master Data Flow
 * ────────────────────────────────
 * View → Action → Store → Reducer → State → View
 * 
 * 第三步：学习副作用处理
 * Step 3: Learn Side Effects
 * ────────────────────────────────
 * 1. 简单副作用：.none
 * 2. 异步操作：.run
 * 3. 取消操作：.cancel
 * 4. 组合操作：.merge, .concatenate
 * 
 * 第四步：实践项目
 * Step 4: Practice Projects
 * ────────────────────────────────
 * 1. 计数器（本例）- 基础概念
 * 2. Todo List - 列表管理
 * 3. 网络请求 - 异步处理
 * 4. 表单验证 - 复杂状态
 * 5. 导航流程 - 多页面协调
 * 
 * 🚨 常见错误及解决方案 / Common Errors and Solutions:
 * 
 * 1. ❌ 错误：State 不更新
 *    ✅ 解决：检查是否使用了 @ObservableState
 * 
 * 2. ❌ 错误：Effect 不执行
 *    ✅ 解决：确保返回了 Effect 而不是 .none
 * 
 * 3. ❌ 错误：定时器不停止
 *    ✅ 解决：添加 .cancellable 并正确调用 .cancel
 * 
 * 4. ❌ 错误：网络请求结果错乱
 *    ✅ 解决：使用值捕获 [value = state.value]
 * 
 * 5. ❌ 错误：内存泄漏
 *    ✅ 解决：避免在 Effect 中强引用 self
 * 
 * 💡 最佳实践 / Best Practices:
 * 
 * 1. ✅ State 保持最小化和扁平化
 * 2. ✅ Action 命名清晰表达意图
 * 3. ✅ Reducer 保持纯函数特性
 * 4. ✅ Effect 正确处理取消逻辑
 * 5. ✅ 使用 CancelID 管理长时间运行的任务
 * 6. ✅ 错误处理要完善
 * 7. ✅ 避免在 Reducer 中进行 UI 操作
 * 8. ✅ 使用计算属性而非存储派生数据
 * 
 * 📖 深入学习资源 / Further Learning:
 * 
 * 1. TCA 官方文档: https://pointfreeco.github.io/swift-composable-architecture/
 * 2. Point-Free 视频教程: https://www.pointfree.co/
 * 3. TCA 示例项目: https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples
 * 4. SwiftUI + TCA 最佳实践
 * 5. 单元测试 TCA 代码
 */