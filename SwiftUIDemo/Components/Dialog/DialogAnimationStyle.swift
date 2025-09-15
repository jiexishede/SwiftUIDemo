//
//  DialogAnimationStyle.swift
//  ReduxSwiftUIDemo
//
//  Dialog animation styles and transitions
//  对话框动画样式和过渡效果
//
//  Created by AI Assistant on 2025/1/12.
//

import SwiftUI

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Strategy Pattern (策略模式)
 *    - Why: Different animation styles require different transition implementations / 为什么：不同的动画样式需要不同的过渡实现
 *    - Benefits: Easy to add new animation styles, clean separation of animation logic / 好处：易于添加新的动画样式，动画逻辑的清晰分离
 *
 * 2. Factory Pattern (工厂模式)
 *    - Why: Creates appropriate transition and animation based on style / 为什么：根据样式创建适当的过渡和动画
 *    - Benefits: Centralized animation creation, consistent behavior / 好处：集中的动画创建，一致的行为
 */

// MARK: - Animation Style / 动画样式
/// Enum defining different animation styles for dialogs / 定义对话框不同动画样式的枚举
public enum DialogAnimationStyle: CaseIterable {
    /// Slide from bottom / 从底部滑入
    case slide
    
    /// Fade in/out / 淡入淡出
    case fade
    
    /// Scale from center / 从中心缩放
    case scale
    
    /// Spring animation / 弹簧动画
    case spring
    
    /// No animation / 无动画
    case none
    
    /// Custom animation with parameters / 带参数的自定义动画
    case custom(Animation)
    
    // CaseIterable conformance for non-associated value cases / 非关联值情况的CaseIterable一致性
    public static var allCases: [DialogAnimationStyle] {
        return [.slide, .fade, .scale, .spring, .none]
    }
    
    // MARK: - Animation Properties / 动画属性
    
    /// Get the SwiftUI Animation for this style / 获取此样式的SwiftUI动画
    public var animation: Animation {
        switch self {
        case .slide:
            return .easeInOut(duration: 0.3)
        case .fade:
            return .easeInOut(duration: 0.25)
        case .scale:
            return .spring(response: 0.35, dampingFraction: 0.8)
        case .spring:
            return .spring(response: 0.4, dampingFraction: 0.75)
        case .none:
            return .linear(duration: 0)
        case .custom(let animation):
            return animation
        }
    }
    
    /// Get the transition for this style / 获取此样式的过渡效果
    public var transition: AnyTransition {
        switch self {
        case .slide:
            return AnyTransition.move(edge: .bottom)
                .combined(with: .opacity)
        case .fade:
            return .opacity
        case .scale:
            return AnyTransition.scale(scale: 0.8)
                .combined(with: .opacity)
        case .spring:
            return AnyTransition.scale(scale: 0.9)
                .combined(with: .opacity)
        case .none:
            return .identity
        case .custom:
            return .opacity
        }
    }
    
    /// Duration of the animation / 动画持续时间
    public var duration: Double {
        switch self {
        case .slide:
            return 0.3
        case .fade:
            return 0.25
        case .scale:
            return 0.35
        case .spring:
            return 0.4
        case .none:
            return 0
        case .custom:
            return 0.3
        }
    }
}

// MARK: - Animation Modifier / 动画修饰符
/// ViewModifier for applying dialog animations / 用于应用对话框动画的ViewModifier
///
/// Example usage / 使用示例:
/// ```swift
/// dialogView
///     .modifier(DialogAnimationModifier(
///         isPresented: $isShowing,
///         style: .spring
///     ))
/// ```
public struct DialogAnimationModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Binding to presentation state / 绑定到展示状态
    @Binding var isPresented: Bool
    
    /// Animation style / 动画样式
    let style: DialogAnimationStyle
    
    /// Drag offset for drag-to-dismiss / 拖动关闭的拖动偏移
    @State private var dragOffset: CGSize = .zero
    
    /// Is dragging / 是否正在拖动
    @State private var isDragging: Bool = false
    
    /// Enable drag to dismiss / 启用拖动关闭
    let enableDragToDismiss: Bool
    
    // MARK: - Initializer / 初始化器
    
    /// Initialize the animation modifier / 初始化动画修饰符
    /// - Parameters:
    ///   - isPresented: Binding to presentation state / 绑定到展示状态
    ///   - style: Animation style / 动画样式
    ///   - enableDragToDismiss: Enable drag to dismiss / 启用拖动关闭
    public init(
        isPresented: Binding<Bool>,
        style: DialogAnimationStyle = .spring,
        enableDragToDismiss: Bool = false
    ) {
        self._isPresented = isPresented
        self.style = style
        self.enableDragToDismiss = enableDragToDismiss
    }
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        content
            .offset(y: dragOffset.height)
            .opacity(isDragging ? 0.8 : 1.0)
            .scaleEffect(isDragging ? 0.95 : 1.0)
            .gesture(
                enableDragToDismiss ? dragGesture : nil
            )
            .transition(style.transition)
            .animation(style.animation, value: isPresented)
            .animation(.spring(), value: dragOffset)
    }
    
    // MARK: - Drag Gesture / 拖动手势
    
    /// Drag gesture for drag-to-dismiss / 拖动关闭的拖动手势
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow downward dragging / 只允许向下拖动
                if value.translation.height > 0 {
                    dragOffset = value.translation
                    isDragging = true
                }
            }
            .onEnded { value in
                // Dismiss if dragged more than 100 points / 如果拖动超过100点则关闭
                if value.translation.height > 100 {
                    withAnimation(style.animation) {
                        isPresented = false
                    }
                }
                // Reset position / 重置位置
                withAnimation(.spring()) {
                    dragOffset = .zero
                    isDragging = false
                }
            }
    }
}

// MARK: - Backdrop Animation / 背景动画
/// ViewModifier for dialog backdrop animation / 对话框背景动画的ViewModifier
public struct DialogBackdropModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Is dialog presented / 对话框是否展示
    let isPresented: Bool
    
    /// Backdrop color / 背景颜色
    let backdropColor: Color
    
    /// Backdrop opacity / 背景不透明度
    let backdropOpacity: Double
    
    /// Tap to dismiss action / 点击关闭动作
    let onTapDismiss: (() -> Void)?
    
    // MARK: - Initializer / 初始化器
    
    /// Initialize backdrop modifier / 初始化背景修饰符
    /// - Parameters:
    ///   - isPresented: Is dialog presented / 对话框是否展示
    ///   - backdropColor: Backdrop color / 背景颜色
    ///   - backdropOpacity: Backdrop opacity / 背景不透明度
    ///   - onTapDismiss: Tap to dismiss action / 点击关闭动作
    public init(
        isPresented: Bool,
        backdropColor: Color = .black,
        backdropOpacity: Double = 0.3,
        onTapDismiss: (() -> Void)? = nil
    ) {
        self.isPresented = isPresented
        self.backdropColor = backdropColor
        self.backdropOpacity = backdropOpacity
        self.onTapDismiss = onTapDismiss
    }
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                backdropColor
                    .opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: isPresented)
                    .onTapGesture {
                        onTapDismiss?()
                    }
            }
        }
    }
}

// MARK: - Shake Animation / 摇动动画
/// ViewModifier for shake animation (e.g., for errors) / 摇动动画的ViewModifier（例如，用于错误）
public struct ShakeAnimationModifier: ViewModifier {
    // MARK: - Properties / 属性
    
    /// Number of shakes / 摇动次数
    let shakeCount: Int
    
    /// Animation trigger / 动画触发器
    @Binding var animationTrigger: Bool
    
    /// Current offset / 当前偏移
    @State private var offset: CGFloat = 0
    
    // MARK: - Body / 主体
    
    public func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: animationTrigger) { newValue in
                if newValue {
                    performShake()
                }
            }
    }
    
    // MARK: - Methods / 方法
    
    /// Perform shake animation / 执行摇动动画
    private func performShake() {
        withAnimation(
            Animation.linear(duration: 0.05)
                .repeatCount(shakeCount * 2, autoreverses: true)
        ) {
            offset = 10
        }
        
        // Reset after animation / 动画后重置
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(shakeCount) * 0.1) {
            offset = 0
            animationTrigger = false
        }
    }
}

// MARK: - Animation Extensions / 动画扩展
extension View {
    /// Apply dialog animation modifier / 应用对话框动画修饰符
    /// - Parameters:
    ///   - isPresented: Binding to presentation state / 绑定到展示状态
    ///   - style: Animation style / 动画样式
    ///   - enableDragToDismiss: Enable drag to dismiss / 启用拖动关闭
    /// - Returns: Modified view / 修改后的视图
    public func dialogAnimation(
        isPresented: Binding<Bool>,
        style: DialogAnimationStyle = .spring,
        enableDragToDismiss: Bool = false
    ) -> some View {
        modifier(DialogAnimationModifier(
            isPresented: isPresented,
            style: style,
            enableDragToDismiss: enableDragToDismiss
        ))
    }
    
    /// Apply dialog backdrop / 应用对话框背景
    /// - Parameters:
    ///   - isPresented: Is dialog presented / 对话框是否展示
    ///   - color: Backdrop color / 背景颜色
    ///   - opacity: Backdrop opacity / 背景不透明度
    ///   - onTapDismiss: Tap to dismiss action / 点击关闭动作
    /// - Returns: Modified view / 修改后的视图
    public func dialogBackdrop(
        isPresented: Bool,
        color: Color = .black,
        opacity: Double = 0.3,
        onTapDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(DialogBackdropModifier(
            isPresented: isPresented,
            backdropColor: color,
            backdropOpacity: opacity,
            onTapDismiss: onTapDismiss
        ))
    }
    
    /// Apply shake animation / 应用摇动动画
    /// - Parameters:
    ///   - trigger: Animation trigger binding / 动画触发器绑定
    ///   - shakeCount: Number of shakes / 摇动次数
    /// - Returns: Modified view / 修改后的视图
    public func shakeAnimation(
        trigger: Binding<Bool>,
        shakeCount: Int = 3
    ) -> some View {
        modifier(ShakeAnimationModifier(
            shakeCount: shakeCount,
            animationTrigger: trigger
        ))
    }
}