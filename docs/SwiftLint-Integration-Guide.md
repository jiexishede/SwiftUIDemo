# SwiftLint Integration and Code Style Guide / SwiftLint 集成与代码风格指南

## Table of Contents / 目录

1. [What is SwiftLint? / 什么是 SwiftLint？](#what-is-swiftlint)
2. [Installation / 安装](#installation)
3. [Configuration / 配置](#configuration)
4. [Common Rules / 常用规则](#common-rules)
5. [Custom Rules / 自定义规则](#custom-rules)
6. [Xcode Integration / Xcode 集成](#xcode-integration)
7. [CI/CD Integration / CI/CD 集成](#cicd-integration)
8. [Best Practices / 最佳实践](#best-practices)

---

## What is SwiftLint? / 什么是 SwiftLint？

SwiftLint is a tool to enforce Swift style and conventions. It uses the AST (Abstract Syntax Tree) representation of your source files to determine violations.

SwiftLint 是一个强制执行 Swift 风格和约定的工具。它使用源文件的 AST（抽象语法树）表示来确定违规。

### Benefits / 好处

1. **Consistency / 一致性**: Ensures consistent code style across the team
2. **Quality / 质量**: Catches potential bugs and code smells
3. **Readability / 可读性**: Makes code easier to read and maintain
4. **Automation / 自动化**: Reduces code review burden
5. **Learning / 学习**: Helps developers learn Swift best practices

---

## Installation / 安装

### Method 1: Using Homebrew (Recommended) / 方法1：使用 Homebrew（推荐）

```bash
# Install SwiftLint / 安装 SwiftLint
brew install swiftlint

# Update SwiftLint / 更新 SwiftLint
brew upgrade swiftlint

# Check version / 检查版本
swiftlint version
```

### Method 2: Using CocoaPods / 方法2：使用 CocoaPods

```ruby
# Add to Podfile / 添加到 Podfile
pod 'SwiftLint'

# Install / 安装
pod install
```

### Method 3: Using Swift Package Manager / 方法3：使用 Swift Package Manager

```swift
// Add to Package.swift / 添加到 Package.swift
dependencies: [
    .package(url: "https://github.com/realm/SwiftLint", from: "0.50.0")
]
```

### Method 4: Using Mint / 方法4：使用 Mint

```bash
# Install Mint first / 先安装 Mint
brew install mint

# Install SwiftLint via Mint / 通过 Mint 安装 SwiftLint
mint install realm/SwiftLint
```

---

## Configuration / 配置

### Creating .swiftlint.yml / 创建 .swiftlint.yml

Create a `.swiftlint.yml` file in your project root:

在项目根目录创建 `.swiftlint.yml` 文件：

```yaml
# SwiftLint Configuration File
# SwiftLint 配置文件
# 
# This file defines all the rules and settings for SwiftLint
# 此文件定义 SwiftLint 的所有规则和设置

# Paths to include for linting / 要检查的路径
included:
  - SwiftUIDemo
  - SwiftUIDemoTests
  - SwiftUIDemoUITests

# Paths to exclude from linting / 要排除的路径
excluded:
  - Pods
  - .build
  - DerivedData
  - ${PWD}/Carthage
  - ${PWD}/.build
  - ${PWD}/build
  - ${PWD}/Pods
  - ${PWD}/Scripts
  - ${PWD}/vendor
  - ${PWD}/fastlane

# Rules that are enabled by default / 默认启用的规则
disabled_rules:
  - trailing_whitespace # Sometimes needed for markdown / 有时 markdown 需要
  - todo # Allow TODO comments during development / 开发期间允许 TODO 注释

# Rules that are not enabled by default / 默认未启用的规则
opt_in_rules:
  - array_init
  - attributes
  - closure_end_indentation
  - closure_spacing
  - collection_alignment
  - contains_over_filter_count
  - contains_over_filter_is_empty
  - contains_over_first_not_nil
  - contains_over_range_nil_comparison
  - convenience_type
  - discouraged_assert
  - discouraged_object_literal
  - empty_collection_literal
  - empty_count
  - empty_string
  - empty_xctest_method
  - enum_case_associated_values_count
  - explicit_init
  - extension_access_modifier
  - fallthrough
  - fatal_error_message
  - file_header
  - first_where
  - flatmap_over_map_reduce
  - force_unwrapping
  - function_default_parameter_at_end
  - identical_operands
  - implicit_return
  - implicitly_unwrapped_optional
  - joined_default_parameter
  - last_where
  - legacy_multiple
  - legacy_random
  - literal_expression_end_indentation
  - lower_acl_than_parent
  - modifier_order
  - multiline_arguments
  - multiline_function_chains
  - multiline_literal_brackets
  - multiline_parameters
  - multiline_parameters_brackets
  - nimble_operator
  - nslocalizedstring_key
  - number_separator
  - object_literal
  - operator_usage_whitespace
  - optional_enum_case_matching
  - overridden_super_call
  - pattern_matching_keywords
  - prefer_self_type_over_type_of_self
  - private_action
  - private_outlet
  - prohibited_super_call
  - quick_discouraged_call
  - quick_discouraged_focused_test
  - quick_discouraged_pending_test
  - raw_value_for_camel_cased_codable_enum
  - reduce_into
  - redundant_nil_coalescing
  - redundant_type_annotation
  - required_enum_case
  - single_test_class
  - sorted_first_last
  - static_operator
  - strong_iboutlet
  - switch_case_on_newline
  - toggle_bool
  - trailing_closure
  - type_contents_order
  - unavailable_function
  - unneeded_parentheses_in_closure_argument
  - untyped_error_in_catch
  - unused_declaration
  - unused_import
  - vertical_parameter_alignment_on_call
  - vertical_whitespace_closing_braces
  - vertical_whitespace_opening_braces
  - xct_specific_matcher
  - yoda_condition

# Analyzer rules (requires --analyze) / 分析器规则（需要 --analyze）
analyzer_rules:
  - capture_variable
  - explicit_self
  - unused_declaration
  - unused_import

# Rule configurations / 规则配置
line_length:
  warning: 120
  error: 200
  ignores_urls: true
  ignores_function_declarations: true
  ignores_comments: true

file_length:
  warning: 500
  error: 1000
  ignore_comment_only_lines: true

function_body_length:
  warning: 40
  error: 100

function_parameter_count:
  warning: 6
  error: 8

type_body_length:
  warning: 250
  error: 500

cyclomatic_complexity:
  warning: 10
  error: 20

nesting:
  type_level:
    warning: 2
    error: 3
  function_level:
    warning: 3
    error: 5

identifier_name:
  min_length:
    warning: 2
    error: 1
  max_length:
    warning: 40
    error: 50
  excluded:
    - id
    - ip
    - db
    - to
    - up
    - ok
    - no
    - on
    - x
    - y
    - z

type_name:
  min_length:
    warning: 3
    error: 2
  max_length:
    warning: 40
    error: 50

# Custom file header template / 自定义文件头模板
file_header:
  required_pattern: |
    \/\/
    \/\/  .*\.swift
    \/\/  SwiftUIDemo
    \/\/
    \/\/  .*
    \/\/  .*
    \/\/

# Force specific modifier order / 强制特定修饰符顺序
modifier_order:
  preferred_modifier_order:
    - acl
    - setterACL
    - override
    - dynamic
    - mutators
    - lazy
    - final
    - required
    - convenience
    - typeMethods
    - owned

# Custom type contents order / 自定义类型内容顺序
type_contents_order:
  order:
    - case
    - associated_type
    - type_alias
    - subtype
    - type_property
    - instance_property
    - ib_outlet
    - ib_inspectable
    - initializer
    - deinitializer
    - subscript
    - type_method
    - view_life_cycle_method
    - ib_action
    - other_method

# Reporter type (xcode, json, csv, checkstyle, junit, html, emoji) / 报告类型
reporter: "xcode"
```

---

## Common Rules / 常用规则

### 1. Line Length / 行长度

```swift
/**
 * LINE LENGTH RULE
 * 行长度规则
 * 
 * Maximum 120 characters per line (warning)
 * 每行最多 120 个字符（警告）
 * Maximum 200 characters per line (error)
 * 每行最多 200 个字符（错误）
 */

// ❌ BAD: Line too long / 错误：行太长
let veryLongVariableName = "This is a very long string that exceeds the maximum line length limit and will trigger a SwiftLint warning or error"

// ✅ GOOD: Properly formatted / 正确：格式正确
let veryLongVariableName = """
    This is a very long string that is properly
    formatted across multiple lines to stay within
    the line length limit
    """

// ✅ GOOD: Breaking long function calls / 正确：拆分长函数调用
let result = someVeryLongFunctionName(
    withParameter: value1,
    andAnotherParameter: value2,
    andYetAnotherParameter: value3
)
```

### 2. File Length / 文件长度

```swift
/**
 * FILE LENGTH RULE
 * 文件长度规则
 * 
 * Keep files under 500 lines (warning)
 * 保持文件少于 500 行（警告）
 * Keep files under 1000 lines (error)
 * 保持文件少于 1000 行（错误）
 * 
 * SOLUTION: Split large files into extensions or separate files
 * 解决方案：将大文件拆分为扩展或单独的文件
 */

// MainView.swift - Keep main logic / 保持主要逻辑
struct MainView: View {
    var body: some View {
        // Main view implementation
    }
}

// MainView+Extensions.swift - Move extensions to separate file / 将扩展移到单独文件
extension MainView {
    // Helper methods
}

// MainView+Components.swift - Move subviews to separate file / 将子视图移到单独文件
extension MainView {
    struct SubComponent: View {
        // Subview implementation
    }
}
```

### 3. Function Body Length / 函数体长度

```swift
/**
 * FUNCTION BODY LENGTH RULE
 * 函数体长度规则
 * 
 * Keep functions under 40 lines (warning)
 * 保持函数少于 40 行（警告）
 * Keep functions under 100 lines (error)
 * 保持函数少于 100 行（错误）
 */

// ❌ BAD: Function too long / 错误：函数太长
func processData() {
    // Line 1
    // Line 2
    // ... 50+ lines of code
    // Line 50
}

// ✅ GOOD: Split into smaller functions / 正确：拆分为更小的函数
func processData() {
    let validated = validateInput()
    let transformed = transformData(validated)
    let result = saveData(transformed)
    return result
}

private func validateInput() -> Data {
    // Validation logic
}

private func transformData(_ data: Data) -> ProcessedData {
    // Transformation logic
}

private func saveData(_ data: ProcessedData) -> Result {
    // Saving logic
}
```

### 4. Cyclomatic Complexity / 圈复杂度

```swift
/**
 * CYCLOMATIC COMPLEXITY RULE
 * 圈复杂度规则
 * 
 * Measures the number of linearly independent paths through code
 * 测量代码中线性独立路径的数量
 * 
 * Keep complexity under 10 (warning)
 * 保持复杂度低于 10（警告）
 * Keep complexity under 20 (error)
 * 保持复杂度低于 20（错误）
 */

// ❌ BAD: High complexity / 错误：高复杂度
func complexFunction(value: Int) -> String {
    if value > 0 {
        if value < 10 {
            if value % 2 == 0 {
                return "small even"
            } else {
                return "small odd"
            }
        } else if value < 100 {
            if value % 2 == 0 {
                return "medium even"
            } else {
                return "medium odd"
            }
        } else {
            if value % 2 == 0 {
                return "large even"
            } else {
                return "large odd"
            }
        }
    } else {
        return "negative"
    }
}

// ✅ GOOD: Reduced complexity / 正确：降低复杂度
func simpleFunction(value: Int) -> String {
    guard value > 0 else { return "negative" }
    
    let size = sizeCategory(for: value)
    let parity = value % 2 == 0 ? "even" : "odd"
    
    return "\(size) \(parity)"
}

private func sizeCategory(for value: Int) -> String {
    switch value {
    case 0..<10: return "small"
    case 10..<100: return "medium"
    default: return "large"
    }
}
```

### 5. Nesting Level / 嵌套级别

```swift
/**
 * NESTING LEVEL RULE
 * 嵌套级别规则
 * 
 * Maximum 2 levels for types (warning)
 * 类型最多 2 级（警告）
 * Maximum 3 levels for functions (warning)
 * 函数最多 3 级（警告）
 */

// ❌ BAD: Too much nesting / 错误：过多嵌套
struct BadView: View {
    var body: some View {
        VStack {                    // Level 1
            HStack {                // Level 2
                VStack {            // Level 3
                    ForEach {       // Level 4 - Too deep!
                        // Content
                    }
                }
            }
        }
    }
}

// ✅ GOOD: Extracted components / 正确：提取组件
struct GoodView: View {
    var body: some View {
        VStack {                    // Level 1
            headerSection
            contentSection
        }
    }
    
    private var headerSection: some View {
        HStack {                    // Level 1 in extracted view
            Text("Header")
        }
    }
    
    private var contentSection: some View {
        ContentList()               // Separate component
    }
}

struct ContentList: View {
    var body: some View {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### 6. Force Unwrapping / 强制解包

```swift
/**
 * FORCE UNWRAPPING RULE
 * 强制解包规则
 * 
 * Avoid force unwrapping to prevent crashes
 * 避免强制解包以防止崩溃
 */

// ❌ BAD: Force unwrapping / 错误：强制解包
let value = optionalValue!
let url = URL(string: urlString)!

// ✅ GOOD: Safe unwrapping / 正确：安全解包
// Option 1: Guard statement / 选项1：Guard 语句
guard let value = optionalValue else { return }

// Option 2: If let / 选项2：If let
if let url = URL(string: urlString) {
    // Use url
}

// Option 3: Nil coalescing / 选项3：空合并
let value = optionalValue ?? defaultValue

// Option 4: Optional chaining / 选项4：可选链
let count = optionalArray?.count ?? 0
```

### 7. Implicit Return / 隐式返回

```swift
/**
 * IMPLICIT RETURN RULE
 * 隐式返回规则
 * 
 * Use implicit return in single-expression functions
 * 在单表达式函数中使用隐式返回
 */

// ❌ BAD: Unnecessary return / 错误：不必要的返回
var computedProperty: Int {
    return 5 * 10
}

func simpleFunction() -> String {
    return "Hello"
}

// ✅ GOOD: Implicit return / 正确：隐式返回
var computedProperty: Int {
    5 * 10
}

func simpleFunction() -> String {
    "Hello"
}

// SwiftUI views benefit from this / SwiftUI 视图受益于此
var body: some View {
    Text("Hello, World!")  // Implicit return
}
```

---

## Custom Rules / 自定义规则

### Creating Custom Rules / 创建自定义规则

```yaml
# Custom rules in .swiftlint.yml / .swiftlint.yml 中的自定义规则

custom_rules:
  # Rule: No print statements in production code
  # 规则：生产代码中没有 print 语句
  no_print_statements:
    name: "No Print Statements"
    regex: '^\s*print\('
    message: "Print statements should not be used in production code. Use os.log or a proper logging framework."
    severity: warning
    excluded:
      - "*Tests.swift"
      - "*Test.swift"
      - "*/Debug/*"

  # Rule: Bilingual comments required
  # 规则：需要双语注释
  bilingual_comments:
    name: "Bilingual Comments Required"
    regex: '^\s*\/\/\s*[^\/]*$'
    match_kinds:
      - comment
    message: "Comments must be bilingual (English / 中文)"
    severity: warning

  # Rule: TODO format
  # 规则：TODO 格式
  todo_format:
    name: "TODO Format"
    regex: '\/\/\s*TODO(?!:)'
    message: "TODOs should be formatted as: // TODO: Description"
    severity: warning

  # Rule: MARK format
  # 规则：MARK 格式
  mark_format:
    name: "MARK Format"
    regex: '\/\/\s*MARK(?!:[\s\-])'
    message: "MARKs should be formatted as: // MARK: - Section Name"
    severity: warning

  # Rule: No hardcoded strings
  # 规则：没有硬编码字符串
  no_hardcoded_strings:
    name: "No Hardcoded Strings"
    regex: '(Text|Label|Button|Alert)\("[^"]{10,}"'
    message: "Long strings should be extracted to constants or localized"
    severity: warning

  # Rule: SwiftUI view naming
  # 规则：SwiftUI 视图命名
  swiftui_view_suffix:
    name: "SwiftUI View Suffix"
    regex: '^struct\s+\w+(?<!View)(?<!Screen)(?<!Cell)\s*:\s*View\s*\{'
    message: "SwiftUI views should end with 'View', 'Screen', or 'Cell'"
    severity: warning
```

---

## Xcode Integration / Xcode 集成

### Build Phase Script / 构建阶段脚本

Add a new "Run Script Phase" in your target's Build Phases:

在目标的 Build Phases 中添加新的 "Run Script Phase"：

```bash
#!/bin/bash

# SwiftLint Build Phase Script
# SwiftLint 构建阶段脚本
#
# This script runs SwiftLint during the build process
# 此脚本在构建过程中运行 SwiftLint

# Check if SwiftLint is installed / 检查是否安装了 SwiftLint
if which swiftlint >/dev/null; then
    # Run SwiftLint / 运行 SwiftLint
    swiftlint
    
    # Optional: Auto-fix violations / 可选：自动修复违规
    # swiftlint --fix
    
    # Optional: Only run on specific configurations / 可选：仅在特定配置上运行
    # if [ "${CONFIGURATION}" = "Debug" ]; then
    #     swiftlint
    # fi
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    echo "警告：SwiftLint 未安装，请从 https://github.com/realm/SwiftLint 下载"
fi
```

### Pre-commit Hook / 预提交钩子

Create `.git/hooks/pre-commit`:

创建 `.git/hooks/pre-commit`：

```bash
#!/bin/bash

# Pre-commit hook for SwiftLint
# SwiftLint 的预提交钩子

# Run SwiftLint on staged Swift files / 对暂存的 Swift 文件运行 SwiftLint
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.swift$")

if [ -n "$FILES" ]; then
    # Check for SwiftLint / 检查 SwiftLint
    if which swiftlint >/dev/null; then
        echo "Running SwiftLint..."
        echo "正在运行 SwiftLint..."
        
        # Run SwiftLint on staged files / 对暂存文件运行 SwiftLint
        swiftlint lint --path "$FILES"
        RESULT=$?
        
        if [ $RESULT -ne 0 ]; then
            echo "❌ SwiftLint found violations. Please fix them before committing."
            echo "❌ SwiftLint 发现违规。请在提交前修复它们。"
            exit 1
        fi
        
        echo "✅ SwiftLint passed!"
        echo "✅ SwiftLint 通过！"
    else
        echo "⚠️ SwiftLint not installed"
        echo "⚠️ SwiftLint 未安装"
    fi
fi

exit 0
```

Make the hook executable / 使钩子可执行：

```bash
chmod +x .git/hooks/pre-commit
```

---

## CI/CD Integration / CI/CD 集成

### GitHub Actions / GitHub 操作

```yaml
# .github/workflows/swiftlint.yml

name: SwiftLint

on:
  pull_request:
    paths:
      - '**/*.swift'

jobs:
  swiftlint:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install SwiftLint
      run: brew install swiftlint
    
    - name: Run SwiftLint
      run: swiftlint lint --reporter github-actions-logging
```

### Fastlane Integration / Fastlane 集成

```ruby
# Fastfile

desc "Run SwiftLint"
lane :lint do
  swiftlint(
    mode: :lint,
    config_file: ".swiftlint.yml",
    raise_if_swiftlint_error: true,
    reporter: "json",
    output_file: "swiftlint.result.json"
  )
end

desc "Auto-fix SwiftLint violations"
lane :lint_fix do
  swiftlint(
    mode: :fix,
    config_file: ".swiftlint.yml"
  )
end
```

---

## Best Practices / 最佳实践

### 1. Progressive Adoption / 渐进式采用

```yaml
# Start with fewer rules, gradually add more
# 从较少的规则开始，逐渐添加更多

# Phase 1: Basic rules / 阶段1：基本规则
disabled_rules:
  - line_length
  - file_length
  - function_body_length

# Phase 2: Add more rules / 阶段2：添加更多规则
# Remove from disabled_rules

# Phase 3: Add opt-in rules / 阶段3：添加可选规则
opt_in_rules:
  - force_unwrapping
  - implicit_return
```

### 2. Team Agreement / 团队协议

```swift
/**
 * TEAM CODING STANDARDS
 * 团队编码标准
 * 
 * Agree on these before enabling rules:
 * 在启用规则之前就这些达成一致：
 * 
 * 1. Line length: 120 characters
 * 2. File length: 500 lines
 * 3. Function length: 40 lines
 * 4. Nesting level: 2 for SwiftUI views
 * 5. Force unwrapping: Never in production code
 * 6. Comments: Always bilingual (EN/CN)
 */
```

### 3. Gradual Fixing / 逐步修复

```bash
# Fix violations gradually / 逐步修复违规
# 
# Step 1: Fix critical issues / 步骤1：修复关键问题
swiftlint --fix --only force_unwrapping

# Step 2: Fix style issues / 步骤2：修复样式问题
swiftlint --fix --only trailing_whitespace,trailing_comma

# Step 3: Fix complexity issues manually / 步骤3：手动修复复杂性问题
# These require human judgment / 这些需要人工判断
```

### 4. Documentation / 文档

```swift
/**
 * SWIFTLINT DISABLE/ENABLE
 * SwiftLint 禁用/启用
 * 
 * Use sparingly and document why
 * 谨慎使用并记录原因
 */

// swiftlint:disable:next force_unwrapping
// Reason: URL is hardcoded and guaranteed to be valid
// 原因：URL 是硬编码的，保证有效
let url = URL(string: "https://api.example.com")!

// swiftlint:disable force_cast
// Reason: Cell type is guaranteed by registration
// 原因：单元格类型由注册保证
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
// swiftlint:enable force_cast
```

### 5. Regular Updates / 定期更新

```bash
# Check for new rules / 检查新规则
swiftlint rules

# Update SwiftLint regularly / 定期更新 SwiftLint
brew upgrade swiftlint

# Review and update configuration / 审查和更新配置
# Every sprint or monthly / 每个冲刺或每月
```

---

## Common Issues and Solutions / 常见问题和解决方案

### Issue 1: Build Time / 问题1：构建时间

```bash
# Problem: SwiftLint slows down build / 问题：SwiftLint 减慢构建
# Solution: Run only on Debug builds / 解决方案：仅在调试构建上运行

if [ "${CONFIGURATION}" = "Debug" ]; then
    swiftlint
fi
```

### Issue 2: Too Many Violations / 问题2：太多违规

```yaml
# Solution: Use baseline / 解决方案：使用基线
# Create a baseline file of current violations
# 创建当前违规的基线文件

# Generate baseline / 生成基线
swiftlint lint --reporter json > .swiftlint.baseline.json

# Use baseline in CI / 在 CI 中使用基线
# Only fail on new violations / 仅在新违规时失败
```

### Issue 3: Conflicts with Formatter / 问题3：与格式化程序冲突

```yaml
# Solution: Disable conflicting rules / 解决方案：禁用冲突规则
disabled_rules:
  - trailing_comma # If using different formatter / 如果使用不同的格式化程序
```

---

## Summary / 总结

### Key Takeaways / 关键要点

1. **Start Small** / **从小做起**
   - Begin with basic rules
   - 从基本规则开始

2. **Automate Everything** / **自动化一切**
   - Use build phases and hooks
   - 使用构建阶段和钩子

3. **Team Consensus** / **团队共识**
   - Agree on rules together
   - 共同商定规则

4. **Regular Maintenance** / **定期维护**
   - Update rules and SwiftLint version
   - 更新规则和 SwiftLint 版本

5. **Document Exceptions** / **记录例外**
   - Explain why rules are disabled
   - 解释为什么禁用规则

### Quick Commands / 快速命令

```bash
# Install / 安装
brew install swiftlint

# Lint / 检查
swiftlint

# Auto-fix / 自动修复
swiftlint --fix

# Specific folder / 特定文件夹
swiftlint lint --path Sources

# Generate report / 生成报告
swiftlint lint --reporter html > report.html

# List all rules / 列出所有规则
swiftlint rules
```

Remember: SwiftLint is a tool to help, not hinder. Configure it to match your team's needs.

记住：SwiftLint 是帮助工具，而不是阻碍。配置它以匹配你团队的需求。