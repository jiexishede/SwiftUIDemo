# 📚 TCA Counter Demo 完整学习指南
# 📚 TCA Counter Demo Complete Learning Guide

## 🎯 学习目标 / Learning Objectives

通过这个计数器示例，你将学会：

Through this counter example, you will learn:

1. **TCA 核心概念** - State、Action、Reducer、Effect、Store
2. **单向数据流** - 理解数据如何在 TCA 中流动
3. **副作用处理** - 定时器、网络请求等异步操作
4. **View 层集成** - 如何将 TCA 与 SwiftUI 结合

---

## 📖 第一部分：理解 TCA 架构
## 📖 Part 1: Understanding TCA Architecture

### 🏗️ TCA 架构图
### 🏗️ TCA Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      用户界面 (UI)                        │
│                         View                             │
│                  显示状态 | 响应用户操作                    │
└────────────────────┬───────────────┬───────────────────┘
                     │               │
                  读取状态         发送 Action
                     │               │
                     ↓               ↓
┌─────────────────────────────────────────────────────────┐
│                    ViewStore                             │
│              观察状态变化 | 分发 Action                     │
└────────────────────┬───────────────┬───────────────────┘
                     │               │
                     ↓               ↓
┌─────────────────────────────────────────────────────────┐
│                      Store                               │
│               状态容器 | Action 分发器                     │
└────────────────────┬───────────────┬───────────────────┘
                     │               │
                     ↓               ↓
┌─────────────────────────────────────────────────────────┐
│                     Reducer                              │
│           纯函数：(State, Action) → (State, Effect)       │
└────────────────────┬───────────────┬───────────────────┘
                     │               │
                  更新 State      执行 Effect
                     │               │
                     ↓               ↓
┌──────────────────────┐    ┌────────────────────────────┐
│       State          │    │        Effect              │
│     应用状态数据       │    │    副作用（异步操作）         │
└──────────────────────┘    └────────────────────────────┘
```

### 🔄 数据流向说明
### 🔄 Data Flow Explanation

1. **用户交互** → View 捕获用户操作
2. **发送 Action** → View 通过 ViewStore 发送 Action
3. **Store 接收** → Store 接收 Action 并传递给 Reducer
4. **Reducer 处理** → Reducer 根据 Action 更新 State，返回 Effect
5. **State 更新** → 新的 State 被保存
6. **Effect 执行** → 异步操作执行，可能发送新的 Action
7. **UI 更新** → View 观察到 State 变化，自动更新 UI

---

## 📝 第二部分：代码详解
## 📝 Part 2: Code Breakdown

### 1️⃣ State - 状态定义

```swift
@ObservableState
struct State: Equatable {
    var count: Int = 0              // 核心数据
    var isTimerActive: Bool = false // UI 状态
    var randomFactAlert: String? = nil // 临时数据
}
```

**关键点 / Key Points:**
- ✅ 使用 `@ObservableState` 使状态可观察
- ✅ 实现 `Equatable` 用于状态比较
- ✅ 只存储必要的数据
- ❌ 不要存储 View 或闭包

### 2️⃣ Action - 动作定义

```swift
enum Action {
    // 用户操作
    case incrementButtonTapped
    case decrementButtonTapped
    
    // 系统事件
    case timerTick
    
    // 带数据的 Action
    case randomFactResponse(String)
}
```

**命名规范 / Naming Convention:**
- 用户操作：`xxxButtonTapped`
- 系统响应：`xxxResponse`
- 生命周期：`onAppear`, `onDisappear`

### 3️⃣ Reducer - 业务逻辑

```swift
var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        case .incrementButtonTapped:
            state.count += 1
            return .none  // 无副作用
            
        case .toggleTimerButtonTapped:
            state.isTimerActive.toggle()
            if state.isTimerActive {
                return .run { send in  // 异步副作用
                    while true {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            } else {
                return .cancel(id: CancelID.timer)
            }
        }
    }
}
```

### 4️⃣ View - 视图层

```swift
struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                // 读取状态
                Text("Count: \(viewStore.count)")
                
                // 发送 Action
                Button("Increment") {
                    viewStore.send(.incrementButtonTapped)
                }
            }
        }
    }
}
```

---

## 🎮 第三部分：实战练习
## 🎮 Part 3: Hands-on Practice

### 练习 1：添加倍增功能
### Exercise 1: Add Double Feature

**需求 / Requirements:**
添加一个按钮，点击后将计数翻倍

Add a button that doubles the count when tapped

**步骤 / Steps:**

1. 在 Action 中添加新 case：
```swift
enum Action {
    // ... existing cases
    case doubleButtonTapped  // 新增
}
```

2. 在 Reducer 中处理：
```swift
case .doubleButtonTapped:
    state.count *= 2
    return .none
```

3. 在 View 中添加按钮：
```swift
Button("Double") {
    viewStore.send(.doubleButtonTapped)
}
```

### 练习 2：添加历史记录
### Exercise 2: Add History

**需求 / Requirements:**
记录最近 5 次的计数值

Keep track of the last 5 count values

**提示 / Hints:**
- 在 State 中添加 `var history: [Int] = []`
- 在每次计数改变时更新历史
- 限制数组长度为 5

### 练习 3：添加自动计数
### Exercise 3: Add Auto Count

**需求 / Requirements:**
添加一个开关，开启后每秒自动增加计数

Add a toggle that automatically increments count every second

**提示 / Hints:**
- 参考现有的定时器实现
- 使用不同的 CancelID
- 处理开关状态

---

## ⚠️ 第四部分：常见错误及解决方案
## ⚠️ Part 4: Common Errors and Solutions

### 错误 1：直接修改状态
### Error 1: Directly Modifying State

❌ **错误代码 / Wrong Code:**
```swift
Button("Increment") {
    viewStore.count += 1  // 不能直接修改！
}
```

✅ **正确代码 / Correct Code:**
```swift
Button("Increment") {
    viewStore.send(.incrementButtonTapped)
}
```

**原因 / Reason:**
TCA 遵循单向数据流，所有状态修改必须通过 Reducer

TCA follows unidirectional data flow, all state changes must go through Reducer

### 错误 2：Effect 不执行
### Error 2: Effect Not Executing

❌ **错误代码 / Wrong Code:**
```swift
case .fetchData:
    fetchDataFromNetwork()  // 直接调用异步函数
    return .none
```

✅ **正确代码 / Correct Code:**
```swift
case .fetchData:
    return .run { send in
        let data = await fetchDataFromNetwork()
        await send(.dataResponse(data))
    }
```

### 错误 3：定时器不停止
### Error 3: Timer Won't Stop

❌ **错误代码 / Wrong Code:**
```swift
return .run { send in
    while true {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await send(.timerTick)
    }
}
// 忘记添加 .cancellable
```

✅ **正确代码 / Correct Code:**
```swift
return .run { send in
    while true {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        await send(.timerTick)
    }
}
.cancellable(id: CancelID.timer)  // 必须添加！
```

### 错误 4：竞态条件
### Error 4: Race Condition

❌ **错误代码 / Wrong Code:**
```swift
case .fetchNumberFact:
    return .run { send in
        // 直接使用 state.count，可能已经改变
        let fact = await getNumberFact(for: state.count)
        await send(.factResponse(fact))
    }
```

✅ **正确代码 / Correct Code:**
```swift
case .fetchNumberFact:
    return .run { [count = state.count] send in
        // 捕获当前值，避免竞态条件
        let fact = await getNumberFact(for: count)
        await send(.factResponse(fact))
    }
```

---

## 💡 第五部分：最佳实践
## 💡 Part 5: Best Practices

### 1. State 设计原则
### 1. State Design Principles

```swift
// ✅ 好的 State 设计
struct State: Equatable {
    var items: [Item] = []        // 核心数据
    var isLoading: Bool = false   // UI 状态
    var errorMessage: String?     // 错误信息
    
    // 使用计算属性而非存储派生数据
    var hasItems: Bool {
        !items.isEmpty
    }
}

// ❌ 不好的 State 设计
struct State: Equatable {
    var items: [Item] = []
    var itemCount: Int = 0        // 派生数据，应该用计算属性
    var view: AnyView?            // 不应该存储 View
    var timer: Timer?             // 不应该存储引用类型
}
```

### 2. Action 命名规范
### 2. Action Naming Convention

```swift
enum Action {
    // ✅ 清晰的命名
    case loginButtonTapped
    case loginResponse(Result<User, Error>)
    case logoutConfirmationShown
    
    // ❌ 模糊的命名
    case update
    case change
    case action1
}
```

### 3. Reducer 组织
### 3. Reducer Organization

```swift
var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        // 按功能分组
        
        // MARK: - Authentication
        case .loginButtonTapped:
            return handleLogin(state: &state)
            
        // MARK: - Data Loading
        case .refreshButtonTapped:
            return handleRefresh(state: &state)
            
        // MARK: - UI State
        case .alertDismissed:
            state.alert = nil
            return .none
        }
    }
}

// 复杂逻辑抽取为私有方法
private func handleLogin(state: inout State) -> Effect<Action> {
    // ...
}
```

### 4. Effect 管理
### 4. Effect Management

```swift
// 使用枚举管理 CancelID
private enum CancelID: Hashable {
    case timer
    case dataFetch
    case userSession
}

// 正确取消 Effect
case .viewDisappeared:
    return .merge(
        .cancel(id: CancelID.timer),
        .cancel(id: CancelID.dataFetch)
    )
```

---

## 📊 第六部分：调试技巧
## 📊 Part 6: Debugging Tips

### 1. 使用 _printChanges()
### 1. Using _printChanges()

```swift
var body: some ReducerOf<Self> {
    Reduce { state, action in
        // 打印每个 Action 和 State 变化
        return .none
    }
    ._printChanges()  // 添加这行进行调试
}
```

### 2. 日志记录
### 2. Logging

```swift
case .incrementButtonTapped:
    print("🔵 Action: Increment, Old count: \(state.count)")
    state.count += 1
    print("🟢 New count: \(state.count)")
    return .none
```

### 3. 断点调试
### 3. Breakpoint Debugging

在以下位置设置断点：
- Reducer 的 switch 语句
- Effect 的异步代码块
- View 的 send 调用

Set breakpoints at:
- Reducer's switch statement
- Effect's async code blocks
- View's send calls

---

## 🎯 第七部分：进阶主题
## 🎯 Part 7: Advanced Topics

### 1. Dependency Injection
### 1. 依赖注入

```swift
@Reducer
struct Feature {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            case .fetchData:
                return .run { send in
                    let data = try await apiClient.fetch()
                    await send(.dataResponse(data))
                }
        }
    }
}
```

### 2. Testing
### 2. 测试

```swift
@MainActor
final class CounterFeatureTests: XCTestCase {
    func testIncrement() async {
        let store = TestStore(
            initialState: CounterFeature.State(count: 0)
        ) {
            CounterFeature()
        }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
    }
}
```

### 3. Composition
### 3. 组合

```swift
@Reducer
struct AppFeature {
    struct State {
        var counter = CounterFeature.State()
        var profile = ProfileFeature.State()
    }
    
    enum Action {
        case counter(CounterFeature.Action)
        case profile(ProfileFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.counter, action: /Action.counter) {
            CounterFeature()
        }
        Scope(state: \.profile, action: /Action.profile) {
            ProfileFeature()
        }
    }
}
```

---

## 📚 第八部分：学习资源
## 📚 Part 8: Learning Resources

### 官方资源 / Official Resources
1. **TCA Documentation**: https://pointfreeco.github.io/swift-composable-architecture/
2. **Point-Free Videos**: https://www.pointfree.co/
3. **GitHub Examples**: https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples

### 学习路径 / Learning Path
1. **Week 1**: 理解基础概念，完成 Counter Demo
2. **Week 2**: 学习 Effect 和异步操作
3. **Week 3**: 掌握导航和多页面管理
4. **Week 4**: 学习测试和依赖注入

### 实战项目建议 / Project Suggestions
1. **Todo App**: 列表管理、CRUD 操作
2. **Weather App**: 网络请求、错误处理
3. **Timer App**: 复杂状态、后台任务
4. **Chat App**: 实时更新、WebSocket

---

## ✅ 总结
## ✅ Summary

通过这个 Counter Demo，你已经学会了：

Through this Counter Demo, you have learned:

1. ✅ TCA 的核心概念和架构
2. ✅ 如何定义 State、Action 和 Reducer
3. ✅ 如何处理副作用（Effect）
4. ✅ 如何将 TCA 与 SwiftUI 集成
5. ✅ 常见错误和最佳实践

**下一步 / Next Steps:**
- 尝试完成练习题
- 阅读更多 TCA 文档
- 构建自己的 TCA 项目
- 加入 TCA 社区讨论

---

## 🤔 常见问题 FAQ
## 🤔 Frequently Asked Questions

**Q: 为什么要使用 TCA 而不是 SwiftUI 的 @State？**

**A:** TCA 提供了更好的状态管理、可测试性和可预测性，特别适合复杂应用。

TCA provides better state management, testability, and predictability, especially for complex apps.

**Q: TCA 的学习曲线如何？**

**A:** 初期较陡峭，但掌握后能大幅提升代码质量和开发效率。

Initial learning curve is steep, but mastery significantly improves code quality and development efficiency.

**Q: TCA 适合所有项目吗？**

**A:** 不一定。简单项目可能过度设计，中大型项目效果最佳。

Not necessarily. Simple projects might be over-engineered, medium to large projects benefit most.

**Q: 如何调试 TCA 应用？**

**A:** 使用 _printChanges()、断点、日志和 TCA 的测试工具。

Use _printChanges(), breakpoints, logging, and TCA's testing tools.

---

*Happy Learning! 祝学习愉快！* 🚀