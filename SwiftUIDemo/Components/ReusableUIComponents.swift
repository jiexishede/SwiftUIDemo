//
//  ReusableUIComponents.swift
//  SwiftUIDemo
//
//  Highly modular and reusable UI components library
//  高度模块化和可复用的 UI 组件库
//

import SwiftUI

/**
 * REUSABLE UI COMPONENTS LIBRARY
 * 可复用 UI 组件库
 * 
 * DESIGN PRINCIPLES / 设计原则:
 * 1. Single Responsibility - Each component does one thing well / 单一职责 - 每个组件只做好一件事
 * 2. Composability - Components can be combined / 可组合性 - 组件可以组合使用
 * 3. Customizability - Flexible configuration options / 可定制性 - 灵活的配置选项
 * 4. Consistency - Uniform API design / 一致性 - 统一的 API 设计
 * 5. Reusability - Zero duplication / 可复用性 - 零重复
 */

// MARK: - 1. TEXT COMPONENTS / 文本组件
// ============================================================

/**
 * Reusable header text component / 可复用的标题文本组件
 * 
 * USAGE / 使用:
 * ```
 * HeaderText(title: "Title", subtitle: "Subtitle")
 * HeaderText(title: "Title", subtitle: "Subtitle", style: .large)
 * ```
 */
struct HeaderText: View {
    let title: String
    let subtitle: String?
    let style: HeaderStyle
    
    enum HeaderStyle {
        case small, medium, large
        
        var titleFont: Font {
            switch self {
            case .small: return .headline
            case .medium: return .title3
            case .large: return .title
            }
        }
        
        var subtitleFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    init(title: String, subtitle: String? = nil, style: HeaderStyle = .medium) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: style.spacing) {
            Text(title)
                .font(style.titleFont)
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(style.subtitleFont)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/**
 * Footer text component / 页脚文本组件
 */
struct FooterText: View {
    let primary: String
    let secondary: String?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(primary)
                .font(.caption)
                .foregroundColor(.primary)
            
            if let secondary = secondary {
                Text(secondary)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

// MARK: - 2. BUTTON COMPONENTS / 按钮组件
// ============================================================

/**
 * Configurable action button / 可配置的操作按钮
 * 
 * USAGE / 使用:
 * ```
 * ActionButton("Save", style: .primary) { save() }
 * ActionButton("Cancel", style: .secondary) { cancel() }
 * ActionButton("Delete", style: .destructive) { delete() }
 * ```
 */
struct ActionButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive, ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return Color(.secondarySystemBackground)
            case .destructive: return .red
            case .ghost: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            case .destructive: return .white
            case .ghost: return .accentColor
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: style == .ghost ? nil : .infinity)
            .background(style.backgroundColor)
            .cornerRadius(10)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - 3. CARD COMPONENTS / 卡片组件
// ============================================================

/**
 * Reusable card container / 可复用的卡片容器
 */
struct CardContainer<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(
        padding: CGFloat = 16,
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 5,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

// MARK: - 4. LIST ITEM COMPONENTS / 列表项组件
// ============================================================

/**
 * Configurable list item / 可配置的列表项
 */
struct ListItemView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color
    let accessory: AccessoryType
    let action: (() -> Void)?
    
    enum AccessoryType {
        case none
        case chevron
        case checkmark
        case toggle(Binding<Bool>)
        case text(String)
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color = .accentColor,
        accessory: AccessoryType = .none,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.accessory = accessory
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                // Icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                        .frame(width: 32)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Accessory
                accessoryView
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil && !isToggle)
    }
    
    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        case .checkmark:
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundColor(.accentColor)
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
        case .text(let text):
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var isToggle: Bool {
        if case .toggle = accessory {
            return true
        }
        return false
    }
}

// MARK: - 5. LOADING & EMPTY STATES / 加载和空状态
// ============================================================

/**
 * Loading view component / 加载视图组件
 */
struct LoadingView: View {
    let message: String?
    let style: LoadingStyle
    
    enum LoadingStyle {
        case small, medium, large
        
        var scale: CGFloat {
            switch self {
            case .small: return 0.8
            case .medium: return 1.0
            case .large: return 1.5
            }
        }
    }
    
    init(message: String? = nil, style: LoadingStyle = .medium) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(style.scale)
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/**
 * Empty state view / 空状态视图
 */
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let message = message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                ActionButton(actionTitle, style: .primary, action: action)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 6. VIEW MODIFIERS / 视图修饰符
// ============================================================

/**
 * Card style modifier / 卡片样式修饰符
 */
struct CardStyleModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let padding: CGFloat
    
    init(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 5,
        padding: CGFloat = 16
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

/**
 * Loading overlay modifier / 加载遮罩修饰符
 */
struct LoadingOverlayModifier: ViewModifier {
    @Binding var isLoading: Bool
    let message: String?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                LoadingView(message: message)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isLoading)
    }
}

/**
 * Error state modifier / 错误状态修饰符
 */
struct ErrorStateModifier: ViewModifier {
    @Binding var error: String?
    let retry: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let error = error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text(error)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    if let retry = retry {
                        ActionButton("Retry", style: .primary, action: retry)
                    }
                }
                .padding()
                .cardStyle()
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - 7. VIEW EXTENSIONS / 视图扩展
// ============================================================

extension View {
    /**
     * Apply card style / 应用卡片样式
     */
    func cardStyle(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 5,
        padding: CGFloat = 16
    ) -> some View {
        modifier(CardStyleModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            padding: padding
        ))
    }
    
    /**
     * Add loading overlay / 添加加载遮罩
     */
    func loadingOverlay(isLoading: Binding<Bool>, message: String? = nil) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message))
    }
    
    /**
     * Add error state / 添加错误状态
     */
    func errorState(error: Binding<String?>, retry: (() -> Void)? = nil) -> some View {
        modifier(ErrorStateModifier(error: error, retry: retry))
    }
    
    /**
     * Conditional modifier / 条件修饰符
     */
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /**
     * Hide conditionally / 条件隐藏
     */
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
    
    /**
     * Disabled with opacity / 带透明度的禁用
     */
    func disabledWithOpacity(_ isDisabled: Bool, opacity: Double = 0.6) -> some View {
        self
            .disabled(isDisabled)
            .opacity(isDisabled ? opacity : 1.0)
    }
}

// MARK: - 8. ANIMATION MODIFIERS / 动画修饰符
// ============================================================

/**
 * Shake animation modifier / 震动动画修饰符
 */
struct ShakeModifier: ViewModifier {
    let shakes: CGFloat
    let amplitude: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * amplitude)
    }
}

extension View {
    /**
     * Add shake animation / 添加震动动画
     */
    func shake(times: Int, amplitude: CGFloat = 10) -> some View {
        modifier(ShakeModifier(shakes: CGFloat(times), amplitude: amplitude))
    }
}

// MARK: - 9. LAYOUT HELPERS / 布局助手
// ============================================================

/**
 * Adaptive stack that switches between HStack and VStack
 * 在 HStack 和 VStack 之间切换的自适应堆栈
 */
struct AdaptiveStack<Content: View>: View {
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let threshold: CGFloat
    let content: Content
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    init(
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        threshold: CGFloat = 500,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.threshold = threshold
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > threshold {
                HStack(alignment: verticalAlignment, spacing: spacing) {
                    content
                }
            } else {
                VStack(alignment: horizontalAlignment, spacing: spacing) {
                    content
                }
            }
        }
    }
}

// MARK: - 10. USAGE EXAMPLES / 使用示例
// ============================================================

/**
 * Example view showing how to use the components
 * 展示如何使用组件的示例视图
 */
struct ComponentsExampleView: View {
    @State private var isLoading = false
    @State private var error: String? = nil
    @State private var toggleValue = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header example / 标题示例
                HeaderText(
                    title: "Components Library",
                    subtitle: "Reusable UI Components",
                    style: .large
                )
                
                // Card with list items / 带列表项的卡片
                CardContainer {
                    VStack(spacing: 0) {
                        ListItemView(
                            title: "Settings",
                            subtitle: "App preferences",
                            icon: "gearshape",
                            accessory: .chevron
                        ) {
                            print("Settings tapped")
                        }
                        
                        Divider()
                        
                        ListItemView(
                            title: "Notifications",
                            subtitle: "Enable push notifications",
                            icon: "bell",
                            accessory: .toggle($toggleValue)
                        )
                    }
                }
                
                // Action buttons / 操作按钮
                HStack(spacing: 12) {
                    ActionButton("Cancel", style: .secondary) {
                        print("Cancel")
                    }
                    
                    ActionButton("Save", icon: "checkmark", style: .primary, isLoading: isLoading) {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
                }
                .padding(.horizontal)
                
                // Empty state / 空状态
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Documents",
                    message: "Create your first document to get started",
                    actionTitle: "Create Document"
                ) {
                    print("Create document")
                }
                .cardStyle()
                
                // Footer / 页脚
                FooterText(
                    primary: "Highly Reusable Components",
                    secondary: "Build once, use everywhere"
                )
            }
            .padding()
        }
        .loadingOverlay(isLoading: $isLoading, message: "Processing...")
        .errorState(error: $error) {
            error = nil
        }
    }
}

#Preview {
    ComponentsExampleView()
}