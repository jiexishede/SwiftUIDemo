/**
 * iOS15RefreshableView.swift
 * iOS 15 专用的下拉刷新视图实现
 * iOS 15 specific pull-to-refresh view implementation
 * 
 * 设计思路：
 * iOS 15 的 refreshable 修饰符有一些限制，特别是在 List 中使用时。
 * 本文件提供了一个完全兼容 iOS 15 的下拉刷新解决方案。
 * 
 * Design approach:
 * iOS 15's refreshable modifier has some limitations, especially when used with List.
 * This file provides a fully iOS 15 compatible pull-to-refresh solution.
 * 
 * 技术要点 / Technical Points:
 * 1. 使用 List 而不是 ScrollView 来支持 refreshable
 * 2. 确保异步操作正确完成
 * 3. 使用 Task.sleep 代替 continuousClock (iOS 16+)
 * 4. 避免使用 iOS 16+ 的 API
 */

import SwiftUI
import ComposableArchitecture

// MARK: - iOS 15 Compatible Refreshable View
// iOS 15 兼容的可刷新视图 / iOS 15 Compatible Refreshable View
struct iOS15RefreshableView: View {
    let store: StoreOf<RefreshableListFeature>
    @State private var isRefreshing = false
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                // 主内容区域 / Main content area
                mainContent(viewStore: viewStore)
                
                // 加载遮罩 / Loading overlay
                if viewStore.showLoadingOverlay {
                    LoadingOverlay(
                        isLoading: true,
                        message: getLoadingMessage(viewStore: viewStore)
                    )
                }
            }
            .navigationTitle("订单列表")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private func mainContent(viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>) -> some View {
        VStack(spacing: 0) {
            // 筛选器 / Filter
            OrderFilterDropdown(viewStore: viewStore)
            
            // 控制面板 / Control Panel
            ControlPanel(viewStore: viewStore)
            
            // 内容区域 / Content Area
            contentArea(viewStore: viewStore)
        }
    }
    
    // MARK: - Content Area
    @ViewBuilder
    private func contentArea(viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>) -> some View {
        if viewStore.showInitialLoading {
            InitialLoadingView()
        } else if viewStore.showInitialError {
            InitialErrorView(viewStore: viewStore)
        } else if viewStore.showEmptyView {
            EmptyListView()
        } else {
            // iOS 15 专用的列表实现 / iOS 15 specific list implementation
            iOS15RefreshableList(viewStore: viewStore, isRefreshing: $isRefreshing)
        }
    }
    
    // MARK: - Helper Methods
    private func getLoadingMessage(viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>) -> String {
        if viewStore.isChangingFilter {
            return "切换筛选中... / Switching filter..."
        }
        
        switch viewStore.pageState {
        case .loading(.initial):
            return "加载数据中... / Loading data..."
        case .loading(.refresh):
            return "刷新数据中... / Refreshing data..."
        case .loaded(_, .loading):
            return "加载更多... / Loading more..."
        default:
            return "处理中... / Processing..."
        }
    }
}

// MARK: - iOS 15 Refreshable List Component
// iOS 15 可刷新列表组件 / iOS 15 Refreshable List Component
struct iOS15RefreshableList: View {
    let viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>
    @Binding var isRefreshing: Bool
    
    var body: some View {
        // 使用 List 来支持 iOS 15 的 refreshable / Use List to support iOS 15 refreshable
        List {
            // 错误横幅 / Error banner
            refreshErrorSection
            
            // 数据项 / Data items
            itemsSection
            
            // 加载更多 / Load more
            loadMoreSection
        }
        .listStyle(PlainListStyle())
        .refreshable {
            // iOS 15 兼容的异步刷新处理 / iOS 15 compatible async refresh handling
            await performRefresh()
        }
    }
    
    // MARK: - Refresh Error Section
    @ViewBuilder
    private var refreshErrorSection: some View {
        if case let .failed(.refresh, errorInfo) = viewStore.pageState {
            RefreshErrorBanner(errorInfo: errorInfo, viewStore: viewStore)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        } else if let errorInfo = viewStore.refreshErrorInfo {
            RefreshErrorBanner(errorInfo: errorInfo, viewStore: viewStore)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
    }
    
    // MARK: - Items Section
    @ViewBuilder
    private var itemsSection: some View {
        ForEach(viewStore.items) { item in
            RefreshableListItemView(item: item)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
    }
    
    // MARK: - Load More Section
    @ViewBuilder
    private var loadMoreSection: some View {
        if case let .loaded(data, loadMoreState) = viewStore.pageState {
            LoadMoreView(
                loadMoreState: loadMoreState,
                hasMore: data.hasMorePages,
                autoLoadMore: true
            ) {
                viewStore.send(.loadMore)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .onAppear {
                // 自动加载更多 / Auto load more
                if data.hasMorePages && loadMoreState == .idle {
                    viewStore.send(.loadMore)
                }
            }
        }
    }
    
    // MARK: - Perform Refresh
    /**
     * iOS 15 兼容的刷新实现
     * iOS 15 compatible refresh implementation
     * 
     * 关键点 / Key points:
     * 1. 使用 Task.sleep(nanoseconds:) 而不是 Task.sleep(for:) (iOS 16+)
     * 2. 确保刷新操作完成后才返回
     * 3. 使用状态轮询来检测刷新完成
     */
    private func performRefresh() async {
        // 标记开始刷新 / Mark refresh started
        isRefreshing = true
        
        // 发送刷新动作 / Send refresh action
        viewStore.send(.pullToRefresh)
        
        // 等待刷新开始（最多等待 1 秒）/ Wait for refresh to start (max 1 second)
        var attempts = 0
        while !viewStore.pageState.isRefreshing && attempts < 10 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            attempts += 1
        }
        
        // 等待刷新完成（最多等待 10 秒）/ Wait for refresh to complete (max 10 seconds)
        attempts = 0
        while viewStore.pageState.isRefreshing && attempts < 100 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            attempts += 1
        }
        
        // 额外等待以确保 UI 更新 / Additional wait to ensure UI updates
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // 标记刷新结束 / Mark refresh ended
        isRefreshing = false
    }
}

// MARK: - iOS 15 Pull To Refresh Implementation
// iOS 15 下拉刷新实现 / iOS 15 Pull To Refresh Implementation
extension View {
    /**
     * iOS 15 兼容的下拉刷新修饰符
     * iOS 15 compatible pull-to-refresh modifier
     * 
     * 使用示例 / Usage example:
     * ```swift
     * MyView()
     *     .iOS15Refreshable {
     *         await performRefresh()
     *     }
     * ```
     */
    @ViewBuilder
    func iOS15Refreshable(action: @escaping () async -> Void) -> some View {
        if #available(iOS 16.0, *) {
            // iOS 16+ 使用标准实现 / iOS 16+ use standard implementation
            self.refreshable {
                await action()
            }
        } else if #available(iOS 15.0, *) {
            // iOS 15 专用实现 / iOS 15 specific implementation
            self.refreshable {
                await action()
            }
        } else {
            // iOS 15 以下不支持 / Not supported below iOS 15
            self
        }
    }
}

// MARK: - Custom Pull To Refresh for iOS 15
// iOS 15 自定义下拉刷新 / Custom Pull To Refresh for iOS 15
struct iOS15PullToRefreshModifier: ViewModifier {
    @Binding var isRefreshing: Bool
    let action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                isRefreshing = true
                await action()
                // 确保至少显示 0.5 秒的刷新动画 / Ensure at least 0.5s refresh animation
                try? await Task.sleep(nanoseconds: 500_000_000)
                isRefreshing = false
            }
    }
}

// MARK: - Debug Helper
// 调试助手 / Debug Helper
#if DEBUG
struct iOS15RefreshableView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            iOS15RefreshableView(
                store: Store(
                    initialState: RefreshableListFeature.State(),
                    reducer: { RefreshableListFeature() }
                )
            )
        }
        .previewDevice("iPhone 13")
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
#endif