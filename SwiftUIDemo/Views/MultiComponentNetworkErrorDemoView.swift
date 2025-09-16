//
//  MultiComponentNetworkErrorDemoView.swift
//  SwiftUIDemo
//
//  View for demonstrating multiple components with different custom network error messages
//  演示多个组件使用不同自定义网络错误消息的视图
//

/**
 * 🎯 MULTI-COMPONENT NETWORK ERROR DEMO VIEW - 多组件网络错误演示视图
 * ═══════════════════════════════════════════════════════════════
 * 
 * 🏗️ TCA 集成 / TCA Integration:
 * • 使用 Store 管理状态
 * • 通过 ViewStore 观察状态变化
 * • 发送 Action 处理用户交互
 * • 遵循单向数据流
 * 
 * 🎨 设计模式 / Design Patterns:
 * • MVVM: View 绑定 Store 中的状态
 * • OBSERVER: ViewStore 观察状态变化
 * • COMPOSITE: 多个独立组件组合
 * 
 * 📋 SOLID 原则 / SOLID Principles:
 * • SRP: View 只负责展示
 * • DIP: 依赖 Store 抽象
 */

import SwiftUI
import ComposableArchitecture

struct MultiComponentNetworkErrorDemoView: View {
    let store: StoreOf<MultiComponentNetworkErrorFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section / 头部区域
                    headerSection
                    
                    // Component Selector / 组件选择器
                    componentSelector(viewStore: viewStore)
                    
                    // Error Type Configuration / 错误类型配置
                    errorTypeConfiguration(viewStore: viewStore)
                    
                    // Custom Message Input / 自定义消息输入
                    customMessageInput(viewStore: viewStore)
                    
                    // Components Display Grid / 组件展示网格
                    componentsGrid(viewStore: viewStore)
                    
                    // Quick Actions / 快速操作
                    quickActions(viewStore: viewStore)
                }
                .padding()
            }
            .navigationTitle("多组件错误演示 / Multi-Component Errors")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section / 头部区域
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎯 多组件网络错误演示")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Multi-Component Network Error Demo")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("在一个页面中展示多个组件的不同网络错误状态和自定义消息")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Display different network error states and custom messages for multiple components on one page")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Component Selector / 组件选择器
    
    private func componentSelector(viewStore: ViewStore<MultiComponentNetworkErrorFeature.State, MultiComponentNetworkErrorFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择要配置的组件 / Select Component to Configure")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(ComponentID.allCases, id: \.self) { componentId in
                    ComponentSelectorButton(
                        componentId: componentId,
                        isSelected: viewStore.selectedComponent == componentId,
                        action: {
                            viewStore.send(.selectComponent(componentId))
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Error Type Configuration / 错误类型配置
    
    private func errorTypeConfiguration(viewStore: ViewStore<MultiComponentNetworkErrorFeature.State, MultiComponentNetworkErrorFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("为 \(viewStore.selectedComponent.displayName) 选择错误类型")
                .font(.headline)
            
            Text("Select error type for \(viewStore.selectedComponent.englishName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(NetworkErrorType.allCases, id: \.self) { errorType in
                    ErrorTypeButton(
                        errorType: errorType,
                        isSelected: viewStore.state.getErrorType(for: viewStore.selectedComponent) == errorType,
                        action: {
                            viewStore.send(.setErrorType(viewStore.selectedComponent, errorType))
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Custom Message Input / 自定义消息输入
    
    private func customMessageInput(viewStore: ViewStore<MultiComponentNetworkErrorFeature.State, MultiComponentNetworkErrorFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("自定义错误消息 / Custom Error Message")
                .font(.headline)
            
            TextEditor(text: Binding(
                get: {
                    viewStore.state.getCustomMessage(for: viewStore.selectedComponent) ?? ""
                },
                set: { newValue in
                    viewStore.send(.setCustomMessage(viewStore.selectedComponent, newValue))
                }
            ))
            .frame(height: 80)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            HStack {
                Button("使用默认消息 / Use Default") {
                    viewStore.send(.useDefaultMessage(viewStore.selectedComponent))
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("清除 / Clear") {
                    viewStore.send(.clearCustomMessage(viewStore.selectedComponent))
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }
    
    // MARK: - Components Grid / 组件展示网格
    
    private func componentsGrid(viewStore: ViewStore<MultiComponentNetworkErrorFeature.State, MultiComponentNetworkErrorFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("组件展示 / Components Display")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("每个组件独立显示其配置的错误状态")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Each component independently displays its configured error state")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Three components in a vertical stack / 三个组件垂直排列
            VStack(spacing: 16) {
                ForEach(ComponentID.allCases, id: \.self) { componentId in
                    IndependentComponentView(
                        componentId: componentId,
                        store: store
                    )
                }
            }
        }
    }
    
    // MARK: - Quick Actions / 快速操作
    
    private func quickActions(viewStore: ViewStore<MultiComponentNetworkErrorFeature.State, MultiComponentNetworkErrorFeature.Action>) -> some View {
        VStack(spacing: 12) {
            Text("快速操作 / Quick Actions")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button("全部触发错误 / Trigger All Errors") {
                    viewStore.send(.triggerAllErrors)
                }
                .buttonStyle(.borderedProminent)
                
                Button("全部重置 / Reset All") {
                    viewStore.send(.resetAll)
                }
                .buttonStyle(.bordered)
            }
            
            HStack(spacing: 12) {
                Button("随机错误 / Random Errors") {
                    viewStore.send(.randomizeErrors)
                }
                .buttonStyle(.bordered)
                
                Button("加载数据 / Load Data") {
                    viewStore.send(.loadAllData)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

// MARK: - Component Selector Button / 组件选择按钮

struct ComponentSelectorButton: View {
    let componentId: ComponentID
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: componentId.icon)
                    .font(.title3)
                
                Text(componentId.displayName)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Error Type Button / 错误类型按钮

struct ErrorTypeButton: View {
    let errorType: NetworkErrorType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: errorType.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : errorType.color)
                
                Text(errorType.displayName)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? errorType.color : Color(.secondarySystemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Independent Component View / 独立组件视图

struct IndependentComponentView: View {
    let componentId: ComponentID
    let store: StoreOf<MultiComponentNetworkErrorFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                // Component Header / 组件头部
                HStack {
                    Image(systemName: componentId.icon)
                        .foregroundColor(.blue)
                    
                    Text(componentId.displayName)
                        .font(.headline)
                    
                    Text("(\(componentId.englishName))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let errorType = viewStore.state.getErrorType(for: componentId) {
                        Image(systemName: errorType.icon)
                            .foregroundColor(errorType.color)
                            .font(.caption)
                    }
                }
                
                // Component Content / 组件内容
                ComponentContentView(
                    componentId: componentId,
                    pageState: viewStore.state.getPageState(for: componentId)
                )
                .frame(minHeight: 150)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
                // Apply network state modifier / 应用网络状态修饰符
                .universalNetworkState(
                    state: viewStore.state.getPageState(for: componentId),
                    onRetry: {
                        viewStore.send(.retry(componentId))
                    },
                    autoRetry: false,
                    showIndicators: true
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
}

// MARK: - Component Content View / 组件内容视图

struct ComponentContentView: View {
    let componentId: ComponentID
    let pageState: ReduxPageState<ComponentData>
    
    var body: some View {
        switch pageState {
        case .idle:
            idleView
        case .loading:
            EmptyView() // Handled by modifier / 由修饰符处理
        case .loaded(let data, _):
            loadedView(data: data)
        case .failed:
            EmptyView() // Handled by modifier / 由修饰符处理
        }
    }
    
    private var idleView: some View {
        VStack {
            Image(systemName: "arrow.clockwise.circle")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("点击加载数据 / Click to Load")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadedView(data: ComponentData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(data.title)
                .font(.headline)
            
            Text(data.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            ForEach(data.items, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text(item)
                        .font(.caption)
                    
                    Spacer()
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview / 预览

#Preview {
    NavigationView {
        MultiComponentNetworkErrorDemoView(
            store: Store(initialState: MultiComponentNetworkErrorFeature.State()) {
                MultiComponentNetworkErrorFeature()
            }
        )
    }
}