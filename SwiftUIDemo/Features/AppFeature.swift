//
//  AppFeature.swift
//  ReduxSwiftUIDemo
//
//  Main App Feature with Navigation
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var demoItems: [DemoItem] = DemoItem.allItems
    }

    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case demoItemTapped(DemoItem)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .demoItemTapped(item):
                switch item.id {
                case "counter":
                    state.path.append(.counter(CounterFeature.State()))
                case "network":
                    state.path.append(.networkRequest(ReduxPageStateBeRequestFeature.State()))
                case "refreshableList":
                    state.path.append(.refreshableList(RefreshableListFeature.State()))
                case "smartScroll":
                    state.path.append(.smartScroll)
                case "dialogDemo":
                    state.path.append(.dialogDemo(DialogDemoFeature.State()))
                case "originalDialogDemo":
                    state.path.append(.originalDialogDemo(OriginalDialogDemoFeature.State()))
                case "networkErrorDemo":
                    state.path.append(.networkErrorDemo(NetworkErrorDemoFeature.State()))
                case "networkStatus":
                    state.path.append(.networkStatus)
                case "advancedNetworkMonitoring":
                    state.path.append(.advancedNetworkMonitoring)
                case "ecommerce":
                    state.path.append(.ecommerceLogin(ECommerceLoginFeature.State()))
                case "dynamicSheet":
                    state.path.append(.dynamicSheet)
                case "textLayout":
                    state.path.append(.textLayout(TextLayoutFeature.State()))
                case "alignmentGuideFlow":
                    state.path.append(.alignmentGuideFlow)
                default:
                    break
                }
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }

    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case counter(CounterFeature.State)
            case networkRequest(ReduxPageStateBeRequestFeature.State)
            case refreshableList(RefreshableListFeature.State)
            case smartScroll
            case dialogDemo(DialogDemoFeature.State)
            case originalDialogDemo(OriginalDialogDemoFeature.State)
            case networkErrorDemo(NetworkErrorDemoFeature.State)
            case networkStatus
            case networkAwareDemo
            case advancedNetworkMonitoring
            case ecommerceLogin(ECommerceLoginFeature.State)
            case dynamicSheet
            case textLayout(TextLayoutFeature.State)
            case alignmentGuideFlow
        }

        enum Action {
            case counter(CounterFeature.Action)
            case networkRequest(ReduxPageStateBeRequestFeature.Action)
            case refreshableList(RefreshableListFeature.Action)
            case smartScroll
            case dialogDemo(DialogDemoFeature.Action)
            case originalDialogDemo(OriginalDialogDemoFeature.Action)
            case networkErrorDemo(NetworkErrorDemoFeature.Action)
            case networkStatus
            case networkAwareDemo
            case advancedNetworkMonitoring
            case ecommerceLogin(ECommerceLoginFeature.Action)
            case dynamicSheet
            case textLayout(TextLayoutFeature.Action)
            case alignmentGuideFlow
        }

        var body: some ReducerOf<Self> {
            Scope(state: \.counter, action: \.counter) {
                CounterFeature()
            }
            Scope(state: \.networkRequest, action: \.networkRequest) {
                ReduxPageStateBeRequestFeature()
            }
            Scope(state: \.refreshableList, action: \.refreshableList) {
                RefreshableListFeature()
            }
            Scope(state: \.dialogDemo, action: \.dialogDemo) {
                DialogDemoFeature()
            }
            Scope(state: \.originalDialogDemo, action: \.originalDialogDemo) {
                OriginalDialogDemoFeature()
            }
            Scope(state: \.networkErrorDemo, action: \.networkErrorDemo) {
                NetworkErrorDemoFeature()
            }
            Scope(state: \.ecommerceLogin, action: \.ecommerceLogin) {
                ECommerceLoginFeature()
            }
            Scope(state: \.textLayout, action: \.textLayout) {
                TextLayoutFeature()
            }
        }
    }
}

// MARK: - Demo Item Model
struct DemoItem: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String

    static let allItems = [
        DemoItem(
            id: "counter",
            title: "Counter Demo",
            subtitle: "Increment, decrement, timer, and random facts",
            systemImage: "number.circle"
        ),
        DemoItem(
            id: "network",
            title: "Network Request States",
            subtitle: "Loading, success, failure, and empty states",
            systemImage: "network"
        ),
        DemoItem(
            id: "refreshableList",
            title: "Refreshable List",
            subtitle: "Pull-to-refresh, load more, empty & error states",
            systemImage: "arrow.clockwise.square"
        ),
        DemoItem(
            id: "smartScroll",
            title: "智能滚动视图 / Smart Scroll",
            subtitle: "横向滚动与竖向滚动智能切换 / Intelligent scroll direction switching",
            systemImage: "scroll"
        ),
        DemoItem(
            id: "dialogDemo",
            title: "弹窗演示 / Dialog Demo",
            subtitle: "防连点按钮与底部弹窗 / Debounced buttons & bottom sheets",
            systemImage: "rectangle.bottomthird.inset.filled"
        ),
        DemoItem(
            id: "originalDialogDemo",
            title: "原始弹窗 / Original Dialog",
            subtitle: "队列优先级与LIFO演示 / Queue priority & LIFO demo",
            systemImage: "bubble.left.and.bubble.right"
        ),
        DemoItem(
            id: "networkStatus",
            title: "网络状态监控 / Network Monitor",
            subtitle: "实时检测断网与连接类型 / Real-time connectivity detection",
            systemImage: "wifi"
        ),
        DemoItem(
            id: "advancedNetworkMonitoring",
            title: "高级网络监控 / Advanced Network Monitoring",
            subtitle: "自定义错误模拟与智能重试 / Custom error simulation & intelligent retry",
            systemImage: "network.badge.shield.half.filled"
        ),
        DemoItem(
            id: "ecommerce",
            title: "电商首页 / E-Commerce Home",
            subtitle: "登录+复杂首页+分层错误处理 / Login + Complex Home + Layered Error Handling",
            systemImage: "cart.fill.badge.plus"
        ),
        DemoItem(
            id: "dynamicSheet",
            title: "动态 Sheet / Dynamic Sheet",
            subtitle: "动态高度弹窗与表格视图 / Dynamic height popup with table view",
            systemImage: "rectangle.bottomthird.inset.filled"
        ),
        DemoItem(
            id: "textLayout",
            title: "文字布局框架 / Text Layout Framework",
            subtitle: "横向流式、纵向流式、网格布局 / Horizontal flow, vertical flow, grid layout",
            systemImage: "text.alignleft"
        ),
        DemoItem(
            id: "alignmentGuideFlow",
            title: "AlignmentGuide 流式布局 / AlignmentGuide Flow Layout",
            subtitle: "轻量级流式布局实现 / Lightweight flow layout implementation",
            systemImage: "rectangle.3.group"
        )
    ]
}