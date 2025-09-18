# Login Test Guide / 登录测试指南

## 🔐 Test Credentials / 测试凭据

### Valid Login / 有效登录
- **Username / 用户名**: `demo`
- **Password / 密码**: `123456`

## 🧪 Testing Steps / 测试步骤

### 1. Navigate to E-Commerce / 导航到电商模块
1. Launch the app / 启动应用
2. From main list, tap "电商首页演示 / E-Commerce Home Demo"
3. You should see the login page / 应该看到登录页面

### 2. Login Process / 登录过程
1. Enter username: `demo`
2. Enter password: `123456`
3. Tap "登录 / Sign In" button
4. Wait for login animation / 等待登录动画

### 3. Expected Result / 预期结果
- ✅ Login page should transition to home page / 登录页应该切换到首页
- ✅ You should see the e-commerce home with user info / 应该看到带用户信息的电商首页
- ✅ Back button should return to main list (not login) / 返回按钮应该回到主列表（不是登录页）

## 🐛 Debug Logs / 调试日志

When testing, check Xcode console for these logs:
测试时，检查Xcode控制台的这些日志：

```
📱 shouldNavigateToHome changed to: true
✅ Calling onLoginSuccess callback
🎯 Login success callback triggered / 登录成功回调触发
```

## 🔍 Troubleshooting / 故障排除

### If login doesn't transition / 如果登录没有切换

1. **Check console logs** / 检查控制台日志
   - Are the debug logs appearing? / 调试日志是否出现？
   - Is shouldNavigateToHome becoming true? / shouldNavigateToHome 是否变为 true？

2. **Verify credentials** / 验证凭据
   - Username must be exactly `demo`
   - Password must be exactly `123456`

3. **Check animation** / 检查动画
   - The transition has a 0.3s animation / 切换有0.3秒动画
   - There's also a 500ms delay after login success / 登录成功后还有500毫秒延迟

### Common Issues / 常见问题

1. **Page not changing / 页面不切换**
   - Solution: Check if onLoginSuccess callback is nil / 检查 onLoginSuccess 回调是否为 nil
   - The callback chain: LoginFeature → LoginView → RootView

2. **Back button issue / 返回按钮问题**
   - Should go: Home → Main List / 应该是：首页 → 主列表
   - Not: Home → Login → Main List / 不是：首页 → 登录 → 主列表

## 📱 iOS Compatibility / iOS 兼容性

### iOS 15
- Uses `onReceive` with publisher / 使用 onReceive 配合 publisher
- Navigation handled by state change / 导航通过状态改变处理

### iOS 16+
- Could use `onChange(of:initial:)` / 可以使用 onChange(of:initial:)
- But we use iOS 15 compatible approach / 但我们使用 iOS 15 兼容方式

## 🏗️ Architecture Flow / 架构流程

```
ContentView
    ↓
ECommerceRootView
    ├── isLoggedIn: false → ECommerceLoginWrapperView
    │                           ↓
    │                    ECommerceLoginView
    │                           ↓
    │                    (on success callback)
    │                           ↓
    └── isLoggedIn: true → ECommerceHomeView
```

## ✅ Success Indicators / 成功指标

1. **Visual** / 视觉
   - Smooth transition from login to home / 从登录到首页的流畅切换
   - User info displayed in home header / 用户信息显示在首页头部

2. **Navigation** / 导航
   - Back button works correctly / 返回按钮正常工作
   - No intermediate stops / 无中间停留

3. **State** / 状态
   - isLoggedIn changes from false to true / isLoggedIn 从 false 变为 true
   - Home page loads with all APIs / 首页加载所有 API