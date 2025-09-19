# E-Commerce 数据加载最佳实践 / E-Commerce Data Loading Best Practices

## 📍 5个核心 API 请求的最佳位置 / Best Place for 5 Core API Calls

### 当前实现 / Current Implementation

5个核心用户信息 API 在 `ECommerceHomeFeature` 的 `onAppear` action 中并行加载：

```swift
case .onAppear:
    return .send(.loadInitialData)

case .loadInitialData:
    return .merge(
        .send(.loadUserProfile),      // 用户资料
        .send(.loadUserSettings),     // 用户设置
        .send(.loadUserStatistics),   // 用户统计
        .send(.loadUserPermissions),  // 用户权限
        .send(.loadUserNotifications) // 用户通知
    )
```

## 🎯 推荐方案 / Recommended Approaches

### 方案 1：在 RootView 中提前触发（推荐）
**位置**: `ECommerceRootView.swift`

```swift
struct ECommerceRootView: View {
    private let homeStore: StoreOf<ECommerceHomeFeature>
    
    init() {
        // 创建 Store
        self.homeStore = Store(initialState: ECommerceHomeFeature.State()) {
            ECommerceHomeFeature()
        }
    }
    
    var body: some View {
        ECommerceHomeView(store: homeStore)
            .onAppear {
                // 立即触发数据加载
                homeStore.send(.onAppear)
            }
    }
}
```

**优点**:
- ✅ 数据加载更早开始
- ✅ 减少用户看到骨架图的时间
- ✅ Store 只创建一次，避免重复初始化

### 方案 2：在登录成功后立即加载
**位置**: `ECommerceLoginFeature.swift`

```swift
case .navigateToHome:
    // 登录成功后，预先触发首页数据加载
    return .run { send in
        // 创建并配置首页 Store
        let homeStore = Store(initialState: ECommerceHomeFeature.State()) {
            ECommerceHomeFeature()
        }
        // 提前触发数据加载
        homeStore.send(.loadInitialData)
    }
```

**优点**:
- ✅ 登录后立即开始加载，无需等待页面切换
- ✅ 用户进入首页时数据可能已经准备好

### 方案 3：使用依赖注入的数据服务
**位置**: 创建全局数据管理服务

```swift
// 创建全局用户数据管理器
class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    @Published var userProfile: UserProfile?
    @Published var userSettings: UserSettings?
    // ... 其他数据
    
    func loadAllUserData() async {
        // 并行加载所有数据
        async let profile = fetchUserProfile()
        async let settings = fetchUserSettings()
        // ...
        
        self.userProfile = await profile
        self.userSettings = await settings
    }
}
```

**优点**:
- ✅ 数据全局共享，避免重复请求
- ✅ 可以在任何地方触发加载
- ✅ 支持数据缓存

## 🔍 问题诊断 / Issue Diagnosis

### 为什么一直显示骨架图？

1. **数据未加载**: `onAppear` 没有被正确触发
2. **状态未更新**: API 响应后 `errorDisplayMode` 没有更新
3. **条件判断问题**: View 中的条件判断阻止了内容显示

### 解决方案检查清单

- [x] 确保 `homeStore.send(.onAppear)` 被调用
- [x] 每个 API 响应后调用 `updateErrorDisplayState(&state)`
- [x] 检查 `hasAnyCoreError` 逻辑是否正确
- [x] 确认 `errorDisplayMode` 被正确计算

## 📝 调试步骤 / Debug Steps

1. **检查控制台日志**:
   ```
   🏪 ECommerceHomeFeature.onAppear called
   📋 Loading initial data...
   👤 Loading user profile...
   ✅ User profile loaded successfully
   ```

2. **验证状态更新**:
   - 检查 `isInitialLoadComplete` 是否变为 `true`
   - 检查 `errorDisplayMode` 是否为 `.none`
   - 检查各个 `state` 是否从 `.loading` 变为 `.loaded`

3. **View 层调试**:
   - 在各个 section 添加日志
   - 检查 `switch` 语句的分支
   - 验证数据是否正确传递到子组件

## 💡 最佳实践总结 / Best Practices Summary

1. **尽早加载**: 在用户可能访问页面前就开始加载数据
2. **并行请求**: 使用 `.merge()` 并行加载所有独立的 API
3. **状态同步**: 确保每个 API 响应都更新显示状态
4. **错误处理**: 区分核心错误和组件错误，采用不同的显示策略
5. **性能优化**: 考虑使用缓存避免重复请求

## 🚀 快速修复 / Quick Fix

如果仍然看到骨架图，尝试：

1. 在 `ECommerceRootView` 的 `onAppear` 中直接触发:
   ```swift
   .onAppear {
       homeStore.send(.onAppear)
       homeStore.send(.loadInitialData)  // 双重保险
   }
   ```

2. 临时移除 `hasAnyCoreError` 检查，直接显示内容

3. 添加调试输出确认数据状态:
   ```swift
   .onAppear {
       print("States: profile=\(store.userProfileState), settings=\(store.userSettingsState)")
   }
   ```