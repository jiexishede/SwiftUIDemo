//
//  CounterViewDetailed.swift
//  SwiftUIDemo
//
//  TCA View 层详细学习示例 - 计数器视图
//  TCA View Layer Detailed Learning Example - Counter View
//

/**
 * 🎯 TCA VIEW LAYER - 视图层详解
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * 📚 学习目标 / Learning Objectives:
 * 1. 理解 Store 和 ViewStore 的作用
 * 2. 掌握 WithViewStore 的使用方法
 * 3. 学习如何发送 Action
 * 4. 理解状态观察和 UI 更新机制
 * 
 * Understand Store and ViewStore roles
 * Master WithViewStore usage
 * Learn how to send Actions
 * Understand state observation and UI updates
 * 
 * 🏗️ View 层架构 / View Layer Architecture:
 * 
 *     Store (状态容器)
 *          ↓
 *     WithViewStore (观察状态)
 *          ↓
 *     ViewStore (访问状态和发送 Action)
 *          ↓
 *     SwiftUI View (UI 渲染)
 * 
 * ⚠️ 易错点提醒 / Common Pitfalls:
 * 1. 忘记使用 WithViewStore 包装视图
 * 2. 直接访问 store 而非 viewStore
 * 3. 在 View 中进行业务逻辑处理
 * 4. 错误的状态观察导致过度渲染
 * 5. Alert 绑定处理不当
 */

import SwiftUI
import ComposableArchitecture

struct CounterViewDetailed: View {
    
    // MARK: - 🏪 Store 属性 / Store Property
    
    /**
     * Store 的作用 / Purpose of Store:
     * 
     * Store 是 TCA 的核心容器，负责：
     * 1. 持有应用状态 (State)
     * 2. 接收和分发动作 (Action)
     * 3. 执行 Reducer 逻辑
     * 4. 管理副作用 (Effects)
     * 
     * Store is TCA's core container, responsible for:
     * 1. Holding application state
     * 2. Receiving and dispatching actions
     * 3. Executing reducer logic
     * 4. Managing side effects
     * 
     * 🔑 关键点 / Key Points:
     * • 使用 StoreOf<Feature> 类型别名简化声明
     * • Store 是引用类型，在视图间共享
     * • 不直接在 View 中访问 store.state
     * 
     * ⚠️ 重要：Store 必须通过 WithViewStore 使用
     * ⚠️ Important: Store must be used through WithViewStore
     */
    let store: StoreOf<CounterFeatureDetailed>
    
    // 等价于 / Equivalent to:
    // let store: Store<CounterFeatureDetailed.State, CounterFeatureDetailed.Action>
    
    var body: some View {
        
        // MARK: - 📺 WithViewStore 包装器 / WithViewStore Wrapper
        
        /**
         * WithViewStore 的作用 / Purpose of WithViewStore:
         * 
         * 1. 观察 Store 中的状态变化
         * 2. 当状态改变时触发视图更新
         * 3. 提供 ViewStore 实例供视图使用
         * 4. 优化渲染性能
         * 
         * Observe state changes in Store
         * Trigger view updates when state changes
         * Provide ViewStore instance for view usage
         * Optimize rendering performance
         * 
         * 🎯 observe 参数详解 / observe Parameter:
         * 
         * observe: { $0 } 表示观察整个 state
         * 可以优化为只观察需要的部分：
         * 
         * observe: { $0 } means observe entire state
         * Can optimize to observe only needed parts:
         * 
         * 示例 / Examples:
         * • observe: \.count - 只观察 count
         * • observe: { ($0.count, $0.isTimerActive) } - 观察多个属性
         * • observe: { $0 } - 观察所有（简单场景可接受）
         * 
         * ⚠️ 性能提示 / Performance Tip:
         * 只观察必要的状态可以减少不必要的重渲染
         * Observing only necessary state reduces unnecessary re-renders
         */
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            /**
             * 🔑 viewStore 的作用 / Purpose of viewStore:
             * 
             * ViewStore 提供了两个核心功能：
             * 1. 访问当前状态：viewStore.state 或 viewStore.count
             * 2. 发送 Action：viewStore.send(.someAction)
             * 
             * ViewStore provides two core functions:
             * 1. Access current state: viewStore.state or viewStore.count
             * 2. Send actions: viewStore.send(.someAction)
             * 
             * 可以直接访问 state 的属性，因为 ViewStore 使用了 @dynamicMemberLookup
             * Can directly access state properties due to @dynamicMemberLookup
             */
            
            VStack(spacing: 20) {
                
                // MARK: - 📊 状态显示 / State Display
                
                /**
                 * 🎯 学习点：读取状态
                 * Learning Point: Reading State
                 * 
                 * 直接通过 viewStore 访问 state 属性
                 * SwiftUI 会自动监听变化并更新 UI
                 * 
                 * Directly access state properties through viewStore
                 * SwiftUI automatically listens for changes and updates UI
                 */
                Text("Count: \(viewStore.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(viewStore.count > 0 ? .blue : .gray)
                    /**
                     * 💡 提示：可以基于状态进行条件渲染
                     * 💡 Tip: Can do conditional rendering based on state
                     */
                
                // 显示额外的状态信息 / Display additional state info
                if viewStore.isTimerActive {
                    Text("⏱ Timer is running...")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                // MARK: - 🎮 基础操作按钮 / Basic Operation Buttons
                
                HStack(spacing: 20) {
                    
                    /**
                     * 🎯 学习点：发送简单 Action
                     * Learning Point: Sending Simple Actions
                     * 
                     * 使用 viewStore.send() 发送 Action
                     * Action 会被 Store 接收并传递给 Reducer
                     * 
                     * Use viewStore.send() to send Actions
                     * Actions are received by Store and passed to Reducer
                     * 
                     * ⚠️ 注意：不要在这里处理业务逻辑
                     * ⚠️ Note: Don't handle business logic here
                     * 
                     * ❌ 错误示例 / Wrong Example:
                     * Button {
                     *     viewStore.count -= 1  // 不能直接修改！
                     * }
                     * 
                     * ✅ 正确示例 / Correct Example:
                     * Button {
                     *     viewStore.send(.decrementButtonTapped)
                     * }
                     */
                    Button(action: {
                        viewStore.send(.decrementButtonTapped)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(viewStore.count > 0 ? .blue : .gray)
                    }
                    .disabled(viewStore.count <= 0)
                    /**
                     * 💡 提示：可以基于状态禁用按钮
                     * 💡 Tip: Can disable buttons based on state
                     */
                    
                    Button(action: {
                        viewStore.send(.incrementButtonTapped)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                
                // MARK: - 🎛 控制按钮 / Control Buttons
                
                HStack(spacing: 20) {
                    
                    /**
                     * 🎯 学习点：复合 Action
                     * Learning Point: Compound Actions
                     * 
                     * Reset 按钮会触发多个状态更新
                     * 这些都在 Reducer 中处理，View 只负责发送
                     * 
                     * Reset button triggers multiple state updates
                     * All handled in Reducer, View only sends
                     */
                    Button(action: {
                        viewStore.send(.resetButtonTapped)
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .padding(.horizontal)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    /**
                     * 🎯 学习点：基于状态的动态 UI
                     * Learning Point: State-based Dynamic UI
                     * 
                     * 按钮文本根据 isTimerActive 状态动态变化
                     * Button text changes based on isTimerActive state
                     */
                    Button(action: {
                        viewStore.send(.toggleTimerButtonTapped)
                    }) {
                        HStack {
                            Image(systemName: viewStore.isTimerActive ? "stop.fill" : "play.fill")
                            Text(viewStore.isTimerActive ? "Stop Timer" : "Start Timer")
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewStore.isTimerActive ? .red : .green)
                }
                
                // MARK: - 🌐 网络请求按钮 / Network Request Button
                
                /**
                 * 🎯 学习点：触发异步操作
                 * Learning Point: Triggering Async Operations
                 * 
                 * View 不需要知道这是异步操作
                 * 只需要发送 Action，Reducer 处理具体逻辑
                 * 
                 * View doesn't need to know it's async
                 * Just send Action, Reducer handles logic
                 */
                Button(action: {
                    viewStore.send(.getRandomFactButtonTapped)
                }) {
                    HStack {
                        Image(systemName: "network")
                        Text("Get Random Fact")
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.bordered)
                
                // 添加一些视觉反馈 / Add visual feedback
                if viewStore.randomFactAlert != nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .navigationTitle("Counter Demo 计数器演示")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - 🔔 Alert 处理 / Alert Handling
            
            /**
             * 🎯 学习点：Alert 的 TCA 处理方式
             * Learning Point: TCA Way of Handling Alerts
             * 
             * 关键技术点 / Key Technical Points:
             * 
             * 1. isPresented 绑定：
             *    使用 .constant() 创建只读绑定
             *    基于 state 中的可选值判断
             * 
             * 2. presenting 参数：
             *    传递要显示的数据
             * 
             * 3. 在 action 闭包中发送 dismiss Action
             * 
             * ⚠️ 易错点 / Common Mistakes:
             * ❌ 使用 @State 管理 alert 状态
             * ❌ 直接修改 viewStore 的值
             * ✅ 通过 Action 管理所有状态变化
             */
            .alert(
                "Number Fact 数字趣事",
                isPresented: .constant(viewStore.randomFactAlert != nil),
                /**
                 * 🔑 .constant() 的作用：
                 * Purpose of .constant():
                 * 
                 * 创建一个只读的 Binding
                 * Alert 不能直接修改这个值
                 * 所有修改必须通过 Action
                 * 
                 * Creates a read-only Binding
                 * Alert cannot directly modify this value
                 * All modifications must go through Actions
                 */
                presenting: viewStore.randomFactAlert
            ) { fact in
                // Alert 按钮 / Alert buttons
                Button("OK 确定") {
                    viewStore.send(.dismissRandomFactAlert)
                }
                
                // 可以添加更多按钮 / Can add more buttons
                Button("Share 分享") {
                    // 发送分享 Action
                    // Send share Action
                    print("Share: \(fact)")
                }
            } message: { fact in
                // Alert 消息内容 / Alert message content
                Text(fact)
            }
            
            // MARK: - 🎨 其他 UI 元素 / Other UI Elements
            
            /**
             * 💡 最佳实践提示 / Best Practice Tips:
             * 
             * 1. View 保持简单，只负责：
             *    - 显示状态
             *    - 发送 Action
             *    - 基本的 UI 逻辑
             * 
             * 2. 不要在 View 中：
             *    - 进行复杂计算
             *    - 直接修改状态
             *    - 处理业务逻辑
             *    - 进行网络请求
             * 
             * 3. 使用 ViewModifier 封装重复的 UI 模式
             * 
             * 4. 合理拆分子视图避免过于复杂
             */
        }
    }
}

// MARK: - 🎭 Preview Provider / 预览提供者

/**
 * 🎯 学习点：创建预览
 * Learning Point: Creating Previews
 * 
 * TCA 视图的预览需要创建 Store
 * TCA view previews need to create Store
 */
struct CounterViewDetailed_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CounterViewDetailed(
                store: Store(
                    initialState: CounterFeatureDetailed.State(
                        count: 5,
                        isTimerActive: false,
                        randomFactAlert: nil
                    )
                ) {
                    CounterFeatureDetailed()
                }
            )
        }
    }
}

// MARK: - 📚 View 层学习总结 / View Layer Learning Summary

/**
 * 🎓 TCA View 层核心概念 / TCA View Layer Core Concepts:
 * 
 * 1️⃣ Store（存储）
 * ────────────────────────────────
 * • 容器：持有 State 和 Reducer
 * • 中心：所有状态管理的中心
 * • 共享：在视图间共享状态
 * 
 * 2️⃣ ViewStore（视图存储）
 * ────────────────────────────────
 * • 观察：监听状态变化
 * • 访问：读取当前状态
 * • 发送：分发 Action
 * 
 * 3️⃣ WithViewStore（观察包装器）
 * ────────────────────────────────
 * • 连接：连接 Store 和 View
 * • 优化：控制重渲染范围
 * • 提供：提供 ViewStore 实例
 * 
 * 4️⃣ Action（动作）
 * ────────────────────────────────
 * • 意图：表达用户意图
 * • 单向：单向数据流
 * • 纯粹：不包含逻辑
 * 
 * 🚨 View 层常见错误 / Common View Layer Errors:
 * 
 * ❌ 错误 1：直接修改状态
 * viewStore.count += 1  // 错误！
 * ✅ 正确：viewStore.send(.increment)
 * 
 * ❌ 错误 2：在 View 中处理逻辑
 * if viewStore.count < 0 { viewStore.count = 0 }  // 错误！
 * ✅ 正确：在 Reducer 中处理
 * 
 * ❌ 错误 3：使用 @State 管理状态
 * @State var count = 0  // 错误！
 * ✅ 正确：使用 Store 中的状态
 * 
 * ❌ 错误 4：忘记 WithViewStore
 * Text("\(store.state.count)")  // 错误！
 * ✅ 正确：WithViewStore { viewStore in Text("\(viewStore.count)") }
 * 
 * ❌ 错误 5：过度观察
 * observe: { $0 }  // 观察所有，可能导致过度渲染
 * ✅ 正确：observe: \.count  // 只观察需要的
 * 
 * 💡 性能优化技巧 / Performance Optimization Tips:
 * 
 * 1. 精确观察：只观察需要的状态属性
 * 2. 拆分视图：将复杂视图拆分为子视图
 * 3. 使用 EquatableView：对于复杂的等值比较
 * 4. 避免闭包捕获：使用 [weak self] 避免循环引用
 * 5. 延迟加载：使用 LazyVStack/LazyHStack
 * 
 * 📖 进阶学习方向 / Advanced Learning:
 * 
 * 1. Scoping：如何将 Store 作用域限制到子功能
 * 2. IfLetStore：处理可选状态
 * 3. ForEachStore：处理集合状态
 * 4. Navigation：TCA 中的导航处理
 * 5. Testing：如何测试 TCA 视图
 */