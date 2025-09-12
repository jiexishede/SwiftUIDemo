# ViewModifier and Reusable Components Guide / ViewModifier 和可复用组件指南

## Table of Contents / 目录

1. [ViewModifier Fundamentals / ViewModifier 基础](#viewmodifier-fundamentals)
2. [Creating Custom ViewModifiers / 创建自定义 ViewModifier](#creating-custom-viewmodifiers)
3. [Reusable View Components / 可复用视图组件](#reusable-view-components)
4. [View Extensions with onXXX Pattern / 带 onXXX 模式的视图扩展](#view-extensions-pattern)
5. [Advanced Composition Techniques / 高级组合技术](#advanced-composition)
6. [Best Practices / 最佳实践](#best-practices)

---

## ViewModifier Fundamentals / ViewModifier 基础

### What is ViewModifier? / 什么是 ViewModifier？

ViewModifier is a protocol that defines a modifier that can be applied to any view. It's the foundation of SwiftUI's declarative syntax.

ViewModifier 是一个协议，定义了可以应用于任何视图的修饰符。它是 SwiftUI 声明式语法的基础。

```swift
/**
 * ViewModifier Protocol Definition
 * ViewModifier 协议定义
 * 
 * Every custom modifier must implement this protocol
 * 每个自定义修饰符必须实现此协议
 */
protocol ViewModifier {
    associatedtype Body: View
    func body(content: Content) -> Self.Body
}
```

### Why Use ViewModifiers? / 为什么使用 ViewModifier？

1. **Reusability / 可重用性**: Write once, use everywhere
2. **Consistency / 一致性**: Ensure UI consistency across the app
3. **Maintainability / 可维护性**: Update styling in one place
4. **Composability / 可组合性**: Chain multiple modifiers together
5. **Testability / 可测试性**: Test UI logic separately

---

## Creating Custom ViewModifiers / 创建自定义 ViewModifier

### Basic ViewModifier / 基础 ViewModifier

```swift
/**
 * BASIC CARD MODIFIER
 * 基础卡片修饰符
 * 
 * PURPOSE / 目的:
 * - Standardize card appearance across the app
 * - 标准化应用中的卡片外观
 * 
 * USAGE / 使用:
 * Text("Hello").modifier(CardModifier())
 * OR / 或
 * Text("Hello").cardStyle() // with extension
 */
struct CardModifier: ViewModifier {
    // Customizable properties / 可自定义属性
    var backgroundColor: Color = .white
    var cornerRadius: CGFloat = 12
    var shadowColor: Color = .black.opacity(0.1)
    var shadowRadius: CGFloat = 5
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
    }
}

// Convenience extension / 便利扩展
extension View {
    /**
     * Apply card styling with default or custom parameters
     * 使用默认或自定义参数应用卡片样式
     * 
     * Examples / 示例:
     * - Default: someView.cardStyle()
     * - Custom: someView.cardStyle(backgroundColor: .blue, shadowRadius: 10)
     */
    func cardStyle(
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 5,
        padding: CGFloat = 16
    ) -> some View {
        modifier(CardModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            padding: padding
        ))
    }
}
```

### Conditional ViewModifier / 条件 ViewModifier

```swift
/**
 * CONDITIONAL HIGHLIGHT MODIFIER
 * 条件高亮修饰符
 * 
 * PURPOSE / 目的:
 * - Apply styling based on conditions
 * - 基于条件应用样式
 * 
 * USE CASES / 使用场景:
 * - Highlighting selected items
 * - 高亮选中的项目
 * - Showing validation states
 * - 显示验证状态
 * - Indicating active/inactive states
 * - 指示活动/非活动状态
 */
struct ConditionalHighlightModifier: ViewModifier {
    let condition: Bool
    let highlightColor: Color
    let normalColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(condition ? highlightColor : normalColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(condition ? highlightColor : Color.clear, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: condition)
    }
}

extension View {
    /**
     * Highlight view based on condition
     * 基于条件高亮视图
     * 
     * Usage / 使用:
     * Text("Item")
     *     .highlight(when: isSelected, 
     *               highlightColor: .blue.opacity(0.3))
     */
    func highlight(
        when condition: Bool,
        highlightColor: Color = .blue.opacity(0.2),
        normalColor: Color = .clear
    ) -> some View {
        modifier(ConditionalHighlightModifier(
            condition: condition,
            highlightColor: highlightColor,
            normalColor: normalColor
        ))
    }
}
```

### Animated ViewModifier / 动画 ViewModifier

```swift
/**
 * SHAKE ANIMATION MODIFIER
 * 摇动动画修饰符
 * 
 * PURPOSE / 目的:
 * - Provide attention-grabbing animation
 * - 提供引人注意的动画
 * - Indicate errors or important actions
 * - 指示错误或重要操作
 */
struct ShakeModifier: ViewModifier {
    @Binding var shake: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: shake ? -10 : 0)
            .animation(
                shake ? 
                Animation.default.repeatCount(3).speed(6) : 
                Animation.default,
                value: shake
            )
            .onChange(of: shake) { newValue in
                if newValue {
                    // Reset shake after animation
                    // 动画后重置摇动
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        shake = false
                    }
                }
            }
    }
}

extension View {
    /**
     * Add shake animation to any view
     * 为任何视图添加摇动动画
     * 
     * Usage / 使用:
     * TextField("Email", text: $email)
     *     .shake($showError)
     * 
     * // Trigger shake / 触发摇动
     * Button("Submit") {
     *     if email.isEmpty {
     *         showError = true
     *     }
     * }
     */
    func shake(_ shake: Binding<Bool>) -> some View {
        modifier(ShakeModifier(shake: shake))
    }
}
```

---

## Reusable View Components / 可复用视图组件

### Loading View Component / 加载视图组件

```swift
/**
 * REUSABLE LOADING VIEW
 * 可复用加载视图
 * 
 * PURPOSE / 目的:
 * - Consistent loading indicators across the app
 * - 应用中一致的加载指示器
 * 
 * FEATURES / 功能:
 * - Customizable message and style
 * - 可自定义消息和样式
 * - Support for different sizes
 * - 支持不同大小
 * - Animated appearance
 * - 动画外观
 */
struct LoadingView: View {
    let message: String
    let style: Style
    
    enum Style {
        case small, medium, large
        case fullScreen
        
        var scale: CGFloat {
            switch self {
            case .small: return 0.8
            case .medium: return 1.0
            case .large: return 1.5
            case .fullScreen: return 2.0
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            case .fullScreen: return 24
            }
        }
    }
    
    init(message: String = "Loading...", style: Style = .medium) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: style.spacing) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(style.scale)
            
            Text(message)
                .font(style == .fullScreen ? .title3 : .caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .if(style == .fullScreen) { view in
            view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .ignoresSafeArea()
        }
    }
}

/**
 * USAGE EXAMPLES / 使用示例
 * 
 * // Simple loading / 简单加载
 * if isLoading {
 *     LoadingView()
 * }
 * 
 * // Custom message and style / 自定义消息和样式
 * LoadingView(message: "Fetching data...", style: .large)
 * 
 * // Full screen loading / 全屏加载
 * ZStack {
 *     ContentView()
 *     if isLoading {
 *         LoadingView(message: "Please wait", style: .fullScreen)
 *     }
 * }
 */
```

### Empty State View Component / 空状态视图组件

```swift
/**
 * EMPTY STATE VIEW
 * 空状态视图
 * 
 * PURPOSE / 目的:
 * - Show meaningful content when no data is available
 * - 在没有数据时显示有意义的内容
 * - Guide users on what to do next
 * - 指导用户下一步做什么
 */
struct EmptyStateView: View {
    let config: Configuration
    
    struct Configuration {
        let image: String
        let title: String
        let message: String
        let buttonTitle: String?
        let action: (() -> Void)?
        
        // Predefined configurations / 预定义配置
        static let noData = Configuration(
            image: "tray",
            title: "No Data",
            message: "There's nothing to show here yet.",
            buttonTitle: "Refresh",
            action: nil
        )
        
        static let noResults = Configuration(
            image: "magnifyingglass",
            title: "No Results",
            message: "Try adjusting your search or filters.",
            buttonTitle: nil,
            action: nil
        )
        
        static let error = Configuration(
            image: "exclamationmark.triangle",
            title: "Something Went Wrong",
            message: "We couldn't load the content. Please try again.",
            buttonTitle: "Retry",
            action: nil
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: config.image)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(config.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(config.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let buttonTitle = config.buttonTitle,
               let action = config.action {
                Button(action: action) {
                    Text(buttonTitle)
                        .fontWeight(.medium)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/**
 * USAGE / 使用:
 * 
 * EmptyStateView(config: .noData)
 * 
 * EmptyStateView(config: Configuration(
 *     image: "cart",
 *     title: "Your Cart is Empty",
 *     message: "Add some items to get started",
 *     buttonTitle: "Browse Products",
 *     action: { navigateToProducts() }
 * ))
 */
```

### Error View Component / 错误视图组件

```swift
/**
 * ERROR VIEW COMPONENT
 * 错误视图组件
 * 
 * PURPOSE / 目的:
 * - Consistent error presentation
 * - 一致的错误展示
 * - Clear error messaging and recovery actions
 * - 清晰的错误消息和恢复操作
 */
struct ErrorView: View {
    let error: Error
    let retry: (() -> Void)?
    let dismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            // Error icon / 错误图标
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            // Error details / 错误详情
            VStack(spacing: 8) {
                Text("Error")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Actions / 操作
            HStack(spacing: 16) {
                if let dismiss = dismiss {
                    Button("Dismiss") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                if let retry = retry {
                    Button("Retry") {
                        retry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}
```

---

## View Extensions with onXXX Pattern / 带 onXXX 模式的视图扩展

### Core onXXX Extensions / 核心 onXXX 扩展

```swift
/**
 * VIEW EXTENSIONS WITH onXXX PATTERN
 * 带 onXXX 模式的视图扩展
 * 
 * NAMING CONVENTION / 命名约定:
 * - Start with "on" to indicate event or state handling
 * - 以 "on" 开头表示事件或状态处理
 * - Use descriptive names that clearly indicate purpose
 * - 使用清楚表明目的的描述性名称
 * 
 * BENEFITS / 好处:
 * - Chainable API design
 * - 可链式调用的 API 设计
 * - Consistent with SwiftUI's built-in modifiers
 * - 与 SwiftUI 内置修饰符一致
 * - Self-documenting code
 * - 自文档化代码
 */

extension View {
    /**
     * Show loading overlay
     * 显示加载覆盖层
     * 
     * USAGE / 使用:
     * ContentView()
     *     .onLoading(viewModel.isLoading)
     * 
     * CHAIN WITH OTHER MODIFIERS / 与其他修饰符链式调用:
     * ContentView()
     *     .onLoading(isLoading, message: "Fetching...")
     *     .onError(errorMessage)
     *     .onEmpty(items.isEmpty)
     */
    func onLoading(
        _ isLoading: Bool,
        message: String = "Loading..."
    ) -> some View {
        self.overlay(
            isLoading ? 
            LoadingView(message: message, style: .fullScreen) : 
            nil
        )
    }
    
    /**
     * Show error state
     * 显示错误状态
     * 
     * ADVANCED USAGE / 高级用法:
     * ContentView()
     *     .onError(viewModel.error) { error in
     *         // Custom error view
     *         ErrorView(error: error, retry: viewModel.retry)
     *     }
     */
    func onError(
        _ error: Error?,
        retry: (() -> Void)? = nil,
        dismiss: (() -> Void)? = nil
    ) -> some View {
        self.overlay(
            error != nil ? 
            ErrorView(error: error!, retry: retry, dismiss: dismiss) : 
            nil
        )
    }
    
    /**
     * Show empty state
     * 显示空状态
     * 
     * CONDITIONAL USAGE / 条件使用:
     * List(items) { item in
     *     ItemRow(item: item)
     * }
     * .onEmpty(
     *     items.isEmpty && !isLoading,
     *     config: .noData
     * )
     */
    func onEmpty(
        _ isEmpty: Bool,
        config: EmptyStateView.Configuration = .noData
    ) -> some View {
        self.overlay(
            isEmpty ? EmptyStateView(config: config) : nil
        )
    }
    
    /**
     * Show success message
     * 显示成功消息
     */
    func onSuccess(
        _ message: String?,
        duration: Double = 3.0
    ) -> some View {
        self.overlay(
            message != nil ?
            SuccessToast(message: message!, duration: duration) :
            nil
        )
    }
}
```

### Advanced onXXX Patterns / 高级 onXXX 模式

```swift
/**
 * ADVANCED CONDITIONAL MODIFIERS
 * 高级条件修饰符
 */
extension View {
    /**
     * Apply modifier only when condition is true
     * 仅在条件为真时应用修饰符
     * 
     * USAGE / 使用:
     * Text("Hello")
     *     .onCondition(isPremium) { view in
     *         view.foregroundColor(.gold)
     *            .bold()
     *     }
     */
    @ViewBuilder
    func onCondition<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /**
     * Apply different modifiers based on condition
     * 基于条件应用不同的修饰符
     * 
     * USAGE / 使用:
     * Image("profile")
     *     .onConditional(
     *         isSelected,
     *         whenTrue: { $0.border(Color.blue, width: 2) },
     *         whenFalse: { $0.opacity(0.5) }
     *     )
     */
    @ViewBuilder
    func onConditional<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        whenTrue: (Self) -> TrueContent,
        whenFalse: (Self) -> FalseContent
    ) -> some View {
        if condition {
            whenTrue(self)
        } else {
            whenFalse(self)
        }
    }
    
    /**
     * Perform action when view appears for first time only
     * 仅在视图首次出现时执行操作
     */
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        self.modifier(FirstAppearModifier(action: action))
    }
}

struct FirstAppearModifier: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.onAppear {
            if !hasAppeared {
                hasAppeared = true
                action()
            }
        }
    }
}

/**
 * VALIDATION MODIFIERS
 * 验证修饰符
 */
extension View {
    /**
     * Show validation state on text fields
     * 在文本字段上显示验证状态
     * 
     * USAGE / 使用:
     * TextField("Email", text: $email)
     *     .onValidation(
     *         isValid: email.contains("@"),
     *         message: "Invalid email format"
     *     )
     */
    func onValidation(
        isValid: Bool,
        message: String
    ) -> some View {
        self
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: isValid ? "checkmark.circle" : "xmark.circle")
                        .foregroundColor(isValid ? .green : .red)
                }
                .padding(.trailing, 8)
            )
            .overlay(
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .opacity(isValid ? 0 : 1)
                    .animation(.easeInOut, value: isValid),
                alignment: .bottom
            )
    }
}
```

---

## Advanced Composition Techniques / 高级组合技术

### Modifier Composition / 修饰符组合

```swift
/**
 * COMPOSING MULTIPLE MODIFIERS
 * 组合多个修饰符
 * 
 * Create complex modifiers by combining simpler ones
 * 通过组合简单的修饰符创建复杂的修饰符
 */
struct PremiumCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cardStyle(backgroundColor: .gold.opacity(0.1))
            .overlay(
                LinearGradient(
                    colors: [.clear, .gold.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .allowsHitTesting(false)
            )
            .overlay(
                Image(systemName: "crown.fill")
                    .foregroundColor(.gold)
                    .offset(x: -10, y: -10),
                alignment: .topTrailing
            )
    }
}

/**
 * STATE-DRIVEN MODIFIER COMPOSITION
 * 状态驱动的修饰符组合
 */
struct InteractiveCardModifier: ViewModifier {
    @State private var isPressed = false
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .brightness(isHovered ? 0.1 : 0)
            .animation(.spring(response: 0.3), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onTapGesture { }
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                },
                perform: { }
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
```

### Complex Component Example / 复杂组件示例

```swift
/**
 * COMPLETE LIST VIEW WITH ALL STATES
 * 包含所有状态的完整列表视图
 * 
 * Demonstrates how to compose multiple reusable components
 * 演示如何组合多个可复用组件
 */
struct SmartListView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let isLoading: Bool
    let error: Error?
    let onRefresh: () async -> Void
    let onLoadMore: () async -> Void
    let content: (Item) -> Content
    
    @State private var isRefreshing = false
    @State private var isLoadingMore = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    content(item)
                        .cardStyle()
                }
                
                // Load more indicator / 加载更多指示器
                if isLoadingMore {
                    LoadingView(message: "Loading more...", style: .small)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
        }
        .refreshable {
            await onRefresh()
        }
        .onAppear {
            checkLoadMore()
        }
        .onLoading(isLoading && items.isEmpty)
        .onError(error) {
            Task { await onRefresh() }
        }
        .onEmpty(
            items.isEmpty && !isLoading && error == nil,
            config: .noData
        )
    }
    
    private func checkLoadMore() {
        // Load more logic / 加载更多逻辑
    }
}

/**
 * USAGE EXAMPLE / 使用示例:
 * 
 * SmartListView(
 *     items: viewModel.products,
 *     isLoading: viewModel.isLoading,
 *     error: viewModel.error,
 *     onRefresh: viewModel.refresh,
 *     onLoadMore: viewModel.loadMore
 * ) { product in
 *     ProductRow(product: product)
 * }
 */
```

---

## Best Practices / 最佳实践

### 1. Naming Conventions / 命名约定

```swift
/**
 * GOOD NAMING EXAMPLES / 好的命名示例
 */

// ViewModifiers: Use descriptive names with "Modifier" suffix
// ViewModifiers：使用带 "Modifier" 后缀的描述性名称
struct CardStyleModifier: ViewModifier { }
struct LoadingOverlayModifier: ViewModifier { }

// View extensions: Use "on" prefix for state/event handlers
// 视图扩展：对状态/事件处理器使用 "on" 前缀
func onLoading(_ isLoading: Bool) -> some View { }
func onError(_ error: Error?) -> some View { }

// Reusable views: Clear, descriptive names
// 可复用视图：清晰、描述性的名称
struct EmptyStateView: View { }
struct ErrorBannerView: View { }
```

### 2. Parameter Design / 参数设计

```swift
/**
 * PARAMETER BEST PRACTICES / 参数最佳实践
 */

// Provide sensible defaults / 提供合理的默认值
func cardStyle(
    padding: CGFloat = 16,  // Default value
    cornerRadius: CGFloat = 12
) -> some View

// Use configuration objects for many parameters
// 对多个参数使用配置对象
struct ButtonConfiguration {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
}

// Support both simple and advanced usage
// 支持简单和高级用法
extension View {
    // Simple version / 简单版本
    func loading(_ isLoading: Bool) -> some View
    
    // Advanced version / 高级版本
    func loading(
        _ isLoading: Bool,
        message: String,
        style: LoadingView.Style
    ) -> some View
}
```

### 3. Composition Guidelines / 组合指南

```swift
/**
 * COMPOSITION BEST PRACTICES / 组合最佳实践
 */

// ✅ GOOD: Small, focused modifiers / 好：小而专注的修饰符
struct BorderModifier: ViewModifier { }
struct ShadowModifier: ViewModifier { }
struct PaddingModifier: ViewModifier { }

// ❌ BAD: Large, do-everything modifier / 坏：大而全的修饰符
struct EverythingModifier: ViewModifier {
    // Too many responsibilities / 太多职责
}

// ✅ GOOD: Compose modifiers / 好：组合修饰符
extension View {
    func premiumStyle() -> some View {
        self
            .borderStyle()
            .shadowStyle()
            .paddingStyle()
    }
}
```

### 4. Performance Considerations / 性能考虑

```swift
/**
 * PERFORMANCE TIPS / 性能提示
 */

// Use @State and @Binding wisely / 明智使用 @State 和 @Binding
struct EfficientModifier: ViewModifier {
    // Only use @State for internal state
    // 仅对内部状态使用 @State
    @State private var internalState = false
    
    // Use Binding for external state
    // 对外部状态使用 Binding
    @Binding var externalState: Bool
}

// Avoid heavy computations in body / 避免在 body 中进行繁重计算
struct OptimizedModifier: ViewModifier {
    // Compute once and cache / 计算一次并缓存
    private let expensiveValue: Int
    
    init() {
        self.expensiveValue = Self.computeExpensiveValue()
    }
    
    func body(content: Content) -> some View {
        content
            .tag(expensiveValue)
    }
    
    private static func computeExpensiveValue() -> Int {
        // Heavy computation / 繁重计算
        return 42
    }
}
```

### 5. Testing Strategies / 测试策略

```swift
/**
 * TESTING VIEWMODIFIERS / 测试 ViewModifier
 */

import XCTest
import SwiftUI

class ViewModifierTests: XCTestCase {
    func testCardModifier() {
        // Create a test view / 创建测试视图
        let view = Text("Test")
            .modifier(CardModifier(padding: 20))
        
        // Test modifier properties / 测试修饰符属性
        let modifier = CardModifier(padding: 20)
        XCTAssertEqual(modifier.padding, 20)
    }
}

// Test reusable components / 测试可复用组件
class ComponentTests: XCTestCase {
    func testEmptyStateConfiguration() {
        let config = EmptyStateView.Configuration.noData
        XCTAssertEqual(config.title, "No Data")
        XCTAssertNotNil(config.image)
    }
}
```

---

## Summary / 总结

### Key Takeaways / 关键要点

1. **ViewModifiers are powerful** / **ViewModifier 很强大**
   - Encapsulate styling and behavior
   - 封装样式和行为

2. **Reusable components save time** / **可复用组件节省时间**
   - Write once, use everywhere
   - 一次编写，到处使用

3. **onXXX pattern is intuitive** / **onXXX 模式很直观**
   - Follows SwiftUI conventions
   - 遵循 SwiftUI 约定

4. **Composition over inheritance** / **组合优于继承**
   - Build complex UI from simple pieces
   - 从简单片段构建复杂 UI

5. **Test your components** / **测试你的组件**
   - Ensure reliability and maintainability
   - 确保可靠性和可维护性

### Quick Reference / 快速参考

| Pattern | Use Case | Example |
|---------|----------|---------|
| ViewModifier | Reusable styling | `.cardStyle()` |
| View Extension | State handling | `.onLoading()` |
| Reusable Component | Common UI elements | `LoadingView()` |
| Composition | Complex UI | Multiple modifiers |

Remember: The goal is to write less code while building more consistent, maintainable UI.

记住：目标是编写更少的代码，同时构建更一致、可维护的 UI。