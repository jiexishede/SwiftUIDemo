# SwiftUI Best Practices Guide / SwiftUI 最佳实践指南

## Table of Contents / 目录

1. [View Structure / 视图结构](#view-structure)
2. [State Management / 状态管理](#state-management)
3. [Performance Optimization / 性能优化](#performance-optimization)
4. [Layout and Composition / 布局和组合](#layout-composition)
5. [Navigation Patterns / 导航模式](#navigation-patterns)
6. [Data Flow / 数据流](#data-flow)
7. [Accessibility / 可访问性](#accessibility)
8. [Testing / 测试](#testing)
9. [Common Pitfalls / 常见陷阱](#common-pitfalls)

---

## View Structure / 视图结构

### 1. Keep Views Small and Focused / 保持视图小而专注

```swift
/**
 * ❌ BAD: Monolithic view with everything
 * 错误：包含所有内容的单体视图
 * 
 * Problems / 问题:
 * - Hard to read and maintain / 难以阅读和维护
 * - Poor reusability / 可重用性差
 * - Difficult to test / 难以测试
 * - Performance issues / 性能问题
 */
struct BadProfileView: View {
    @State private var user: User?
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        ScrollView {
            VStack {
                // Avatar section - 50 lines of code
                VStack {
                    if let avatarURL = user?.avatarURL {
                        AsyncImage(url: avatarURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    }
                    // ... more avatar code
                }
                
                // Info section - 100 lines of code
                VStack {
                    Text(user?.name ?? "")
                        .font(.title)
                    Text(user?.bio ?? "")
                        .font(.body)
                    // ... more info code
                }
                
                // Posts section - 200 lines of code
                LazyVStack {
                    ForEach(posts) { post in
                        VStack {
                            Text(post.title)
                            Text(post.content)
                            // ... more post code
                        }
                    }
                }
            }
        }
    }
}

/**
 * ✅ GOOD: Decomposed into focused components
 * 正确：分解为专注的组件
 * 
 * Benefits / 好处:
 * - Easy to understand / 易于理解
 * - Highly reusable / 高度可重用
 * - Testable in isolation / 可独立测试
 * - Better performance / 更好的性能
 */
struct GoodProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileAvatarView(user: viewModel.user)
                ProfileInfoView(user: viewModel.user)
                PostsListView(posts: viewModel.posts)
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}

// Focused subviews / 专注的子视图
struct ProfileAvatarView: View {
    let user: User?
    
    var body: some View {
        AvatarView(url: user?.avatarURL)
            .frame(width: 100, height: 100)
    }
}

struct ProfileInfoView: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 8) {
            Text(user?.name ?? "")
                .font(.title)
            Text(user?.bio ?? "")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct PostsListView: View {
    let posts: [Post]
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(posts) { post in
                PostCardView(post: post)
            }
        }
    }
}
```

### 2. Maximum 2-Level Nesting Rule / 最大 2 级嵌套规则

```swift
/**
 * NESTING RULE: Maximum 2 levels of {} nesting
 * 嵌套规则：最多 2 级 {} 嵌套
 * 
 * Why? / 为什么？
 * - Improves readability / 提高可读性
 * - Forces better decomposition / 强制更好的分解
 * - Reduces complexity / 降低复杂性
 */

// ❌ BAD: Too many nesting levels / 错误：太多嵌套级别
struct BadNestingView: View {
    var body: some View {
        VStack {                        // Level 1
            ScrollView {                // Level 2
                VStack {                // Level 3 - VIOLATION!
                    ForEach(items) {    // Level 4 - VIOLATION!
                        HStack {        // Level 5 - VIOLATION!
                            // Content
                        }
                    }
                }
            }
        }
    }
}

// ✅ GOOD: Properly refactored / 正确：正确重构
struct GoodNestingView: View {
    var body: some View {
        VStack {                        // Level 1
            contentScrollView           // Extracted
        }
    }
    
    private var contentScrollView: some View {
        ScrollView {                    // Level 1 in extracted view
            ItemsList()                 // Separate component
        }
    }
}

struct ItemsList: View {
    var body: some View {
        VStack {                        // Level 1
            ForEach(items) { item in
                ItemRow(item: item)    // Separate component
            }
        }
    }
}
```

### 3. Use Computed Properties for Complex Views / 对复杂视图使用计算属性

```swift
/**
 * COMPUTED PROPERTIES FOR VIEW SECTIONS
 * 视图部分的计算属性
 * 
 * Benefits / 好处:
 * - Cleaner body property / 更清晰的 body 属性
 * - Better organization / 更好的组织
 * - Easier navigation / 更容易导航
 */
struct WellOrganizedView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBar
            contentView
            tabBar
        }
    }
    
    // MARK: - View Components / 视图组件
    
    private var headerView: some View {
        HStack {
            Text("Title")
                .font(.largeTitle)
                .bold()
            Spacer()
            settingsButton
        }
        .padding()
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText)
            if !searchText.isEmpty {
                clearButton
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var contentView: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<3) { index in
                Text("Tab \(index)")
                    .tag(index)
            }
        }
    }
    
    private var tabBar: some View {
        HStack {
            ForEach(0..<3) { index in
                tabButton(for: index)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Views / 辅助视图
    
    private var settingsButton: some View {
        Button(action: openSettings) {
            Image(systemName: "gear")
        }
    }
    
    private var clearButton: some View {
        Button(action: { searchText = "" }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
    
    private func tabButton(for index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            Text("Tab \(index)")
                .foregroundColor(selectedTab == index ? .accentColor : .secondary)
        }
    }
    
    // MARK: - Actions / 操作
    
    private func openSettings() {
        // Open settings
    }
}
```

---

## State Management / 状态管理

### 1. Choose the Right Property Wrapper / 选择正确的属性包装器

```swift
/**
 * STATE MANAGEMENT PROPERTY WRAPPERS
 * 状态管理属性包装器
 * 
 * Choose based on ownership and lifetime
 * 根据所有权和生命周期选择
 */

struct StateManagementExamples: View {
    /**
     * @State - View owns and manages the state
     * @State - 视图拥有并管理状态
     * 
     * Use for / 用于:
     * - Simple, private, view-local state
     * - 简单、私有、视图本地状态
     * - UI state (selected tab, text field content)
     * - UI 状态（选中的标签、文本字段内容）
     */
    @State private var isExpanded = false
    @State private var text = ""
    
    /**
     * @Binding - Two-way connection to state owned elsewhere
     * @Binding - 与其他地方拥有的状态的双向连接
     * 
     * Use for / 用于:
     * - Child views that need to modify parent's state
     * - 需要修改父状态的子视图
     * - Reusable components
     * - 可重用组件
     */
    @Binding var externalValue: String
    
    /**
     * @StateObject - View owns the observable object
     * @StateObject - 视图拥有可观察对象
     * 
     * Use for / 用于:
     * - View models created by this view
     * - 此视图创建的视图模型
     * - Objects that should survive view updates
     * - 应该在视图更新后存活的对象
     */
    @StateObject private var viewModel = ViewModel()
    
    /**
     * @ObservedObject - References observable object owned elsewhere
     * @ObservedObject - 引用其他地方拥有的可观察对象
     * 
     * Use for / 用于:
     * - View models passed from parent
     * - 从父级传递的视图模型
     * - Shared models
     * - 共享模型
     */
    @ObservedObject var sharedModel: SharedModel
    
    /**
     * @EnvironmentObject - Shared across view hierarchy
     * @EnvironmentObject - 在视图层次结构中共享
     * 
     * Use for / 用于:
     * - App-wide settings
     * - 应用级设置
     * - User session data
     * - 用户会话数据
     */
    @EnvironmentObject var appSettings: AppSettings
    
    /**
     * @Environment - System or custom environment values
     * @Environment - 系统或自定义环境值
     * 
     * Use for / 用于:
     * - System settings (color scheme, locale)
     * - 系统设置（配色方案、语言环境）
     * - Custom environment values
     * - 自定义环境值
     */
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // View implementation
        EmptyView()
    }
}

/**
 * PROPER STATE INITIALIZATION
 * 正确的状态初始化
 */
struct ProperInitialization: View {
    // ✅ GOOD: Use @StateObject for owned objects
    // 正确：对拥有的对象使用 @StateObject
    @StateObject private var ownedModel = MyViewModel()
    
    // ❌ BAD: Don't use @ObservedObject for owned objects
    // 错误：不要对拥有的对象使用 @ObservedObject
    // @ObservedObject private var ownedModel = MyViewModel() // Will be recreated!
    
    // ✅ GOOD: Use @ObservedObject for passed objects
    // 正确：对传递的对象使用 @ObservedObject
    @ObservedObject var passedModel: ExternalViewModel
    
    var body: some View {
        Text("Content")
    }
}
```

### 2. State Should Be Single Source of Truth / 状态应该是单一真相源

```swift
/**
 * SINGLE SOURCE OF TRUTH PRINCIPLE
 * 单一真相源原则
 * 
 * Each piece of state should have one owner
 * 每个状态应该有一个所有者
 */

// ❌ BAD: Duplicated state / 错误：重复状态
struct BadStateView: View {
    @State private var items: [Item] = []
    @State private var itemCount: Int = 0  // Duplicates items.count!
    @State private var hasItems: Bool = false  // Duplicates !items.isEmpty!
    
    var body: some View {
        VStack {
            if hasItems {  // Should use !items.isEmpty
                Text("Count: \(itemCount)")  // Should use items.count
            }
        }
    }
}

// ✅ GOOD: Single source of truth / 正确：单一真相源
struct GoodStateView: View {
    @State private var items: [Item] = []
    
    // Derived from single source / 从单一源派生
    private var itemCount: Int { items.count }
    private var hasItems: Bool { !items.isEmpty }
    
    var body: some View {
        VStack {
            if hasItems {
                Text("Count: \(itemCount)")
            }
        }
    }
}

/**
 * SHARED STATE MANAGEMENT
 * 共享状态管理
 */
class AppState: ObservableObject {
    // Single source of truth for app state
    // 应用状态的单一真相源
    @Published var user: User?
    @Published var settings: Settings
    @Published var cart: [Product] = []
    
    // Derived properties / 派生属性
    var isLoggedIn: Bool { user != nil }
    var cartCount: Int { cart.count }
    var cartTotal: Decimal {
        cart.reduce(0) { $0 + $1.price }
    }
}

struct AppView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ContentView()
            .environmentObject(appState)  // Share across hierarchy
    }
}
```

---

## Performance Optimization / 性能优化

### 1. Use Lazy Containers / 使用懒加载容器

```swift
/**
 * LAZY LOADING FOR PERFORMANCE
 * 性能的懒加载
 * 
 * Only create views when needed
 * 仅在需要时创建视图
 */

// ❌ BAD: Creates all views immediately / 错误：立即创建所有视图
struct BadListView: View {
    let items: [Item]  // 1000 items
    
    var body: some View {
        ScrollView {
            VStack {  // Creates all 1000 views!
                ForEach(items) { item in
                    ExpensiveItemView(item: item)
                }
            }
        }
    }
}

// ✅ GOOD: Creates views on demand / 正确：按需创建视图
struct GoodListView: View {
    let items: [Item]  // 1000 items
    
    var body: some View {
        ScrollView {
            LazyVStack {  // Only creates visible views
                ForEach(items) { item in
                    ExpensiveItemView(item: item)
                }
            }
        }
    }
}

/**
 * LAZY GRIDS FOR PERFORMANCE
 * 性能的懒网格
 */
struct OptimizedGridView: View {
    let items: [Item]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    ItemCardView(item: item)
                }
            }
            .padding()
        }
    }
}
```

### 2. Avoid Expensive Computations in Body / 避免在 Body 中进行昂贵计算

```swift
/**
 * COMPUTATION OPTIMIZATION
 * 计算优化
 * 
 * Move expensive operations out of body
 * 将昂贵操作移出 body
 */

// ❌ BAD: Expensive computation in body / 错误：body 中的昂贵计算
struct BadComputationView: View {
    let numbers: [Int]
    
    var body: some View {
        // This runs every time view updates!
        // 每次视图更新时都会运行！
        let sum = numbers.reduce(0, +)  // O(n) operation
        let average = Double(sum) / Double(numbers.count)
        let sorted = numbers.sorted()  // O(n log n) operation
        
        VStack {
            Text("Sum: \(sum)")
            Text("Average: \(average)")
            Text("Max: \(sorted.last ?? 0)")
        }
    }
}

// ✅ GOOD: Cache expensive computations / 正确：缓存昂贵计算
struct GoodComputationView: View {
    let numbers: [Int]
    
    // Computed once and cached / 计算一次并缓存
    private let statistics: Statistics
    
    init(numbers: [Int]) {
        self.numbers = numbers
        self.statistics = Statistics(numbers: numbers)
    }
    
    var body: some View {
        VStack {
            Text("Sum: \(statistics.sum)")
            Text("Average: \(statistics.average)")
            Text("Max: \(statistics.max)")
        }
    }
}

struct Statistics {
    let sum: Int
    let average: Double
    let max: Int
    
    init(numbers: [Int]) {
        self.sum = numbers.reduce(0, +)
        self.average = numbers.isEmpty ? 0 : Double(sum) / Double(numbers.count)
        self.max = numbers.max() ?? 0
    }
}
```

### 3. Use EquatableView for Expensive Views / 对昂贵视图使用 EquatableView

```swift
/**
 * EQUATABLE VIEW FOR PERFORMANCE
 * 性能的 EquatableView
 * 
 * Skip unnecessary updates
 * 跳过不必要的更新
 */

struct ExpensiveChartView: View, Equatable {
    let data: ChartData
    
    var body: some View {
        // Expensive rendering logic
        // 昂贵的渲染逻辑
        Canvas { context, size in
            // Complex drawing operations
        }
    }
    
    // Only re-render when data actually changes
    // 仅在数据实际更改时重新渲染
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data.id == rhs.data.id &&
        lhs.data.lastModified == rhs.data.lastModified
    }
}

// Usage / 使用
struct ContentView: View {
    @State private var chartData: ChartData
    
    var body: some View {
        ExpensiveChartView(data: chartData)
            .equatable()  // Use equatable checking
    }
}
```

---

## Layout and Composition / 布局和组合

### 1. Adaptive Layouts / 自适应布局

```swift
/**
 * ADAPTIVE LAYOUT PATTERNS
 * 自适应布局模式
 * 
 * Support different screen sizes and orientations
 * 支持不同的屏幕尺寸和方向
 */

struct AdaptiveLayoutView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone portrait / iPhone 竖屏
            compactLayout
        } else {
            // iPad or iPhone landscape / iPad 或 iPhone 横屏
            regularLayout
        }
    }
    
    private var compactLayout: some View {
        VStack {
            HeaderView()
            ContentView()
            FooterView()
        }
    }
    
    private var regularLayout: some View {
        HStack {
            SidebarView()
            VStack {
                HeaderView()
                ContentView()
                FooterView()
            }
        }
    }
}

/**
 * VIEWTHATFITS FOR ADAPTIVE CONTENT
 * 自适应内容的 ViewThatFits
 * 
 * iOS 16+ feature for automatic layout selection
 * iOS 16+ 自动布局选择功能
 */
struct AdaptiveContentView: View {
    let items: [Item]
    
    var body: some View {
        ViewThatFits {
            // Try horizontal layout first / 首先尝试水平布局
            HStack {
                ForEach(items) { item in
                    ItemView(item: item)
                }
            }
            
            // Fall back to vertical if doesn't fit / 如果不适合则回退到垂直
            VStack {
                ForEach(items) { item in
                    ItemView(item: item)
                }
            }
            
            // Last resort: scrollable / 最后手段：可滚动
            ScrollView {
                VStack {
                    ForEach(items) { item in
                        ItemView(item: item)
                    }
                }
            }
        }
    }
}
```

### 2. Safe Area Management / 安全区域管理

```swift
/**
 * SAFE AREA BEST PRACTICES
 * 安全区域最佳实践
 */

struct SafeAreaExampleView: View {
    var body: some View {
        ZStack {
            // Background ignores safe area / 背景忽略安全区域
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content respects safe area / 内容遵守安全区域
            VStack {
                headerView
                    .padding(.top)  // Additional padding if needed
                
                ScrollView {
                    contentView
                }
                
                bottomBar
                    .background(.ultraThinMaterial)
            }
        }
    }
    
    private var headerView: some View {
        Text("Header")
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
    }
    
    private var contentView: some View {
        VStack {
            ForEach(0..<20) { index in
                Text("Item \(index)")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
    
    private var bottomBar: some View {
        HStack {
            Button("Action 1") { }
            Spacer()
            Button("Action 2") { }
        }
        .padding()
        .padding(.bottom)  // Extra padding for home indicator
    }
}
```

---

## Navigation Patterns / 导航模式

### 1. iOS Version Adaptive Navigation / iOS 版本自适应导航

```swift
/**
 * NAVIGATION THAT WORKS ON iOS 15 AND 16+
 * 适用于 iOS 15 和 16+ 的导航
 */

struct AdaptiveNavigationView: View {
    @State private var path = NavigationPath()
    @State private var selectedItem: Item?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            // iOS 16+: Use NavigationStack / 使用 NavigationStack
            NavigationStack(path: $path) {
                ItemListView()
                    .navigationDestination(for: Item.self) { item in
                        ItemDetailView(item: item)
                    }
            }
        } else {
            // iOS 15: Use NavigationView / 使用 NavigationView
            NavigationView {
                ItemListView()
                    .background(
                        NavigationLink(
                            destination: selectedItem.map { ItemDetailView(item: $0) },
                            isActive: .constant(selectedItem != nil),
                            label: { EmptyView() }
                        )
                    )
            }
        }
    }
}

/**
 * PROGRAMMATIC NAVIGATION
 * 程序化导航
 */
@available(iOS 16.0, *)
struct ProgrammaticNavigationView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Go to Settings") {
                    path.append(Route.settings)
                }
                
                Button("Go to Profile") {
                    path.append(Route.profile(userId: "123"))
                }
                
                Button("Reset Navigation") {
                    path = NavigationPath()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .settings:
                    SettingsView()
                case .profile(let userId):
                    ProfileView(userId: userId)
                }
            }
        }
    }
}

enum Route: Hashable {
    case settings
    case profile(userId: String)
}
```

---

## Data Flow / 数据流

### 1. Unidirectional Data Flow / 单向数据流

```swift
/**
 * UNIDIRECTIONAL DATA FLOW PATTERN
 * 单向数据流模式
 * 
 * Data flows in one direction: Parent -> Child
 * 数据单向流动：父级 -> 子级
 * Events flow up: Child -> Parent
 * 事件向上流动：子级 -> 父级
 */

struct ParentView: View {
    @State private var data = DataModel()
    
    var body: some View {
        VStack {
            // Pass data down / 向下传递数据
            ChildView(
                data: data,
                onUpdate: updateData,
                onDelete: deleteData
            )
        }
    }
    
    // Handle events from child / 处理来自子级的事件
    private func updateData(_ newData: DataModel) {
        data = newData
    }
    
    private func deleteData() {
        data = DataModel()
    }
}

struct ChildView: View {
    let data: DataModel
    let onUpdate: (DataModel) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            Text(data.title)
            
            // Send events up / 向上发送事件
            Button("Update") {
                let newData = data.updated()
                onUpdate(newData)
            }
            
            Button("Delete") {
                onDelete()
            }
        }
    }
}
```

### 2. Dependency Injection / 依赖注入

```swift
/**
 * DEPENDENCY INJECTION PATTERNS
 * 依赖注入模式
 */

// Protocol for testability / 可测试性协议
protocol DataServiceProtocol {
    func fetchData() async throws -> [Item]
    func saveData(_ items: [Item]) async throws
}

// Real implementation / 真实实现
class DataService: DataServiceProtocol {
    func fetchData() async throws -> [Item] {
        // Real network call
        return []
    }
    
    func saveData(_ items: [Item]) async throws {
        // Real save operation
    }
}

// Mock for testing / 测试模拟
class MockDataService: DataServiceProtocol {
    var mockItems: [Item] = []
    
    func fetchData() async throws -> [Item] {
        return mockItems
    }
    
    func saveData(_ items: [Item]) async throws {
        mockItems = items
    }
}

// ViewModel with dependency injection / 带依赖注入的 ViewModel
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    private let dataService: DataServiceProtocol
    
    // Inject dependency / 注入依赖
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
    }
    
    func loadItems() async {
        do {
            items = try await dataService.fetchData()
        } catch {
            print("Error loading items: \(error)")
        }
    }
}

// Usage in view / 在视图中使用
struct ItemsView: View {
    @StateObject private var viewModel: ItemViewModel
    
    // Dependency injection in init / 在 init 中依赖注入
    init(dataService: DataServiceProtocol = DataService()) {
        _viewModel = StateObject(wrappedValue: ItemViewModel(dataService: dataService))
    }
    
    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .task {
            await viewModel.loadItems()
        }
    }
}

// Testing / 测试
func testItemsView() {
    let mockService = MockDataService()
    mockService.mockItems = [Item(id: "1", name: "Test")]
    
    let view = ItemsView(dataService: mockService)
    // Test the view with mock data
}
```

---

## Accessibility / 可访问性

### Best Practices for Accessibility / 可访问性最佳实践

```swift
/**
 * ACCESSIBILITY IMPLEMENTATION
 * 可访问性实现
 * 
 * Make your app usable by everyone
 * 让每个人都能使用你的应用
 */

struct AccessibleView: View {
    @State private var count = 0
    @State private var isEnabled = true
    
    var body: some View {
        VStack(spacing: 20) {
            /**
             * Labels and hints / 标签和提示
             */
            Button(action: increment) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Increment")
                }
            }
            .accessibilityLabel("Increment counter")
            .accessibilityHint("Adds one to the current count")
            .accessibilityValue("\(count)")
            
            /**
             * Custom actions / 自定义操作
             */
            ItemCard()
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Item card")
                .accessibilityCustomAction("Edit") {
                    editItem()
                    return true
                }
                .accessibilityCustomAction("Delete") {
                    deleteItem()
                    return true
                }
            
            /**
             * Adjustable trait / 可调整特征
             */
            Slider(value: .constant(0.5))
                .accessibilityLabel("Volume")
                .accessibilityValue("50 percent")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment:
                        // Increase volume
                        break
                    case .decrement:
                        // Decrease volume
                        break
                    @unknown default:
                        break
                    }
                }
            
            /**
             * Hidden from accessibility / 从可访问性隐藏
             */
            Image(systemName: "decorative.image")
                .accessibilityHidden(true)  // Decorative only
            
            /**
             * Grouped elements / 分组元素
             */
            HStack {
                Text("Status:")
                Image(systemName: isEnabled ? "checkmark" : "xmark")
                Text(isEnabled ? "Enabled" : "Disabled")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Status: \(isEnabled ? "Enabled" : "Disabled")")
        }
    }
    
    private func increment() {
        count += 1
    }
    
    private func editItem() {
        // Edit logic
    }
    
    private func deleteItem() {
        // Delete logic
    }
}

struct ItemCard: View {
    var body: some View {
        VStack {
            Text("Item Title")
            Text("Item Description")
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
```

---

## Testing / 测试

### SwiftUI View Testing Strategies / SwiftUI 视图测试策略

```swift
/**
 * TESTING BEST PRACTICES
 * 测试最佳实践
 */

import XCTest
import SwiftUI
import ViewInspector  // Third-party testing library

// Testable view model / 可测试的视图模型
class TestableViewModel: ObservableObject {
    @Published var items: [String] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service: ServiceProtocol
    
    init(service: ServiceProtocol) {
        self.service = service
    }
    
    func loadItems() async {
        isLoading = true
        do {
            items = try await service.fetchItems()
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

// Unit tests for view model / 视图模型的单元测试
class ViewModelTests: XCTestCase {
    func testLoadItemsSuccess() async {
        // Arrange / 准备
        let mockService = MockService()
        mockService.mockItems = ["Item 1", "Item 2"]
        let viewModel = TestableViewModel(service: mockService)
        
        // Act / 执行
        await viewModel.loadItems()
        
        // Assert / 断言
        XCTAssertEqual(viewModel.items.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testLoadItemsFailure() async {
        // Arrange / 准备
        let mockService = MockService()
        mockService.shouldFail = true
        let viewModel = TestableViewModel(service: mockService)
        
        // Act / 执行
        await viewModel.loadItems()
        
        // Assert / 断言
        XCTAssertTrue(viewModel.items.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
}

// View testing with ViewInspector / 使用 ViewInspector 测试视图
struct TestableView: View {
    @ObservedObject var viewModel: TestableViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .accessibilityIdentifier("loadingIndicator")
            } else if let error = viewModel.error {
                Text(error.localizedDescription)
                    .accessibilityIdentifier("errorText")
            } else {
                List(viewModel.items, id: \.self) { item in
                    Text(item)
                }
                .accessibilityIdentifier("itemsList")
            }
        }
    }
}

class ViewTests: XCTestCase {
    func testShowsLoadingIndicator() throws {
        // Arrange / 准备
        let viewModel = TestableViewModel(service: MockService())
        viewModel.isLoading = true
        let view = TestableView(viewModel: viewModel)
        
        // Act & Assert / 执行和断言
        let inspection = try view.inspect()
        XCTAssertNoThrow(try inspection.find(viewWithAccessibilityIdentifier: "loadingIndicator"))
    }
    
    func testShowsErrorMessage() throws {
        // Arrange / 准备
        let viewModel = TestableViewModel(service: MockService())
        viewModel.error = TestError.sample
        let view = TestableView(viewModel: viewModel)
        
        // Act & Assert / 执行和断言
        let inspection = try view.inspect()
        let errorText = try inspection.find(viewWithAccessibilityIdentifier: "errorText").text()
        XCTAssertEqual(try errorText.string(), TestError.sample.localizedDescription)
    }
}
```

---

## Common Pitfalls / 常见陷阱

### 1. Avoid These Common Mistakes / 避免这些常见错误

```swift
/**
 * COMMON PITFALLS AND HOW TO AVOID THEM
 * 常见陷阱及如何避免
 */

// ❌ PITFALL 1: Creating @StateObject in computed property
// 陷阱 1：在计算属性中创建 @StateObject
struct BadView1: View {
    var body: some View {
        SubView(viewModel: ViewModel())  // ❌ Recreated on every render!
    }
}

// ✅ SOLUTION: Use @StateObject
struct GoodView1: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        SubView(viewModel: viewModel)
    }
}

// ❌ PITFALL 2: Capturing self in escaping closure
// 陷阱 2：在逃逸闭包中捕获 self
class BadViewModel: ObservableObject {
    func loadData() {
        APIClient.fetch { data in
            self.processData(data)  // ❌ Potential retain cycle!
        }
    }
}

// ✅ SOLUTION: Use weak self
class GoodViewModel: ObservableObject {
    func loadData() {
        APIClient.fetch { [weak self] data in
            self?.processData(data)
        }
    }
}

// ❌ PITFALL 3: Heavy computation in View init
// 陷阱 3：在视图 init 中进行繁重计算
struct BadView3: View {
    let items: [Item]
    let processedData: ProcessedData
    
    init(items: [Item]) {
        self.items = items
        // ❌ This runs every time parent updates!
        self.processedData = ExpensiveProcessor.process(items)
    }
}

// ✅ SOLUTION: Use onAppear or task
struct GoodView3: View {
    let items: [Item]
    @State private var processedData: ProcessedData?
    
    var body: some View {
        ContentView(data: processedData)
            .task {
                processedData = await ExpensiveProcessor.process(items)
            }
    }
}

// ❌ PITFALL 4: Not handling optional binding updates
// 陷阱 4：不处理可选绑定更新
struct BadView4: View {
    @Binding var optionalValue: String?
    
    var body: some View {
        // ❌ Crashes if optionalValue is nil!
        TextField("Text", text: $optionalValue!)
    }
}

// ✅ SOLUTION: Provide default binding
struct GoodView4: View {
    @Binding var optionalValue: String?
    
    var body: some View {
        TextField("Text", text: Binding(
            get: { optionalValue ?? "" },
            set: { optionalValue = $0.isEmpty ? nil : $0 }
        ))
    }
}
```

---

## Summary / 总结

### Golden Rules of SwiftUI / SwiftUI 黄金法则

1. **Keep views small and focused** / **保持视图小而专注**
2. **Use the right property wrapper** / **使用正确的属性包装器**
3. **Maintain single source of truth** / **维护单一真相源**
4. **Optimize for performance** / **优化性能**
5. **Support accessibility** / **支持可访问性**
6. **Write testable code** / **编写可测试代码**
7. **Follow platform conventions** / **遵循平台约定**
8. **Handle all states (loading, error, empty, success)** / **处理所有状态**

### Quick Reference Checklist / 快速参考清单

- [ ] Views under 100 lines / 视图少于 100 行
- [ ] Maximum 2 levels of nesting / 最多 2 级嵌套
- [ ] No expensive computations in body / body 中没有昂贵计算
- [ ] Using lazy containers for lists / 对列表使用懒容器
- [ ] Proper state management / 正确的状态管理
- [ ] Accessibility labels and hints / 可访问性标签和提示
- [ ] Error handling implemented / 实现错误处理
- [ ] Loading states shown / 显示加载状态
- [ ] Memory leaks checked / 检查内存泄漏
- [ ] Unit tests written / 编写单元测试

Remember: SwiftUI is declarative. Describe what you want, not how to get there.

记住：SwiftUI 是声明式的。描述你想要什么，而不是如何到达那里。