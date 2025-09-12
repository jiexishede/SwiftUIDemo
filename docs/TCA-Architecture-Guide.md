# The Composable Architecture (TCA) Complete Guide / TCA 架构完整指南

## Table of Contents / 目录

1. [Introduction / 介绍](#introduction)
2. [Core Concepts / 核心概念](#core-concepts)
3. [Basic Implementation / 基础实现](#basic-implementation)
4. [Advanced Features / 高级功能](#advanced-features)
5. [Navigation / 导航](#navigation)
6. [Side Effects / 副作用](#side-effects)
7. [Testing / 测试](#testing)
8. [Best Practices / 最佳实践](#best-practices)
9. [Common Patterns / 常用模式](#common-patterns)

---

## Introduction / 介绍

### What is TCA? / 什么是 TCA？

The Composable Architecture (TCA) is a library for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind.

The Composable Architecture (TCA) 是一个用于以一致和可理解的方式构建应用程序的库，考虑了组合、测试和人体工程学。

### Key Benefits / 主要优势

1. **State Management / 状态管理**: Single source of truth for application state
2. **Composition / 组合**: Build complex features from simple components
3. **Side Effects / 副作用**: Controlled and testable side effects
4. **Testing / 测试**: Comprehensive testing support
5. **Ergonomics / 人体工程学**: Clear and consistent patterns

---

## Core Concepts / 核心概念

### The Four Core Components / 四个核心组件

```swift
/**
 * TCA CORE COMPONENTS
 * TCA 核心组件
 * 
 * 1. State: What data the feature needs
 *    状态：功能需要的数据
 * 
 * 2. Action: What can happen in the feature
 *    动作：功能中可能发生的事情
 * 
 * 3. Reducer: How state changes when actions occur
 *    Reducer：动作发生时状态如何变化
 * 
 * 4. Store: Runtime that powers the feature
 *    Store：驱动功能的运行时
 */

import ComposableArchitecture

// 1. STATE - The data model / 状态 - 数据模型
@ObservableState
struct CounterFeature: Reducer {
    struct State: Equatable {
        var count = 0
        var isTimerRunning = false
        var factAlert: String?
    }
    
    // 2. ACTION - User interactions and effects / 动作 - 用户交互和效果
    enum Action: Equatable {
        case incrementButtonTapped
        case decrementButtonTapped
        case toggleTimerButtonTapped
        case timerTick
        case factButtonTapped
        case factResponse(String)
        case dismissAlert
    }
    
    // Dependencies / 依赖
    @Dependency(\.continuousClock) var clock
    @Dependency(\.factClient) var factClient
    
    // Timer effect ID for cancellation / 用于取消的计时器效果 ID
    private enum CancelID { case timer }
    
    // 3. REDUCER - Business logic / Reducer - 业务逻辑
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    // Start timer / 启动计时器
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    // Stop timer / 停止计时器
                    return .cancel(id: CancelID.timer)
                }
                
            case .timerTick:
                state.count += 1
                return .none
                
            case .factButtonTapped:
                // Fetch fact about current number / 获取当前数字的事实
                return .run { [count = state.count] send in
                    let fact = try await factClient.fetch(count)
                    await send(.factResponse(fact))
                } catch: { error, send in
                    // Handle error / 处理错误
                    await send(.factResponse("Error: \(error.localizedDescription)"))
                }
                
            case let .factResponse(fact):
                state.factAlert = fact
                return .none
                
            case .dismissAlert:
                state.factAlert = nil
                return .none
            }
        }
    }
}

// 4. STORE & VIEW - The runtime and UI / Store 和视图 - 运行时和 UI
struct CounterView: View {
    // Store is the runtime that drives the feature
    // Store 是驱动功能的运行时
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack(spacing: 20) {
            // Observe state changes / 观察状态变化
            Text("\(store.count)")
                .font(.largeTitle)
            
            HStack(spacing: 20) {
                Button("-") {
                    // Send actions to store / 向 store 发送动作
                    store.send(.decrementButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
            
            Button(store.isTimerRunning ? "Stop Timer" : "Start Timer") {
                store.send(.toggleTimerButtonTapped)
            }
            
            Button("Get Fact") {
                store.send(.factButtonTapped)
            }
        }
        .alert(
            item: Binding(
                get: { store.factAlert.map { FactAlert(message: $0) } },
                set: { _ in store.send(.dismissAlert) }
            )
        ) { factAlert in
            Alert(title: Text("Fact"), message: Text(factAlert.message))
        }
    }
}

struct FactAlert: Identifiable {
    let id = UUID()
    let message: String
}
```

---

## Basic Implementation / 基础实现

### Step-by-Step Feature Creation / 逐步创建功能

```swift
/**
 * CREATING A TODO LIST FEATURE
 * 创建待办事项列表功能
 * 
 * Step-by-step guide to building a feature with TCA
 * 使用 TCA 构建功能的分步指南
 */

// STEP 1: Define the domain models / 步骤 1：定义领域模型
struct Todo: Equatable, Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Priority
    
    enum Priority: CaseIterable {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
}

// STEP 2: Create the feature reducer / 步骤 2：创建功能 reducer
@Reducer
struct TodoListFeature {
    // State definition / 状态定义
    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<Todo> = []
        var filter: Filter = .all
        var searchQuery = ""
        var isLoading = false
        var alert: AlertState<Action>?
        
        enum Filter: CaseIterable {
            case all, active, completed
            
            var title: String {
                switch self {
                case .all: return "All"
                case .active: return "Active"
                case .completed: return "Completed"
                }
            }
        }
        
        // Computed property for filtered todos / 过滤后的待办事项计算属性
        var filteredTodos: IdentifiedArrayOf<Todo> {
            var result = todos
            
            // Apply filter / 应用过滤器
            switch filter {
            case .all:
                break
            case .active:
                result = result.filter { !$0.isCompleted }
            case .completed:
                result = result.filter { $0.isCompleted }
            }
            
            // Apply search / 应用搜索
            if !searchQuery.isEmpty {
                result = result.filter { 
                    $0.title.localizedCaseInsensitiveContains(searchQuery)
                }
            }
            
            return result
        }
    }
    
    // Action definition / 动作定义
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case addTodoButtonTapped
        case todoAdded(Todo)
        case todoToggled(id: Todo.ID)
        case todoDeleted(id: Todo.ID)
        case clearCompletedButtonTapped
        case loadTodos
        case todosLoaded(Result<[Todo], Error>)
        case alertDismissed
    }
    
    // Dependencies / 依赖
    @Dependency(\.uuid) var uuid
    @Dependency(\.todoClient) var todoClient
    
    // Reducer body / Reducer 主体
    var body: some ReducerOf<Self> {
        BindingReducer()  // Handle @Binding updates / 处理 @Binding 更新
        
        Reduce { state, action in
            switch action {
            case .binding:
                // Handled by BindingReducer / 由 BindingReducer 处理
                return .none
                
            case .addTodoButtonTapped:
                let newTodo = Todo(
                    id: uuid(),
                    title: "New Todo",
                    isCompleted: false,
                    priority: .medium
                )
                return .send(.todoAdded(newTodo))
                
            case let .todoAdded(todo):
                state.todos.append(todo)
                // Save to backend / 保存到后端
                return .run { _ in
                    try await todoClient.save(todo)
                } catch: { error, _ in
                    // Handle error / 处理错误
                    print("Failed to save todo: \(error)")
                }
                
            case let .todoToggled(id):
                guard var todo = state.todos[id: id] else { return .none }
                todo.isCompleted.toggle()
                state.todos[id: id] = todo
                return .none
                
            case let .todoDeleted(id):
                state.todos.remove(id: id)
                return .run { _ in
                    try await todoClient.delete(id)
                } catch: { error, _ in
                    print("Failed to delete todo: \(error)")
                }
                
            case .clearCompletedButtonTapped:
                let completedIds = state.todos
                    .filter { $0.isCompleted }
                    .map { $0.id }
                
                state.todos.removeAll { completedIds.contains($0.id) }
                
                return .run { _ in
                    for id in completedIds {
                        try await todoClient.delete(id)
                    }
                }
                
            case .loadTodos:
                state.isLoading = true
                return .run { send in
                    let result = await Result {
                        try await todoClient.fetchAll()
                    }
                    await send(.todosLoaded(result))
                }
                
            case let .todosLoaded(.success(todos)):
                state.isLoading = false
                state.todos = IdentifiedArray(uniqueElements: todos)
                return .none
                
            case let .todosLoaded(.failure(error)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("Error")
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case .alertDismissed:
                state.alert = nil
                return .none
            }
        }
    }
}

// STEP 3: Create the view / 步骤 3：创建视图
struct TodoListView: View {
    @Bindable var store: StoreOf<TodoListFeature>
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar / 搜索栏
                SearchBar(text: $store.searchQuery)
                
                // Filter picker / 过滤器选择器
                Picker("Filter", selection: $store.filter) {
                    ForEach(TodoListFeature.State.Filter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Todo list / 待办事项列表
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.filteredTodos) { todo in
                            TodoRow(
                                todo: todo,
                                onToggle: {
                                    store.send(.todoToggled(id: todo.id))
                                },
                                onDelete: {
                                    store.send(.todoDeleted(id: todo.id))
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear Completed") {
                        store.send(.clearCompletedButtonTapped)
                    }
                    .disabled(store.todos.filter { $0.isCompleted }.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.addTodoButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                store.send(.loadTodos)
            }
            .alert(
                store: store.scope(state: \.$alert, action: \.alertDismissed)
            )
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .gray : .primary)
            }
            
            Spacer()
            
            Circle()
                .fill(todo.priority.color)
                .frame(width: 10, height: 10)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
```

---

## Advanced Features / 高级功能

### 1. Composition / 组合

```swift
/**
 * FEATURE COMPOSITION
 * 功能组合
 * 
 * Building complex features from simple ones
 * 从简单功能构建复杂功能
 */

// Parent feature containing child features / 包含子功能的父功能
@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var tab = Tab.todos
        var todos = TodoListFeature.State()
        var profile = ProfileFeature.State()
        var settings = SettingsFeature.State()
        
        enum Tab {
            case todos, profile, settings
        }
    }
    
    enum Action {
        case tabChanged(State.Tab)
        case todos(TodoListFeature.Action)
        case profile(ProfileFeature.Action)
        case settings(SettingsFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        // Compose child reducers / 组合子 reducer
        Scope(state: \.todos, action: \.todos) {
            TodoListFeature()
        }
        
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }
        
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
        
        // Parent reducer logic / 父 reducer 逻辑
        Reduce { state, action in
            switch action {
            case let .tabChanged(tab):
                state.tab = tab
                return .none
                
            case .todos:
                // Child reducer handles this / 子 reducer 处理此动作
                return .none
                
            case .profile:
                return .none
                
            case .settings:
                return .none
            }
        }
    }
}

// Parent view composing child views / 组合子视图的父视图
struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView(selection: .constant(store.tab)) {
            TodoListView(
                store: store.scope(state: \.todos, action: \.todos)
            )
            .tabItem {
                Label("Todos", systemImage: "checklist")
            }
            .tag(AppFeature.State.Tab.todos)
            
            ProfileView(
                store: store.scope(state: \.profile, action: \.profile)
            )
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppFeature.State.Tab.profile)
            
            SettingsView(
                store: store.scope(state: \.settings, action: \.settings)
            )
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(AppFeature.State.Tab.settings)
        }
    }
}
```

### 2. Dependencies / 依赖

```swift
/**
 * DEPENDENCY MANAGEMENT
 * 依赖管理
 * 
 * Inject dependencies for testing and modularity
 * 注入依赖以实现测试和模块化
 */

// Define dependency interface / 定义依赖接口
struct TodoClient {
    var fetchAll: @Sendable () async throws -> [Todo]
    var save: @Sendable (Todo) async throws -> Void
    var delete: @Sendable (Todo.ID) async throws -> Void
}

// Dependency key / 依赖键
extension DependencyValues {
    var todoClient: TodoClient {
        get { self[TodoClient.self] }
        set { self[TodoClient.self] = newValue }
    }
}

extension TodoClient: DependencyKey {
    // Live implementation / 实时实现
    static let liveValue = TodoClient(
        fetchAll: {
            // Real API call / 真实 API 调用
            let url = URL(string: "https://api.example.com/todos")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Todo].self, from: data)
        },
        save: { todo in
            // Save to API / 保存到 API
            let url = URL(string: "https://api.example.com/todos")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(todo)
            _ = try await URLSession.shared.data(for: request)
        },
        delete: { id in
            // Delete from API / 从 API 删除
            let url = URL(string: "https://api.example.com/todos/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            _ = try await URLSession.shared.data(for: request)
        }
    )
    
    // Test implementation / 测试实现
    static let testValue = TodoClient(
        fetchAll: {
            [
                Todo(id: UUID(), title: "Test Todo 1", isCompleted: false, priority: .high),
                Todo(id: UUID(), title: "Test Todo 2", isCompleted: true, priority: .low)
            ]
        },
        save: { _ in },
        delete: { _ in }
    )
    
    // Preview implementation / 预览实现
    static let previewValue = TodoClient(
        fetchAll: {
            [
                Todo(id: UUID(), title: "Buy groceries", isCompleted: false, priority: .high),
                Todo(id: UUID(), title: "Walk the dog", isCompleted: false, priority: .medium),
                Todo(id: UUID(), title: "Read a book", isCompleted: true, priority: .low)
            ]
        },
        save: { _ in },
        delete: { _ in }
    )
}

// Using dependency in reducer / 在 reducer 中使用依赖
@Reducer
struct TodoFeature {
    @Dependency(\.todoClient) var todoClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.continuousClock) var clock
    
    // Use dependencies in reducer logic
    // 在 reducer 逻辑中使用依赖
}
```

---

## Navigation / 导航

### Navigation Stack with TCA / 使用 TCA 的导航堆栈

```swift
/**
 * NAVIGATION IN TCA
 * TCA 中的导航
 * 
 * Managing navigation state with TCA
 * 使用 TCA 管理导航状态
 */

@Reducer
struct NavigationFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var items: [Item] = []
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case itemTapped(Item)
        case goBackToRoot
    }
    
    // Define navigation destinations / 定义导航目标
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case detail(ItemDetailFeature.State)
            case edit(ItemEditFeature.State)
            case settings(SettingsFeature.State)
        }
        
        enum Action {
            case detail(ItemDetailFeature.Action)
            case edit(ItemEditFeature.Action)
            case settings(SettingsFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) {
                ItemDetailFeature()
            }
            Scope(state: \.edit, action: \.edit) {
                ItemEditFeature()
            }
            Scope(state: \.settings, action: \.settings) {
                SettingsFeature()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .itemTapped(item):
                // Navigate to detail / 导航到详情
                state.path.append(.detail(ItemDetailFeature.State(item: item)))
                return .none
                
            case .goBackToRoot:
                // Pop to root / 弹出到根视图
                state.path.removeAll()
                return .none
                
            case let .path(.element(id: _, action: .detail(.editButtonTapped))):
                // Navigate from detail to edit / 从详情导航到编辑
                if let detailState = state.path.last,
                   case let .detail(detail) = detailState {
                    state.path.append(.edit(ItemEditFeature.State(item: detail.item)))
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
}

// Navigation view / 导航视图
struct NavigationView: View {
    @Bindable var store: StoreOf<NavigationFeature>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            // Root view / 根视图
            List(store.items) { item in
                Button {
                    store.send(.itemTapped(item))
                } label: {
                    ItemRow(item: item)
                }
            }
            .navigationTitle("Items")
            .toolbar {
                Button("Reset") {
                    store.send(.goBackToRoot)
                }
            }
        } destination: { store in
            switch store.state {
            case .detail:
                if let detailStore = store.scope(state: \.detail, action: \.detail) {
                    ItemDetailView(store: detailStore)
                }
            case .edit:
                if let editStore = store.scope(state: \.edit, action: \.edit) {
                    ItemEditView(store: editStore)
                }
            case .settings:
                if let settingsStore = store.scope(state: \.settings, action: \.settings) {
                    SettingsView(store: settingsStore)
                }
            }
        }
    }
}
```

---

## Side Effects / 副作用

### Managing Async Operations / 管理异步操作

```swift
/**
 * SIDE EFFECTS IN TCA
 * TCA 中的副作用
 * 
 * Handling async operations, timers, and external events
 * 处理异步操作、计时器和外部事件
 */

@Reducer
struct EffectsFeature {
    @ObservableState
    struct State: Equatable {
        var searchQuery = ""
        var searchResults: [SearchResult] = []
        var isSearching = false
        var webSocketMessages: [String] = []
        var isConnected = false
    }
    
    enum Action: Equatable {
        // Search actions / 搜索动作
        case searchQueryChanged(String)
        case searchResponse(Result<[SearchResult], Error>)
        
        // WebSocket actions / WebSocket 动作
        case connectWebSocket
        case disconnectWebSocket
        case webSocketConnected
        case webSocketMessageReceived(String)
        case webSocketDisconnected
        
        // Timer actions / 计时器动作
        case startPolling
        case stopPolling
        case pollTick
    }
    
    @Dependency(\.searchClient) var searchClient
    @Dependency(\.webSocketClient) var webSocketClient
    @Dependency(\.continuousClock) var clock
    
    private enum CancelID {
        case search
        case webSocket
        case polling
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.searchQuery = query
                state.isSearching = true
                
                // Debounced search / 防抖搜索
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    
                    let results = try await searchClient.search(query)
                    await send(.searchResponse(.success(results)))
                } catch: { error, send in
                    await send(.searchResponse(.failure(error)))
                }
                .cancellable(id: CancelID.search)
                
            case let .searchResponse(.success(results)):
                state.searchResults = results
                state.isSearching = false
                return .none
                
            case .searchResponse(.failure):
                state.isSearching = false
                return .none
                
            case .connectWebSocket:
                state.isConnected = true
                
                // Long-running effect for WebSocket / WebSocket 的长时间运行效果
                return .run { send in
                    await send(.webSocketConnected)
                    
                    for await message in webSocketClient.messages() {
                        await send(.webSocketMessageReceived(message))
                    }
                    
                    await send(.webSocketDisconnected)
                }
                .cancellable(id: CancelID.webSocket)
                
            case .disconnectWebSocket:
                state.isConnected = false
                return .cancel(id: CancelID.webSocket)
                
            case .webSocketConnected:
                state.isConnected = true
                return .none
                
            case let .webSocketMessageReceived(message):
                state.webSocketMessages.append(message)
                // Keep only last 100 messages / 只保留最后 100 条消息
                if state.webSocketMessages.count > 100 {
                    state.webSocketMessages.removeFirst()
                }
                return .none
                
            case .webSocketDisconnected:
                state.isConnected = false
                return .none
                
            case .startPolling:
                // Periodic polling / 定期轮询
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(5)) {
                        await send(.pollTick)
                    }
                }
                .cancellable(id: CancelID.polling)
                
            case .stopPolling:
                return .cancel(id: CancelID.polling)
                
            case .pollTick:
                // Perform polling action / 执行轮询动作
                return .run { send in
                    // Fetch latest data / 获取最新数据
                    let results = try await searchClient.fetchLatest()
                    await send(.searchResponse(.success(results)))
                }
            }
        }
    }
}

/**
 * FIRE AND FORGET EFFECTS
 * 即发即忘效果
 * 
 * Effects that don't send actions back
 * 不发送动作返回的效果
 */
extension Reducer {
    func analytics() -> some ReducerOf<Self> {
        Reduce { state, action in
            // Log every action / 记录每个动作
            return .run { _ in
                await AnalyticsClient.shared.log(action)
            }
            .merge(with: self.reduce(into: &state, action: action))
        }
    }
}
```

---

## Testing / 测试

### Comprehensive Testing / 全面测试

```swift
/**
 * TESTING TCA FEATURES
 * 测试 TCA 功能
 * 
 * Test state changes, effects, and dependencies
 * 测试状态变化、效果和依赖
 */

import ComposableArchitecture
import XCTest

@MainActor
final class TodoFeatureTests: XCTestCase {
    /**
     * TEST STATE CHANGES
     * 测试状态变化
     */
    func testAddTodo() async {
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.todoClient = .testValue
        }
        
        // Test adding a todo / 测试添加待办事项
        await store.send(.addTodoButtonTapped)
        
        await store.receive(\.todoAdded) { state in
            state.todos = [
                Todo(
                    id: UUID(0),
                    title: "New Todo",
                    isCompleted: false,
                    priority: .medium
                )
            ]
        }
    }
    
    /**
     * TEST ASYNC EFFECTS
     * 测试异步效果
     */
    func testLoadTodos() async {
        let todos = [
            Todo(id: UUID(), title: "Test 1", isCompleted: false, priority: .high),
            Todo(id: UUID(), title: "Test 2", isCompleted: true, priority: .low)
        ]
        
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.todoClient.fetchAll = { todos }
        }
        
        await store.send(.loadTodos) {
            $0.isLoading = true
        }
        
        await store.receive(\.todosLoaded.success) {
            $0.isLoading = false
            $0.todos = IdentifiedArray(uniqueElements: todos)
        }
    }
    
    /**
     * TEST ERROR HANDLING
     * 测试错误处理
     */
    func testLoadTodosFailure() async {
        struct TestError: Error, Equatable {}
        
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.todoClient.fetchAll = { throw TestError() }
        }
        
        await store.send(.loadTodos) {
            $0.isLoading = true
        }
        
        await store.receive(\.todosLoaded.failure) {
            $0.isLoading = false
            $0.alert = AlertState {
                TextState("Error")
            } message: {
                TextState("The operation couldn't be completed.")
            }
        }
    }
    
    /**
     * TEST TIMER EFFECTS
     * 测试计时器效果
     */
    func testTimer() async {
        let clock = TestClock()
        
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        
        // Advance clock and verify ticks / 推进时钟并验证滴答
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.count = 1
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.count = 2
        }
        
        // Stop timer / 停止计时器
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
    
    /**
     * TEST NON-EXHAUSTIVE
     * 非详尽测试
     * 
     * For testing only specific actions
     * 用于仅测试特定动作
     */
    func testNonExhaustive() async {
        let store = TestStore(initialState: TodoListFeature.State()) {
            TodoListFeature()
        } withDependencies: {
            $0.todoClient = .testValue
        }
        
        store.exhaustivity = .off
        
        // Only test what we care about / 只测试我们关心的
        await store.send(.addTodoButtonTapped)
        // Don't need to assert on todoAdded action
    }
}

/**
 * SNAPSHOT TESTING
 * 快照测试
 */
import SnapshotTesting

class TodoViewTests: XCTestCase {
    func testTodoListView() {
        let store = Store(
            initialState: TodoListFeature.State(
                todos: [
                    Todo(id: UUID(), title: "Buy milk", isCompleted: false, priority: .high),
                    Todo(id: UUID(), title: "Walk dog", isCompleted: true, priority: .medium)
                ]
            )
        ) {
            TodoListFeature()
        } withDependencies: {
            $0.todoClient = .previewValue
        }
        
        let view = TodoListView(store: store)
        
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13Pro)))
    }
}
```

---

## Best Practices / 最佳实践

### 1. State Design / 状态设计

```swift
/**
 * STATE DESIGN BEST PRACTICES
 * 状态设计最佳实践
 */

// ✅ GOOD: Normalized state / 正确：规范化状态
@ObservableState
struct GoodState: Equatable {
    var users: IdentifiedArrayOf<User> = []
    var posts: IdentifiedArrayOf<Post> = []
    var currentUserId: User.ID?
    
    // Computed properties for derived state / 派生状态的计算属性
    var currentUser: User? {
        guard let id = currentUserId else { return nil }
        return users[id: id]
    }
    
    var currentUserPosts: [Post] {
        guard let userId = currentUserId else { return [] }
        return posts.filter { $0.authorId == userId }
    }
}

// ❌ BAD: Denormalized state / 错误：非规范化状态
struct BadState: Equatable {
    var currentUser: User?
    var currentUserPosts: [Post] = []  // Duplicated data!
    var allUsers: [User] = []
    var allPosts: [Post] = []
}
```

### 2. Action Design / 动作设计

```swift
/**
 * ACTION DESIGN BEST PRACTICES
 * 动作设计最佳实践
 */

enum GoodAction: Equatable {
    // ✅ User intentions, not implementation details
    // 用户意图，而不是实现细节
    case userTappedLoginButton
    case userEnteredCredentials(username: String, password: String)
    case userRequestedPasswordReset
    
    // ✅ Clear naming for effects
    // 效果的清晰命名
    case loginResponse(Result<User, LoginError>)
    case passwordResetEmailSent
}

enum BadAction: Equatable {
    // ❌ Implementation details
    // 实现细节
    case setUsername(String)
    case setPassword(String)
    case setIsLoading(Bool)
    case setError(String?)
}
```

### 3. Dependency Design / 依赖设计

```swift
/**
 * DEPENDENCY DESIGN BEST PRACTICES
 * 依赖设计最佳实践
 */

// ✅ GOOD: Protocol-based, testable / 正确：基于协议，可测试
struct APIClient {
    var fetch: @Sendable (Request) async throws -> Response
    var upload: @Sendable (Data, URL) async throws -> Void
    
    static let live = APIClient(
        fetch: { request in
            // Real implementation
        },
        upload: { data, url in
            // Real implementation
        }
    )
    
    static let test = APIClient(
        fetch: { _ in .mock },
        upload: { _, _ in }
    )
}

// ❌ BAD: Concrete, hard to test / 错误：具体，难以测试
class BadAPIClient {
    func fetch(_ request: Request) async throws -> Response {
        // Hard to mock
    }
}
```

---

## Common Patterns / 常用模式

### 1. Form Validation / 表单验证

```swift
/**
 * FORM VALIDATION PATTERN
 * 表单验证模式
 */

@Reducer
struct FormFeature {
    @ObservableState
    struct State: Equatable {
        var email = ""
        var password = ""
        var confirmPassword = ""
        
        var emailError: String? {
            guard !email.isEmpty else { return nil }
            guard email.contains("@") else { return "Invalid email" }
            return nil
        }
        
        var passwordError: String? {
            guard !password.isEmpty else { return nil }
            guard password.count >= 8 else { return "Password too short" }
            return nil
        }
        
        var confirmPasswordError: String? {
            guard !confirmPassword.isEmpty else { return nil }
            guard confirmPassword == password else { return "Passwords don't match" }
            return nil
        }
        
        var isValid: Bool {
            !email.isEmpty &&
            !password.isEmpty &&
            !confirmPassword.isEmpty &&
            emailError == nil &&
            passwordError == nil &&
            confirmPasswordError == nil
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitTapped
        case submissionResponse(Result<Void, Error>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .submitTapped:
                guard state.isValid else { return .none }
                // Submit form
                return .none
                
            case .submissionResponse:
                return .none
            }
        }
    }
}
```

### 2. Pagination / 分页

```swift
/**
 * PAGINATION PATTERN
 * 分页模式
 */

@Reducer
struct PaginatedListFeature {
    @ObservableState
    struct State: Equatable {
        var items: IdentifiedArrayOf<Item> = []
        var currentPage = 1
        var hasMorePages = true
        var isLoadingPage = false
    }
    
    enum Action {
        case loadNextPage
        case pageLoaded(Result<Page<Item>, Error>)
        case refresh
    }
    
    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadNextPage:
                guard !state.isLoadingPage,
                      state.hasMorePages else { return .none }
                
                state.isLoadingPage = true
                
                return .run { [page = state.currentPage] send in
                    let result = await Result {
                        try await apiClient.fetchPage(page)
                    }
                    await send(.pageLoaded(result))
                }
                
            case let .pageLoaded(.success(page)):
                state.items.append(contentsOf: page.items)
                state.currentPage += 1
                state.hasMorePages = page.hasMore
                state.isLoadingPage = false
                return .none
                
            case .pageLoaded(.failure):
                state.isLoadingPage = false
                return .none
                
            case .refresh:
                state.items = []
                state.currentPage = 1
                state.hasMorePages = true
                return .send(.loadNextPage)
            }
        }
    }
}
```

---

## Summary / 总结

### TCA Principles / TCA 原则

1. **State** is the single source of truth / **状态**是单一真相源
2. **Actions** describe what can happen / **动作**描述可能发生的事情
3. **Reducers** handle state mutations / **Reducer** 处理状态变化
4. **Effects** handle async and side effects / **效果**处理异步和副作用
5. **Dependencies** enable testing and modularity / **依赖**实现测试和模块化

### Key Benefits / 主要优势

- ✅ Predictable state management / 可预测的状态管理
- ✅ Comprehensive testing support / 全面的测试支持
- ✅ Modular and composable / 模块化和可组合
- ✅ Time travel debugging / 时间旅行调试
- ✅ Clear separation of concerns / 清晰的关注点分离

### When to Use TCA / 何时使用 TCA

**Use TCA when / 使用 TCA 当:**
- Building complex applications / 构建复杂应用
- Team collaboration is important / 团队协作很重要
- Testing is a priority / 测试是优先事项
- Consistent patterns matter / 一致的模式很重要

**Consider alternatives when / 考虑替代方案当:**
- Building simple prototypes / 构建简单原型
- Learning SwiftUI basics / 学习 SwiftUI 基础
- Rapid prototyping needed / 需要快速原型

Remember: TCA is powerful but has a learning curve. Start small and gradually adopt more features.

记住：TCA 很强大但有学习曲线。从小处开始，逐步采用更多功能。