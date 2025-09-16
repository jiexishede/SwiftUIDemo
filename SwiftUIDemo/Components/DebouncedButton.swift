//
//  DebouncedButton.swift
//  SwiftUIDemo
//
//  Button with debounce functionality / 防连点按钮
//

/**
 * DebouncedButton - 防连点按钮组件
 *
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Decorator Pattern (装饰器模式)
 *    - Why: Adds debounce behavior without modifying original button / 为什么：在不修改原始按钮的情况下添加防连点行为
 *    - Benefits: Reusable, composable, flexible / 好处：可重用、可组合、灵活
 *    - Implementation: ViewModifier wraps button with debounce logic / 实现：ViewModifier 包装按钮添加防连点逻辑
 *
 * 2. Strategy Pattern (策略模式)
 *    - Why: Different debounce strategies for different use cases / 为什么：不同场景使用不同的防连点策略
 *    - Benefits: Easily switch between strategies / 好处：易于在策略之间切换
 *    - Implementation: Enum defines different debounce strategies / 实现：枚举定义不同的防连点策略
 *
 * APPLE'S RECOMMENDED APPROACHES / 苹果推荐的方法:
 * 1. Task-based debouncing with async/await (iOS 15+) / 基于 Task 的异步防连点
 * 2. Disabled state management / 禁用状态管理
 * 3. Combine's debounce operator / Combine 的 debounce 操作符
 *
 * USAGE EXAMPLES / 使用示例:
 * ```
 * // Example 1: Simple disabled-based debounce / 基于禁用的简单防连点
 * Button("Click Me") {
 *     performAction()
 * }
 * .debouncedButton(duration: 2.0, strategy: .disabled)
 *
 * // Example 2: Task-based with loading indicator / 基于 Task 带加载指示器
 * Button("Submit") {
 *     await submitForm()
 * }
 * .debouncedButton(duration: 2.0, strategy: .taskBased, showLoading: true)
 *
 * // Example 3: Combine-based debounce / 基于 Combine 的防连点
 * Button("Search") {
 *     search(query)
 * }
 * .debouncedButton(duration: 0.5, strategy: .combine)
 * ```
 */

import SwiftUI
import Combine

// MARK: - Debounce Strategy / 防连点策略

/**
 * Different debounce strategies / 不同的防连点策略
 *
 * WHY MULTIPLE STRATEGIES / 为什么要多种策略:
 * - Different UI contexts require different feedback / 不同的 UI 场景需要不同的反馈
 * - Performance considerations / 性能考虑
 * - User experience optimization / 用户体验优化
 */
enum DebounceStrategy {
    case disabled       // Simply disable button / 简单禁用按钮
    case taskBased      // Use Task for async operations / 使用 Task 处理异步操作
    case combine        // Use Combine's debounce / 使用 Combine 的 debounce
    case cooldown       // Visual cooldown timer / 可视化冷却计时器
}

// MARK: - Strategy 1: Disabled-based Debounce / 策略1：基于禁用的防连点

/**
 * SIMPLEST APPROACH - APPLE RECOMMENDED / 最简单方法 - 苹果推荐
 *
 * Pros / 优点:
 * - Simple and straightforward / 简单直接
 * - No external dependencies / 无外部依赖
 * - Clear visual feedback / 清晰的视觉反馈
 *
 * Cons / 缺点:
 * - Button appears disabled / 按钮显示为禁用状态
 * - May not be suitable for all UX requirements / 可能不适合所有 UX 需求
 */
struct DisabledDebounceModifier: ViewModifier {
    let duration: TimeInterval
    @State private var isDisabled = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    guard !isDisabled else { return }

                    // Perform action / 执行操作
                    action()

                    // Disable button / 禁用按钮
                    isDisabled = true

                    // Re-enable after duration / 持续时间后重新启用
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        isDisabled = false
                    }
                }
            )
    }
}

// MARK: - Strategy 2: Task-based Debounce / 策略2：基于 Task 的防连点

/**
 * MODERN ASYNC/AWAIT APPROACH - iOS 15+ / 现代异步方法 - iOS 15+
 *
 * Pros / 优点:
 * - Cancellable operations / 可取消操作
 * - Works well with async functions / 与异步函数配合良好
 * - Clean code structure / 代码结构清晰
 *
 * Cons / 缺点:
 * - Requires iOS 15+ / 需要 iOS 15+
 * - More complex than disabled approach / 比禁用方法更复杂
 */
struct TaskDebounceModifier: ViewModifier {
    let duration: TimeInterval
    let showLoading: Bool
    @State private var currentTask: Task<Void, Never>?
    @State private var isProcessing = false
    let action: () async -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isProcessing)
                .opacity(isProcessing && showLoading ? 0.6 : 1.0)
                .simultaneousGesture(
                    TapGesture().onEnded { _ in
                        // Cancel previous task if exists / 取消之前的任务（如果存在）
                        currentTask?.cancel()

                        // Create new task / 创建新任务
                        currentTask = Task {
                            isProcessing = true

                            // Perform async action / 执行异步操作
                            await action()

                            // Wait for debounce duration / 等待防连点持续时间
                            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

                            // Check if not cancelled / 检查是否未被取消
                            if !Task.isCancelled {
                                isProcessing = false
                            }
                        }
                    }
                )

            // Loading indicator / 加载指示器
            if isProcessing && showLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

// MARK: - Strategy 3: Combine-based Debounce / 策略3：基于 Combine 的防连点

/**
 * REACTIVE APPROACH USING COMBINE / 使用 Combine 的响应式方法
 *
 * Pros / 优点:
 * - Built-in debounce operator / 内置的 debounce 操作符
 * - Works well with reactive patterns / 与响应式模式配合良好
 * - Can combine with other operators / 可以与其他操作符组合
 *
 * Cons / 缺点:
 * - Requires understanding of Combine / 需要理解 Combine
 * - More setup code / 更多的设置代码
 */
class CombineDebounceModel: ObservableObject {
    private let subject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(duration: TimeInterval, action: @escaping () -> Void) {
        subject
            .debounce(for: .seconds(duration), scheduler: DispatchQueue.main)
            .sink { _ in
                action()
            }
            .store(in: &cancellables)
    }

    func trigger() {
        subject.send(())
    }
}

struct CombineDebounceModifier: ViewModifier {
    let duration: TimeInterval
    let action: () -> Void
    @StateObject private var model: CombineDebounceModel

    init(duration: TimeInterval, action: @escaping () -> Void) {
        self.duration = duration
        self.action = action
        self._model = StateObject(wrappedValue: CombineDebounceModel(duration: duration, action: action))
    }

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    model.trigger()
                }
            )
    }
}

// MARK: - Strategy 4: Visual Cooldown Timer / 策略4：可视化冷却计时器

/**
 * VISUAL FEEDBACK APPROACH / 可视化反馈方法
 *
 * Pros / 优点:
 * - Clear visual feedback to user / 给用户清晰的视觉反馈
 * - Shows remaining cooldown time / 显示剩余冷却时间
 * - Engaging user experience / 吸引人的用户体验
 *
 * Cons / 缺点:
 * - More complex implementation / 更复杂的实现
 * - Additional UI elements / 额外的 UI 元素
 */
struct CooldownDebounceModifier: ViewModifier {
    let duration: TimeInterval
    @State private var cooldownProgress: Double = 0
    @State private var isOnCooldown = false
    @State private var timer: Timer?
    let action: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isOnCooldown)
                .opacity(isOnCooldown ? 0.6 : 1.0)
                .overlay(
                    // Cooldown progress overlay / 冷却进度遮罩
                    GeometryReader { geometry in
                        if isOnCooldown {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geometry.size.width * CGFloat(1 - cooldownProgress))
                                .animation(.linear(duration: 0.1), value: cooldownProgress)
                        }
                    }
                )
                .simultaneousGesture(
                    TapGesture().onEnded { _ in
                        guard !isOnCooldown else { return }

                        // Perform action / 执行操作
                        action()

                        // Start cooldown / 开始冷却
                        startCooldown()
                    }
                )

            // Cooldown timer text / 冷却计时器文本
            if isOnCooldown {
                Text(String(format: "%.1fs", duration * (1 - cooldownProgress)))
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
            }
        }
    }

    private func startCooldown() {
        isOnCooldown = true
        cooldownProgress = 0

        // Create timer for smooth progress update / 创建计时器以平滑更新进度
        let interval = 0.1
        let steps = duration / interval
        var currentStep = 0.0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentStep += 1
            cooldownProgress = currentStep / steps

            if currentStep >= steps {
                timer.invalidate()
                isOnCooldown = false
                cooldownProgress = 0
            }
        }
    }
}

// MARK: - View Extension for Easy Use / 视图扩展便于使用

extension View {
    /**
     * Apply debounce to any button / 为任何按钮应用防连点
     *
     * USAGE / 使用:
     * ```
     * Button("Click") { action() }
     *     .debouncedButton(strategy: .disabled)
     * ```
     */
    func debouncedButton(
        duration: TimeInterval = 2.0,
        strategy: DebounceStrategy = .disabled,
        showLoading: Bool = false,
        action: @escaping () -> Void = {}
    ) -> some View {
        switch strategy {
        case .disabled:
            return AnyView(self.modifier(DisabledDebounceModifier(duration: duration, action: action)))
        case .taskBased:
            return AnyView(self.modifier(TaskDebounceModifier(
                duration: duration,
                showLoading: showLoading,
                action: { await withCheckedContinuation { continuation in
                    action()
                    continuation.resume()
                }}
            )))
        case .combine:
            return AnyView(self.modifier(CombineDebounceModifier(duration: duration, action: action)))
        case .cooldown:
            return AnyView(self.modifier(CooldownDebounceModifier(duration: duration, action: action)))
        }
    }

    /**
     * Async version for task-based debounce / 异步版本用于基于任务的防连点
     */
    func debouncedButton(
        duration: TimeInterval = 2.0,
        showLoading: Bool = false,
        action: @escaping () async -> Void
    ) -> some View {
        self.modifier(TaskDebounceModifier(
            duration: duration,
            showLoading: showLoading,
            action: action
        ))
    }
}

// MARK: - Reusable Debounced Button Component / 可重用的防连点按钮组件

/**
 * Pre-configured debounced button / 预配置的防连点按钮
 *
 * USAGE / 使用:
 * ```
 * DebouncedButton("Submit", strategy: .taskBased) {
 *     await submitForm()
 * }
 * ```
 */
struct DebouncedButton: View {
    let title: String
    let strategy: DebounceStrategy
    let duration: TimeInterval
    let action: () -> Void

    init(
        _ title: String,
        strategy: DebounceStrategy = .disabled,
        duration: TimeInterval = 2.0,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.strategy = strategy
        self.duration = duration
        self.action = action
    }

    var body: some View {
        Button(title) {
            // Action handled by modifier / 操作由修饰符处理
        }
        .debouncedButton(
            duration: duration,
            strategy: strategy,
            action: action
        )
    }
}