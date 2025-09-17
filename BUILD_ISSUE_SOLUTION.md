# Build Issue Solution / 构建问题解决方案

## 🚨 Current Issue / 当前问题

### Error Message / 错误信息
```
Could not compute dependency graph: unable to load transferred PIF: 
The workspace contains multiple references with the same GUID 'PACKAGE:1V8H5UZ1OHTLGSS41EPZ03KXWPJUGNV9G::MAINGROUP'
```

### Additional Errors / 其他错误
```
external macro implementation type 'ComposableArchitectureMacros.ReducerMacro' could not be found
```

## ✅ Solution Steps / 解决步骤

### Step 1: Clean All Build Artifacts / 清理所有构建产物
```bash
# Clean DerivedData / 清理派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean local build folder / 清理本地构建文件夹
rm -rf .build
rm -rf Package.resolved

# Clean Xcode project / 清理Xcode项目
xcodebuild -project SwiftUIDemo.xcodeproj -scheme SwiftUIDemo clean
```

### Step 2: Reset Package Cache / 重置包缓存
```bash
# In Xcode IDE / 在Xcode IDE中:
# File → Packages → Reset Package Caches
# 文件 → 包 → 重置包缓存
```

### Step 3: Open in Xcode IDE / 在Xcode IDE中打开
```bash
# Open project in Xcode / 在Xcode中打开项目
open SwiftUIDemo.xcodeproj
```

### Step 4: In Xcode / 在Xcode中
1. **Wait for package resolution** / 等待包解析完成
2. **Build project (⌘+B)** / 构建项目 (⌘+B)
3. **If still fails, try** / 如果仍然失败，尝试:
   - Product → Clean Build Folder (⇧⌘K)
   - Product → Build (⌘B)

## 🔍 Root Cause Analysis / 根本原因分析

### 1. TCA Macro System / TCA宏系统
The Composable Architecture uses Swift macros which require:
Composable Architecture使用Swift宏，需要：

- **Xcode 15.0+** with macro support / 支持宏的Xcode 15.0+
- **Swift 5.9+** for macro expansion / 用于宏展开的Swift 5.9+
- **IDE integration** for proper macro processing / IDE集成以正确处理宏

### 2. Package GUID Conflict / 包GUID冲突
The GUID conflict typically occurs when:
GUID冲突通常发生在：

- Multiple package references exist / 存在多个包引用
- Package cache is corrupted / 包缓存损坏
- DerivedData contains stale references / DerivedData包含陈旧引用

## 🛠️ Alternative Solutions / 替代解决方案

### Option 1: Remove and Re-add TCA / 删除并重新添加TCA
```swift
// In Package.swift or Xcode Package Dependencies
// 在Package.swift或Xcode包依赖中

1. Remove TCA dependency / 删除TCA依赖
2. Clean build folder / 清理构建文件夹
3. Re-add TCA dependency / 重新添加TCA依赖
   - https://github.com/pointfreeco/swift-composable-architecture
   - Version: 1.22.2
```

### Option 2: Use SPM Command Line / 使用SPM命令行
```bash
# Reset all packages / 重置所有包
swift package reset

# Update packages / 更新包
swift package update

# Resolve packages / 解析包
swift package resolve
```

### Option 3: Create New Xcode Project / 创建新的Xcode项目
If the issue persists, consider:
如果问题持续存在，考虑：

1. Create new Xcode project / 创建新的Xcode项目
2. Copy source files / 复制源文件
3. Re-add package dependencies / 重新添加包依赖

## 📋 Verification Steps / 验证步骤

After fixing, verify:
修复后，验证：

1. **No build errors** in Xcode / Xcode中无构建错误
2. **Macros expand correctly** / 宏正确展开
3. **App runs on simulator** / 应用在模拟器上运行

## 🎯 Implementation Status / 实现状态

Despite the build issue, the implementation is complete:
尽管有构建问题，实现已完成：

### ✅ Completed Features / 已完成功能
1. **Dual error banner system** / 双错误横幅系统
   - Pink banner (top) with smart retry / 粉红横幅（顶部）带智能重试
   - Orange banner (bottom) with full retry / 橙色横幅（底部）带完全重试

2. **Conditional content display** / 条件内容显示
   - Error state when core APIs fail / 核心API失败时的错误状态
   - Normal content when all succeed / 全部成功时的正常内容

3. **Smart retry logic** / 智能重试逻辑
   - `retryFailedCoreAPIs` action / `retryFailedCoreAPIs`动作
   - `retryAllCoreAPIs` action / `retryAllCoreAPIs`动作

### 📁 Modified Files / 修改的文件
- `ECommerceHomeFeature.swift`
- `ECommerceHomeView.swift`
- `ECommerceService.swift`

## 💡 Tips / 提示

1. **Always use Xcode IDE** for TCA projects / TCA项目始终使用Xcode IDE
2. **Keep Xcode updated** to latest version / 保持Xcode更新到最新版本
3. **Check Swift version** compatibility / 检查Swift版本兼容性
4. **Regular clean builds** prevent cache issues / 定期清理构建防止缓存问题

## 📞 Support / 支持

If issues persist / 如果问题持续:
- Check TCA GitHub issues: https://github.com/pointfreeco/swift-composable-architecture/issues
- Verify Xcode version: Xcode 15.0+ required
- Ensure macOS is updated / 确保macOS已更新