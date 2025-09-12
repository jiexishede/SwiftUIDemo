# SOLID Principles in Swift / Swift 中的 SOLID 原则

## Overview / 概述

SOLID principles are five design principles that help create maintainable, scalable, and robust software. In Swift and SwiftUI development, these principles guide us to write better code.

SOLID 原则是五个设计原则，帮助创建可维护、可扩展和健壮的软件。在 Swift 和 SwiftUI 开发中，这些原则指导我们编写更好的代码。

---

## 1. Single Responsibility Principle (SRP) / 单一职责原则

### Definition / 定义
A class should have only one reason to change, meaning it should have only one job or responsibility.

一个类应该只有一个改变的理由，意味着它应该只有一个工作或职责。

### ❌ Bad Example / 错误示例
```swift
// This class violates SRP - it handles too many responsibilities
// 这个类违反了 SRP - 它处理了太多职责
class UserManager {
    var users: [User] = []
    
    // Responsibility 1: User data management / 职责1：用户数据管理
    func addUser(_ user: User) {
        users.append(user)
    }
    
    // Responsibility 2: Data persistence / 职责2：数据持久化
    func saveToDatabase() {
        // Database saving logic / 数据库保存逻辑
    }
    
    // Responsibility 3: Email notifications / 职责3：邮件通知
    func sendWelcomeEmail(to user: User) {
        // Email sending logic / 发送邮件逻辑
    }
    
    // Responsibility 4: Data validation / 职责4：数据验证
    func validateUser(_ user: User) -> Bool {
        // Validation logic / 验证逻辑
        return true
    }
}
```

### ✅ Good Example / 正确示例
```swift
// Each class has a single responsibility / 每个类有单一职责

// Responsibility: User data management / 职责：用户数据管理
class UserRepository {
    private var users: [User] = []
    
    func add(_ user: User) {
        users.append(user)
    }
    
    func remove(_ user: User) {
        users.removeAll { $0.id == user.id }
    }
    
    func getAll() -> [User] {
        return users
    }
}

// Responsibility: Data persistence / 职责：数据持久化
class UserPersistenceService {
    func save(_ users: [User]) async throws {
        // Only handles saving to database
        // 只处理保存到数据库
    }
    
    func load() async throws -> [User] {
        // Only handles loading from database
        // 只处理从数据库加载
    }
}

// Responsibility: Email notifications / 职责：邮件通知
class EmailService {
    func sendWelcomeEmail(to user: User) async throws {
        // Only handles email sending
        // 只处理邮件发送
    }
}

// Responsibility: User validation / 职责：用户验证
class UserValidator {
    func validate(_ user: User) -> ValidationResult {
        // Only handles validation logic
        // 只处理验证逻辑
        if user.email.isEmpty {
            return .failure("Email is required")
        }
        return .success
    }
}
```

### SwiftUI Example / SwiftUI 示例
```swift
// ❌ BAD: View doing too much / 错误：视图做了太多事情
struct UserProfileView: View {
    @State private var user: User
    
    var body: some View {
        VStack {
            // View logic
        }
    }
    
    // ❌ Network call in view / 在视图中进行网络调用
    func fetchUserData() async {
        // API call
    }
    
    // ❌ Business logic in view / 在视图中包含业务逻辑
    func calculateUserScore() -> Int {
        // Complex calculation
    }
}

// ✅ GOOD: Separated concerns / 正确：分离的关注点
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.userName)
            Text("Score: \(viewModel.userScore)")
        }
        .task {
            await viewModel.loadUser()
        }
    }
}

class UserProfileViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userScore = 0
    
    private let userService: UserService
    private let scoreCalculator: ScoreCalculator
    
    init(userService: UserService = .init(),
         scoreCalculator: ScoreCalculator = .init()) {
        self.userService = userService
        self.scoreCalculator = scoreCalculator
    }
    
    func loadUser() async {
        // Delegates to appropriate services
        // 委托给适当的服务
    }
}
```

---

## 2. Open/Closed Principle (OCP) / 开闭原则

### Definition / 定义
Software entities should be open for extension but closed for modification.

软件实体应该对扩展开放，对修改关闭。

### ❌ Bad Example / 错误示例
```swift
// This violates OCP - we need to modify the class to add new shapes
// 这违反了 OCP - 我们需要修改类来添加新形状
class AreaCalculator {
    func calculateArea(shape: String, width: Double, height: Double) -> Double {
        switch shape {
        case "rectangle":
            return width * height
        case "triangle":
            return (width * height) / 2
        // ❌ Need to modify this class to add new shapes
        // 需要修改这个类来添加新形状
        default:
            return 0
        }
    }
}
```

### ✅ Good Example / 正确示例
```swift
// Protocol defines the contract / 协议定义契约
protocol Shape {
    func area() -> Double
}

// Extension without modification / 扩展而不修改
struct Rectangle: Shape {
    let width: Double
    let height: Double
    
    func area() -> Double {
        return width * height
    }
}

struct Triangle: Shape {
    let base: Double
    let height: Double
    
    func area() -> Double {
        return (base * height) / 2
    }
}

// New shape can be added without modifying existing code
// 可以添加新形状而无需修改现有代码
struct Circle: Shape {
    let radius: Double
    
    func area() -> Double {
        return .pi * radius * radius
    }
}

// Calculator is closed for modification but open for extension
// 计算器对修改关闭但对扩展开放
class AreaCalculator {
    func calculateArea(for shape: Shape) -> Double {
        return shape.area()
    }
}
```

### SwiftUI Example with ViewModifier / 使用 ViewModifier 的 SwiftUI 示例
```swift
// Base styling protocol / 基础样式协议
protocol CardStyling: ViewModifier {
    var backgroundColor: Color { get }
    var cornerRadius: CGFloat { get }
}

// Different card styles without modifying base / 不同的卡片样式而不修改基础
struct StandardCardStyle: CardStyling {
    let backgroundColor = Color.white
    let cornerRadius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

struct PremiumCardStyle: CardStyling {
    let backgroundColor = Color.gold
    let cornerRadius: CGFloat = 15
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow),
                alignment: .topTrailing
            )
    }
}

// Usage - open for extension / 使用 - 对扩展开放
extension View {
    func cardStyle<S: CardStyling>(_ style: S) -> some View {
        modifier(style)
    }
}
```

---

## 3. Liskov Substitution Principle (LSP) / 里氏替换原则

### Definition / 定义
Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

父类的对象应该可以被其子类的对象替换，而不破坏应用程序。

### ❌ Bad Example / 错误示例
```swift
class Bird {
    func fly() {
        print("Flying in the sky")
    }
}

// ❌ Penguin can't fly, violates LSP
// 企鹅不能飞，违反 LSP
class Penguin: Bird {
    override func fly() {
        fatalError("Penguins can't fly!") // Breaking the contract
    }
}

// This code will crash / 这段代码会崩溃
func makeBirdFly(_ bird: Bird) {
    bird.fly() // Expects all birds to fly / 期望所有鸟都能飞
}
```

### ✅ Good Example / 正确示例
```swift
// Better design with proper abstraction / 更好的设计与适当的抽象
protocol Bird {
    func eat()
    func sleep()
}

protocol FlyingBird: Bird {
    func fly()
}

class Sparrow: FlyingBird {
    func eat() { print("Eating seeds") }
    func sleep() { print("Sleeping in nest") }
    func fly() { print("Flying in the sky") }
}

class Penguin: Bird {
    func eat() { print("Eating fish") }
    func sleep() { print("Sleeping on ice") }
    func swim() { print("Swimming in water") }
}

// Now we can safely use the appropriate abstraction
// 现在我们可以安全地使用适当的抽象
func makeFlyingBirdFly(_ bird: FlyingBird) {
    bird.fly() // Only flying birds can be passed / 只能传递会飞的鸟
}
```

### SwiftUI Example / SwiftUI 示例
```swift
// Protocol for list items / 列表项协议
protocol ListItemDisplayable {
    var id: String { get }
    var title: String { get }
    var subtitle: String? { get }
}

// Different implementations that respect the contract
// 遵守契约的不同实现
struct Product: ListItemDisplayable {
    let id: String
    let title: String
    let subtitle: String?
    let price: Double
}

struct Category: ListItemDisplayable {
    let id: String
    let title: String
    var subtitle: String? { 
        return "\(itemCount) items"
    }
    let itemCount: Int
}

// View that works with any ListItemDisplayable
// 适用于任何 ListItemDisplayable 的视图
struct ListItemView: View {
    let item: ListItemDisplayable
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

---

## 4. Interface Segregation Principle (ISP) / 接口隔离原则

### Definition / 定义
Clients should not be forced to depend on interfaces they don't use.

客户端不应该被强制依赖它们不使用的接口。

### ❌ Bad Example / 错误示例
```swift
// Fat interface that forces unnecessary implementations
// 强制不必要实现的臃肿接口
protocol Worker {
    func work()
    func eat()
    func sleep()
    func attendMeeting()
    func writeCode()
    func manageTeam()
}

// ❌ Developer doesn't manage teams but must implement it
// 开发者不管理团队但必须实现它
class Developer: Worker {
    func work() { }
    func eat() { }
    func sleep() { }
    func attendMeeting() { }
    func writeCode() { }
    func manageTeam() { 
        // Forced to implement but not used / 被迫实现但不使用
    }
}
```

### ✅ Good Example / 正确示例
```swift
// Segregated interfaces / 隔离的接口
protocol Workable {
    func work()
}

protocol Eatable {
    func eat()
}

protocol Sleepable {
    func sleep()
}

protocol Codeable {
    func writeCode()
}

protocol Manageable {
    func manageTeam()
}

// Classes only implement what they need / 类只实现它们需要的
class Developer: Workable, Eatable, Sleepable, Codeable {
    func work() { print("Working") }
    func eat() { print("Eating") }
    func sleep() { print("Sleeping") }
    func writeCode() { print("Writing code") }
}

class Manager: Workable, Eatable, Sleepable, Manageable {
    func work() { print("Working") }
    func eat() { print("Eating") }
    func sleep() { print("Sleeping") }
    func manageTeam() { print("Managing team") }
}

class Robot: Workable, Codeable {
    func work() { print("Working 24/7") }
    func writeCode() { print("Generating code") }
    // Doesn't need eat or sleep / 不需要吃或睡
}
```

### SwiftUI Example / SwiftUI 示例
```swift
// Segregated view capability protocols / 隔离的视图能力协议
protocol Refreshable {
    func refresh() async
}

protocol Searchable {
    func search(query: String) async -> [Any]
}

protocol Sortable {
    var sortOptions: [SortOption] { get }
    func sort(by option: SortOption)
}

// Views only adopt needed capabilities / 视图只采用需要的能力
struct SimpleListView: View {
    // No protocols needed for simple list / 简单列表不需要协议
    var body: some View {
        List {
            // Simple content
        }
    }
}

struct RefreshableListView: View, Refreshable {
    func refresh() async {
        // Only implements refresh / 只实现刷新
    }
    
    var body: some View {
        List {
            // Content
        }
        .refreshable {
            await refresh()
        }
    }
}

struct AdvancedListView: View, Refreshable, Searchable, Sortable {
    // Implements all capabilities / 实现所有能力
    func refresh() async { }
    func search(query: String) async -> [Any] { [] }
    var sortOptions: [SortOption] { [] }
    func sort(by option: SortOption) { }
    
    var body: some View {
        // Complex list with all features
    }
}
```

---

## 5. Dependency Inversion Principle (DIP) / 依赖倒置原则

### Definition / 定义
High-level modules should not depend on low-level modules. Both should depend on abstractions.

高层模块不应该依赖低层模块。两者都应该依赖抽象。

### ❌ Bad Example / 错误示例
```swift
// High-level class directly depends on low-level implementation
// 高层类直接依赖低层实现
class EmailService {
    func sendEmail(to: String, message: String) {
        print("Sending email to \(to)")
    }
}

class UserRegistration {
    private let emailService = EmailService() // ❌ Direct dependency
    
    func registerUser(email: String) {
        // Registration logic
        emailService.sendEmail(to: email, message: "Welcome!")
    }
}
// Problem: Can't test without sending real emails
// 问题：不发送真实邮件就无法测试
```

### ✅ Good Example / 正确示例
```swift
// Abstraction (protocol) / 抽象（协议）
protocol EmailServiceProtocol {
    func sendEmail(to: String, message: String) async throws
}

// Low-level implementation / 低层实现
class EmailService: EmailServiceProtocol {
    func sendEmail(to: String, message: String) async throws {
        // Real email sending
    }
}

// Mock for testing / 测试用模拟
class MockEmailService: EmailServiceProtocol {
    var sentEmails: [(to: String, message: String)] = []
    
    func sendEmail(to: String, message: String) async throws {
        sentEmails.append((to, message))
    }
}

// High-level class depends on abstraction / 高层类依赖抽象
class UserRegistration {
    private let emailService: EmailServiceProtocol
    
    // Dependency injection / 依赖注入
    init(emailService: EmailServiceProtocol = EmailService()) {
        self.emailService = emailService
    }
    
    func registerUser(email: String) async throws {
        // Registration logic
        try await emailService.sendEmail(to: email, message: "Welcome!")
    }
}

// Testing becomes easy / 测试变得容易
func testUserRegistration() async throws {
    let mockEmail = MockEmailService()
    let registration = UserRegistration(emailService: mockEmail)
    
    try await registration.registerUser(email: "test@example.com")
    
    assert(mockEmail.sentEmails.count == 1)
    assert(mockEmail.sentEmails.first?.to == "test@example.com")
}
```

### SwiftUI + TCA Example / SwiftUI + TCA 示例
```swift
// Dependencies protocol / 依赖协议
protocol DataServiceProtocol {
    func fetchData() async throws -> [Item]
}

// Real implementation / 真实实现
class APIDataService: DataServiceProtocol {
    func fetchData() async throws -> [Item] {
        // Real API call
        return []
    }
}

// Test implementation / 测试实现
class MockDataService: DataServiceProtocol {
    var mockData: [Item] = []
    
    func fetchData() async throws -> [Item] {
        return mockData
    }
}

// TCA Reducer with dependency injection / 带依赖注入的 TCA Reducer
struct ItemListFeature: Reducer {
    struct State: Equatable {
        var items: [Item] = []
        var isLoading = false
    }
    
    enum Action: Equatable {
        case fetchItems
        case itemsResponse(TaskResult<[Item]>)
    }
    
    // Dependency injection / 依赖注入
    @Dependency(\.dataService) var dataService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchItems:
                state.isLoading = true
                return .run { send in
                    await send(.itemsResponse(
                        TaskResult { try await dataService.fetchData() }
                    ))
                }
                
            case let .itemsResponse(.success(items)):
                state.items = items
                state.isLoading = false
                return .none
                
            case .itemsResponse(.failure):
                state.isLoading = false
                return .none
            }
        }
    }
}

// Dependency key / 依赖键
private enum DataServiceKey: DependencyKey {
    static let liveValue: DataServiceProtocol = APIDataService()
    static let testValue: DataServiceProtocol = MockDataService()
}

extension DependencyValues {
    var dataService: DataServiceProtocol {
        get { self[DataServiceKey.self] }
        set { self[DataServiceKey.self] = newValue }
    }
}
```

---

## Summary / 总结

### Benefits of Following SOLID / 遵循 SOLID 的好处

1. **Maintainability / 可维护性**
   - Code is easier to understand and modify
   - 代码更容易理解和修改

2. **Testability / 可测试性**
   - Components can be tested in isolation
   - 组件可以独立测试

3. **Flexibility / 灵活性**
   - Easy to add new features without breaking existing ones
   - 易于添加新功能而不破坏现有功能

4. **Reusability / 可重用性**
   - Components can be reused in different contexts
   - 组件可以在不同上下文中重用

5. **Reduced Coupling / 减少耦合**
   - Changes in one part don't affect others
   - 一部分的更改不会影响其他部分

### Quick Reference / 快速参考

| Principle | Key Concept | SwiftUI Application |
|-----------|------------|-------------------|
| **SRP** | One responsibility per class | Separate Views, ViewModels, and Services |
| **OCP** | Extend, don't modify | Use protocols and extensions |
| **LSP** | Substitutable subclasses | Proper protocol hierarchies |
| **ISP** | Small, focused interfaces | Split large protocols |
| **DIP** | Depend on abstractions | Use dependency injection |

### Remember / 记住

- SOLID principles are guidelines, not rigid rules / SOLID 原则是指导方针，不是刚性规则
- Apply them where they add value / 在它们增加价值的地方应用
- Don't over-engineer simple problems / 不要过度设计简单问题
- Balance is key / 平衡是关键