//
//  DialogButton.swift
//  ReduxSwiftUIDemo
//
//  Dialog button with Strategy pattern for action handling
//  使用策略模式进行动作处理的对话框按钮
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Strategy Pattern (策略模式)
 *    - Why: Encapsulates different button action algorithms and makes them interchangeable / 为什么：封装不同的按钮动作算法并使它们可互换
 *    - Benefits: Flexible action handling, easy to add new action types, separation of concerns / 好处：灵活的动作处理，易于添加新的动作类型，关注点分离
 *    - Usage: Different button styles have different behaviors and appearances / 用法：不同的按钮样式具有不同的行为和外观
 *
 * 2. Factory Method Pattern (工厂方法模式)
 *    - Why: Provides convenient creation methods for common button types / 为什么：为常见按钮类型提供便捷的创建方法
 *    - Benefits: Simplified button creation, consistent API / 好处：简化按钮创建，一致的API
 */

// MARK: - Button Style / 按钮样式
/// Enum defining different button styles / 定义不同按钮样式的枚举
public enum DialogButtonStyle {
    /// Default style for primary actions / 主要操作的默认样式
    case `default`

    /// Cancel style for dismissive actions / 取消操作的样式
    case cancel

    /// Destructive style for dangerous actions / 危险操作的破坏性样式
    case destructive

    /// Secondary style for alternative actions / 替代操作的次要样式
    case secondary

    /// Custom style with specified colors / 自定义颜色的样式
    case custom(background: Color, foreground: Color)

    /// Get the background color for the style / 获取样式的背景颜色
    var backgroundColor: Color {
        switch self {
        case .default:
            return Color.accentColor
        case .cancel:
            return Color.gray.opacity(0.2)
        case .destructive:
            return Color.red
        case .secondary:
            return Color.secondary.opacity(0.2)
        case .custom(let background, _):
            return background
        }
    }

    /// Get the foreground color for the style / 获取样式的前景颜色
    var foregroundColor: Color {
        switch self {
        case .default:
            return .white
        case .cancel:
            return .primary
        case .destructive:
            return .white
        case .secondary:
            return .primary
        case .custom(_, let foreground):
            return foreground
        }
    }
}

// MARK: - Button Action Strategy / 按钮动作策略
/// Protocol defining button action strategy / 定义按钮动作策略的协议
public protocol DialogButtonActionStrategy {
    /// Execute the button action / 执行按钮动作
    /// - Parameter dialogManager: The dialog manager instance / 对话框管理器实例
    func execute(dialogManager: DialogManager)
}

/// Default action strategy that executes a closure / 执行闭包的默认动作策略
public struct ClosureActionStrategy: DialogButtonActionStrategy {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public func execute(dialogManager: DialogManager) {
        action()
    }
}

/// Dismiss action strategy that closes the dialog / 关闭对话框的消除动作策略
public struct DismissActionStrategy: DialogButtonActionStrategy {
    private let additionalAction: (() -> Void)?

    public init(additionalAction: (() -> Void)? = nil) {
        self.additionalAction = additionalAction
    }

    public func execute(dialogManager: DialogManager) {
        dialogManager.dismissCurrentDialog()
        additionalAction?()
    }
}

/// Async action strategy for asynchronous operations / 异步操作的异步动作策略
public struct AsyncActionStrategy: DialogButtonActionStrategy {
    private let asyncAction: () async -> Void

    public init(asyncAction: @escaping () async -> Void) {
        self.asyncAction = asyncAction
    }

    public func execute(dialogManager: DialogManager) {
        Task {
            await asyncAction()
        }
    }
}

// MARK: - Dialog Button / 对话框按钮
/// Main dialog button struct / 主要的对话框按钮结构体
///
/// Example usage / 使用示例:
/// ```swift
/// // Simple button with closure / 带闭包的简单按钮
/// let okButton = DialogButton(title: "OK", style: .default) {
///     print("OK tapped")
/// }
///
/// // Cancel button with automatic dismiss / 自动关闭的取消按钮
/// let cancelButton = DialogButton.cancel()
///
/// // Destructive button with confirmation / 带确认的破坏性按钮
/// let deleteButton = DialogButton.destructive(title: "Delete") {
///     deleteItem()
/// }
///
/// // Async button / 异步按钮
/// let saveButton = DialogButton.async(title: "Save") {
///     await saveData()
/// }
/// ```
public struct DialogButton: Identifiable {
    // MARK: - Properties / 属性

    /// Unique identifier / 唯一标识符
    public let id = UUID()

    /// Button title / 按钮标题
    public let title: String

    /// Button style / 按钮样式
    public let style: DialogButtonStyle

    /// Action strategy / 动作策略
    public let actionStrategy: DialogButtonActionStrategy

    /// Is button enabled / 按钮是否启用
    public let isEnabled: Bool

    /// Loading state / 加载状态
    public let isLoading: Bool

    /// Custom icon / 自定义图标
    public let icon: Image?

    // MARK: - Initializers / 初始化器

    /// Initialize with all parameters / 使用所有参数初始化
    /// - Parameters:
    ///   - title: Button title / 按钮标题
    ///   - style: Button style / 按钮样式
    ///   - isEnabled: Is button enabled / 按钮是否启用
    ///   - isLoading: Is in loading state / 是否处于加载状态
    ///   - icon: Optional icon / 可选图标
    ///   - actionStrategy: Action strategy / 动作策略
    public init(
        title: String,
        style: DialogButtonStyle = .default,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        icon: Image? = nil,
        actionStrategy: DialogButtonActionStrategy
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.icon = icon
        self.actionStrategy = actionStrategy
    }

    /// Initialize with closure action / 使用闭包动作初始化
    /// - Parameters:
    ///   - title: Button title / 按钮标题
    ///   - style: Button style / 按钮样式
    ///   - isEnabled: Is button enabled / 按钮是否启用
    ///   - isLoading: Is in loading state / 是否处于加载状态
    ///   - icon: Optional icon / 可选图标
    ///   - action: Action closure / 动作闭包
    public init(
        title: String,
        style: DialogButtonStyle = .default,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            style: style,
            isEnabled: isEnabled,
            isLoading: isLoading,
            icon: icon,
            actionStrategy: ClosureActionStrategy(action: action)
        )
    }

    // MARK: - Factory Methods / 工厂方法

    /// Create a default OK button / 创建默认的OK按钮
    /// - Parameter action: Optional action closure / 可选的动作闭包
    /// - Returns: Configured DialogButton / 配置好的DialogButton
    public static func ok(action: (() -> Void)? = nil) -> DialogButton {
        DialogButton(
            title: "OK",
            style: .default,
            actionStrategy: DismissActionStrategy(additionalAction: action)
        )
    }

    /// Create a cancel button / 创建取消按钮
    /// - Parameter action: Optional action closure / 可选的动作闭包
    /// - Returns: Configured DialogButton / 配置好的DialogButton
    public static func cancel(action: (() -> Void)? = nil) -> DialogButton {
        DialogButton(
            title: "Cancel",
            style: .cancel,
            actionStrategy: DismissActionStrategy(additionalAction: action)
        )
    }

    /// Create a destructive button / 创建破坏性按钮
    /// - Parameters:
    ///   - title: Button title / 按钮标题
    ///   - action: Action closure / 动作闭包
    /// - Returns: Configured DialogButton / 配置好的DialogButton
    public static func destructive(title: String, action: @escaping () -> Void) -> DialogButton {
        DialogButton(
            title: title,
            style: .destructive,
            action: action
        )
    }

    /// Create a secondary button / 创建次要按钮
    /// - Parameters:
    ///   - title: Button title / 按钮标题
    ///   - action: Action closure / 动作闭包
    /// - Returns: Configured DialogButton / 配置好的DialogButton
    public static func secondary(title: String, action: @escaping () -> Void) -> DialogButton {
        DialogButton(
            title: title,
            style: .secondary,
            action: action
        )
    }

    /// Create an async button / 创建异步按钮
    /// - Parameters:
    ///   - title: Button title / 按钮标题
    ///   - style: Button style / 按钮样式
    ///   - action: Async action closure / 异步动作闭包
    /// - Returns: Configured DialogButton / 配置好的DialogButton
    public static func async(
        title: String,
        style: DialogButtonStyle = .default,
        action: @escaping () async -> Void
    ) -> DialogButton {
        DialogButton(
            title: title,
            style: style,
            actionStrategy: AsyncActionStrategy(asyncAction: action)
        )
    }

    /// Create a button with icon / 创建带图标的按钮
    /// - Parameters:
    ///   - title: Button title / 按钮标题
    ///   - icon: Button icon / 按钮图标
    ///   - style: Button style / 按钮样式
    ///   - action: Action closure / 动作闭包
    /// - Returns: Configured DialogButton / 配置好的DialogButton
    public static func withIcon(
        title: String,
        icon: Image,
        style: DialogButtonStyle = .default,
        action: @escaping () -> Void
    ) -> DialogButton {
        DialogButton(
            title: title,
            style: style,
            icon: icon,
            action: action
        )
    }

    // MARK: - Methods / 方法

    /// Execute the button action / 执行按钮动作
    /// - Parameter dialogManager: Dialog manager instance / 对话框管理器实例
    public func execute(with dialogManager: DialogManager) {
        guard isEnabled && !isLoading else { return }
        actionStrategy.execute(dialogManager: dialogManager)
    }
}

// MARK: - Button Layout Strategy / 按钮布局策略
/// Enum defining button layout strategies / 定义按钮布局策略的枚举
public enum DialogButtonLayout {
    /// Horizontal layout for 1-2 buttons / 1-2个按钮的水平布局
    case horizontal

    /// Vertical layout for 3+ buttons / 3个以上按钮的垂直布局
    case vertical

    /// Automatic layout based on button count / 基于按钮数量的自动布局
    case automatic

    /// Determine actual layout based on button count / 根据按钮数量确定实际布局
    /// - Parameter buttonCount: Number of buttons / 按钮数量
    /// - Returns: Actual layout to use / 要使用的实际布局
    public func actualLayout(for buttonCount: Int) -> DialogButtonLayout {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        case .automatic:
            return buttonCount <= 2 ? .horizontal : .vertical
        }
    }
}

