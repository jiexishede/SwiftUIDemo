//
//  DialogView.swift
//  ReduxSwiftUIDemo
//
//  Core dialog view component
//  核心对话框视图组件
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Composite Pattern (组合模式)
 *    - Why: Dialog is composed of multiple reusable components / 为什么：对话框由多个可重用组件组成
 *    - Benefits: Flexible composition, easy to customize parts / 好处：灵活的组合，易于自定义部分
 *
 * 2. Template Method Pattern (模板方法模式)
 *    - Why: Defines skeleton of dialog rendering with customizable parts / 为什么：定义对话框渲染的框架与可自定义部分
 *    - Benefits: Consistent structure, extensible behavior / 好处：一致的结构，可扩展的行为
 */

// MARK: - Dialog View / 对话框视图
/// Main dialog view component / 主要的对话框视图组件
///
/// Example usage / 使用示例:
/// ```swift
/// DialogView(
///     configuration: dialogConfig,
///     isPresented: $showDialog,
///     dialogManager: DialogManager.shared
/// )
/// ```
public struct DialogView: View {
    // MARK: - Properties / 属性
    
    /// Dialog configuration / 对话框配置
    let configuration: DialogConfiguration
    
    /// Binding to presentation state / 绑定到展示状态
    @Binding var isPresented: Bool
    
    /// Dialog manager instance / 对话框管理器实例
    let dialogManager: DialogManager
    
    /// Environment values / 环境值
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    /// State / 状态
    @State private var contentSize: CGSize = .zero
    @State private var keyboardHeight: CGFloat = 0
    @State private var shakeAnimation: Bool = false
    
    // MARK: - Computed Properties / 计算属性
    
    /// Background color based on color scheme / 基于配色方案的背景颜色
    private var backgroundColor: Color {
        #if canImport(UIKit)
        configuration.backgroundColor ?? (colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
        #else
        configuration.backgroundColor ?? (colorScheme == .dark ? Color.gray : .white)
        #endif
    }
    
    /// Foreground color based on color scheme / 基于配色方案的前景颜色
    private var foregroundColor: Color {
        configuration.foregroundColor ?? (colorScheme == .dark ? .white : .black)
    }
    
    /// Determine button layout / 确定按钮布局
    private var buttonLayout: DialogButtonLayout {
        DialogButtonLayout.automatic.actualLayout(for: configuration.buttons.count)
    }
    
    /// Calculate dialog width / 计算对话框宽度
    private var dialogWidth: CGFloat {
        // Adapt to size class / 适应尺寸类别
        #if canImport(UIKit)
        if horizontalSizeClass == .regular {
            return min(500, UIScreen.main.bounds.width * 0.6)
        } else {
            return UIScreen.main.bounds.width * 0.9
        }
        #else
        return 400
        #endif
    }
    
    // MARK: - Body / 主体
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Backdrop / 背景
                if configuration.dismissOnTapOutside {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissDialog()
                        }
                }
                
                // Dialog content / 对话框内容
                VStack(spacing: 0) {
                    dialogContent
                }
                .frame(width: dialogWidth)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(configuration.cornerRadius)
                .shadow(radius: configuration.shadowRadius)
                .overlay(alignment: .topTrailing) {
                    closeButtonOverlay
                }
                .dialogAnimation(
                    isPresented: $isPresented,
                    style: configuration.animationStyle,
                    enableDragToDismiss: configuration.dismissOnDrag
                )
                .shakeAnimation(trigger: $shakeAnimation)
                .offset(y: -keyboardHeight / 2)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
        }
        .onAppear {
            if configuration.isKeyboardAdaptive {
                subscribeToKeyboardEvents()
            }
        }
        .onDisappear {
            unsubscribeFromKeyboardEvents()
        }
    }
    
    // MARK: - Dialog Content / 对话框内容
    
    /// Main dialog content view / 主要对话框内容视图
    private var dialogContent: some View {
        VStack(spacing: 16) {
            // Header section / 头部部分
            headerSection
            
            // Content section / 内容部分
            if let content = configuration.content {
                contentSection(content: content)
            }
            
            // Buttons section / 按钮部分
            buttonsSection
        }
        .padding(20)
    }
    
    /// Header section with title and subtitle / 带标题和副标题的头部部分
    private var headerSection: some View {
        VStack(spacing: 8) {
            // Title / 标题
            Text(configuration.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Subtitle / 副标题
            if let subtitle = configuration.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    /// Content section / 内容部分
    /// - Parameter content: Dialog content / 对话框内容
    /// - Returns: Content view / 内容视图
    @ViewBuilder
    private func contentSection(content: DialogContent) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    switch content {
                    case .text(let text):
                        Text(text)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    case .custom(let view):
                        view
                    }
                }
                .frame(maxWidth: .infinity)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: ContentSizePreferenceKey.self,
                        value: geometry.size
                    )
                })
            }
            .frame(maxHeight: configuration.maxContentHeight ?? 300)
        }
        .onPreferenceChange(ContentSizePreferenceKey.self) { size in
            contentSize = size
        }
    }
    
    /// Buttons section / 按钮部分
    private var buttonsSection: some View {
        Group {
            switch buttonLayout {
            case .horizontal, .automatic:
                horizontalButtons
            case .vertical:
                verticalButtons
            }
        }
    }
    
    /// Horizontal button layout / 水平按钮布局
    private var horizontalButtons: some View {
        HStack(spacing: 12) {
            ForEach(configuration.buttons) { button in
                dialogButton(button)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// Vertical button layout / 垂直按钮布局
    private var verticalButtons: some View {
        VStack(spacing: 10) {
            ForEach(configuration.buttons) { button in
                dialogButton(button)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// Create button view / 创建按钮视图
    /// - Parameter button: Button configuration / 按钮配置
    /// - Returns: Button view / 按钮视图
    private func dialogButton(_ button: DialogButton) -> some View {
        Button(action: {
            handleButtonTap(button)
        }) {
            HStack(spacing: 8) {
                if let icon = button.icon {
                    icon
                        .font(.system(size: 16))
                }
                
                if button.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Text(button.title)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(button.style.backgroundColor)
            .foregroundColor(button.style.foregroundColor)
            .cornerRadius(8)
        }
        .disabled(!button.isEnabled || button.isLoading)
        .opacity(button.isEnabled ? 1.0 : 0.6)
    }
    
    /// Close button overlay / 关闭按钮覆盖层
    @ViewBuilder
    private var closeButtonOverlay: some View {
        if configuration.showCloseButton {
            Button(action: dismissDialog) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
            .padding(8)
            // Large tap area for easier dismissal / 更大的点击区域以便于关闭
            .contentShape(Rectangle().size(width: 44, height: 44))
        }
    }
    
    // MARK: - Methods / 方法
    
    /// Handle button tap / 处理按钮点击
    /// - Parameter button: Tapped button / 点击的按钮
    private func handleButtonTap(_ button: DialogButton) {
        // Execute button action / 执行按钮动作
        button.execute(with: dialogManager)
        
        // Auto-dismiss for certain button styles / 某些按钮样式的自动关闭
        switch button.style {
        case .cancel:
            dismissDialog()
        default:
            break
        }
    }
    
    /// Dismiss the dialog / 关闭对话框
    private func dismissDialog() {
        withAnimation(configuration.animationStyle.animation) {
            isPresented = false
        }
    }
    
    /// Subscribe to keyboard events / 订阅键盘事件
    private func subscribeToKeyboardEvents() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
        #endif
    }
    
    /// Unsubscribe from keyboard events / 取消订阅键盘事件
    private func unsubscribeFromKeyboardEvents() {
        #if canImport(UIKit)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        #endif
    }
}

// MARK: - Preference Key / 偏好键
/// Preference key for content size / 内容大小的偏好键
private struct ContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Preview Provider / 预览提供者
struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(
            configuration: DialogConfiguration.Builder()
                .setTitle("Sample Dialog")
                .setSubtitle("This is a subtitle")
                .setTextContent("This is the dialog content that can be quite long and will scroll if needed.")
                .addButton(DialogButton.cancel())
                .addButton(DialogButton.ok())
                .build(),
            isPresented: .constant(true),
            dialogManager: DialogManager.shared
        )
    }
}