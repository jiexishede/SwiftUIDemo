//
//  ContentView.swift
//  ReduxSwiftUIDemo
//
//  Main list view with navigation
//

/**
 * 🎯 MAIN NAVIGATION VIEW - 主导航视图
 * ═══════════════════════════════════════════════════════════════
 * 
 * 🏭 导航架构 / Navigation Architecture:
 * 
 * ┌─────────────────────────────────────────────┐
 * │           ContentView (Root)                │
 * │                   │                         │
 * │        iOS 16+    │    iOS 15              │
 * │           ↓       ↓       ↓                │
 * │   NavigationStackStore  NavigationView      │
 * │           │                │                │
 * │      DemoListView    DemoListViewIOS15      │
 * │           │                │                │
 * │    ┌──────┴──────┐   ┌────┴────┐         │
 * │    │ Destination │   │ NavLink │         │
 * │    │    Views    │   │  Views  │         │
 * │    └────────────┘   └─────────┘         │
 * └─────────────────────────────────────────────┘
 * 
 * 🎨 设计模式详解 / Design Patterns Explained:
 * 
 * 1️⃣ ADAPTER PATTERN (适配器模式) 🔌
 * ┌─────────────────────────────────────────────┐
 * │ 版本适配:                                    │
 * │ • iOS 16+: NavigationStackStore (TCA)      │
 * │ • iOS 15: NavigationView (Legacy)          │
 * │                                           │
 * │ if #available(iOS 16.0, *) {              │
 * │     // 现代导航 API                         │
 * │ } else {                                  │
 * │     // 兼容旧版本                           │
 * │ }                                         │
 * └─────────────────────────────────────────────┘
 * 
 * 2️⃣ COORDINATOR PATTERN (协调器模式) 🗺️
 * ┌─────────────────────────────────────────────┐
 * │ 导航管理:                                   │
 * │ • NavigationStackStore 管理导航栈         │
 * │ • Path.State 定义所有可能的目的地        │
 * │ • destinationView 决定导航目标            │
 * │                                           │
 * │ 职责分离:                                  │
 * │ • View: 只发送 Action                      │
 * │ • Store: 管理导航状态                      │
 * │ • Reducer: 处理导航逻辑                   │
 * └─────────────────────────────────────────────┘
 * 
 * 3️⃣ FACTORY PATTERN (工厂模式) 🏭
 * ┌─────────────────────────────────────────────┐
 * │ 视图创建:                                   │
 * │ • destinationView 是视图工厂方法          │
 * │ • 根据 state 类型创建不同视图              │
 * │ • @ViewBuilder 支持条件构建              │
 * │                                           │
 * │ switch store.state {                      │
 * │     case .counter: CounterView()          │
 * │     case .network: NetworkView()          │
 * │ }                                         │
 * └─────────────────────────────────────────────┘
 * 
 * 4️⃣ LAZY INITIALIZATION (延迟初始化) ⏰
 * ┌─────────────────────────────────────────────┐
 * │ iOS 15 解决方案:                            │
 * │ • @State private var childStore           │
 * │ • onAppear 时创建新 Store                  │
 * │ • 确保每次导航状态重置                    │
 * │                                           │
 * │ 为什么需要:                                │
 * │ • iOS 15 NavigationLink 缓存问题         │
 * │ • 防止状态持久化                        │
 * └─────────────────────────────────────────────┘
 * 
 * 🎯 SOLID 原则应用 / SOLID Principles Applied:
 * 
 * • SRP (单一职责): ContentView 只负责导航结构
 * • OCP (开闭原则): 添加新页面只需扩展 Path.State
 * • LSP (里氏替换): 所有子视图遵循相同 Store 协议
 * • ISP (接口隔离): 每个视图只依赖它需要的 Store
 * • DIP (依赖倒置): 依赖 TCA 抽象而非具体实现
 * 
 * 🔥 核心功能 / Core Features:
 * • iOS 版本适配 (15.0 & 16.0+)
 * • TCA 导航集成
 * • 模块化页面管理
 * • 类型安全的导航
 */

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    /**
     * 🎬 STORE PROPERTY - Store 属性
     * 
     * 设计模式 / Design Pattern: DEPENDENCY INJECTION
     * • Store 通过构造函数注入
     * • 解耦视图和业务逻辑
     * • 便于测试和重用
     * 
     * StoreOf<AppFeature> 类型:
     * • 类型别名简化: Store<AppFeature.State, AppFeature.Action>
     * • 包含应用全局状态和动作
     */
    let store: StoreOf<AppFeature>

    var body: some View {
        /**
         * 🔄 VERSION ADAPTIVE NAVIGATION - 版本适配导航
         * 
         * 设计模式 / Design Pattern: ADAPTER PATTERN
         * 
         * #available 编译指令:
         * • 编译时检查 iOS 版本
         * • 确保 API 可用性
         * • 避免运行时崩溃
         * 
         * 为什么需要适配:
         * • iOS 16 引入 NavigationStack
         * • iOS 15 只有 NavigationView
         * • TCA 提供不同的集成方式
         */
        // Version-adaptive navigation / 版本适配的导航
        if #available(iOS 16.0, *) {
            /**
             * 🆕 iOS 16+ NAVIGATION - iOS 16+ 导航
             * 
             * NavigationStackStore:
             * • TCA 提供的导航容器
             * • 管理导航栈状态
             * • 支持类型安全的导航
             * 
             * scope 方法:
             * • state: \.path - 提取导航路径状态
             * • action: \.path - 提取导航动作
             * • 创建子 Store 用于导航
             */
            // iOS 16+ uses NavigationStackStore / iOS 16+ 使用 NavigationStackStore
            NavigationStackStore(self.store.scope(state: \.path, action: \.path)) {
                DemoListView(store: store)
            } destination: { store in
                destinationView(for: store)
            }
        } else {
            // iOS 15 uses NavigationView with NavigationLink / iOS 15 使用 NavigationView 配合 NavigationLink
            NavigationView {
                DemoListViewIOS15(store: store)
            }
        }
    }

    // Extract destination view logic for reuse / 提取目标视图逻辑以便重用
    @ViewBuilder
    private func destinationView(for store: Store<AppFeature.Path.State, AppFeature.Path.Action>) -> some View {
        switch store.state {
        case .counter:
            if let store = store.scope(state: \.counter, action: \.counter) {
                CounterView(store: store)
            }
        case .networkRequest:
            if let store = store.scope(state: \.networkRequest, action: \.networkRequest) {
                ReduxPageStateBeRequestView(store: store)
            }
        case .refreshableList:
            if let store = store.scope(state: \.refreshableList, action: \.refreshableList) {
                RefreshableListView(store: store)
            }
        case .smartScroll:
            SmartScrollDemoView()
        case .dialogDemo:
            if let store = store.scope(state: \.dialogDemo, action: \.dialogDemo) {
                DialogDemoView(store: store)
            }
        case .originalDialogDemo:
            if let store = store.scope(state: \.originalDialogDemo, action: \.originalDialogDemo) {
                OriginalDialogDemoView(store: store)
            }
        case .networkErrorDemo:
            if let store = store.scope(state: \.networkErrorDemo, action: \.networkErrorDemo) {
                NetworkErrorDemoView(store: store)
            }
        case .networkStatus:
            NetworkStatusDemoView()
        case .networkAwareDemo:
            NetworkAwareDemoView()
        case .advancedNetworkMonitoring:
            AdvancedNetworkMonitoringDemoView()
        case .ecommerceLogin:
            if let store = store.scope(state: \.ecommerceLogin, action: \.ecommerceLogin) {
                ECommerceLoginView(store: store)
            }
        }
    }
}

// MARK: - Demo List View
struct DemoListView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List(viewStore.demoItems) { item in
                DemoItemRow(item: item) {
                    viewStore.send(.demoItemTapped(item))
                }
            }
            .navigationTitle("TCA Demos")
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(PlainListStyle())
            #endif
        }
    }
}

// MARK: - Demo Item Row
struct DemoItemRow: View {
    let item: DemoItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var rowContent: some View {
        HStack {
            itemIcon
            itemText
            Spacer()
            chevronIcon
        }
        .padding(.vertical, 8)
    }

    private var itemIcon: some View {
        Image(systemName: item.systemImage)
            .font(.title2)
            .foregroundColor(.blue)
            .frame(width: 40)
    }

    private var itemText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(item.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }

    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

// MARK: - iOS 15 Navigation Support / iOS 15 导航支持
struct DemoListViewIOS15: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List(viewStore.demoItems) { item in
                NavigationLink(
                    destination: iOS15DestinationView(item: item, parentStore: store)
                ) {
                    DemoItemRowContent(item: item)
                }
            }
            .navigationTitle("TCA Demos")
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(PlainListStyle())
            #endif
        }
    }
}

// MARK: - iOS 15 Destination View Wrapper
// iOS 15 目标视图包装器 / iOS 15 Destination View Wrapper
struct iOS15DestinationView: View {
    let item: DemoItem
    let parentStore: StoreOf<AppFeature>

    // 每次视图出现时创建新的 Store / Create new Store each time view appears
    @State private var childStore: AnyView?

    var body: some View {
        Group {
            if let childStore = childStore {
                childStore
            } else {
                ProgressView()
                    .onAppear {
                        createFreshStore()
                    }
            }
        }
        .onAppear {
            // 每次进入页面时创建新的 Store / Create new Store each time entering the page
            createFreshStore()
        }
    }

    private func createFreshStore() {
        // 创建全新的 Store，确保状态被重置 / Create fresh Store to ensure state is reset
        switch item.id {
        case "counter":
            childStore = AnyView(
                CounterView(
                    store: Store(initialState: CounterFeature.State()) {
                        CounterFeature()
                    }
                )
            )
        case "network":
            childStore = AnyView(
                ReduxPageStateBeRequestView(
                    store: Store(initialState: ReduxPageStateBeRequestFeature.State()) {
                        ReduxPageStateBeRequestFeature()
                    }
                )
            )
        case "refreshableList":
            // 确保每次都是全新的状态，toggles 都是 false / Ensure fresh state with toggles set to false
            childStore = AnyView(
                RefreshableListView(
                    store: Store(
                        initialState: RefreshableListFeature.State(
                            pageState: .idle,
                            simulateError: false,  // 重置为 false / Reset to false
                            simulateEmpty: false,  // 重置为 false / Reset to false
                            refreshErrorInfo: nil
                        )
                    ) {
                        RefreshableListFeature()
                    }
                )
            )
        case "smartScroll":
            childStore = AnyView(SmartScrollDemoView())
        case "dialogDemo":
            childStore = AnyView(
                DialogDemoView(
                    store: Store(initialState: DialogDemoFeature.State()) {
                        DialogDemoFeature()
                    }
                )
            )
        case "originalDialogDemo":
            childStore = AnyView(
                OriginalDialogDemoView(
                    store: Store(initialState: OriginalDialogDemoFeature.State()) {
                        OriginalDialogDemoFeature()
                    }
                )
            )
        case "networkStatus":
            childStore = AnyView(NetworkStatusDemoView())
        case "advancedNetworkMonitoring":
            childStore = AnyView(AdvancedNetworkMonitoringDemoView())
        case "ecommerce":
            childStore = AnyView(
                ECommerceLoginView(
                    store: Store(initialState: ECommerceLoginFeature.State()) {
                        ECommerceLoginFeature()
                    }
                )
            )
        default:
            childStore = AnyView(Text("Unknown Demo"))
        }
    }
}

// MARK: - Demo Item Row Content / 演示项行内容
struct DemoItemRowContent: View {
    let item: DemoItem

    var body: some View {
        HStack {
            Image(systemName: item.systemImage)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}