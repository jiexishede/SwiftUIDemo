//
//  AdaptiveBottomSheet.swift
//  SwiftUIDemo
//
//  Bottom sheet with adaptive height / 自适应高度的底部弹窗
//

/**
 * AdaptiveBottomSheet - 自适应高度底部弹窗
 * 
 * HEIGHT CALCULATION STRATEGIES / 高度计算策略:
 * 1. GeometryReader-based (几何读取器)
 *    - Measures actual content height / 测量实际内容高度
 *    - Most accurate but requires layout pass / 最准确但需要布局传递
 * 
 * 2. PreferenceKey-based (偏好键)
 *    - Child views report their height / 子视图报告其高度
 *    - Good for dynamic content / 适合动态内容
 * 
 * 3. Fixed Percentage (固定百分比)
 *    - Simple but less flexible / 简单但不够灵活
 *    - Good for consistent layouts / 适合一致的布局
 * 
 * 4. Content-Intrinsic (内容固有)
 *    - Uses SwiftUI's layout system / 使用 SwiftUI 的布局系统
 *    - Automatic but less control / 自动但控制较少
 * 
 * APPLE'S RECOMMENDATIONS / 苹果的建议:
 * - Use .presentationDetents for iOS 16+ / iOS 16+ 使用 .presentationDetents
 * - Use GeometryReader sparingly / 谨慎使用 GeometryReader
 * - Prefer PreferenceKey for size reporting / 优先使用 PreferenceKey 报告大小
 */

import SwiftUI
import Combine

// MARK: - Height Strategy / 高度策略

enum BottomSheetHeight {
    case automatic                    // Auto-calculate based on content / 基于内容自动计算
    case fixed(CGFloat)              // Fixed height / 固定高度
    case percentage(CGFloat)         // Percentage of screen / 屏幕百分比
    case adaptive(min: CGFloat, max: CGFloat) // Adaptive with bounds / 带边界的自适应
}

// MARK: - Height PreferenceKey / 高度偏好键

/**
 * PreferenceKey for reporting content height / 用于报告内容高度的偏好键
 * 
 * WHY PREFERENCEKEY / 为什么使用 PreferenceKey:
 * - Child-to-parent communication / 子到父通信
 * - Avoids @Binding complexity / 避免 @Binding 复杂性
 * - Works across view hierarchy / 跨视图层次结构工作
 */
struct BottomSheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/**
 * PreferenceKey for tracking focused field frame / 用于跟踪聚焦字段框架的偏好键
 * 
 * For smart keyboard management / 用于智能键盘管理
 */
struct FocusedFieldFrameKey: PreferenceKey {
    static var defaultValue: CGRect? = nil
    
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

// MARK: - Adaptive Bottom Sheet View / 自适应底部弹窗视图

struct AdaptiveBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let height: BottomSheetHeight
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let dragIndicator: Bool
    let content: Content
    
    // Internal state / 内部状态
    @State private var contentHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false
    
    // Smart keyboard handling / 智能键盘处理
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardAnimationDuration: Double = 0.25
    @State private var focusedFieldFrame: CGRect? = nil
    let useSmartKeyboard: Bool
    
    init(
        isPresented: Binding<Bool>,
        height: BottomSheetHeight = .automatic,
        cornerRadius: CGFloat = 20,
        backgroundColor: Color = Color(.systemBackground),
        dragIndicator: Bool = true,
        useSmartKeyboard: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.height = height
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.dragIndicator = dragIndicator
        self.useSmartKeyboard = useSmartKeyboard
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background overlay / 背景遮罩
                if isPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }
                        .transition(.opacity)
                }
                
                // Bottom sheet content / 底部弹窗内容
                if isPresented {
                    VStack(spacing: 0) {
                        // Drag indicator / 拖动指示器
                        if dragIndicator {
                            dragIndicatorView
                        }
                        
                        // Main content with height measurement / 带高度测量的主内容
                        content
                            .frame(maxHeight: calculateMaxContentHeight(in: geometry))
                            .fixedSize(horizontal: false, vertical: true) // Allow content to expand vertically / 允许内容垂直扩展
                            .background(
                                GeometryReader { contentGeometry in
                                    Color.clear
                                        .preference(
                                            key: BottomSheetHeightKey.self,
                                            value: contentGeometry.size.height
                                        )
                                }
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: calculatedHeight(in: geometry))
                    .background(backgroundColor)
                    .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    .offset(y: calculateSmartOffset(in: geometry))
                    .gesture(dragGesture)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onPreferenceChange(BottomSheetHeightKey.self) { height in
                        contentHeight = height
                    }
                    .onAppear {
                        if useSmartKeyboard {
                            setupSmartKeyboardObservers()
                        }
                    }
                    .onDisappear {
                        if useSmartKeyboard {
                            removeSmartKeyboardObservers()
                        }
                    }
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .onAppear {
                                    // Track content frame for smart keyboard / 跟踪内容框架以实现智能键盘
                                }
                        }
                    )
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
            .animation(.interactiveSpring(), value: dragOffset)
            .animation(.easeOut(duration: keyboardAnimationDuration), value: keyboardHeight)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Height Calculations / 高度计算
    
    /**
     * Calculate maximum content height / 计算最大内容高度
     */
    private func calculateMaxContentHeight(in geometry: GeometryProxy) -> CGFloat {
        let maxHeight = geometry.size.height * 0.85
        let indicatorHeight: CGFloat = dragIndicator ? 30 : 0
        return maxHeight - indicatorHeight - geometry.safeAreaInsets.bottom
    }
    
    /**
     * Calculate sheet height based on strategy / 根据策略计算弹窗高度
     */
    private func calculatedHeight(in geometry: GeometryProxy) -> CGFloat {
        switch height {
        case .automatic:
            // Use measured content height with safety bounds / 使用测量的内容高度并设置安全边界
            let indicatorHeight: CGFloat = dragIndicator ? 30 : 0
            let measuredHeight = contentHeight + indicatorHeight
            
            // Set reasonable bounds / 设置合理的边界
            let minHeight: CGFloat = 150
            let maxHeight: CGFloat = geometry.size.height * 0.85
            
            // Return appropriate height / 返回适当的高度
            if measuredHeight < minHeight {
                return minHeight
            } else if measuredHeight > maxHeight {
                return maxHeight
            } else {
                return measuredHeight
            }
            
        case .fixed(let height):
            return height
            
        case .percentage(let percent):
            return geometry.size.height * percent
            
        case .adaptive(let minHeight, let maxHeight):
            let measured = contentHeight + (dragIndicator ? 30 : 0)
            return min(max(measured, minHeight), maxHeight)
        }
    }
    
    // MARK: - Drag Indicator / 拖动指示器
    
    private var dragIndicatorView: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
    
    // MARK: - Drag Gesture / 拖动手势
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                // Only allow dragging down / 只允许向下拖动
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                // Dismiss if dragged more than 100 points / 拖动超过 100 点则关闭
                if value.translation.height > 100 {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                } else {
                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Smart Keyboard Offset Calculation / 智能键盘偏移计算
    
    /**
     * Calculate smart vertical offset / 计算智能垂直偏移
     * 
     * SMART LOGIC / 智能逻辑:
     * 1. Only move if TextField would be hidden / 仅在输入框会被遮挡时移动
     * 2. Calculate minimum movement needed / 计算所需的最小移动
     * 3. Respect sheet boundaries / 尊重弹窗边界
     */
    private func calculateSmartOffset(in geometry: GeometryProxy) -> CGFloat {
        // Base offset from dragging / 拖动的基础偏移
        let baseOffset = max(0, dragOffset)
        
        if !useSmartKeyboard {
            // Fallback to simple keyboard offset / 回退到简单的键盘偏移
            return baseOffset - keyboardHeight
        }
        
        // Smart keyboard offset / 智能键盘偏移
        guard let fieldFrame = focusedFieldFrame,
              keyboardHeight > 0 else {
            return baseOffset
        }
        
        // Calculate positions / 计算位置
        let sheetTop = geometry.frame(in: .global).minY
        let fieldBottomRelativeToSheet = fieldFrame.maxY - sheetTop
        let sheetHeight = calculatedHeight(in: geometry)
        let visibleSheetHeight = sheetHeight - keyboardHeight
        
        // Check if field would be hidden / 检查字段是否会被遮挡
        if fieldBottomRelativeToSheet > visibleSheetHeight {
            // Calculate minimum offset needed / 计算所需的最小偏移
            let overlap = fieldBottomRelativeToSheet - visibleSheetHeight
            let keyboardOffset = -(overlap + 30)  // 30pt padding / 30点内边距
            
            // Ensure sheet doesn't go too high / 确保弹窗不会太高
            let maxUpwardOffset = -(sheetHeight * 0.3)  // Max 30% up / 最多上移 30%
            return baseOffset + max(keyboardOffset, maxUpwardOffset)
        }
        
        return baseOffset
    }
    
    /**
     * Setup smart keyboard observers / 设置智能键盘观察者
     */
    private func setupSmartKeyboardObservers() {
        // Keyboard will show / 键盘将显示
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
            }
            
            keyboardAnimationDuration = duration
            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        // Keyboard will hide / 键盘将隐藏
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                return
            }
            
            keyboardAnimationDuration = duration
            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = 0
            }
        }
    }
    
    /**
     * Remove smart keyboard observers / 移除智能键盘观察者
     */
    private func removeSmartKeyboardObservers() {
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
    }
}

// MARK: - Corner Radius Extension / 圆角扩展

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - iOS 16+ Sheet Detents / iOS 16+ 弹窗定位

@available(iOS 16.0, *)
extension View {
    /**
     * Modern approach using presentationDetents / 使用 presentationDetents 的现代方法
     * 
     * USAGE / 使用:
     * ```
     * .sheet(isPresented: $showSheet) {
     *     ContentView()
     *         .adaptiveSheetHeight()
     * }
     * ```
     */
    func adaptiveSheetHeight() -> some View {
        self
            .presentationDetents([
                .height(200),  // Minimum height / 最小高度
                .medium,       // 50% of screen / 屏幕的 50%
                .large         // Full screen / 全屏
            ])
            .presentationDragIndicator(.visible)
    }
    
    /**
     * Custom detents based on content / 基于内容的自定义定位
     */
    func dynamicSheetHeight() -> some View {
        self
            .presentationDetents([
                .custom(DynamicHeightDetent.self)
            ])
    }
}

// MARK: - Dynamic Height Detent / 动态高度定位

@available(iOS 16.0, *)
struct DynamicHeightDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        // Calculate based on content / 基于内容计算
        // This is a simplified example / 这是一个简化的示例
        return min(context.maxDetentValue, 400)
    }
}

// MARK: - Bottom Sheet Modifier / 底部弹窗修饰符

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let height: BottomSheetHeight
    let content: () -> SheetContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            AdaptiveBottomSheet(
                isPresented: $isPresented,
                height: height,
                content: self.content
            )
        }
    }
}

extension View {
    /**
     * Present adaptive bottom sheet / 展示自适应底部弹窗
     * 
     * USAGE / 使用:
     * ```
     * SomeView()
     *     .adaptiveBottomSheet(isPresented: $showSheet) {
     *         SheetContent()
     *     }
     * ```
     */
    func adaptiveBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        height: BottomSheetHeight = .automatic,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(BottomSheetModifier(
            isPresented: isPresented,
            height: height,
            content: content
        ))
    }
}