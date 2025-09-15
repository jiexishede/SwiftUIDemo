//
//  DialogDemoFeature.swift
//  ReduxSwiftUIDemo
//
//  TCA feature for dialog system demonstration
//  对话框系统演示的TCA功能
//
//  Created by AI Assistant on 2025/1/12.
//

import ComposableArchitecture
import SwiftUI

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Reducer Pattern (TCA) (归约器模式)
 *    - Why: Manages state changes in a predictable, testable way / 为什么：以可预测、可测试的方式管理状态变化
 *    - Benefits: Unidirectional data flow, time-travel debugging, testability / 好处：单向数据流，时间旅行调试，可测试性
 */

// MARK: - Dialog Demo Feature / 对话框演示功能
@Reducer
public struct DialogDemoFeature {
    // MARK: - State / 状态
    
    /// Feature state / 功能状态
    @ObservableState
    public struct State: Equatable {
        /// Selected dialog type for demo / 演示的选定对话框类型
        var selectedDialogType: DialogType?
        
        /// Custom dialog configuration / 自定义对话框配置
        var customDialogConfig: DialogConfiguration?
        
        /// Show custom dialog / 显示自定义对话框
        var showCustomDialog: Bool = false
        
        /// Input text from input dialog / 输入对话框的输入文本
        var inputText: String = ""
        
        /// Demo result message / 演示结果消息
        var resultMessage: String = ""
        
        /// Loading state / 加载状态
        var isLoading: Bool = false
        
        /// Active bottom sheet / 活动的底部弹窗
        var activeSheet: BottomSheetType? = nil
        
        /// Initialize state / 初始化状态
        public init() {}
    }
    
    /// Bottom sheet types / 底部弹窗类型
    public enum BottomSheetType: String, CaseIterable {
        case minimal = "Minimal"
        case smallTable = "Small Table"
        case tableView = "Table View"
        case largeList = "Large List"
        case formView = "Form View"
        case chartView = "Chart View"
        case mediaGallery = "Media Gallery"
        case settings = "Settings"
        case userProfile = "User Profile"
        case longContent = "Long Content"
        // New dynamic height demos / 新的动态高度演示
        case expandableContent = "Expandable Content"
        case dynamicForm = "Dynamic Form"
        case asyncLoading = "Async Loading"
        case nestedScrolls = "Nested Scrolls"
        case mixedContent = "Mixed Content"
    }
    
    // MARK: - Action / 动作
    
    /// Feature actions / 功能动作
    public enum Action: Equatable {
        /// Show specific dialog type / 显示特定对话框类型
        case showDialog(DialogType)
        
        /// Handle dialog result / 处理对话框结果
        case handleDialogResult(String)
        
        /// Clear result message / 清除结果消息
        case clearResult
        
        /// Toggle loading state / 切换加载状态
        case toggleLoading
        
        /// Show custom configured dialog / 显示自定义配置的对话框
        case showCustomDialog
        
        /// Dismiss custom dialog / 关闭自定义对话框
        case dismissCustomDialog
        
        /// Show bottom sheet / 显示底部弹窗
        case showBottomSheet(BottomSheetType)
        
        /// Dismiss bottom sheet / 关闭底部弹窗
        case dismissBottomSheet
    }
    
    // MARK: - Dialog Type / 对话框类型
    
    /// Available dialog types for demo / 演示的可用对话框类型
    public enum DialogType: String, CaseIterable {
        case alert = "Alert"
        case confirm = "Confirmation"
        case input = "Input"
        case error = "Error"
        case loading = "Loading"
        case success = "Success"
        case warning = "Warning"
        case options = "Options"
        case custom = "Custom"
        case queue = "Queue Demo"
        case multipleDefer = "Multiple Defer Demo"
        case actionSheet = "Action Sheet"
        case fullScreen = "Full Screen"
        case customPopup = "Custom Popup"
        
        /// Icon for dialog type / 对话框类型的图标
        var icon: String {
            switch self {
            case .alert: return "exclamationmark.bubble"
            case .confirm: return "questionmark.circle"
            case .input: return "text.cursor"
            case .error: return "xmark.circle"
            case .loading: return "arrow.clockwise"
            case .success: return "checkmark.circle"
            case .warning: return "exclamationmark.triangle"
            case .options: return "list.bullet"
            case .custom: return "slider.horizontal.3"
            case .queue: return "rectangle.stack"
            case .multipleDefer: return "arrow.uturn.backward.circle"
            case .actionSheet: return "rectangle.grid.1x2"
            case .fullScreen: return "rectangle.fill"
            case .customPopup: return "sparkles"
            }
        }
        
        /// Description for dialog type / 对话框类型的描述
        var description: String {
            switch self {
            case .alert: return "Basic alert dialog / 基本警报对话框"
            case .confirm: return "Confirmation with actions / 带动作的确认"
            case .input: return "Text input dialog / 文本输入对话框"
            case .error: return "Error presentation / 错误展示"
            case .loading: return "Loading indicator / 加载指示器"
            case .success: return "Success notification / 成功通知"
            case .warning: return "Warning message / 警告消息"
            case .options: return "Multiple options / 多个选项"
            case .custom: return "Custom configuration / 自定义配置"
            case .queue: return "Queue management demo / 队列管理演示"
            case .multipleDefer: return "Swift defer-like LIFO demo / Swift defer式LIFO演示"
            case .actionSheet: return "iOS action sheet / iOS 操作表"
            case .fullScreen: return "Full screen modal / 全屏模态弹窗"
            case .customPopup: return "Custom popup style / 自定义弹出样式"
            }
        }
    }
    
    // MARK: - Reducer / 归约器
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showDialog(let type):
                state.selectedDialogType = type
                showDialogForType(type, state: &state)
                return .none
                
            case .handleDialogResult(let result):
                state.resultMessage = result
                return .none
                
            case .clearResult:
                state.resultMessage = ""
                return .none
                
            case .toggleLoading:
                state.isLoading.toggle()
                if state.isLoading {
                    // Simulate loading for 3 seconds / 模拟加载3秒
                    return .run { send in
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        await send(.toggleLoading)
                        await send(.handleDialogResult("Loading completed / 加载完成"))
                    }
                }
                return .none
                
            case .showCustomDialog:
                state.showCustomDialog = true
                state.customDialogConfig = createCustomDialogConfiguration()
                return .none
                
            case .dismissCustomDialog:
                state.showCustomDialog = false
                state.customDialogConfig = nil
                return .none
                
            case .showBottomSheet(let type):
                state.activeSheet = type
                return .none
                
            case .dismissBottomSheet:
                state.activeSheet = nil
                return .none
            }
        }
    }
    
    // MARK: - Private Methods / 私有方法
    
    /// Show dialog for specific type / 显示特定类型的对话框
    private func showDialogForType(_ type: DialogType, state: inout State) {
        switch type {
        case .alert:
            showAlertDialog()
            
        case .confirm:
            showConfirmationDialog(state: &state)
            
        case .input:
            showInputDialog(state: &state)
            
        case .error:
            showErrorDialog()
            
        case .loading:
            showLoadingDialog()
            
        case .success:
            showSuccessDialog()
            
        case .warning:
            showWarningDialog()
            
        case .options:
            showOptionsDialog(state: &state)
            
        case .custom:
            state.showCustomDialog = true
            state.customDialogConfig = createCustomDialogConfiguration()
            
        case .queue:
            showQueueDemo()
            
        case .multipleDefer:
            showMultipleDeferDemo()
            
        case .actionSheet:
            showActionSheetDialog(state: &state)
            
        case .fullScreen:
            showFullScreenDialog(state: &state)
            
        case .customPopup:
            showCustomPopupDialog(state: &state)
        }
    }
    
    /// Show alert dialog / 显示警报对话框
    private func showAlertDialog() {
        DialogManager.shared.showAlert(
            title: "Alert Demo / 警报演示",
            message: "This is a basic alert dialog / 这是一个基本的警报对话框",
            buttonTitle: "Got it / 知道了"
        )
    }
    
    /// Show confirmation dialog / 显示确认对话框
    private func showConfirmationDialog(state: inout State) {
        let confirm = ConfirmationDialogTemplate(
            title: "Delete Item? / 删除项目？",
            message: "This action cannot be undone / 此操作无法撤消",
            confirmTitle: "Delete / 删除",
            cancelTitle: "Cancel / 取消",
            isDestructive: true,
            onConfirm: {
                DialogManager.shared.showAlert(
                    title: "Deleted / 已删除",
                    message: "Item has been deleted / 项目已被删除"
                )
            }
        )
        DialogManager.shared.show(configuration: confirm.configuration)
    }
    
    /// Show input dialog / 显示输入对话框
    private func showInputDialog(state: inout State) {
        let input = InputDialogTemplate(
            title: "Enter Your Name / 输入您的名字",
            message: "Please enter your name below / 请在下方输入您的名字",
            placeholder: "Your name / 您的名字",
            validation: { text in
                !text.isEmpty && text.count >= 2
            },
            onSubmit: { name in
                DialogManager.shared.showAlert(
                    title: "Hello, \(name)!",
                    message: "Nice to meet you / 很高兴见到你"
                )
            }
        )
        DialogManager.shared.show(configuration: input.configuration)
    }
    
    /// Show error dialog / 显示错误对话框
    private func showErrorDialog() {
        struct DemoError: LocalizedError {
            var errorDescription: String? {
                "Something went wrong. Please try again later. / 出了点问题。请稍后再试。"
            }
        }
        
        DialogManager.shared.showError(
            title: "Error Occurred / 发生错误",
            error: DemoError()
        )
    }
    
    /// Show loading dialog / 显示加载对话框
    private func showLoadingDialog() {
        let loadingId = DialogManager.shared.showLoading(
            title: "Processing / 处理中",
            message: "Please wait... / 请稍候..."
        )
        
        // Auto-dismiss after 3 seconds / 3秒后自动关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            DialogManager.shared.dismissLoading(id: loadingId)
            DialogManager.shared.showAlert(
                title: "Complete / 完成",
                message: "Processing finished / 处理完成"
            )
        }
    }
    
    /// Show success dialog / 显示成功对话框
    private func showSuccessDialog() {
        let alert = AlertDialogTemplate(
            title: "Success! / 成功！",
            message: "Operation completed successfully / 操作成功完成",
            style: .success
        )
        DialogManager.shared.show(configuration: alert.configuration)
    }
    
    /// Show warning dialog / 显示警告对话框
    private func showWarningDialog() {
        let alert = AlertDialogTemplate(
            title: "Warning / 警告",
            message: "Low storage space available / 可用存储空间不足",
            style: .warning
        )
        DialogManager.shared.show(configuration: alert.configuration)
    }
    
    /// Show options dialog / 显示选项对话框
    private func showOptionsDialog(state: inout State) {
        let options = OptionsDialogTemplate(
            title: "Choose Action / 选择操作",
            message: "What would you like to do? / 您想做什么？",
            options: [
                .init(
                    title: "Edit / 编辑",
                    icon: Image(systemName: "pencil"),
                    action: {
                        DialogManager.shared.showAlert(title: "Edit selected / 已选择编辑")
                    }
                ),
                .init(
                    title: "Share / 分享",
                    icon: Image(systemName: "square.and.arrow.up"),
                    action: {
                        DialogManager.shared.showAlert(title: "Share selected / 已选择分享")
                    }
                ),
                .init(
                    title: "Delete / 删除",
                    icon: Image(systemName: "trash"),
                    style: .destructive,
                    action: {
                        DialogManager.shared.showAlert(title: "Delete selected / 已选择删除")
                    }
                )
            ]
        )
        DialogManager.shared.show(configuration: options.configuration)
    }
    
    /// Show queue demo / 显示队列演示
    private func showQueueDemo() {
        // Create 10+ dialogs with different priorities to demonstrate queue management
        // 创建10个以上不同优先级的对话框来演示队列管理
        
        // 1. Deferred dialog (will show last) / 延迟对话框（最后显示）
        let deferredConfig = DialogConfiguration.Builder()
            .setTitle("1. Deferred (最后) 💤")
            .setTextContent("This dialog uses defer priority, shown last like Swift defer / 这个对话框使用延迟优先级，像Swift defer一样最后显示")
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showDeferred(configuration: deferredConfig)
        
        // 2. Low priority dialog / 低优先级对话框
        let lowConfig1 = DialogConfiguration.Builder()
            .setTitle("2. Low Priority #1 / 低优先级 #1 🟢")
            .setTextContent("Order: 2, Priority: Low / 顺序：2，优先级：低")
            .addButton(DialogButton.ok())
            .setPriority(.low)
            .build()
        DialogManager.shared.show(configuration: lowConfig1)
        
        // 3. Normal priority dialog / 正常优先级对话框
        let normalConfig1 = DialogConfiguration.Builder()
            .setTitle("3. Normal Priority #1 / 正常优先级 #1 🔵")
            .setTextContent("Order: 3, Priority: Normal / 顺序：3，优先级：正常")
            .addButton(DialogButton.ok())
            .setPriority(.normal)
            .build()
        DialogManager.shared.show(configuration: normalConfig1)
        
        // 4. High priority dialog / 高优先级对话框
        let highConfig1 = DialogConfiguration.Builder()
            .setTitle("4. High Priority #1 / 高优先级 #1 🟠")
            .setTextContent("Order: 4, Priority: High / 顺序：4，优先级：高")
            .addButton(DialogButton.ok())
            .setPriority(.high)
            .build()
        DialogManager.shared.show(configuration: highConfig1)
        
        // 5. Critical priority dialog / 关键优先级对话框
        let criticalConfig = DialogConfiguration.Builder()
            .setTitle("5. Critical Priority / 关键优先级 🔴")
            .setTextContent("Order: 5, Priority: Critical / 顺序：5，优先级：关键")
            .addButton(DialogButton.ok())
            .setPriority(.critical)
            .build()
        DialogManager.shared.show(configuration: criticalConfig)
        
        // 6. Another low priority / 另一个低优先级
        let lowConfig2 = DialogConfiguration.Builder()
            .setTitle("6. Low Priority #2 / 低优先级 #2 🟢")
            .setTextContent("Order: 6, Priority: Low / 顺序：6，优先级：低")
            .addButton(DialogButton.ok())
            .setPriority(.low)
            .build()
        DialogManager.shared.show(configuration: lowConfig2)
        
        // 7. Another normal priority / 另一个正常优先级
        let normalConfig2 = DialogConfiguration.Builder()
            .setTitle("7. Normal Priority #2 / 正常优先级 #2 🔵")
            .setTextContent("Order: 7, Priority: Normal / 顺序：7，优先级：正常")
            .addButton(DialogButton.ok())
            .setPriority(.normal)
            .build()
        DialogManager.shared.show(configuration: normalConfig2)
        
        // 8. Another high priority / 另一个高优先级
        let highConfig2 = DialogConfiguration.Builder()
            .setTitle("8. High Priority #2 / 高优先级 #2 🟠")
            .setTextContent("Order: 8, Priority: High / 顺序：8，优先级：高")
            .addButton(DialogButton.ok())
            .setPriority(.high)
            .build()
        DialogManager.shared.show(configuration: highConfig2)
        
        // 9. Immediate priority (will show first) / 立即优先级（首先显示）
        let immediateConfig = DialogConfiguration.Builder()
            .setTitle("9. Immediate (首先) ⚡")
            .setTextContent("This dialog uses immediate priority, shown first / 这个对话框使用立即优先级，首先显示")
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showImmediate(configuration: immediateConfig)
        
        // 10. Another deferred / 另一个延迟
        let deferredConfig2 = DialogConfiguration.Builder()
            .setTitle("10. Deferred #2 (最后) 💤")
            .setTextContent("Order: 10, Another defer priority / 顺序：10，另一个延迟优先级")
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showDeferred(configuration: deferredConfig2)
        
        // Show summary dialog with normal priority
        // 用正常优先级显示摘要对话框
        DialogManager.shared.showAlert(
            title: "Queue Demo Started / 队列演示已开始 📊",
            message: """
            Added 10 dialogs with different priorities:
            添加了10个不同优先级的对话框：
            
            Expected order / 预期顺序:
            1. Immediate (⚡)
            2. Critical (🔴)
            3. High #1, #2 (🟠)
            4. Normal #1, #2 (🔵)
            5. Low #1, #2 (🟢)
            6. Summary (this)
            7. Deferred #1, #2 (💤)
            
            Watch them appear in priority order!
            观察它们按优先级顺序出现！
            """,
            buttonTitle: "Start / 开始"
        )
    }
    
    /// Show multiple defer demo (LIFO behavior like Swift defer) / 显示多个defer演示（像Swift defer的LIFO行为）
    private func showMultipleDeferDemo() {
        // This simulates Swift's defer behavior:
        // 这模拟了Swift的defer行为：
        // func example() {
        //     defer { print("3") }  // Executes third
        //     defer { print("2") }  // Executes second
        //     defer { print("1") }  // Executes first
        //     print("0")           // Executes immediately
        // }
        // Output: 0, 1, 2, 3
        
        // Add immediate dialog (executes first) / 添加立即对话框（首先执行）
        DialogManager.shared.showAlert(
            title: "Step 0: Function Start / 步骤0：函数开始 ▶️",
            message: "This executes immediately, like normal code / 这立即执行，像普通代码",
            buttonTitle: "Next / 下一个"
        )
        
        // Add first defer (will execute last - #3) / 添加第一个defer（最后执行 - #3）
        let defer1 = DialogConfiguration.Builder()
            .setTitle("Defer #1 (Step 3) / Defer #1（步骤3）🔴")
            .setTextContent("""
                First defer added, but executes LAST!
                第一个添加的defer，但最后执行！
                
                Like: defer { print("3") }
                """)
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showDeferred(configuration: defer1)
        
        // Add second defer (will execute second to last - #2) / 添加第二个defer（倒数第二执行 - #2）
        let defer2 = DialogConfiguration.Builder()
            .setTitle("Defer #2 (Step 2) / Defer #2（步骤2）🟠")
            .setTextContent("""
                Second defer added, executes SECOND!
                第二个添加的defer，第二个执行！
                
                Like: defer { print("2") }
                """)
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showDeferred(configuration: defer2)
        
        // Add third defer (will execute third to last - #1) / 添加第三个defer（倒数第三执行 - #1）
        let defer3 = DialogConfiguration.Builder()
            .setTitle("Defer #3 (Step 1) / Defer #3（步骤1）🟡")
            .setTextContent("""
                Third defer added, but executes FIRST of defers!
                第三个添加的defer，但在defer中首先执行！
                
                Like: defer { print("1") }
                """)
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showDeferred(configuration: defer3)
        
        // Add fourth defer to demonstrate LIFO clearly / 添加第四个defer来清楚地演示LIFO
        let defer4 = DialogConfiguration.Builder()
            .setTitle("Defer #4 (Cleanup) / Defer #4（清理）🟢")
            .setTextContent("""
                Last defer added, executes first of all defers!
                最后添加的defer，在所有defer中首先执行！
                
                This is like cleanup code in Swift defer.
                这就像Swift defer中的清理代码。
                """)
            .addButton(DialogButton.ok())
            .build()
        DialogManager.shared.showDeferred(configuration: defer4)
        
        // Add a normal priority dialog to show it comes before defers
        // 添加一个正常优先级的对话框来显示它在defer之前
        DialogManager.shared.showAlert(
            title: "Normal Priority / 正常优先级 🔵",
            message: """
                This shows BEFORE all defers
                这在所有defer之前显示
                
                Order: Immediate → Normal → Defers (LIFO)
                顺序：立即 → 正常 → Defers（LIFO）
                """,
            buttonTitle: "Continue / 继续"
        )
        
        // Summary dialog with high priority / 高优先级的摘要对话框
        let summaryConfig = DialogConfiguration.Builder()
            .setTitle("Multiple Defer Demo / 多个Defer演示 📚")
            .setTextContent("""
                Added 4 defer dialogs + 2 normal dialogs
                添加了4个defer对话框 + 2个普通对话框
                
                Expected order / 预期顺序:
                1. This summary (High) / 本摘要（高）
                2. Function Start (Normal) / 函数开始（正常）
                3. Normal Priority / 正常优先级
                4. Defer #4 (Last added, First executed) / 最后添加，首先执行
                5. Defer #3 (Third added, Second executed) / 第三个添加，第二个执行
                6. Defer #2 (Second added, Third executed) / 第二个添加，第三个执行
                7. Defer #1 (First added, Last executed) / 第一个添加，最后执行
                
                Just like Swift's defer: LIFO (Last In, First Out)!
                就像Swift的defer：LIFO（后进先出）！
                """)
            .addButton(DialogButton(title: "Start Demo / 开始演示", style: .default) {
                print("Multiple defer demo started / 多个defer演示已开始")
            })
            .setPriority(.high)
            .build()
        DialogManager.shared.show(configuration: summaryConfig)
    }
    
    /// Create custom dialog configuration / 创建自定义对话框配置
    private func createCustomDialogConfiguration() -> DialogConfiguration {
        return DialogConfiguration.Builder()
            .setTitle("Custom Dialog / 自定义对话框")
            .setSubtitle("Fully customizable / 完全可自定义")
            .setContent(.customView(
                VStack(spacing: 20) {
                    Image(systemName: "paintbrush.pointed")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("This is a custom dialog with custom content and styling / 这是一个带有自定义内容和样式的自定义对话框")
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 10) {
                        ForEach(0..<5) { i in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding()
            ))
            .addButton(DialogButton(
                title: "Cool! / 很酷！",
                style: .custom(background: .purple, foreground: .white),
                icon: Image(systemName: "hand.thumbsup")
            ) {
                DialogManager.shared.dismissCurrentDialog()
            })
            .setCornerRadius(20)
            .setShadowRadius(15)
            .setDismissOnDrag(true)
            .build()
    }
    
    /// Show action sheet dialog / 显示操作表对话框
    private func showActionSheetDialog(state: inout State) {
        let actionSheet = OptionsDialogTemplate(
            title: "选择操作 / Choose Action",
            message: "您想要执行什么操作？/ What would you like to do?",
            options: [
                .init(
                    title: "拍照 / Take Photo",
                    icon: Image(systemName: "camera"),
                    action: {
                        DialogManager.shared.showAlert(
                            title: "Camera",
                            message: "Camera opened / 相机已打开"
                        )
                    }
                ),
                .init(
                    title: "从相册选择 / Choose from Library",
                    icon: Image(systemName: "photo.on.rectangle"),
                    action: {
                        DialogManager.shared.showAlert(
                            title: "Photo Library",
                            message: "Photo library opened / 相册已打开"
                        )
                    }
                ),
                .init(
                    title: "删除照片 / Delete Photo",
                    icon: Image(systemName: "trash"),
                    style: .destructive,
                    action: {
                        DialogManager.shared.showAlert(
                            title: "Delete",
                            message: "Photo deleted / 照片已删除"
                        )
                    }
                )
            ]
        )
        DialogManager.shared.show(configuration: actionSheet.configuration)
    }
    
    /// Show full screen dialog / 显示全屏对话框
    private func showFullScreenDialog(state: inout State) {
        let fullScreen = DialogConfiguration.Builder()
            .setTitle("全屏模态 / Full Screen Modal")
            .setContent(.customView(
                VStack(spacing: 20) {
                    Image(systemName: "rectangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.teal)
                    
                    Text("这是一个全屏模态弹窗")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This is a full screen modal dialog")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("全屏弹窗适合展示重要内容或需要用户专注的任务")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Full screen modals are good for important content or tasks requiring focus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        DialogManager.shared.dismissCurrentDialog()
                    }) {
                        Text("关闭 / Close")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
            ))
            .build()
        DialogManager.shared.show(configuration: fullScreen)
    }
    
    /// Show custom popup dialog / 显示自定义弹出对话框
    private func showCustomPopupDialog(state: inout State) {
        let popup = DialogConfiguration.Builder()
            .setTitle("✨ 自定义弹出 / Custom Popup")
            .setContent(.customView(
                VStack(spacing: 16) {
                    // Animated gradient background / 动画渐变背景
                    LinearGradient(
                        colors: [.pink, .purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 100)
                    .cornerRadius(12)
                    .overlay(
                        Text("🎨")
                            .font(.system(size: 50))
                    )
                    
                    Text("独特的视觉体验")
                        .font(.headline)
                    
                    Text("Unique Visual Experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            DialogManager.shared.dismissCurrentDialog()
                            DialogManager.shared.showAlert(
                                title: "Success",
                                message: "Liked! / 已点赞！"
                            )
                        }) {
                            Label("喜欢", systemImage: "heart.fill")
                                .foregroundColor(.pink)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            DialogManager.shared.dismissCurrentDialog()
                            DialogManager.shared.showAlert(
                                title: "Success",
                                message: "Shared! / 已分享！"
                            )
                        }) {
                            Label("分享", systemImage: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            ))
            .setAnimationStyle(.spring)
            .setCornerRadius(25)
            .setShadowRadius(20)
            .build()
        DialogManager.shared.show(configuration: popup)
    }
}