//
//  OriginalDialogDemoView.swift
//  SwiftUIDemo
//
//  Original dialog system demonstration / 原始对话框系统演示
//  对话框队列、优先级和LIFO演示 / Dialog queue, priority and LIFO demonstration
//

import SwiftUI
import ComposableArchitecture
#if canImport(UIKit)
import UIKit
#endif

/**
 * ORIGINAL DIALOG DEMO / 原始对话框演示
 *
 * FEATURES / 功能:
 * 1. Dialog queue management / 对话框队列管理
 * 2. Priority-based display / 基于优先级的显示
 * 3. LIFO (defer) behavior / LIFO（defer）行为
 * 4. Various dialog types / 各种对话框类型
 *
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. MVVM Pattern (via TCA) (MVVM模式，通过TCA)
 *    - Why: Separates view logic from business logic / 为什么：将视图逻辑与业务逻辑分离
 *    - Benefits: Testable, reusable, maintainable / 好处：可测试，可重用，可维护
 *
 * 2. Composite Pattern (组合模式)
 *    - Why: Composes complex UI from simpler components / 为什么：从更简单的组件组合复杂的UI
 *    - Benefits: Reusable components, clear structure / 好处：可重用组件，清晰的结构
 */

// MARK: - Original Dialog Demo View / 原始对话框演示视图

public struct OriginalDialogDemoView: View {
    // MARK: - Properties / 属性

    /// TCA store / TCA存储
    let store: StoreOf<OriginalDialogDemoFeature>

    /// Grid columns / 网格列
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: - Body / 主体

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 24) {
                    // Header section / 头部部分
                    headerSection

                    // Dialog type grid / 对话框类型网格
                    dialogTypeGrid(viewStore: viewStore)

                    // Result section / 结果部分
                    if !viewStore.resultMessage.isEmpty {
                        resultSection(message: viewStore.resultMessage, viewStore: viewStore)
                    }

                    // Additional controls / 附加控件
                    additionalControls(viewStore: viewStore)
                }
                .padding()
            }
            .navigationTitle("原始弹窗演示 / Original Dialog")
            .navigationBarTitleDisplayMode(.large)
            .dialog(
                isPresented: viewStore.binding(
                    get: \.showCustomDialog,
                    send: { _ in .dismissCustomDialog }
                ),
                configuration: viewStore.customDialogConfig
            )
            .loadingDialog(
                isPresented: viewStore.binding(
                    get: \.isLoading,
                    send: { _ in .toggleLoading }
                ),
                title: "Processing / 处理中",
                message: "This will take 3 seconds / 这将需要3秒"
            )
            .globalDialogPresenter()
        }
    }

    // MARK: - Header Section / 头部部分

    /// Header section view / 头部部分视图
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("原始对话框系统演示")
                .font(.title2)
                .fontWeight(.bold)

            Text("Original Dialog System Demo")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("展示队列管理、优先级和LIFO行为")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Demonstrates queue management, priority and LIFO behavior")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Dialog Type Grid / 对话框类型网格

    /// Dialog type grid view / 对话框类型网格视图
    private func dialogTypeGrid(viewStore: ViewStore<OriginalDialogDemoFeature.State, OriginalDialogDemoFeature.Action>) -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(OriginalDialogDemoFeature.DialogType.allCases, id: \.self) { type in
                dialogTypeButton(type: type, viewStore: viewStore)
            }
        }
    }

    /// Dialog type button / 对话框类型按钮
    private func dialogTypeButton(
        type: OriginalDialogDemoFeature.DialogType,
        viewStore: ViewStore<OriginalDialogDemoFeature.State, OriginalDialogDemoFeature.Action>
    ) -> some View {
        Button(action: {
            viewStore.send(.showDialog(type))
        }) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)

                Text(type.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Result Section / 结果部分

    /// Result section view / 结果部分视图
    private func resultSection(
        message: String,
        viewStore: ViewStore<OriginalDialogDemoFeature.State, OriginalDialogDemoFeature.Action>
    ) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text("Result / 结果")
                    .font(.headline)

                Spacer()

                Button(action: {
                    viewStore.send(.clearResult)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }

            Text(message)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }

    // MARK: - Additional Controls / 附加控件

    /// Additional controls section / 附加控件部分
    private func additionalControls(
        viewStore: ViewStore<OriginalDialogDemoFeature.State, OriginalDialogDemoFeature.Action>
    ) -> some View {
        VStack(spacing: 16) {
            // Loading demo button / 加载演示按钮
            Button(action: {
                viewStore.send(.toggleLoading)
            }) {
                Label(
                    "Start Loading Demo / 开始加载演示",
                    systemImage: "arrow.clockwise.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewStore.isLoading)

            // Queue demo button / 队列演示按钮
            Button(action: {
                viewStore.send(.showDialog(.queue))
            }) {
                Label(
                    "Queue Priority Demo / 队列优先级演示",
                    systemImage: "rectangle.stack"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            // Defer demo button / Defer演示按钮
            Button(action: {
                viewStore.send(.showDialog(.multipleDefer))
            }) {
                Label(
                    "LIFO (Defer) Demo / LIFO（Defer）演示",
                    systemImage: "arrow.uturn.backward.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            // Queue statistics / 队列统计
            queueStatisticsView()
        }
    }

    /// Queue statistics view / 队列统计视图
    private func queueStatisticsView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Queue Statistics / 队列统计")
                .font(.headline)

            HStack {
                Label(
                    "Pending: \(DialogManager.shared.pendingDialogCount)",
                    systemImage: "rectangle.stack"
                )
                .font(.caption)

                Spacer()

                Label(
                    "Active: \(DialogManager.shared.isPresented ? "Yes" : "No")",
                    systemImage: "bubble.left"
                )
                .font(.caption)
            }

            if DialogManager.shared.hasPendingDialogs {
                Text("Dialogs are queued and will show in priority order / 对话框已排队，将按优先级顺序显示")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Scale Button Style (Reused) / 缩放按钮样式（复用）
/// Custom button style with scale effect / 带缩放效果的自定义按钮样式
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview Provider / 预览提供者
struct OriginalDialogDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OriginalDialogDemoView(
                store: Store(initialState: OriginalDialogDemoFeature.State()) {
                    OriginalDialogDemoFeature()
                }
            )
        }
    }
}