//
//  DialogModifier.swift
//  ReduxSwiftUIDemo
//
//  ViewModifier for presenting dialogs
//  用于展示对话框的ViewModifier
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI

// MARK: - iOS Version Compatibility Extension / iOS 版本兼容性扩展

public extension View {
    /**
     * Cross-version compatible onChange modifier
     * 跨版本兼容的 onChange 修饰符
     * 
     * This wrapper handles the deprecation warning for iOS 17+
     * 此包装器处理 iOS 17+ 的弃用警告
     */
    @ViewBuilder
    func compatibleOnChange<Value: Equatable>(
        of value: Value,
        perform action: @escaping (Value) -> Void
    ) -> some View {
        if #available(iOS 17.0, *) {
            // iOS 17+ uses new onChange with oldValue and newValue
            // iOS 17+ 使用带有 oldValue 和 newValue 的新 onChange
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            // iOS 15-16 uses single value parameter
            // iOS 15-16 使用单个值参数
            self.onChange(of: value, perform: action)
        }
    }
}

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Decorator Pattern (装饰器模式)
 *    - Why: ViewModifier adds dialog presentation capability to any view / 为什么：ViewModifier为任何视图添加对话框展示能力
 *    - Benefits: Reusable, composable, doesn't modify original view / 好处：可重用，可组合，不修改原始视图
 *
 * 2. Chain of Responsibility Pattern (责任链模式)
 *    - Why: Modifiers can be chained to add multiple dialog behaviors / 为什么：修饰符可以链式添加多个对话框行为
 *    - Benefits: Flexible composition, separation of concerns / 好处：灵活的组合，关注点分离
 */

// MARK: - Dialog Presentation Modifier / 对话框展示修饰符
/// ViewModifier for presenting a dialog / 用于展示对话框的ViewModifier
///
/// Example usage / 使用示例:
/// ```swift
/// struct ContentView: View {
///     @State private var showDialog = false
///     @State private var dialogConfig: DialogConfiguration?
///     
///     var body: some View {
///         VStack {
///             Button("Show Dialog") {
///                 dialogConfig = createDialogConfig()
///                 showDialog = true
///             }
///         }
///         .dialog(
///             isPresented: $showDialog,
///             configuration: dialogConfig
///         )
///     }
/// }
/// ```
public struct DialogPresentationModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Binding to presentation state / 绑定到展示状态
    @Binding var isPresented: Bool
    
    /// Dialog configuration / 对话框配置
    let configuration: DialogConfiguration?
    
    /// Dialog manager / 对话框管理器
    let dialogManager: DialogManager
    
    /// On dismiss handler / 关闭处理器
    let onDismiss: (() -> Void)?
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented, let config = configuration {
                    DialogView(
                        configuration: config,
                        isPresented: $isPresented,
                        dialogManager: dialogManager
                    )
                    .transition(config.animationStyle.transition)
                    .zIndex(999)
                }
            }
            .compatibleOnChange(of: isPresented) { newValue in
                if !newValue {
                    onDismiss?()
                }
            }
    }
}

// MARK: - Global Dialog Modifier / 全局对话框修饰符
/// ViewModifier for global dialog presentation / 用于全局对话框展示的ViewModifier
///
/// Example usage / 使用示例:
/// ```swift
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .globalDialogPresenter()
///         }
///     }
/// }
/// ```
public struct GlobalDialogModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Dialog manager / 对话框管理器
    @ObservedObject private var dialogManager = DialogManager.shared
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                if dialogManager.isPresented,
                   let configuration = dialogManager.currentDialog {
                    DialogView(
                        configuration: configuration,
                        isPresented: .init(
                            get: { dialogManager.isPresented },
                            set: { _ in dialogManager.dismissCurrentDialog() }
                        ),
                        dialogManager: dialogManager
                    )
                    .transition(configuration.animationStyle.transition)
                    .zIndex(999)
                }
            }
    }
}

// MARK: - Loading Dialog Modifier / 加载对话框修饰符
/// ViewModifier for showing loading dialogs / 用于显示加载对话框的ViewModifier
///
/// Example usage / 使用示例:
/// ```swift
/// struct ContentView: View {
///     @State private var isLoading = false
///     
///     var body: some View {
///         VStack {
///             Button("Load Data") {
///                 isLoading = true
///                 loadData()
///             }
///         }
///         .loadingDialog(
///             isPresented: $isLoading,
///             title: "Loading Data..."
///         )
///     }
/// }
/// ```
public struct LoadingDialogModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Binding to loading state / 绑定到加载状态
    @Binding var isPresented: Bool
    
    /// Loading title / 加载标题
    let title: String
    
    /// Loading message / 加载消息
    let message: String?
    
    /// Can dismiss / 是否可以关闭
    let canDismiss: Bool
    
    /// Loading dialog ID / 加载对话框ID
    @State private var loadingDialogId: UUID?
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        content
            .compatibleOnChange(of: isPresented) { newValue in
                if newValue {
                    // Show loading dialog / 显示加载对话框
                    loadingDialogId = DialogManager.shared.showLoading(
                        title: title,
                        message: message
                    )
                } else if let dialogId = loadingDialogId {
                    // Dismiss loading dialog / 关闭加载对话框
                    DialogManager.shared.dismissLoading(id: dialogId)
                    loadingDialogId = nil
                }
            }
    }
}

// MARK: - Error Dialog Modifier / 错误对话框修饰符
/// ViewModifier for showing error dialogs / 用于显示错误对话框的ViewModifier
///
/// Example usage / 使用示例:
/// ```swift
/// struct ContentView: View {
///     @State private var errorMessage: String?
///     
///     var body: some View {
///         VStack {
///             Button("Trigger Error") {
///                 errorMessage = "Something went wrong"
///             }
///         }
///         .errorDialog(errorMessage: $errorMessage)
///     }
/// }
/// ```
public struct ErrorDialogModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Binding to error message / 绑定到错误消息
    @Binding var errorMessage: String?
    
    /// Error title / 错误标题
    let title: String
    
    /// On dismiss handler / 关闭处理器
    let onDismiss: (() -> Void)?
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        content
            .compatibleOnChange(of: errorMessage) { newErrorMessage in
                if let message = newErrorMessage {
                    // Create a simple error struct for display / 创建用于显示的简单错误结构
                    struct DisplayError: LocalizedError {
                        let message: String
                        var errorDescription: String? { message }
                    }
                    
                    DialogManager.shared.showError(
                        title: title,
                        error: DisplayError(message: message),
                        onDismiss: {
                            self.errorMessage = nil
                            onDismiss?()
                        }
                    )
                }
            }
    }
}

// MARK: - Deferred Dialog Modifier / 延迟对话框修饰符
/// ViewModifier for showing dialogs with deferred priority / 用于显示延迟优先级对话框的ViewModifier
public struct DeferredDialogModifier: ViewModifier {
    let configuration: DialogConfiguration?
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        content
            .compatibleOnChange(of: isPresented) { newValue in
                if newValue, let config = configuration {
                    DialogManager.shared.showDeferred(configuration: config)
                    isPresented = false
                }
            }
    }
}

// MARK: - Immediate Dialog Modifier / 立即对话框修饰符
/// ViewModifier for showing dialogs with immediate priority / 用于显示立即优先级对话框的ViewModifier
public struct ImmediateDialogModifier: ViewModifier {
    let configuration: DialogConfiguration?
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        content
            .compatibleOnChange(of: isPresented) { newValue in
                if newValue, let config = configuration {
                    DialogManager.shared.showImmediate(configuration: config)
                    isPresented = false
                }
            }
    }
}

// MARK: - View Extensions / 视图扩展
extension View {
    /// Present a dialog with configuration / 使用配置展示对话框
    /// - Parameters:
    ///   - isPresented: Binding to presentation state / 绑定到展示状态
    ///   - configuration: Dialog configuration / 对话框配置
    ///   - dialogManager: Dialog manager instance / 对话框管理器实例
    ///   - onDismiss: Dismiss handler / 关闭处理器
    /// - Returns: Modified view / 修改后的视图
    public func dialog(
        isPresented: Binding<Bool>,
        configuration: DialogConfiguration?,
        dialogManager: DialogManager = DialogManager.shared,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(DialogPresentationModifier(
            isPresented: isPresented,
            configuration: configuration,
            dialogManager: dialogManager,
            onDismiss: onDismiss
        ))
    }
    
    /// Enable global dialog presentation / 启用全局对话框展示
    /// - Returns: Modified view / 修改后的视图
    public func globalDialogPresenter() -> some View {
        modifier(GlobalDialogModifier())
    }
    
    /// Show loading dialog / 显示加载对话框
    /// - Parameters:
    ///   - isPresented: Binding to loading state / 绑定到加载状态
    ///   - title: Loading title / 加载标题
    ///   - message: Loading message / 加载消息
    ///   - canDismiss: Can dismiss / 是否可以关闭
    /// - Returns: Modified view / 修改后的视图
    public func loadingDialog(
        isPresented: Binding<Bool>,
        title: String = "Loading",
        message: String? = nil,
        canDismiss: Bool = false
    ) -> some View {
        modifier(LoadingDialogModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            canDismiss: canDismiss
        ))
    }
    
    /// Show error dialog / 显示错误对话框
    /// - Parameters:
    ///   - errorMessage: Binding to error message / 绑定到错误消息
    ///   - title: Error title / 错误标题
    ///   - onDismiss: Dismiss handler / 关闭处理器
    /// - Returns: Modified view / 修改后的视图
    public func errorDialog(
        errorMessage: Binding<String?>,
        title: String = "Error",
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorDialogModifier(
            errorMessage: errorMessage,
            title: title,
            onDismiss: onDismiss
        ))
    }
    
    /// Show deferred dialog (like Swift defer, shown last) / 显示延迟对话框（像Swift defer，最后显示）
    /// - Parameters:
    ///   - isPresented: Binding to presentation state / 绑定到展示状态
    ///   - configuration: Dialog configuration / 对话框配置
    /// - Returns: Modified view / 修改后的视图
    public func deferredDialog(
        isPresented: Binding<Bool>,
        configuration: DialogConfiguration?
    ) -> some View {
        modifier(DeferredDialogModifier(
            configuration: configuration,
            isPresented: isPresented
        ))
    }
    
    /// Show immediate dialog (shown first) / 显示立即对话框（首先显示）
    /// - Parameters:
    ///   - isPresented: Binding to presentation state / 绑定到展示状态
    ///   - configuration: Dialog configuration / 对话框配置
    /// - Returns: Modified view / 修改后的视图
    public func immediateDialog(
        isPresented: Binding<Bool>,
        configuration: DialogConfiguration?
    ) -> some View {
        modifier(ImmediateDialogModifier(
            configuration: configuration,
            isPresented: isPresented
        ))
    }
}