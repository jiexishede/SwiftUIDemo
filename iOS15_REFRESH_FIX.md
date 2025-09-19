# iOS 15 下拉刷新修复说明 / iOS 15 Pull-to-Refresh Fix Documentation

## 问题描述 / Problem Description

在 iOS 15 中，`.refreshable` 修饰符失效，下拉刷新功能无法正常工作。

In iOS 15, the `.refreshable` modifier was not working properly, and pull-to-refresh functionality failed.

## 根本原因 / Root Cause

1. **状态重置问题** / **State Reset Issue**
   - `resetForRefresh` action 需要正确重置所有状态到 `.loading`
   - The `resetForRefresh` action needs to properly reset all states to `.loading`

2. **异步等待问题** / **Async Waiting Issue**  
   - iOS 15 需要明确等待状态变化完成
   - iOS 15 requires explicit waiting for state changes to complete

3. **背景色问题** / **Background Color Issue**
   - ScrollView 需要设置背景色才能在 iOS 15 中正确显示刷新指示器
   - ScrollView needs a background color to properly show refresh indicator in iOS 15

## 解决方案 / Solution

### 1. 添加 ViewStore 观察 / Add ViewStore Observation

```swift
struct ECommerceHomeView: View {
    @ObservedObject var viewStore: ViewStore<ECommerceHomeFeature.State, ECommerceHomeFeature.Action>
    
    init(store: StoreOf<ECommerceHomeFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
}
```

### 2. 实现 performRefresh 函数 / Implement performRefresh Function

```swift
@MainActor
private func performRefresh() async {
    // 发送重置动作 / Send reset action
    store.send(.resetForRefresh)
    
    // 等待数据加载 / Wait for data to load
    var waitTime = 0
    let maxWaitTime = 30 // 3秒最大等待
    
    while waitTime < maxWaitTime {
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        waitTime += 1
        
        // 检查数据是否已加载 / Check if data loaded
        if case .loaded = viewStore.userProfileState,
           case .loaded = viewStore.bannersState {
            break
        }
        
        // 检查错误状态 / Check error state
        if viewStore.errorDisplayMode != .none {
            break
        }
    }
}
```

### 3. 在 ScrollView 上应用 refreshable / Apply refreshable on ScrollView

```swift
ScrollView {
    // 内容 / Content
}
.background(Color(.systemGroupedBackground)) // iOS 15 必需 / Required for iOS 15
.refreshable {
    await performRefresh()
}
```

### 4. 在 Reducer 中实现 resetForRefresh / Implement resetForRefresh in Reducer

```swift
case .resetForRefresh:
    // 重置所有状态为 loading / Reset all states to loading
    state.userProfileState = .loading(.initial)
    state.userSettingsState = .loading(.initial)
    // ... 其他状态
    
    // 清除错误状态 / Clear error states
    state.errorDisplayMode = .none
    state.showPinkErrorBanner = false
    // ... 其他错误标志
    
    // 重新加载数据 / Reload data
    return .send(.loadInitialData)
```

## 关键点 / Key Points

1. **必须使用 ViewStore** / **Must Use ViewStore**
   - 通过 `@ObservedObject var viewStore` 观察状态变化
   - Observe state changes through `@ObservedObject var viewStore`

2. **状态转换完整性** / **Complete State Transition**
   - 确保状态从 `.idle` → `.loading` → `.loaded` 完整转换
   - Ensure complete state transition from `.idle` → `.loading` → `.loaded`

3. **iOS 版本兼容** / **iOS Version Compatibility**
   - 使用 `Task.sleep` 而非 iOS 16+ 的新 API
   - Use `Task.sleep` instead of iOS 16+ new APIs

4. **背景色设置** / **Background Color Setting**
   - ScrollView 必须有背景色才能在 iOS 15 中显示刷新指示器
   - ScrollView must have background color to show refresh indicator in iOS 15

## 测试验证 / Test Verification

### iOS 15.0 测试步骤 / iOS 15.0 Test Steps

1. 在 iOS 15.0 模拟器运行应用
2. 进入电商首页
3. 下拉页面，应看到刷新指示器
4. 释放后数据重新加载
5. 检查控制台日志确认刷新流程

### 预期日志输出 / Expected Log Output

```
🔄 Pull-to-refresh triggered / 下拉刷新触发
📱 iOS Version: 15.0.0
⏰ Refresh started at: 2024-01-20 10:30:00
♻️ Resetting states for refresh...
✅ States reset, triggering loadInitialData
📋 Loading initial data...
✅ Data loaded, stopping refresh
✅ Refresh completed at: 2024-01-20 10:30:01
```

## 注意事项 / Important Notes

- 不要在 iOS 15 中使用 `continuousClock` 或其他 iOS 16+ API
- Don't use `continuousClock` or other iOS 16+ APIs in iOS 15

- 确保 `refreshable` 直接应用在 ScrollView 上，不要嵌套过深
- Ensure `refreshable` is directly applied on ScrollView, avoid deep nesting

- 使用 ViewStore 观察状态变化是关键，否则视图不会更新
- Using ViewStore to observe state changes is crucial, otherwise view won't update