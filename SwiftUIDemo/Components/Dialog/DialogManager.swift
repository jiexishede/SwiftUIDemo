//
//  DialogManager.swift
//  ReduxSwiftUIDemo
//
//  Global dialog manager with Singleton pattern
//  使用单例模式的全局对话框管理器
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI
import Combine

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Singleton Pattern (单例模式)
 *    - Why: Ensures single source of truth for dialog management across the app / 为什么：确保应用程序中对话框管理的单一数据源
 *    - Benefits: Global access, centralized control, prevents multiple instances / 好处：全局访问，集中控制，防止多个实例
 *    - Usage: DialogManager.shared provides access to the single instance / 用法：DialogManager.shared提供对单一实例的访问
 *
 * 2. Facade Pattern (外观模式)
 *    - Why: Provides simplified interface to complex dialog subsystem / 为什么：为复杂的对话框子系统提供简化的接口
 *    - Benefits: Easy to use API, hides complexity, unified interface / 好处：易于使用的API，隐藏复杂性，统一接口
 *
 * 3. Observer Pattern (观察者模式)
 *    - Why: Notifies UI components about dialog state changes / 为什么：通知UI组件对话框状态的变化
 *    - Benefits: Reactive updates, loose coupling, multiple subscribers / 好处：响应式更新，松散耦合，多个订阅者
 */

// MARK: - Dialog Manager / 对话框管理器
/// Singleton manager for global dialog presentation / 全局对话框展示的单例管理器
///
/// Example usage / 使用示例:
/// ```swift
/// // Show a simple alert / 显示简单警报
/// DialogManager.shared.showAlert(
///     title: "Success",
///     message: "Operation completed"
/// )
///
/// // Show a confirmation dialog / 显示确认对话框
/// DialogManager.shared.showConfirmation(
///     title: "Delete Item?",
///     message: "This action cannot be undone",
///     onConfirm: {
///         deleteItem()
///     }
/// )
///
/// // Show custom dialog / 显示自定义对话框
/// let config = DialogConfiguration.Builder()
///     .setTitle("Custom Dialog")
///     .build()
/// DialogManager.shared.show(configuration: config)
///
/// // Dismiss current dialog / 关闭当前对话框
/// DialogManager.shared.dismissCurrentDialog()
/// ```
public final class DialogManager: ObservableObject {
    // MARK: - Singleton Instance / 单例实例
    
    /// Shared singleton instance / 共享单例实例
    public static let shared = DialogManager()
    
    // MARK: - Properties / 属性
    
    /// Dialog queue / 对话框队列
    private let queue = DialogQueue()
    
    /// Currently presented dialog / 当前展示的对话框
    @Published public private(set) var currentDialog: DialogConfiguration?
    
    /// Is dialog currently presented / 对话框是否正在展示
    @Published public private(set) var isPresented: Bool = false
    
    /// Cancellables for Combine subscriptions / Combine订阅的取消器
    private var cancellables = Set<AnyCancellable>()
    
    /// Dialog presentation delay / 对话框展示延迟
    private let presentationDelay: TimeInterval = 0.3
    
    /// Is processing queue / 是否正在处理队列
    private var isProcessingQueue = false
    
    // MARK: - Initializer / 初始化器
    
    /// Private initializer for singleton / 单例的私有初始化器
    private init() {
        setupBindings()
    }
    
    // MARK: - Public Methods - Core / 公共方法 - 核心
    
    /// Show dialog with configuration / 使用配置显示对话框
    /// - Parameters:
    ///   - configuration: Dialog configuration / 对话框配置
    ///   - completion: Completion handler when dismissed / 关闭时的完成处理器
    public func show(
        configuration: DialogConfiguration,
        completion: (() -> Void)? = nil
    ) {
        let item = DialogQueueItem(
            configuration: configuration,
            completion: completion
        )
        
        // Add to queue / 添加到队列
        queue.enqueue(item)
        
        // Process queue if not already processing / 如果尚未处理则处理队列
        if !isProcessingQueue {
            processQueue()
        }
    }
    
    /// Dismiss current dialog / 关闭当前对话框
    public func dismissCurrentDialog() {
        withAnimation {
            isPresented = false
        }
        
        // Process next dialog after delay / 延迟后处理下一个对话框
        DispatchQueue.main.asyncAfter(deadline: .now() + presentationDelay) { [weak self] in
            self?.processQueue()
        }
    }
    
    /// Dismiss all dialogs / 关闭所有对话框
    public func dismissAll() {
        queue.clear()
        withAnimation {
            isPresented = false
            currentDialog = nil
        }
        isProcessingQueue = false
    }
    
    // MARK: - Public Methods - Special Priority / 公共方法 - 特殊优先级
    
    /// Show dialog with defer priority (shown last) / 使用延迟优先级显示对话框（最后显示）
    /// - Parameters:
    ///   - configuration: Dialog configuration / 对话框配置
    ///   - completion: Completion handler when dismissed / 关闭时的完成处理器
    public func showDeferred(
        configuration: DialogConfiguration,
        completion: (() -> Void)? = nil
    ) {
        // Force priority to deferred / 强制优先级为延迟
        let builder = DialogConfiguration.Builder()
            .setTitle(configuration.title)
            .setSubtitle(configuration.subtitle)
            .setContent(configuration.content)
            .setButtons(configuration.buttons)
            .setPriority(.deferred) // Set to deferred priority / 设置为延迟优先级
            .setAnimationStyle(configuration.animationStyle)
            .setShowCloseButton(configuration.showCloseButton)
            .setDismissOnTapOutside(configuration.dismissOnTapOutside)
            .setDismissOnDrag(configuration.dismissOnDrag)
            .setKeyboardAdaptive(configuration.isKeyboardAdaptive)
            .setBackgroundColor(configuration.backgroundColor)
            .setForegroundColor(configuration.foregroundColor)
            .setCornerRadius(configuration.cornerRadius)
            .setShadowRadius(configuration.shadowRadius)
            .setMaxContentHeight(configuration.maxContentHeight)
        
        show(configuration: builder.build(), completion: completion)
    }
    
    /// Show dialog with immediate priority (shown first) / 使用立即优先级显示对话框（首先显示）
    /// - Parameters:
    ///   - configuration: Dialog configuration / 对话框配置
    ///   - completion: Completion handler when dismissed / 关闭时的完成处理器
    public func showImmediate(
        configuration: DialogConfiguration,
        completion: (() -> Void)? = nil
    ) {
        // Force priority to immediate / 强制优先级为立即
        let builder = DialogConfiguration.Builder()
            .setTitle(configuration.title)
            .setSubtitle(configuration.subtitle)
            .setContent(configuration.content)
            .setButtons(configuration.buttons)
            .setPriority(.immediate) // Set to immediate priority / 设置为立即优先级
            .setAnimationStyle(configuration.animationStyle)
            .setShowCloseButton(configuration.showCloseButton)
            .setDismissOnTapOutside(configuration.dismissOnTapOutside)
            .setDismissOnDrag(configuration.dismissOnDrag)
            .setKeyboardAdaptive(configuration.isKeyboardAdaptive)
            .setBackgroundColor(configuration.backgroundColor)
            .setForegroundColor(configuration.foregroundColor)
            .setCornerRadius(configuration.cornerRadius)
            .setShadowRadius(configuration.shadowRadius)
            .setMaxContentHeight(configuration.maxContentHeight)
        
        show(configuration: builder.build(), completion: completion)
    }
    
    // MARK: - Public Methods - Convenience / 公共方法 - 便利
    
    /// Show alert dialog / 显示警报对话框
    /// - Parameters:
    ///   - title: Alert title / 警报标题
    ///   - message: Alert message / 警报消息
    ///   - buttonTitle: Button title / 按钮标题
    ///   - onDismiss: Dismiss handler / 关闭处理器
    public func showAlert(
        title: String,
        message: String? = nil,
        buttonTitle: String = "OK",
        onDismiss: (() -> Void)? = nil
    ) {
        let config = DialogConfiguration.Builder()
            .setTitle(title)
            .setSubtitle(message)
            .addButton(DialogButton(
                title: buttonTitle,
                style: .default,
                actionStrategy: DismissActionStrategy(additionalAction: onDismiss)
            ))
            .setPriority(.normal)
            .build()
        
        show(configuration: config)
    }
    
    /// Show confirmation dialog / 显示确认对话框
    /// - Parameters:
    ///   - title: Dialog title / 对话框标题
    ///   - message: Dialog message / 对话框消息
    ///   - confirmTitle: Confirm button title / 确认按钮标题
    ///   - cancelTitle: Cancel button title / 取消按钮标题
    ///   - isDestructive: Is confirm action destructive / 确认动作是否具有破坏性
    ///   - onConfirm: Confirm handler / 确认处理器
    ///   - onCancel: Cancel handler / 取消处理器
    public func showConfirmation(
        title: String,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let config = DialogConfiguration.Builder()
            .setTitle(title)
            .setSubtitle(message)
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
                self.dismissCurrentDialog()
            })
            .setPriority(.normal)
            .build()
        
        show(configuration: config)
    }
    
    /// Show error dialog / 显示错误对话框
    /// - Parameters:
    ///   - title: Error title / 错误标题
    ///   - error: Error object / 错误对象
    ///   - onDismiss: Dismiss handler / 关闭处理器
    public func showError(
        title: String = "Error",
        error: Error,
        onDismiss: (() -> Void)? = nil
    ) {
        let config = DialogConfiguration.Builder()
            .setTitle(title)
            .setTextContent(error.localizedDescription)
            .addButton(DialogButton(
                title: "OK",
                style: .destructive,
                actionStrategy: DismissActionStrategy(additionalAction: onDismiss)
            ))
            .setPriority(.high)
            .setAnimationStyle(.spring)
            .build()
        
        show(configuration: config)
    }
    
    /// Show loading dialog / 显示加载对话框
    /// - Parameters:
    ///   - title: Loading title / 加载标题
    ///   - message: Loading message / 加载消息
    /// - Returns: Dialog ID for later dismissal / 用于稍后关闭的对话框ID
    @discardableResult
    public func showLoading(
        title: String = "Loading",
        message: String? = nil
    ) -> UUID {
        let config = DialogConfiguration.Builder()
            .setTitle(title)
            .setSubtitle(message)
            .setContent(.customView(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            ))
            .setShowCloseButton(false)
            .setDismissOnTapOutside(false)
            .setPriority(.high)
            .build()
        
        show(configuration: config)
        return config.id
    }
    
    /// Dismiss loading dialog / 关闭加载对话框
    /// - Parameter id: Dialog ID / 对话框ID
    public func dismissLoading(id: UUID) {
        if currentDialog?.id == id {
            dismissCurrentDialog()
        } else {
            queue.remove(byId: id)
        }
    }
    
    // MARK: - Public Methods - Custom Content / 公共方法 - 自定义内容
    
    /// Show dialog with custom view / 显示带自定义视图的对话框
    /// - Parameters:
    ///   - title: Dialog title / 对话框标题
    ///   - view: Custom view / 自定义视图
    ///   - buttons: Dialog buttons / 对话框按钮
    ///   - priority: Dialog priority / 对话框优先级
    public func showCustom<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content,
        buttons: [DialogButton] = [DialogButton.ok()],
        priority: DialogPriority = .normal
    ) {
        let config = DialogConfiguration.Builder()
            .setTitle(title)
            .setContent(.customView(content()))
            .setButtons(buttons)
            .setPriority(priority)
            .build()
        
        show(configuration: config)
    }
    
    // MARK: - Private Methods / 私有方法
    
    /// Setup Combine bindings / 设置Combine绑定
    private func setupBindings() {
        // Monitor queue changes / 监控队列变化
        queue.$isEmpty
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.handleEmptyQueue()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Process dialog queue / 处理对话框队列
    private func processQueue() {
        // Check if already presenting / 检查是否已经在展示
        guard !isPresented else {
            return
        }
        
        // Get next dialog from queue / 从队列中获取下一个对话框
        guard let nextItem = queue.dequeue() else {
            isProcessingQueue = false
            return
        }
        
        isProcessingQueue = true
        
        // Present the dialog / 展示对话框
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentDialog = nextItem.configuration
            
            withAnimation(nextItem.configuration.animationStyle.animation) {
                self.isPresented = true
            }
            
            // Execute completion if dialog has it / 如果对话框有完成处理器则执行
            if let completion = nextItem.completion {
                // Store completion for when dialog is dismissed / 存储完成处理器以便对话框关闭时使用
                self.setupDismissalHandler(for: nextItem.configuration.id, completion: completion)
            }
        }
    }
    
    /// Handle empty queue / 处理空队列
    private func handleEmptyQueue() {
        isProcessingQueue = false
    }
    
    /// Setup dismissal handler for dialog / 为对话框设置关闭处理器
    /// - Parameters:
    ///   - id: Dialog ID / 对话框ID
    ///   - completion: Completion handler / 完成处理器
    private func setupDismissalHandler(for id: UUID, completion: @escaping () -> Void) {
        // Monitor when this specific dialog is dismissed / 监控特定对话框何时关闭
        $currentDialog
            .sink { dialog in
                if dialog?.id != id {
                    completion()
                    // Note: Subscription will be automatically removed when needed
                    // 注意：订阅将在需要时自动移除
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Queue Information / 队列信息
    
    /// Get queue statistics / 获取队列统计
    /// - Returns: Queue statistics / 队列统计
    public func getQueueStatistics() -> DialogQueue.Statistics {
        return queue.getStatistics()
    }
    
    /// Check if has pending dialogs / 检查是否有待处理的对话框
    /// - Returns: True if queue has dialogs / 如果队列有对话框返回true
    public var hasPendingDialogs: Bool {
        return !queue.isEmpty
    }
    
    /// Get pending dialog count / 获取待处理对话框数量
    /// - Returns: Number of pending dialogs / 待处理对话框的数量
    public var pendingDialogCount: Int {
        return queue.count
    }
}

// MARK: - Dialog Manager State / 对话框管理器状态
extension DialogManager {
    /// Dialog manager state / 对话框管理器状态
    public struct State {
        /// Is presenting dialog / 是否正在展示对话框
        public let isPresenting: Bool
        
        /// Current dialog configuration / 当前对话框配置
        public let currentDialog: DialogConfiguration?
        
        /// Pending dialog count / 待处理对话框数量
        public let pendingCount: Int
        
        /// Queue statistics / 队列统计
        public let queueStatistics: DialogQueue.Statistics
    }
    
    /// Get current state / 获取当前状态
    /// - Returns: Current dialog manager state / 当前对话框管理器状态
    public var state: State {
        return State(
            isPresenting: isPresented,
            currentDialog: currentDialog,
            pendingCount: pendingDialogCount,
            queueStatistics: getQueueStatistics()
        )
    }
}

// MARK: - Debugging / 调试
extension DialogManager: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        DialogManager:
        - Is Presented: \(isPresented)
        - Current Dialog: \(currentDialog?.title ?? "None")
        - Queue Count: \(pendingDialogCount)
        - Is Processing: \(isProcessingQueue)
        """
    }
}