//
//  DialogConfiguration.swift
//  ReduxSwiftUIDemo
//
//  Dialog configuration with Builder pattern implementation
//  使用建造者模式实现的对话框配置
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Builder Pattern (建造者模式)
 *    - Why: Provides a flexible way to construct complex dialog configurations step by step / 为什么：提供了一种灵活的方式来逐步构建复杂的对话框配置
 *    - Benefits: Separation of construction logic, fluent interface, optional parameters / 好处：分离构建逻辑，流畅的接口，可选参数
 *    - Usage: Allows creation of dialog configurations with different combinations of properties / 用法：允许创建具有不同属性组合的对话框配置
 *
 * 2. Value Type Pattern (值类型模式)
 *    - Why: Ensures immutability and thread safety / 为什么：确保不可变性和线程安全
 *    - Benefits: No unexpected mutations, safe concurrent access / 好处：没有意外的改变，安全的并发访问
 */

// MARK: - Dialog Priority / 对话框优先级
/// Priority levels for dialog queue management / 对话框队列管理的优先级级别
public enum DialogPriority: Int, Comparable {
    case deferred = -1 // Deferred priority, shown last like Swift defer / 延迟优先级，像Swift defer一样最后显示
    case low = 0       // Low priority, can be deferred / 低优先级，可以延迟
    case normal = 1    // Normal priority, standard dialogs / 正常优先级，标准对话框
    case high = 2      // High priority, important notifications / 高优先级，重要通知
    case critical = 3  // Critical priority, errors or urgent alerts / 关键优先级，错误或紧急警报
    case immediate = 99 // Immediate priority, shown first / 立即优先级，首先显示
    
    public static func < (lhs: DialogPriority, rhs: DialogPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Dialog Configuration / 对话框配置
/// Main configuration struct for dialogs / 对话框的主要配置结构体
///
/// Example usage / 使用示例:
/// ```swift
/// let config = DialogConfiguration.Builder()
///     .setTitle("Confirm Action")
///     .setSubtitle("Are you sure?")
///     .setContent("This action cannot be undone.")
///     .addButton(DialogButton(title: "Cancel", style: .cancel))
///     .addButton(DialogButton(title: "Confirm", style: .destructive))
///     .setPriority(.high)
///     .build()
/// ```
public struct DialogConfiguration {
    // MARK: - Properties / 属性
    
    /// Dialog title / 对话框标题
    public let title: String
    
    /// Optional subtitle / 可选副标题
    public let subtitle: String?
    
    /// Content text or custom view / 内容文本或自定义视图
    public let content: DialogContent?
    
    /// Array of buttons (1-5 buttons) / 按钮数组（1-5个按钮）
    public let buttons: [DialogButton]
    
    /// Priority for queue management / 队列管理的优先级
    public let priority: DialogPriority
    
    /// Animation style / 动画样式
    public let animationStyle: DialogAnimationStyle
    
    /// Show close button / 显示关闭按钮
    public let showCloseButton: Bool
    
    /// Can dismiss by tapping outside / 点击外部是否可以关闭
    public let dismissOnTapOutside: Bool
    
    /// Can dismiss by dragging / 拖动是否可以关闭
    public let dismissOnDrag: Bool
    
    /// Keyboard adaptive behavior / 键盘自适应行为
    public let isKeyboardAdaptive: Bool
    
    /// Custom background color / 自定义背景颜色
    public let backgroundColor: Color?
    
    /// Custom foreground color / 自定义前景颜色
    public let foregroundColor: Color?
    
    /// Corner radius / 圆角半径
    public let cornerRadius: CGFloat
    
    /// Shadow radius / 阴影半径
    public let shadowRadius: CGFloat
    
    /// Maximum content height / 最大内容高度
    public let maxContentHeight: CGFloat?
    
    /// Unique identifier / 唯一标识符
    public let id: UUID
    
    /// Creation timestamp / 创建时间戳
    public let timestamp: Date
    
    // MARK: - Builder Pattern Implementation / 建造者模式实现
    
    /// Builder class for constructing DialogConfiguration / 用于构建DialogConfiguration的建造者类
    ///
    /// This builder provides a fluent interface for creating dialog configurations
    /// 这个建造者提供了创建对话框配置的流畅接口
    public class Builder {
        // Private mutable properties / 私有可变属性
        private var title: String = ""
        private var subtitle: String?
        private var content: DialogContent?
        private var buttons: [DialogButton] = []
        private var priority: DialogPriority = .normal
        private var animationStyle: DialogAnimationStyle = .slide
        private var showCloseButton: Bool = true
        private var dismissOnTapOutside: Bool = true
        private var dismissOnDrag: Bool = false
        private var isKeyboardAdaptive: Bool = true
        private var backgroundColor: Color?
        private var foregroundColor: Color?
        private var cornerRadius: CGFloat = 16
        private var shadowRadius: CGFloat = 10
        private var maxContentHeight: CGFloat?
        
        /// Initialize a new builder / 初始化一个新的建造者
        public init() {}
        
        // MARK: - Builder Methods / 建造者方法
        
        /// Set the dialog title / 设置对话框标题
        /// - Parameter title: The title text / 标题文本
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setTitle(_ title: String) -> Builder {
            self.title = title
            return self
        }
        
        /// Set the dialog subtitle / 设置对话框副标题
        /// - Parameter subtitle: The subtitle text / 副标题文本
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setSubtitle(_ subtitle: String?) -> Builder {
            self.subtitle = subtitle
            return self
        }
        
        /// Set the dialog content / 设置对话框内容
        /// - Parameter content: The content / 内容
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setContent(_ content: DialogContent?) -> Builder {
            self.content = content
            return self
        }
        
        /// Set text content / 设置文本内容
        /// - Parameter text: The text content / 文本内容
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setTextContent(_ text: String) -> Builder {
            self.content = .text(text)
            return self
        }
        
        /// Add a button to the dialog / 向对话框添加按钮
        /// - Parameter button: The button to add / 要添加的按钮
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func addButton(_ button: DialogButton) -> Builder {
            guard buttons.count < 5 else {
                print("Warning: Maximum 5 buttons allowed / 警告：最多允许5个按钮")
                return self
            }
            self.buttons.append(button)
            return self
        }
        
        /// Set all buttons at once / 一次设置所有按钮
        /// - Parameter buttons: Array of buttons / 按钮数组
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setButtons(_ buttons: [DialogButton]) -> Builder {
            guard buttons.count <= 5 else {
                print("Warning: Maximum 5 buttons allowed, using first 5 / 警告：最多允许5个按钮，使用前5个")
                self.buttons = Array(buttons.prefix(5))
                return self
            }
            self.buttons = buttons
            return self
        }
        
        /// Set the dialog priority / 设置对话框优先级
        /// - Parameter priority: The priority level / 优先级级别
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setPriority(_ priority: DialogPriority) -> Builder {
            self.priority = priority
            return self
        }
        
        /// Set the animation style / 设置动画样式
        /// - Parameter style: The animation style / 动画样式
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setAnimationStyle(_ style: DialogAnimationStyle) -> Builder {
            self.animationStyle = style
            return self
        }
        
        /// Set whether to show close button / 设置是否显示关闭按钮
        /// - Parameter show: Show close button / 显示关闭按钮
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setShowCloseButton(_ show: Bool) -> Builder {
            self.showCloseButton = show
            return self
        }
        
        /// Set whether to dismiss on tap outside / 设置是否点击外部关闭
        /// - Parameter dismiss: Dismiss on tap outside / 点击外部关闭
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setDismissOnTapOutside(_ dismiss: Bool) -> Builder {
            self.dismissOnTapOutside = dismiss
            return self
        }
        
        /// Set whether to dismiss on drag / 设置是否拖动关闭
        /// - Parameter dismiss: Dismiss on drag / 拖动关闭
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setDismissOnDrag(_ dismiss: Bool) -> Builder {
            self.dismissOnDrag = dismiss
            return self
        }
        
        /// Set keyboard adaptive behavior / 设置键盘自适应行为
        /// - Parameter adaptive: Is keyboard adaptive / 是否键盘自适应
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setKeyboardAdaptive(_ adaptive: Bool) -> Builder {
            self.isKeyboardAdaptive = adaptive
            return self
        }
        
        /// Set background color / 设置背景颜色
        /// - Parameter color: Background color / 背景颜色
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setBackgroundColor(_ color: Color?) -> Builder {
            self.backgroundColor = color
            return self
        }
        
        /// Set foreground color / 设置前景颜色
        /// - Parameter color: Foreground color / 前景颜色
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setForegroundColor(_ color: Color?) -> Builder {
            self.foregroundColor = color
            return self
        }
        
        /// Set corner radius / 设置圆角半径
        /// - Parameter radius: Corner radius / 圆角半径
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setCornerRadius(_ radius: CGFloat) -> Builder {
            self.cornerRadius = radius
            return self
        }
        
        /// Set shadow radius / 设置阴影半径
        /// - Parameter radius: Shadow radius / 阴影半径
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setShadowRadius(_ radius: CGFloat) -> Builder {
            self.shadowRadius = radius
            return self
        }
        
        /// Set maximum content height / 设置最大内容高度
        /// - Parameter height: Maximum height / 最大高度
        /// - Returns: Builder instance for chaining / 返回建造者实例以供链式调用
        @discardableResult
        public func setMaxContentHeight(_ height: CGFloat?) -> Builder {
            self.maxContentHeight = height
            return self
        }
        
        /// Build the final DialogConfiguration / 构建最终的DialogConfiguration
        /// - Returns: Configured DialogConfiguration instance / 配置好的DialogConfiguration实例
        public func build() -> DialogConfiguration {
            // Validation: Ensure at least one button if no close button / 验证：如果没有关闭按钮，确保至少有一个按钮
            if !showCloseButton && buttons.isEmpty {
                print("Warning: Adding default OK button as no buttons and no close button / 警告：添加默认OK按钮，因为没有按钮也没有关闭按钮")
                buttons.append(DialogButton(title: "OK", style: .default, action: {}))
            }
            
            return DialogConfiguration(
                title: title,
                subtitle: subtitle,
                content: content,
                buttons: buttons,
                priority: priority,
                animationStyle: animationStyle,
                showCloseButton: showCloseButton,
                dismissOnTapOutside: dismissOnTapOutside,
                dismissOnDrag: dismissOnDrag,
                isKeyboardAdaptive: isKeyboardAdaptive,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                cornerRadius: cornerRadius,
                shadowRadius: shadowRadius,
                maxContentHeight: maxContentHeight,
                id: UUID(),
                timestamp: Date()
            )
        }
    }
}

// MARK: - Dialog Content / 对话框内容
/// Enum representing different types of dialog content / 表示不同类型对话框内容的枚举
public enum DialogContent {
    /// Plain text content / 纯文本内容
    case text(String)
    
    /// Custom SwiftUI view / 自定义SwiftUI视图
    case custom(AnyView)
    
    /// Convenience initializer for custom views / 自定义视图的便利初始化器
    /// - Parameter view: The custom view / 自定义视图
    public static func customView<V: View>(_ view: V) -> DialogContent {
        return .custom(AnyView(view))
    }
}

// MARK: - Equatable Conformance / Equatable一致性
extension DialogConfiguration: Equatable {
    public static func == (lhs: DialogConfiguration, rhs: DialogConfiguration) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Identifiable Conformance / Identifiable一致性
extension DialogConfiguration: Identifiable {}