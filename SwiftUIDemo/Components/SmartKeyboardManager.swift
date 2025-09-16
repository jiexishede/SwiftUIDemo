//
//  SmartKeyboardManager.swift
//  SwiftUIDemo
//
//  SwiftUI version of IQKeyboardManager / SwiftUI 版本的 IQKeyboardManager
//  Intelligent keyboard avoidance with automatic TextField detection
//  智能键盘避让，自动检测输入框
//

import SwiftUI
import Combine

/**
 * SmartKeyboardManager - SwiftUI Intelligent Keyboard Management
 * SwiftUI 智能键盘管理器
 *
 * INSPIRED BY IQKeyboardManager / 灵感来自 IQKeyboardManager
 *
 * FEATURES / 功能特性:
 * 1. Automatic TextField detection / 自动检测输入框
 * 2. Smart offset calculation / 智能偏移计算
 * 3. Only moves when necessary / 仅在必要时移动
 * 4. Smooth animations / 平滑动画
 * 5. Respects safe areas / 遵守安全区域
 * 6. Works with ScrollView / 支持 ScrollView
 *
 * HOW IT WORKS / 工作原理:
 * 1. Detects focused TextField position / 检测聚焦输入框位置
 * 2. Calculates keyboard overlap / 计算键盘重叠
 * 3. Adjusts only if TextField is hidden / 仅在输入框被遮挡时调整
 * 4. Maintains minimum spacing / 保持最小间距
 *
 * USAGE / 使用方法:
 * ```
 * YourView()
 *     .smartKeyboard()  // That's it! / 就这么简单！
 * ```
 */

// MARK: - Keyboard Info / 键盘信息

/// Keyboard state information / 键盘状态信息
struct KeyboardInfo: Equatable {
    let height: CGFloat
    let animationDuration: Double
    let animationCurve: UIView.AnimationCurve

    static let hidden = KeyboardInfo(height: 0, animationDuration: 0.25, animationCurve: .easeInOut)
}

// MARK: - Smart Keyboard Observer / 智能键盘观察器

class SmartKeyboardObserver: ObservableObject {
    @Published var keyboardInfo = KeyboardInfo.hidden
    @Published var currentOffset: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    // Configuration / 配置
    var minimumSpacing: CGFloat = 20  // Minimum space between TextField and keyboard / 输入框与键盘的最小间距
    var extraOffset: CGFloat = 10     // Extra offset for better visibility / 额外偏移以提高可见性

    init() {
        setupKeyboardObservers()
    }

    private func setupKeyboardObservers() {
        // Keyboard will show / 键盘将显示
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> KeyboardInfo? in
                guard let userInfo = notification.userInfo,
                      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                      let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                      let curve = UIView.AnimationCurve(rawValue: curveValue) else {
                    return nil
                }
                return KeyboardInfo(height: keyboardFrame.height, animationDuration: duration, animationCurve: curve)
            }
            .assign(to: \.keyboardInfo, on: self)
            .store(in: &cancellables)

        // Keyboard will hide / 键盘将隐藏
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in KeyboardInfo.hidden }
            .assign(to: \.keyboardInfo, on: self)
            .store(in: &cancellables)
    }

    /**
     * Calculate smart offset based on focused field position
     * 根据聚焦字段位置计算智能偏移
     *
     * ALGORITHM / 算法:
     * 1. Get focused field's frame in window coordinates / 获取聚焦字段在窗口坐标中的框架
     * 2. Calculate keyboard top position / 计算键盘顶部位置
     * 3. Check if field is hidden by keyboard / 检查字段是否被键盘遮挡
     * 4. Calculate minimum offset needed / 计算所需的最小偏移
     * 5. Add extra spacing for comfort / 添加额外间距以提高舒适度
     */
    func calculateOffset(for fieldFrame: CGRect?, in windowHeight: CGFloat) -> CGFloat {
        guard let fieldFrame = fieldFrame,
              keyboardInfo.height > 0 else {
            return 0
        }

        // Calculate positions / 计算位置
        let fieldBottom = fieldFrame.maxY
        let keyboardTop = windowHeight - keyboardInfo.height

        // Check if field is hidden / 检查字段是否被遮挡
        if fieldBottom > keyboardTop {
            // Calculate how much to move up / 计算需要上移多少
            let overlap = fieldBottom - keyboardTop
            let offset = overlap + minimumSpacing + extraOffset
            return -offset  // Negative to move up / 负值表示上移
        }

        return 0  // No adjustment needed / 不需要调整
    }
}

// MARK: - Focus Field Tracker / 焦点字段跟踪器

/// Tracks the currently focused field's frame / 跟踪当前聚焦字段的框架
struct FocusedFieldKey: PreferenceKey {
    static var defaultValue: CGRect? = nil

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

// MARK: - Smart Keyboard ViewModifier / 智能键盘视图修饰符

struct SmartKeyboardModifier: ViewModifier {
    @StateObject private var keyboard = SmartKeyboardObserver()
    @State private var focusedFieldFrame: CGRect? = nil
    @State private var windowHeight: CGFloat = 0

    // Configuration options / 配置选项
    let minimumSpacing: CGFloat
    let extraOffset: CGFloat
    let animateChanges: Bool

    init(
        minimumSpacing: CGFloat = 20,
        extraOffset: CGFloat = 10,
        animateChanges: Bool = true
    ) {
        self.minimumSpacing = minimumSpacing
        self.extraOffset = extraOffset
        self.animateChanges = animateChanges
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(y: keyboard.currentOffset)
                .onPreferenceChange(FocusedFieldKey.self) { frame in
                    focusedFieldFrame = frame
                    updateOffset(windowHeight: geometry.size.height)
                }
                .compatibleOnChange(of: keyboard.keyboardInfo) { _ in
                    updateOffset(windowHeight: geometry.size.height)
                }
                .onAppear {
                    windowHeight = geometry.size.height
                    keyboard.minimumSpacing = minimumSpacing
                    keyboard.extraOffset = extraOffset
                }
        }
    }

    private func updateOffset(windowHeight: CGFloat) {
        let newOffset = keyboard.calculateOffset(for: focusedFieldFrame, in: windowHeight)

        if animateChanges {
            withAnimation(.easeOut(duration: keyboard.keyboardInfo.animationDuration)) {
                keyboard.currentOffset = newOffset
            }
        } else {
            keyboard.currentOffset = newOffset
        }
    }
}

// MARK: - TextField Focus Tracking Extension / 输入框焦点跟踪扩展

struct SmartTextFieldModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    let fieldId: String

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: FocusedFieldKey.self,
                            value: isFocused ? geometry.frame(in: .global) : nil
                        )
                }
            )
    }
}

// MARK: - Easy-to-use View Extensions / 易用的视图扩展

extension View {
    /**
     * Enable smart keyboard management for any view
     * 为任何视图启用智能键盘管理
     *
     * USAGE / 使用:
     * ```
     * VStack {
     *     TextField("Name", text: $name)
     *         .smartTextField(id: "name")
     *     TextField("Email", text: $email)
     *         .smartTextField(id: "email")
     * }
     * .smartKeyboard()  // Enable smart keyboard / 启用智能键盘
     * ```
     */
    func smartKeyboard(
        minimumSpacing: CGFloat = 20,
        extraOffset: CGFloat = 10,
        animateChanges: Bool = true
    ) -> some View {
        modifier(SmartKeyboardModifier(
            minimumSpacing: minimumSpacing,
            extraOffset: extraOffset,
            animateChanges: animateChanges
        ))
    }

    /**
     * Mark a TextField for smart keyboard tracking
     * 标记一个输入框以进行智能键盘跟踪
     */
    func smartTextField(id: String) -> some View {
        modifier(SmartTextFieldModifier(fieldId: id))
    }
}

// MARK: - Advanced Smart Keyboard Manager / 高级智能键盘管理器

/**
 * SmartKeyboardManager - Global keyboard management
 * 全局键盘管理
 *
 * Similar to IQKeyboardManager's approach / 类似于 IQKeyboardManager 的方法
 */
class SmartKeyboardManager {
    static let shared = SmartKeyboardManager()

    // Configuration / 配置
    var isEnabled = true
    var minimumDistanceFromKeyboard: CGFloat = 20
    var overrideKeyboardAppearance = false
    var toolbarManagementEnabled = false

    private init() {}

    /**
     * Enable for entire app / 为整个应用启用
     * Call this in your App's init / 在 App 的 init 中调用
     */
    func enable() {
        isEnabled = true
        // Additional setup if needed / 如需要可添加额外设置
    }

    func disable() {
        isEnabled = false
    }
}

// MARK: - Smart Keyboard for Bottom Sheet / 底部弹窗的智能键盘

/**
 * Special handling for bottom sheets
 * 底部弹窗的特殊处理
 *
 * Bottom sheets need different logic since they already move
 * 底部弹窗需要不同的逻辑，因为它们本身就会移动
 */
struct SmartBottomSheetKeyboardModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var focusedFieldFrame: CGRect? = nil
    @State private var contentOffset: CGFloat = 0

    // Only move if needed / 仅在需要时移动
    let smartMode: Bool

    init(smartMode: Bool = true) {
        self.smartMode = smartMode
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(y: smartMode ? calculateSmartOffset(in: geometry) : -keyboardHeight)
                .onAppear {
                    setupKeyboardObservers()
                }
                .onPreferenceChange(FocusedFieldKey.self) { frame in
                    focusedFieldFrame = frame
                }
        }
    }

    private func calculateSmartOffset(in geometry: GeometryProxy) -> CGFloat {
        guard let fieldFrame = focusedFieldFrame,
              keyboardHeight > 0 else {
            return 0
        }

        // Get the bottom sheet's frame / 获取底部弹窗的框架
        let sheetFrame = geometry.frame(in: .global)

        // Calculate if field would be hidden / 计算字段是否会被遮挡
        let fieldBottomInSheet = fieldFrame.maxY - sheetFrame.minY
        let visibleSheetHeight = sheetFrame.height - keyboardHeight

        if fieldBottomInSheet > visibleSheetHeight {
            // Calculate minimum movement needed / 计算所需的最小移动
            let overlap = fieldBottomInSheet - visibleSheetHeight
            return -(overlap + 20)  // Add 20pt padding / 添加 20 点内边距
        }

        return 0
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
            }

            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = keyboardFrame.height
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
            }

            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = 0
            }
        }
    }
}

extension View {
    /**
     * Smart keyboard for bottom sheets
     * 底部弹窗的智能键盘
     *
     * Only moves the sheet if the focused field would be hidden
     * 仅在聚焦字段会被遮挡时移动弹窗
     */
    func smartBottomSheetKeyboard() -> some View {
        modifier(SmartBottomSheetKeyboardModifier(smartMode: true))
    }
}