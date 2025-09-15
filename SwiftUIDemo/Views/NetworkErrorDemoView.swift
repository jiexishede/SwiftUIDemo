//
//  NetworkErrorDemoView.swift
//  SwiftUIDemo
//
//  Network error handling demo view with comprehensive error states
//  网络错误处理演示视图，包含全面的错误状态
//

import SwiftUI
import ComposableArchitecture

/**
 * NETWORK ERROR DEMO VIEW - 网络错误演示视图
 * 
 * PURPOSE / 目的:
 * - Demonstrate all network error handling scenarios
 * - 演示所有网络错误处理场景
 * - Show proper UI for each error state
 * - 为每个错误状态显示适当的 UI
 * - Provide testing interface for different scenarios
 * - 提供不同场景的测试界面
 * 
 * FEATURES / 功能:
 * 1. Scenario selector for different error types
 *    不同错误类型的场景选择器
 * 2. Visual feedback for each state
 *    每个状态的视觉反馈
 * 3. Retry and refresh capabilities
 *    重试和刷新功能
 * 4. Integration with reusable components
 *    与可重用组件集成
 */
struct NetworkErrorDemoView: View {
    let store: StoreOf<NetworkErrorDemoFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                // Main content / 主要内容
                VStack(spacing: 0) {
                    // Scenario selector / 场景选择器
                    scenarioSelector(viewStore: viewStore)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Fetch button / 获取按钮
                    fetchButton(viewStore: viewStore)
                        .padding()
                    
                    // Content area / 内容区域
                    contentArea(viewStore: viewStore)
                }
                .navigationTitle("Network Error Demo / 网络错误演示")
                .navigationBarTitleDisplayMode(.inline)
                
                // State overlay / 状态覆盖层
                stateOverlay(viewStore: viewStore)
            }
        }
    }
    
    // MARK: - Scenario Selector / 场景选择器
    
    @ViewBuilder
    private func scenarioSelector(viewStore: ViewStore<NetworkErrorDemoFeature.State, NetworkErrorDemoFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Scenario / 选择场景")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NetworkErrorDemoFeature.NetworkScenario.allCases, id: \.self) { scenario in
                        scenarioChip(
                            scenario: scenario,
                            isSelected: viewStore.selectedScenario == scenario,
                            action: {
                                viewStore.send(.selectScenario(scenario))
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    /**
     * Scenario selection chip
     * 场景选择芯片
     */
    @ViewBuilder
    private func scenarioChip(scenario: NetworkErrorDemoFeature.NetworkScenario, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                // Icon based on scenario / 基于场景的图标
                scenarioIcon(for: scenario)
                    .font(.caption)
                
                Text(scenario.description)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /**
     * Get icon for scenario
     * 获取场景图标
     */
    @ViewBuilder
    private func scenarioIcon(for scenario: NetworkErrorDemoFeature.NetworkScenario) -> some View {
        switch scenario {
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .successEmpty:
            Image(systemName: "tray")
                .foregroundColor(.orange)
        case .notFound:
            Image(systemName: "magnifyingglass.circle")
                .foregroundColor(.orange)
        case .unauthorized:
            Image(systemName: "lock.fill")
                .foregroundColor(.red)
        case .forbidden:
            Image(systemName: "hand.raised.fill")
                .foregroundColor(.red)
        case .serverError:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
        case .timeout:
            Image(systemName: "clock.fill")
                .foregroundColor(.orange)
        case .noConnection:
            Image(systemName: "wifi.slash")
                .foregroundColor(.gray)
        case .rateLimited:
            Image(systemName: "gauge.high")
                .foregroundColor(.orange)
        case .badRequest:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        }
    }
    
    // MARK: - Fetch Button / 获取按钮
    
    @ViewBuilder
    private func fetchButton(viewStore: ViewStore<NetworkErrorDemoFeature.State, NetworkErrorDemoFeature.Action>) -> some View {
        HStack(spacing: 12) {
            // Fetch data button / 获取数据按钮
            Button(action: {
                viewStore.send(.fetchData)
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Fetch Data / 获取数据")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(viewStore.pageState.isLoading)
            
            // Clear button / 清除按钮
            if case .failed = viewStore.pageState {
                Button(action: {
                    viewStore.send(.clearError)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.secondary)
                        .cornerRadius(8)
                }
            } else if !viewStore.items.isEmpty {
                Button(action: {
                    viewStore.send(.clearError)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.secondary)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Content Area / 内容区域
    
    @ViewBuilder
    private func contentArea(viewStore: ViewStore<NetworkErrorDemoFeature.State, NetworkErrorDemoFeature.Action>) -> some View {
        ScrollView {
            if case .loaded = viewStore.pageState, !viewStore.items.isEmpty {
                // Show loaded items / 显示加载的项目
                LazyVStack(spacing: 12) {
                    ForEach(viewStore.items) { item in
                        itemRow(item: item)
                    }
                }
                .padding()
            }
            
            // State information card / 状态信息卡片
            stateInfoCard(viewStore: viewStore)
                .padding()
        }
        .refreshable {
            await viewStore.send(.refresh).finish()
        }
    }
    
    /**
     * Individual item row
     * 单个项目行
     */
    @ViewBuilder
    private func itemRow(item: NetworkErrorDemoFeature.State.MockItem) -> some View {
        HStack(spacing: 12) {
            // Mock image placeholder / 模拟图像占位符
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.accentColor.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - State Information Card / 状态信息卡片
    
    @ViewBuilder
    private func stateInfoCard(viewStore: ViewStore<NetworkErrorDemoFeature.State, NetworkErrorDemoFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current State / 当前状态")
                .font(.headline)
            
            HStack {
                Text("Page State / 页面状态:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(viewStore.pageState.description)
                    .font(.caption.bold())
                    .foregroundColor(stateColor(for: viewStore.pageState))
            }
            
            if let error = viewStore.errorType {
                HStack {
                    Text("Error Type / 错误类型:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(error.localizedDescription)
                        .font(.caption.bold())
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Text("Retry Count / 重试次数:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewStore.retryCount)")
                    .font(.caption.bold())
            }
            
            if let lastRequest = viewStore.lastRequestTime {
                HStack {
                    Text("Last Request / 最后请求:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastRequest, style: .time)
                        .font(.caption.bold())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    /**
     * Get color for page state
     * 获取页面状态的颜色
     */
    private func stateColor(for state: ReduxPageState<ListData<NetworkErrorDemoFeature.State.MockItem>>) -> Color {
        switch state {
        case .idle:
            return .gray
        case .loading:
            return .blue
        case .loaded:
            return .green
        case .failed:
            return .red
        }
    }
    
    // MARK: - State Overlay / 状态覆盖层
    
    @ViewBuilder
    private func stateOverlay(viewStore: ViewStore<NetworkErrorDemoFeature.State, NetworkErrorDemoFeature.Action>) -> some View {
        Group {
            switch viewStore.pageState {
            case .loading:
                LoadingStateView(
                    message: "Loading data... / 加载数据中...",
                    style: .standard
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.95))
                
            case let .loaded(data, _) where data.isEmpty:
                EmptyStateView(
                    icon: "tray",
                    title: "No Data / 无数据",
                    message: "The request was successful but returned no items.\n请求成功但没有返回任何项目。",
                    actionTitle: "Refresh / 刷新",
                    action: {
                        viewStore.send(.refresh)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            case .failed:
                if let error = viewStore.errorType {
                    ErrorStateView(
                        error: error,
                        retryAction: {
                            viewStore.send(.retry)
                        },
                        customAction: nil
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
                
            case .idle, .loaded:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewStore.pageState)
    }
}

// MARK: - Redux Page State Extension / Redux 页面状态扩展

extension ReduxPageState {
    /**
     * Description for display
     * 用于显示的描述
     */
    var description: String {
        switch self {
        case .idle:
            return "Idle / 空闲"
        case .loading(let type):
            switch type {
            case .initial:
                return "Initial Loading / 初始加载"
            case .refresh:
                return "Refreshing / 刷新中"
            case .loadMore:
                return "Loading More / 加载更多"
            }
        case .loaded(_, let loadMoreState):
            switch loadMoreState {
            case .idle:
                return "Loaded / 已加载"
            case .loading:
                return "Loading More / 加载更多"
            case .noMore:
                return "All Loaded / 全部加载"
            case .failed:
                return "Load More Failed / 加载更多失败"
            }
        case .failed(let type, _):
            switch type {
            case .initial:
                return "Initial Load Failed / 初始加载失败"
            case .refresh:
                return "Refresh Failed / 刷新失败"
            case .loadMore:
                return "Load More Failed / 加载更多失败"
            }
        }
    }
}

// MARK: - Preview / 预览

struct NetworkErrorDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NetworkErrorDemoView(
                store: Store(initialState: NetworkErrorDemoFeature.State()) {
                    NetworkErrorDemoFeature()
                }
            )
        }
    }
}