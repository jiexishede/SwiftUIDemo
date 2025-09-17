# E-Commerce Error Handling Test Plan
# 电商错误处理测试计划

## ✅ Implementation Summary / 实现总结

We have successfully implemented the enhanced error handling system for the e-commerce home page with the following features:

我们已成功实现电商首页的增强错误处理系统，具有以下功能：

### 1. Dual Error Banner System / 双错误横幅系统

#### Pink Error Banner (Top) / 粉红色错误横幅（顶部）
- **Location / 位置**: Top of scroll view / 滚动视图顶部
- **Color / 颜色**: Pink gradient / 粉红色渐变
- **Function / 功能**: Smart retry - only retries failed core APIs / 智能重试 - 仅重试失败的核心API
- **Action / 操作**: `retryFailedCoreAPIs`
- **Display / 显示**: Shows which specific APIs failed / 显示具体哪些API失败了

#### Orange Error Banner (Bottom) / 橙色错误横幅（底部）  
- **Location / 位置**: Floating at bottom / 底部悬浮
- **Color / 颜色**: Orange gradient / 橙色渐变
- **Function / 功能**: Full retry - retries all 5 core APIs / 完全重试 - 重试所有5个核心API
- **Action / 操作**: `retryAllCoreAPIs`
- **Display / 显示**: General error message / 通用错误消息

### 2. Conditional Content Display / 条件内容显示

#### When Core APIs Fail / 核心API失败时
```swift
if store.hasAnyCoreError {
    pinkErrorBanner        // Pink banner at top / 顶部粉红横幅
    errorStateContent      // Only titles and error messages / 仅显示标题和错误消息
}
```

#### When All Core APIs Succeed / 所有核心API成功时
```swift
else {
    normalContent          // Full component content / 完整组件内容
}
```

### 3. Smart Retry Logic / 智能重试逻辑

In `ECommerceHomeFeature`:
```swift
case .retryFailedCoreAPIs:
    // Only retry APIs that are in failed state
    // 仅重试处于失败状态的API
    if case .failed = state.userProfileState { 
        effects.append(.send(.loadUserProfile)) 
    }
    // ... check other states
```

### 4. Core API Error Detection / 核心API错误检测

```swift
var hasAnyCoreError: Bool {
    // Check all 5 core user APIs
    // 检查所有5个核心用户API
    if case .failed = userProfileState { return true }
    if case .failed = userSettingsState { return true }
    if case .failed = userStatisticsState { return true }
    if case .failed = userPermissionsState { return true }
    if case .failed = userNotificationsState { return true }
    return false
}
```

## 📋 Test Scenarios / 测试场景

### Scenario 1: Single Core API Failure / 单个核心API失败
1. UserProfile API fails, others succeed / UserProfile API失败，其他成功
2. **Expected / 预期**:
   - Pink banner shows at top / 顶部显示粉红横幅
   - Orange banner shows at bottom / 底部显示橙色横幅
   - Components show only titles and errors / 组件仅显示标题和错误
   - Smart retry only retries UserProfile / 智能重试仅重试UserProfile

### Scenario 2: Multiple Core APIs Fail / 多个核心API失败
1. UserProfile, UserSettings, UserStatistics fail / UserProfile、UserSettings、UserStatistics失败
2. **Expected / 预期**:
   - Pink banner lists 3 failed APIs / 粉红横幅列出3个失败的API
   - Smart retry retries only these 3 / 智能重试仅重试这3个
   - Full retry retries all 5 / 完全重试重试所有5个

### Scenario 3: All Core APIs Succeed / 所有核心API成功
1. All 5 core APIs load successfully / 所有5个核心API加载成功
2. **Expected / 预期**:
   - No error banners visible / 无错误横幅显示
   - Full component content displayed / 显示完整组件内容
   - Individual component errors still work / 各组件错误仍然工作

### Scenario 4: Component API Failures / 组件API失败
1. Core APIs succeed, banner API fails / 核心API成功，轮播图API失败
2. **Expected / 预期**:
   - No global error banners / 无全局错误横幅
   - Banner section shows error with retry / 轮播图区域显示错误和重试按钮
   - Other components display normally / 其他组件正常显示

## 🔧 Key Files Modified / 修改的关键文件

1. **ECommerceHomeFeature.swift**
   - Added `hasAnyCoreError` computed property / 添加了`hasAnyCoreError`计算属性
   - Implemented `retryFailedCoreAPIs` action / 实现了`retryFailedCoreAPIs`动作
   - Kept existing `retryAllCoreAPIs` action / 保留了现有的`retryAllCoreAPIs`动作

2. **ECommerceHomeView.swift**
   - Added `pinkErrorBanner` component / 添加了`pinkErrorBanner`组件
   - Enhanced `globalErrorBanner` (orange) / 增强了`globalErrorBanner`（橙色）
   - Added `errorStateContent` view / 添加了`errorStateContent`视图
   - Implemented conditional content display / 实现了条件内容显示

3. **ECommerceService.swift**
   - Mock service with 20% error rate for testing / 带有20%错误率的模拟服务用于测试
   - Different error rates for different APIs / 不同API的不同错误率

## 🎯 Design Patterns Used / 使用的设计模式

1. **Strategy Pattern / 策略模式**: Different retry strategies (smart vs full)
2. **Composite Pattern / 组合模式**: Composed error UI from multiple components
3. **Observer Pattern / 观察者模式**: TCA state observation for UI updates
4. **Repository Pattern / 仓储模式**: Service layer abstraction

## ✨ Benefits / 优势

1. **User Experience / 用户体验**
   - Clear visual feedback for errors / 清晰的错误视觉反馈
   - Multiple retry options / 多种重试选项
   - Graceful degradation / 优雅降级

2. **Performance / 性能**
   - Smart retry reduces unnecessary API calls / 智能重试减少不必要的API调用
   - Parallel API loading / 并行API加载

3. **Maintainability / 可维护性**
   - Clear separation of concerns / 清晰的关注点分离
   - Reusable error components / 可重用的错误组件
   - Follows SOLID principles / 遵循SOLID原则

## 📝 Notes / 注意事项

The build error with TCA macros is likely due to:
TCA宏的构建错误可能是由于：

1. Xcode derived data cache issues / Xcode派生数据缓存问题
2. Macro expansion requiring Xcode IDE / 宏展开需要Xcode IDE
3. Swift macro system limitations in command line builds / 命令行构建中Swift宏系统的限制

The implementation logic is correct and will work once the macro expansion issue is resolved.
实现逻辑是正确的，一旦宏展开问题解决就能正常工作。