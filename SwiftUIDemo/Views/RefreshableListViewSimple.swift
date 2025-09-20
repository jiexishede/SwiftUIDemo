/**
 * RefreshableListViewSimple.swift
 * 简化版的 iOS 15 兼容可刷新列表视图
 * Simplified iOS 15 compatible refreshable list view
 * 
 * 设计思路 / Design Approach:
 * 基于测试结果，创建一个简化版本，确保 iOS 15 的下拉刷新能正常工作
 * Based on test results, create a simplified version to ensure iOS 15 pull-to-refresh works
 */

import SwiftUI
import ComposableArchitecture

struct RefreshableListViewSimple: View {
    let store: StoreOf<RefreshableListFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                // 主内容 / Main content
                VStack(spacing: 0) {
                    // 筛选器和控制面板 / Filter and control panel
                    OrderFilterDropdown(viewStore: viewStore)
                    ControlPanel(viewStore: viewStore)
                    
                    // 列表内容 / List content
                    if viewStore.showInitialLoading {
                        InitialLoadingView()
                    } else if viewStore.showInitialError {
                        InitialErrorView(viewStore: viewStore)
                    } else if viewStore.showEmptyView {
                        EmptyListView()
                    } else {
                        // iOS 15 兼容的刷新列表 / iOS 15 compatible refresh list
                        refreshableList(viewStore: viewStore)
                    }
                }
                
                // 加载遮罩 / Loading overlay
                if viewStore.showLoadingOverlay {
                    LoadingOverlay(
                        isLoading: true,
                        message: getLoadingMessage(viewStore: viewStore)
                    )
                }
            }
            .navigationTitle("订单列表")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    /**
     * iOS 15 兼容的可刷新列表
     * iOS 15 compatible refreshable list
     * 
     * 关键要点 / Key Points:
     * 1. 使用 List 而不是 ScrollView
     * 2. 确保 List 有内容（即使是空的占位符）
     * 3. refreshable 直接应用在 List 上
     * 4. async/await 必须正确实现
     */
    @ViewBuilder
    private func refreshableList(viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>) -> some View {
        List {
            // 确保 List 始终有内容 / Ensure List always has content
            if viewStore.items.isEmpty {
                // 空列表占位符 / Empty list placeholder
                Text("暂无数据，下拉刷新 / No data, pull to refresh")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            } else {
                // 错误横幅（如果有）/ Error banner (if any)
                if let errorInfo = viewStore.refreshErrorInfo {
                    RefreshErrorBanner(errorInfo: errorInfo, viewStore: viewStore)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                
                // 数据项 / Data items
                ForEach(viewStore.items) { item in
                    RefreshableListItemView(item: item)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                
                // 加载更多 / Load more
                if case let .loaded(data, loadMoreState) = viewStore.pageState,
                   data.hasMorePages {
                    LoadMoreView(
                        loadMoreState: loadMoreState,
                        hasMore: true,
                        autoLoadMore: true
                    ) {
                        viewStore.send(.loadMore)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.systemGroupedBackground))
        .refreshable {
            // iOS 15 关键：简单直接的异步实现
            // iOS 15 key: simple and direct async implementation
            await simplePerformRefresh(viewStore: viewStore)
        }
    }
    
    /**
     * 简化的刷新函数
     * Simplified refresh function
     * 
     * iOS 15 最佳实践 / iOS 15 Best Practice:
     * 1. 立即发送动作
     * 2. 固定等待时间（至少 1-2 秒）
     * 3. 不要过度复杂化
     */
    private func simplePerformRefresh(viewStore: ViewStore<RefreshableListFeature.State, RefreshableListFeature.Action>) async {
        print("🔄 [iOS 15] 开始下拉刷新 / Starting pull-to-refresh")
        
        // 发送刷新动作 / Send refresh action
        viewStore.send(.pullToRefresh)
        
        // iOS 15 需要实际的异步等待时间
        // iOS 15 needs actual async wait time
        do {
            // 等待 2 秒，让刷新动作完成
            // Wait 2 seconds for refresh action to complete
            try await Task.sleep(nanoseconds: 2_000_000_000)
        } catch {
            print("❌ 刷新等待被中断 / Refresh wait interrupted")
        }
        
        print("✅ [iOS 15] 下拉刷新完成 / Pull-to-refresh completed")
    }
    
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

// MARK: - Preview
struct RefreshableListViewSimple_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RefreshableListViewSimple(
                store: Store(
                    initialState: RefreshableListFeature.State(),
                    reducer: { RefreshableListFeature() }
                )
            )
        }
    }
}