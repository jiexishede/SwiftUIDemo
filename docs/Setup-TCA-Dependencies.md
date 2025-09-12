# Setup TCA Dependencies / 设置 TCA 依赖

## For SwiftUIDemo Project / 对于 SwiftUIDemo 项目

### Method 1: Via Xcode GUI / 方法1：通过 Xcode 界面

1. **Open Project / 打开项目**
   - Open `SwiftUIDemo.xcodeproj` in Xcode
   - 在 Xcode 中打开 `SwiftUIDemo.xcodeproj`

2. **Add Package Dependency / 添加包依赖**
   - Select the project in the navigator / 在导航器中选择项目
   - Select the `SwiftUIDemo` target / 选择 `SwiftUIDemo` target
   - Click on "Package Dependencies" tab / 点击 "Package Dependencies" 标签
   - Click the "+" button / 点击 "+" 按钮

3. **Add ComposableArchitecture / 添加 ComposableArchitecture**
   - Enter URL: `https://github.com/pointfreeco/swift-composable-architecture`
   - Version: "Up to Next Major Version" from `1.9.0`
   - Click "Add Package" / 点击 "Add Package"

4. **Select Package Products / 选择包产品**
   - Check "ComposableArchitecture"
   - Add to target: SwiftUIDemo
   - Click "Add Package" / 点击 "Add Package"

### Method 2: Via Package.swift (Already Configured) / 方法2：通过 Package.swift（已配置）

The `Package.swift` file already includes the dependency:
`Package.swift` 文件已经包含了依赖：

```swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.0")
],
targets: [
    .target(
        name: "SwiftUIDemo",
        dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
    )
]
```

### Build and Run / 构建和运行

After adding the dependency / 添加依赖后：

1. **Clean Build Folder / 清理构建文件夹**
   - Product → Clean Build Folder (⇧⌘K)

2. **Resolve Package Dependencies / 解析包依赖**
   - File → Packages → Resolve Package Versions

3. **Build Project / 构建项目**
   - Product → Build (⌘B)

## Troubleshooting / 故障排除

### If "No such module 'ComposableArchitecture'" error / 如果出现 "No such module 'ComposableArchitecture'" 错误

1. **Check Target Membership / 检查目标成员资格**
   - Ensure all Swift files are added to the correct target
   - 确保所有 Swift 文件都添加到正确的目标

2. **Reset Package Cache / 重置包缓存**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf .build
   rm -rf .swiftpm
   ```

3. **Re-resolve Dependencies / 重新解析依赖**
   - File → Packages → Reset Package Caches
   - File → Packages → Resolve Package Versions

4. **Check Minimum iOS Version / 检查最低 iOS 版本**
   - Ensure project's minimum iOS version is 15.0 or higher
   - 确保项目的最低 iOS 版本是 15.0 或更高

## Git Configuration / Git 配置

The `.gitignore` has been updated to:
`.gitignore` 已更新为：

- ✅ **Include** / **包含**:
  - `Package.swift` - SPM configuration / SPM 配置
  - `Package.resolved` - Lock file (optional) / 锁定文件（可选）
  - Project files / 项目文件

- ❌ **Exclude** / **排除**:
  - `SourcePackages/` - Downloaded dependencies / 下载的依赖
  - `.build/` - Build artifacts / 构建产物
  - `.swiftpm/` - SPM cache / SPM 缓存

This keeps your repository clean while maintaining dependency configuration.
这样可以保持仓库干净，同时保留依赖配置。

## Team Collaboration / 团队协作

When someone clones your repository / 当有人克隆你的仓库时：

1. They open the project in Xcode / 他们在 Xcode 中打开项目
2. Xcode automatically downloads dependencies / Xcode 自动下载依赖
3. Or manually: File → Packages → Resolve Package Versions / 或手动：File → Packages → Resolve Package Versions

## Version Management / 版本管理

### Lock Versions (Recommended for Teams) / 锁定版本（团队推荐）
Keep `Package.resolved` in git to ensure everyone uses the same versions.
在 git 中保留 `Package.resolved` 以确保每个人使用相同的版本。

### Flexible Versions (For Development) / 灵活版本（用于开发）
Add `Package.resolved` to `.gitignore` to allow version updates.
将 `Package.resolved` 添加到 `.gitignore` 以允许版本更新。