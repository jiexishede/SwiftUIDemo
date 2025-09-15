//
//  DialogTemplates.swift
//  ReduxSwiftUIDemo
//
//  Pre-configured dialog templates for common use cases
//  常见用例的预配置对话框模板
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Template Method Pattern (模板方法模式)
 *    - Why: Defines skeleton of dialog creation with customizable parts / 为什么：定义对话框创建的框架与可自定义部分
 *    - Benefits: Consistent structure, easy customization, code reuse / 好处：一致的结构，易于自定义，代码重用
 *
 * 2. Factory Pattern (工厂模式)
 *    - Why: Creates specific dialog types with appropriate configurations / 为什么：创建具有适当配置的特定对话框类型
 *    - Benefits: Encapsulated creation logic, consistent interface / 好处：封装的创建逻辑，一致的接口
 */

// MARK: - Alert Template / 警报模板
/// Pre-configured alert dialog template / 预配置的警报对话框模板
///
/// Example usage / 使用示例:
/// ```swift
/// let alert = AlertDialogTemplate(
///     title: "Success",
///     message: "Operation completed successfully",
///     style: .success
/// )
/// DialogManager.shared.show(configuration: alert.configuration)
/// ```
public struct AlertDialogTemplate {
    // MARK: - Alert Style / 警报样式
    
    /// Alert style enumeration / 警报样式枚举
    public enum Style {
        case info      // Information alert / 信息警报
        case success   // Success alert / 成功警报
        case warning   // Warning alert / 警告警报
        case error     // Error alert / 错误警报
        
        /// Get icon for style / 获取样式的图标
        var icon: Image {
            switch self {
            case .info:
                return Image(systemName: "info.circle.fill")
            case .success:
                return Image(systemName: "checkmark.circle.fill")
            case .warning:
                return Image(systemName: "exclamationmark.triangle.fill")
            case .error:
                return Image(systemName: "xmark.circle.fill")
            }
        }
        
        /// Get color for style / 获取样式的颜色
        var color: Color {
            switch self {
            case .info:
                return .blue
            case .success:
                return .green
            case .warning:
                return .orange
            case .error:
                return .red
            }
        }
        
        /// Get priority for style / 获取样式的优先级
        var priority: DialogPriority {
            switch self {
            case .info:
                return .normal
            case .success:
                return .normal
            case .warning:
                return .high
            case .error:
                return .critical
            }
        }
    }
    
    // MARK: - Properties / 属性
    
    /// Dialog configuration / 对话框配置
    public let configuration: DialogConfiguration
    
    // MARK: - Initializer / 初始化器
    
    /// Initialize alert template / 初始化警报模板
    /// - Parameters:
    ///   - title: Alert title / 警报标题
    ///   - message: Alert message / 警报消息
    ///   - style: Alert style / 警报样式
    ///   - buttonTitle: Button title / 按钮标题
    ///   - onDismiss: Dismiss handler / 关闭处理器
    public init(
        title: String,
        message: String? = nil,
        style: Style = .info,
        buttonTitle: String = "OK",
        onDismiss: (() -> Void)? = nil
    ) {
        // Create custom content with icon / 创建带图标的自定义内容
        let content = DialogContent.customView(
            VStack(spacing: 16) {
                style.icon
                    .font(.system(size: 48))
                    .foregroundColor(style.color)
                
                if let message = message {
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        )
        
        self.configuration = DialogConfiguration.Builder()
            .setTitle(title)
            .setContent(content)
            .addButton(DialogButton(
                title: buttonTitle,
                style: .default,
                actionStrategy: DismissActionStrategy(additionalAction: onDismiss)
            ))
            .setPriority(style.priority)
            .setAnimationStyle(.spring)
            .build()
    }
}

// MARK: - Confirmation Template / 确认模板
/// Pre-configured confirmation dialog template / 预配置的确认对话框模板
///
/// Example usage / 使用示例:
/// ```swift
/// let confirm = ConfirmationDialogTemplate(
///     title: "Delete Item?",
///     message: "This action cannot be undone",
///     isDestructive: true,
///     onConfirm: {
///         deleteItem()
///     }
/// )
/// DialogManager.shared.show(configuration: confirm.configuration)
/// ```
public struct ConfirmationDialogTemplate {
    // MARK: - Properties / 属性
    
    /// Dialog configuration / 对话框配置
    public let configuration: DialogConfiguration
    
    // MARK: - Initializer / 初始化器
    
    /// Initialize confirmation template / 初始化确认模板
    /// - Parameters:
    ///   - title: Confirmation title / 确认标题
    ///   - message: Confirmation message / 确认消息
    ///   - confirmTitle: Confirm button title / 确认按钮标题
    ///   - cancelTitle: Cancel button title / 取消按钮标题
    ///   - isDestructive: Is action destructive / 动作是否具有破坏性
    ///   - showIcon: Show confirmation icon / 显示确认图标
    ///   - onConfirm: Confirm handler / 确认处理器
    ///   - onCancel: Cancel handler / 取消处理器
    public init(
        title: String,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        isDestructive: Bool = false,
        showIcon: Bool = true,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        // Create content with optional icon / 创建带可选图标的内容
        let content: DialogContent?
        if showIcon {
            content = DialogContent.customView(
                VStack(spacing: 16) {
                    Image(systemName: isDestructive ? "exclamationmark.triangle.fill" : "questionmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(isDestructive ? .red : .blue)
                    
                    if let message = message {
                        Text(message)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            )
        } else if let message = message {
            content = .text(message)
        } else {
            content = nil
        }
        
        self.configuration = DialogConfiguration.Builder()
            .setTitle(title)
            .setContent(content)
            .addButton(DialogButton(
                title: cancelTitle,
                style: .cancel,
                actionStrategy: DismissActionStrategy(additionalAction: onCancel)
            ))
            .addButton(DialogButton(
                title: confirmTitle,
                style: isDestructive ? .destructive : .default
            ) {
                onConfirm()
                DialogManager.shared.dismissCurrentDialog()
            })
            .setPriority(isDestructive ? .high : .normal)
            .build()
    }
}

// MARK: - Input Template / 输入模板
/// Pre-configured input dialog template / 预配置的输入对话框模板
///
/// Example usage / 使用示例:
/// ```swift
/// let input = InputDialogTemplate(
///     title: "Enter Name",
///     placeholder: "Your name",
///     onSubmit: { name in
///         print("Name: \(name)")
///     }
/// )
/// DialogManager.shared.show(configuration: input.configuration)
/// ```
public struct InputDialogTemplate {
    // MARK: - Properties / 属性
    
    /// Dialog configuration / 对话框配置
    public let configuration: DialogConfiguration
    
    // MARK: - Initializer / 初始化器
    
    /// Initialize input template / 初始化输入模板
    /// - Parameters:
    ///   - title: Input title / 输入标题
    ///   - message: Input message / 输入消息
    ///   - placeholder: Placeholder text / 占位符文本
    ///   - initialValue: Initial input value / 初始输入值
    ///   - isSecure: Is secure text entry / 是否安全文本输入
    ///   - validation: Validation closure / 验证闭包
    ///   - onSubmit: Submit handler / 提交处理器
    ///   - onCancel: Cancel handler / 取消处理器
    public init(
        title: String,
        message: String? = nil,
        placeholder: String = "",
        initialValue: String = "",
        isSecure: Bool = false,
        validation: ((String) -> Bool)? = nil,
        onSubmit: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        // Create input field view / 创建输入字段视图
        let inputView = InputFieldView(
            placeholder: placeholder,
            initialValue: initialValue,
            isSecure: isSecure,
            validation: validation,
            onSubmit: onSubmit
        )
        
        let content = DialogContent.customView(
            VStack(spacing: 16) {
                if let message = message {
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                inputView
            }
            .padding()
        )
        
        self.configuration = DialogConfiguration.Builder()
            .setTitle(title)
            .setContent(content)
            .addButton(DialogButton.cancel(action: onCancel))
            .addButton(DialogButton(
                title: "Submit",
                style: .default
            ) {
                inputView.submit()
            })
            .setKeyboardAdaptive(true)
            .build()
    }
}

// MARK: - Input Field View / 输入字段视图
/// Custom input field view for input dialogs / 输入对话框的自定义输入字段视图
fileprivate struct InputFieldView: View {
    // MARK: - Properties / 属性
    
    let placeholder: String
    let isSecure: Bool
    let validation: ((String) -> Bool)?
    let onSubmit: (String) -> Void
    
    @State private var text: String
    @State private var isValid: Bool = true
    @FocusState private var isFocused: Bool
    
    // MARK: - Initializer / 初始化器
    
    init(
        placeholder: String,
        initialValue: String,
        isSecure: Bool,
        validation: ((String) -> Bool)?,
        onSubmit: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.validation = validation
        self.onSubmit = onSubmit
        self._text = State(initialValue: initialValue)
    }
    
    // MARK: - Body / 主体
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isFocused)
            .onSubmit {
                submit()
            }
            .compatibleOnChange(of: text) { newValue in
                validateInput(newValue)
            }
            
            if !isValid {
                Text("Invalid input")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    // MARK: - Methods / 方法
    
    /// Validate input / 验证输入
    private func validateInput(_ input: String) {
        if let validation = validation {
            isValid = validation(input)
        } else {
            isValid = true
        }
    }
    
    /// Submit input / 提交输入
    func submit() {
        if isValid {
            onSubmit(text)
            DialogManager.shared.dismissCurrentDialog()
        }
    }
}

// MARK: - Options Template / 选项模板
/// Pre-configured options dialog template / 预配置的选项对话框模板
///
/// Example usage / 使用示例:
/// ```swift
/// let options = OptionsDialogTemplate(
///     title: "Choose Action",
///     options: [
///         .init(title: "Edit", icon: Image(systemName: "pencil"), action: { edit() }),
///         .init(title: "Share", icon: Image(systemName: "square.and.arrow.up"), action: { share() }),
///         .init(title: "Delete", icon: Image(systemName: "trash"), style: .destructive, action: { delete() })
///     ]
/// )
/// DialogManager.shared.show(configuration: options.configuration)
/// ```
public struct OptionsDialogTemplate {
    // MARK: - Option / 选项
    
    /// Dialog option / 对话框选项
    public struct Option {
        let title: String
        let icon: Image?
        let style: DialogButtonStyle
        let action: () -> Void
        
        public init(
            title: String,
            icon: Image? = nil,
            style: DialogButtonStyle = .default,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.style = style
            self.action = action
        }
    }
    
    // MARK: - Properties / 属性
    
    /// Dialog configuration / 对话框配置
    public let configuration: DialogConfiguration
    
    // MARK: - Initializer / 初始化器
    
    /// Initialize options template / 初始化选项模板
    /// - Parameters:
    ///   - title: Options title / 选项标题
    ///   - message: Options message / 选项消息
    ///   - options: Available options / 可用选项
    ///   - showCancel: Show cancel button / 显示取消按钮
    public init(
        title: String,
        message: String? = nil,
        options: [Option],
        showCancel: Bool = true
    ) {
        var buttons: [DialogButton] = options.map { option in
            DialogButton.withIcon(
                title: option.title,
                icon: option.icon ?? Image(systemName: "circle"),
                style: option.style
            ) {
                option.action()
                DialogManager.shared.dismissCurrentDialog()
            }
        }
        
        if showCancel {
            buttons.append(DialogButton.cancel())
        }
        
        self.configuration = DialogConfiguration.Builder()
            .setTitle(title)
            .setSubtitle(message)
            .setButtons(buttons)
            .build()
    }
}