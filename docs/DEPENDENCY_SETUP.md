# 依赖管理方案 / Dependency Management Solution

## 🎯 目标 / Goal
让其他人克隆项目后无需额外下载依赖即可运行 / Allow others to run the project without downloading dependencies

## 方案 1：使用 Git Submodules（推荐）/ Solution 1: Git Submodules (Recommended)

### 初始设置（仓库所有者）/ Initial Setup (Repository Owner)

```bash
# 1. 添加 TCA 作为 submodule / Add TCA as submodule
git submodule add https://github.com/pointfreeco/swift-composable-architecture.git Vendor/TCA
git submodule update --init --recursive

# 2. 提交 submodule 配置 / Commit submodule configuration
git add .gitmodules Vendor/TCA
git commit -m "Add TCA as submodule"

# 3. 在 Xcode 中配置本地包 / Configure local package in Xcode
# - 打开 Xcode / Open Xcode
# - File > Add Package Dependencies
# - 点击 "Add Local..." / Click "Add Local..."
# - 选择 Vendor/TCA 文件夹 / Select Vendor/TCA folder
```

### 其他人克隆项目 / Others Clone Project

```bash
# 克隆时自动获取 submodules / Clone with submodules
git clone --recursive https://github.com/your-username/ReduxSwiftUIDemo.git

# 或者克隆后更新 submodules / Or update submodules after clone
git clone https://github.com/your-username/ReduxSwiftUIDemo.git
cd ReduxSwiftUIDemo
git submodule update --init --recursive
```

## 方案 2：直接提交依赖（最简单但文件多）/ Solution 2: Commit Dependencies (Simplest but Many Files)

### 设置步骤 / Setup Steps

```bash
# 1. 解析并下载所有依赖 / Resolve and download all dependencies
xcodebuild -resolvePackageDependencies

# 2. 复制依赖到项目 / Copy dependencies to project
cp -R ~/Library/Developer/Xcode/DerivedData/*/SourcePackages/checkouts Vendor/

# 3. 在 Xcode 中使用本地包 / Use local packages in Xcode
# - 移除远程包依赖 / Remove remote package dependencies
# - 添加 Vendor/ 下的本地包 / Add local packages from Vendor/

# 4. 提交 Vendor 文件夹 / Commit Vendor folder
git add Vendor/
git commit -m "Add vendored dependencies"
```

## 方案 3：使用 Swift Package Manager 缓存

### .gitignore 配置 / Configure .gitignore

```bash
# 不要忽略这些文件 / Don't ignore these files
# !.build/
# !DerivedData/
```

### 提交构建缓存 / Commit Build Cache

```bash
# 构建并缓存 / Build and cache
swift build

# 提交缓存 / Commit cache
git add .build/
git commit -m "Add SPM build cache"
```

## 🌟 推荐方案 / Recommended Approach

**使用 Git Submodules** 是最平衡的方案：
- ✅ 文件不会太多 / Not too many files
- ✅ 可以更新依赖版本 / Can update dependency versions
- ✅ Git 原生支持 / Native Git support
- ✅ 其他人容易理解 / Easy for others to understand

## 自动化脚本 / Automation Script

创建 `setup.sh` 脚本：

```bash
#!/bin/bash
echo "Setting up project dependencies..."

# Check if submodules exist
if [ ! -d "Vendor/TCA/.git" ]; then
    echo "Initializing submodules..."
    git submodule update --init --recursive
fi

echo "Opening Xcode..."
open ReduxSwiftUIDemo.xcodeproj

echo "✅ Setup complete!"
```

## 使用说明 / Usage Instructions

在 README.md 中添加：

```markdown
## 快速开始 / Quick Start

```bash
# 克隆项目 / Clone project
git clone --recursive https://github.com/your-username/ReduxSwiftUIDemo.git

# 或者 / Or
git clone https://github.com/your-username/ReduxSwiftUIDemo.git
cd ReduxSwiftUIDemo
./setup.sh
```
```

这样其他人就能轻松运行你的项目了！