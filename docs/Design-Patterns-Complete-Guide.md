# Complete Design Patterns Guide for Swift / Swift 完整设计模式指南

## Table of Contents / 目录

1. [Creational Patterns / 创建型模式](#creational-patterns)
   - Singleton / 单例模式
   - Factory Method / 工厂方法模式
   - Abstract Factory / 抽象工厂模式
   - Builder / 建造者模式
   - Prototype / 原型模式

2. [Structural Patterns / 结构型模式](#structural-patterns)
   - Adapter / 适配器模式
   - Bridge / 桥接模式
   - Composite / 组合模式
   - Decorator / 装饰器模式
   - Facade / 外观模式
   - Flyweight / 享元模式
   - Proxy / 代理模式

3. [Behavioral Patterns / 行为型模式](#behavioral-patterns)
   - Chain of Responsibility / 责任链模式
   - Command / 命令模式
   - Iterator / 迭代器模式
   - Mediator / 中介者模式
   - Memento / 备忘录模式
   - Observer / 观察者模式
   - State / 状态模式
   - Strategy / 策略模式
   - Template Method / 模板方法模式
   - Visitor / 访问者模式

---

## Creational Patterns / 创建型模式

### 1. Singleton Pattern / 单例模式

```swift
/**
 * SINGLETON PATTERN - 单例模式
 * 
 * INTENT / 意图:
 * Ensure a class has only one instance and provide global access to it
 * 确保类只有一个实例，并提供全局访问点
 * 
 * WHEN TO USE / 使用场景:
 * - Managing shared resources (database, file system)
 * - 管理共享资源（数据库、文件系统）
 * - Coordinating actions across the system
 * - 协调系统中的操作
 * - Caching expensive objects
 * - 缓存昂贵的对象
 * 
 * PROS / 优点:
 * - Controlled access to single instance
 * - 控制对单一实例的访问
 * - Reduced memory footprint
 * - 减少内存占用
 * - Global access point
 * - 全局访问点
 * 
 * CONS / 缺点:
 * - Hard to unit test
 * - 难以单元测试
 * - Hidden dependencies
 * - 隐藏的依赖关系
 * - Violates Single Responsibility Principle
 * - 违反单一职责原则
 */

// Thread-safe singleton implementation / 线程安全的单例实现
final class NetworkManager {
    /**
     * Static constant ensures thread-safe initialization
     * 静态常量确保线程安全的初始化
     * Swift guarantees that static properties are initialized only once
     * Swift 保证静态属性只初始化一次
     */
    static let shared = NetworkManager()
    
    // Private properties / 私有属性
    private let session: URLSession
    private let cache = NSCache<NSString, NSData>()
    private let queue = DispatchQueue(label: "NetworkManager.queue")
    
    /**
     * Private initializer prevents external instantiation
     * 私有初始化器防止外部实例化
     * This is crucial for maintaining singleton pattern
     * 这对于维护单例模式至关重要
     */
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
        
        print("NetworkManager initialized - this should print only once")
        print("NetworkManager 已初始化 - 这应该只打印一次")
    }
    
    /**
     * USAGE EXAMPLE / 使用示例:
     * 
     * // Anywhere in your app / 在应用的任何地方
     * NetworkManager.shared.request(url: "https://api.example.com/data") { result in
     *     switch result {
     *     case .success(let data):
     *         print("Data received: \(data)")
     *     case .failure(let error):
     *         print("Error: \(error)")
     *     }
     * }
     * 
     * // In SwiftUI View / 在 SwiftUI 视图中
     * struct ContentView: View {
     *     @State private var data: Data?
     *     
     *     var body: some View {
     *         Text("Content")
     *             .task {
     *                 data = try? await NetworkManager.shared.fetchData(from: url)
     *             }
     *     }
     * }
     */
    
    func request(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Check cache first / 首先检查缓存
        if let cachedData = cache.object(forKey: url.absoluteString as NSString) {
            completion(.success(cachedData as Data))
            return
        }
        
        // Perform network request / 执行网络请求
        session.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                // Cache the result / 缓存结果
                self?.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                completion(.success(data))
            }
        }.resume()
    }
    
    // Async/await version for modern Swift / 现代 Swift 的 async/await 版本
    func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return data
    }
}

enum NetworkError: Error {
    case invalidURL
}
```

### 2. Factory Method Pattern / 工厂方法模式

```swift
/**
 * FACTORY METHOD PATTERN - 工厂方法模式
 * 
 * INTENT / 意图:
 * Define an interface for creating objects, but let subclasses decide which class to instantiate
 * 定义创建对象的接口，但让子类决定实例化哪个类
 * 
 * WHEN TO USE / 使用场景:
 * - When you don't know exact types and dependencies of objects beforehand
 * - 当你事先不知道对象的确切类型和依赖关系时
 * - When you want to provide library users a way to extend components
 * - 当你想为库用户提供扩展组件的方法时
 * - When you want to reuse existing objects instead of creating new ones
 * - 当你想重用现有对象而不是创建新对象时
 */

// Product protocol / 产品协议
protocol Button {
    func render() -> String
    func onClick()
}

// Concrete products / 具体产品
struct IOSButton: Button {
    let title: String
    
    func render() -> String {
        return "iOS Button: \(title)"
    }
    
    func onClick() {
        print("iOS button tapped with haptic feedback")
    }
}

struct AndroidButton: Button {
    let title: String
    
    func render() -> String {
        return "Android Button: \(title)"
    }
    
    func onClick() {
        print("Android button clicked with ripple effect")
    }
}

struct WebButton: Button {
    let title: String
    
    func render() -> String {
        return "<button>\(title)</button>"
    }
    
    func onClick() {
        print("Web button clicked")
    }
}

// Factory protocol / 工厂协议
protocol ButtonFactory {
    func createButton(title: String) -> Button
}

// Concrete factories / 具体工厂
class IOSButtonFactory: ButtonFactory {
    func createButton(title: String) -> Button {
        /**
         * Factory encapsulates iOS-specific button creation
         * 工厂封装了 iOS 特定的按钮创建
         */
        return IOSButton(title: title)
    }
}

class AndroidButtonFactory: ButtonFactory {
    func createButton(title: String) -> Button {
        return AndroidButton(title: title)
    }
}

class WebButtonFactory: ButtonFactory {
    func createButton(title: String) -> Button {
        return WebButton(title: title)
    }
}

/**
 * USAGE IN SWIFTUI / 在 SwiftUI 中使用
 */
struct CrossPlatformView: View {
    let buttonFactory: ButtonFactory
    
    /**
     * View doesn't know which specific button it's creating
     * 视图不知道它正在创建哪个特定的按钮
     * This makes the view testable and platform-independent
     * 这使得视图可测试且平台无关
     */
    var body: some View {
        VStack {
            ButtonView(button: buttonFactory.createButton(title: "Submit"))
            ButtonView(button: buttonFactory.createButton(title: "Cancel"))
        }
    }
}

struct ButtonView: View {
    let button: Button
    
    var body: some View {
        Text(button.render())
            .onTapGesture {
                button.onClick()
            }
    }
}

// Usage example / 使用示例
func createPlatformSpecificView() -> some View {
    #if os(iOS)
    return CrossPlatformView(buttonFactory: IOSButtonFactory())
    #elseif os(macOS)
    return CrossPlatformView(buttonFactory: WebButtonFactory())
    #else
    return CrossPlatformView(buttonFactory: AndroidButtonFactory())
    #endif
}
```

### 3. Builder Pattern / 建造者模式

```swift
/**
 * BUILDER PATTERN - 建造者模式
 * 
 * INTENT / 意图:
 * Separate construction of complex objects from their representation
 * 将复杂对象的构建与其表示分离
 * 
 * WHEN TO USE / 使用场景:
 * - Creating objects with many optional parameters
 * - 创建具有许多可选参数的对象
 * - When you need different representations of an object
 * - 当你需要对象的不同表示时
 * - Step-by-step object construction
 * - 逐步构建对象
 */

// Product class with many properties / 具有许多属性的产品类
struct UserProfile {
    let id: String
    let username: String
    let email: String
    let firstName: String?
    let lastName: String?
    let avatar: String?
    let bio: String?
    let birthDate: Date?
    let phoneNumber: String?
    let address: Address?
    let preferences: UserPreferences?
    let notificationSettings: NotificationSettings?
}

struct Address {
    let street: String
    let city: String
    let country: String
}

struct UserPreferences {
    let theme: String
    let language: String
}

struct NotificationSettings {
    let emailEnabled: Bool
    let pushEnabled: Bool
}

/**
 * Builder class for UserProfile
 * UserProfile 的建造者类
 * 
 * Benefits / 好处:
 * - Fluent interface for easy chaining
 * - 流畅的接口便于链式调用
 * - Clear separation of construction logic
 * - 清晰分离构建逻辑
 * - Validation can be added at build time
 * - 可以在构建时添加验证
 */
class UserProfileBuilder {
    private var id: String
    private var username: String
    private var email: String
    private var firstName: String?
    private var lastName: String?
    private var avatar: String?
    private var bio: String?
    private var birthDate: Date?
    private var phoneNumber: String?
    private var address: Address?
    private var preferences: UserPreferences?
    private var notificationSettings: NotificationSettings?
    
    /**
     * Initialize with required fields only
     * 仅使用必需字段初始化
     */
    init(id: String, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
    }
    
    /**
     * Fluent interface methods return self for chaining
     * 流畅接口方法返回 self 以便链式调用
     */
    @discardableResult
    func withName(first: String, last: String) -> UserProfileBuilder {
        self.firstName = first
        self.lastName = last
        return self
    }
    
    @discardableResult
    func withAvatar(_ url: String) -> UserProfileBuilder {
        self.avatar = url
        return self
    }
    
    @discardableResult
    func withBio(_ bio: String) -> UserProfileBuilder {
        self.bio = bio
        return self
    }
    
    @discardableResult
    func withBirthDate(_ date: Date) -> UserProfileBuilder {
        self.birthDate = date
        return self
    }
    
    @discardableResult
    func withPhone(_ number: String) -> UserProfileBuilder {
        self.phoneNumber = number
        return self
    }
    
    @discardableResult
    func withAddress(street: String, city: String, country: String) -> UserProfileBuilder {
        self.address = Address(street: street, city: city, country: country)
        return self
    }
    
    @discardableResult
    func withPreferences(theme: String = "light", language: String = "en") -> UserProfileBuilder {
        self.preferences = UserPreferences(theme: theme, language: language)
        return self
    }
    
    @discardableResult
    func withNotifications(email: Bool = true, push: Bool = true) -> UserProfileBuilder {
        self.notificationSettings = NotificationSettings(emailEnabled: email, pushEnabled: push)
        return self
    }
    
    /**
     * Build method creates the final object
     * build 方法创建最终对象
     * Can add validation here before creating the object
     * 可以在创建对象之前在这里添加验证
     */
    func build() throws -> UserProfile {
        // Validation example / 验证示例
        guard email.contains("@") else {
            throw BuilderError.invalidEmail
        }
        
        return UserProfile(
            id: id,
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            avatar: avatar,
            bio: bio,
            birthDate: birthDate,
            phoneNumber: phoneNumber,
            address: address,
            preferences: preferences,
            notificationSettings: notificationSettings
        )
    }
}

enum BuilderError: Error {
    case invalidEmail
    case missingRequiredField
}

/**
 * USAGE EXAMPLES / 使用示例
 */
func createUserProfiles() {
    // Simple profile with only required fields
    // 只有必需字段的简单配置文件
    let simpleProfile = try? UserProfileBuilder(
        id: "1",
        username: "john",
        email: "john@example.com"
    ).build()
    
    // Complex profile with all fields
    // 包含所有字段的复杂配置文件
    let complexProfile = try? UserProfileBuilder(
        id: "2",
        username: "jane",
        email: "jane@example.com"
    )
    .withName(first: "Jane", last: "Doe")
    .withAvatar("https://example.com/avatar.jpg")
    .withBio("iOS Developer passionate about SwiftUI")
    .withBirthDate(Date())
    .withPhone("+1234567890")
    .withAddress(street: "123 Main St", city: "San Francisco", country: "USA")
    .withPreferences(theme: "dark", language: "en")
    .withNotifications(email: true, push: false)
    .build()
    
    /**
     * Builder pattern makes it clear what each parameter means
     * 建造者模式使每个参数的含义清晰
     * Compare with constructor with many parameters:
     * 与具有许多参数的构造函数比较：
     * UserProfile("2", "jane", "jane@example.com", "Jane", "Doe", ...) // Unclear!
     */
}

/**
 * SwiftUI ViewModel using Builder
 * 使用建造者的 SwiftUI ViewModel
 */
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    
    func createProfile(from formData: ProfileFormData) {
        do {
            profile = try UserProfileBuilder(
                id: UUID().uuidString,
                username: formData.username,
                email: formData.email
            )
            .withName(first: formData.firstName, last: formData.lastName)
            .withBio(formData.bio)
            .build()
        } catch {
            print("Failed to build profile: \(error)")
        }
    }
}
```

---

## Structural Patterns / 结构型模式

### 4. Adapter Pattern / 适配器模式

```swift
/**
 * ADAPTER PATTERN - 适配器模式
 * 
 * INTENT / 意图:
 * Allow incompatible interfaces to work together
 * 允许不兼容的接口协同工作
 * 
 * WHEN TO USE / 使用场景:
 * - Integrating third-party libraries
 * - 集成第三方库
 * - Working with legacy code
 * - 使用遗留代码
 * - Converting data between different formats
 * - 在不同格式之间转换数据
 */

// Modern payment interface your app uses / 应用使用的现代支付接口
protocol PaymentGateway {
    func processPayment(amount: Decimal, currency: String) async throws -> PaymentResult
    func refund(transactionId: String, amount: Decimal) async throws -> RefundResult
}

struct PaymentResult {
    let success: Bool
    let transactionId: String
    let message: String
}

struct RefundResult {
    let success: Bool
    let refundId: String
}

// Legacy payment system with different interface / 具有不同接口的遗留支付系统
class LegacyPaymentSystem {
    func makePayment(cents: Int, currencyCode: String, completion: @escaping (Bool, String?) -> Void) {
        // Legacy implementation
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(true, "LEGACY-TXN-123")
        }
    }
    
    func processRefund(txnId: String, cents: Int, completion: @escaping (Bool) -> Void) {
        // Legacy implementation
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
}

/**
 * Adapter to make legacy system work with modern interface
 * 使遗留系统与现代接口协同工作的适配器
 * 
 * The adapter:
 * 1. Converts modern async/await to legacy callbacks
 * 2. Converts Decimal amounts to cents (Int)
 * 3. Maps between different result types
 * 
 * 适配器：
 * 1. 将现代 async/await 转换为遗留回调
 * 2. 将 Decimal 金额转换为美分（Int）
 * 3. 在不同结果类型之间映射
 */
class LegacyPaymentAdapter: PaymentGateway {
    private let legacySystem = LegacyPaymentSystem()
    
    /**
     * Convert modern async method to legacy callback
     * 将现代异步方法转换为遗留回调
     */
    func processPayment(amount: Decimal, currency: String) async throws -> PaymentResult {
        return try await withCheckedThrowingContinuation { continuation in
            // Convert decimal to cents / 将小数转换为美分
            let cents = Int(truncating: (amount * 100) as NSNumber)
            
            legacySystem.makePayment(cents: cents, currencyCode: currency) { success, transactionId in
                if success, let txnId = transactionId {
                    continuation.resume(returning: PaymentResult(
                        success: true,
                        transactionId: txnId,
                        message: "Payment processed successfully"
                    ))
                } else {
                    continuation.resume(throwing: PaymentError.processingFailed)
                }
            }
        }
    }
    
    func refund(transactionId: String, amount: Decimal) async throws -> RefundResult {
        return try await withCheckedThrowingContinuation { continuation in
            let cents = Int(truncating: (amount * 100) as NSNumber)
            
            legacySystem.processRefund(txnId: transactionId, cents: cents) { success in
                if success {
                    continuation.resume(returning: RefundResult(
                        success: true,
                        refundId: "REFUND-\(transactionId)"
                    ))
                } else {
                    continuation.resume(throwing: PaymentError.refundFailed)
                }
            }
        }
    }
}

enum PaymentError: Error {
    case processingFailed
    case refundFailed
}

/**
 * USAGE IN SWIFTUI / 在 SwiftUI 中使用
 */
struct PaymentView: View {
    @StateObject private var viewModel = PaymentViewModel()
    
    var body: some View {
        VStack {
            Button("Process Payment") {
                Task {
                    await viewModel.processPayment()
                }
            }
        }
    }
}

class PaymentViewModel: ObservableObject {
    /**
     * ViewModel doesn't know it's using legacy system
     * ViewModel 不知道它在使用遗留系统
     * Can easily switch to modern implementation
     * 可以轻松切换到现代实现
     */
    private let paymentGateway: PaymentGateway
    
    init(paymentGateway: PaymentGateway = LegacyPaymentAdapter()) {
        self.paymentGateway = paymentGateway
    }
    
    func processPayment() async {
        do {
            let result = try await paymentGateway.processPayment(
                amount: 99.99,
                currency: "USD"
            )
            print("Payment successful: \(result.transactionId)")
        } catch {
            print("Payment failed: \(error)")
        }
    }
}
```

### 5. Decorator Pattern / 装饰器模式

```swift
/**
 * DECORATOR PATTERN - 装饰器模式
 * 
 * INTENT / 意图:
 * Attach additional responsibilities to objects dynamically
 * 动态地为对象附加额外的职责
 * 
 * WHEN TO USE / 使用场景:
 * - Adding features to objects without altering their structure
 * - 在不改变对象结构的情况下添加功能
 * - When extension by subclassing is impractical
 * - 当通过子类扩展不切实际时
 * - Combining multiple behaviors
 * - 组合多个行为
 */

// Component protocol / 组件协议
protocol Coffee {
    var description: String { get }
    var cost: Double { get }
}

// Concrete component / 具体组件
struct SimpleCoffee: Coffee {
    let description = "Simple Coffee"
    let cost = 2.0
}

// Base decorator / 基础装饰器
protocol CoffeeDecorator: Coffee {
    var wrappedCoffee: Coffee { get }
}

/**
 * Concrete decorators add functionality
 * 具体装饰器添加功能
 * Each decorator wraps another coffee object
 * 每个装饰器包装另一个咖啡对象
 */
struct MilkDecorator: CoffeeDecorator {
    let wrappedCoffee: Coffee
    
    var description: String {
        return wrappedCoffee.description + ", Milk"
    }
    
    var cost: Double {
        return wrappedCoffee.cost + 0.5
    }
}

struct SugarDecorator: CoffeeDecorator {
    let wrappedCoffee: Coffee
    
    var description: String {
        return wrappedCoffee.description + ", Sugar"
    }
    
    var cost: Double {
        return wrappedCoffee.cost + 0.3
    }
}

struct WhipCreamDecorator: CoffeeDecorator {
    let wrappedCoffee: Coffee
    
    var description: String {
        return wrappedCoffee.description + ", Whip Cream"
    }
    
    var cost: Double {
        return wrappedCoffee.cost + 0.7
    }
}

struct CaramelDecorator: CoffeeDecorator {
    let wrappedCoffee: Coffee
    
    var description: String {
        return wrappedCoffee.description + ", Caramel"
    }
    
    var cost: Double {
        return wrappedCoffee.cost + 0.8
    }
}

/**
 * SWIFTUI VIEW MODIFIER AS DECORATOR
 * SwiftUI 视图修饰符作为装饰器
 * 
 * ViewModifiers are perfect examples of decorator pattern
 * ViewModifiers 是装饰器模式的完美示例
 */
struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    var message: String = "Loading..."
    
    /**
     * Decorates the content with loading overlay
     * 用加载覆盖层装饰内容
     */
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                VStack {
                    ProgressView()
                    Text(message)
                        .font(.caption)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
}

struct ErrorModifier: ViewModifier {
    @Binding var error: String?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let error = error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                    
                    Button("Dismiss") {
                        self.error = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
}

/**
 * Chain multiple decorators in SwiftUI
 * 在 SwiftUI 中链式调用多个装饰器
 */
extension View {
    func withLoading(_ isLoading: Binding<Bool>, message: String = "Loading...") -> some View {
        modifier(LoadingModifier(isLoading: isLoading, message: message))
    }
    
    func withError(_ error: Binding<String?>) -> some View {
        modifier(ErrorModifier(error: error))
    }
}

/**
 * USAGE EXAMPLES / 使用示例
 */
struct CoffeeOrderView: View {
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        VStack {
            Text("Coffee Order")
            // View decorated with multiple modifiers
            // 用多个修饰符装饰的视图
        }
        .withLoading($isLoading)  // First decorator
        .withError($error)         // Second decorator
        .padding()                 // Third decorator
        .background(Color.gray)    // Fourth decorator
    }
    
    func orderCoffee() {
        // Create coffee with decorators / 用装饰器创建咖啡
        let coffee = SimpleCoffee()
        let coffeeWithMilk = MilkDecorator(wrappedCoffee: coffee)
        let coffeeWithMilkAndSugar = SugarDecorator(wrappedCoffee: coffeeWithMilk)
        let finalCoffee = WhipCreamDecorator(wrappedCoffee: coffeeWithMilkAndSugar)
        
        print("Order: \(finalCoffee.description)")
        print("Cost: $\(finalCoffee.cost)")
    }
}
```

---

## Behavioral Patterns / 行为型模式

### 6. Observer Pattern / 观察者模式

```swift
/**
 * OBSERVER PATTERN - 观察者模式
 * 
 * INTENT / 意图:
 * Define one-to-many dependency between objects
 * 定义对象之间的一对多依赖关系
 * 
 * WHEN TO USE / 使用场景:
 * - When changes to one object require changing multiple dependent objects
 * - 当一个对象的更改需要更改多个依赖对象时
 * - When an object needs to notify other objects without knowing who they are
 * - 当对象需要通知其他对象而不知道它们是谁时
 * 
 * In SwiftUI: @Published, @ObservableObject, Combine framework
 * 在 SwiftUI 中：@Published、@ObservableObject、Combine 框架
 */

import Combine

// Subject that can be observed / 可被观察的主题
protocol Observable {
    associatedtype Output
    func subscribe(_ observer: @escaping (Output) -> Void) -> AnyCancellable
}

/**
 * Concrete subject using Combine
 * 使用 Combine 的具体主题
 * 
 * This is the modern Swift way to implement Observer pattern
 * 这是实现观察者模式的现代 Swift 方式
 */
class StockPriceMonitor: ObservableObject {
    /**
     * @Published automatically notifies observers
     * @Published 自动通知观察者
     */
    @Published var currentPrice: Double = 0.0
    @Published var dailyChange: Double = 0.0
    @Published var volume: Int = 0
    
    private var timer: Timer?
    
    func startMonitoring() {
        /**
         * Simulate real-time price updates
         * 模拟实时价格更新
         */
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentPrice = Double.random(in: 100...200)
            self.dailyChange = Double.random(in: -10...10)
            self.volume = Int.random(in: 1000000...5000000)
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
}

/**
 * Observer views in SwiftUI
 * SwiftUI 中的观察者视图
 */
struct StockPriceView: View {
    /**
     * @StateObject makes this view an observer
     * @StateObject 使这个视图成为观察者
     * View automatically updates when published properties change
     * 当发布的属性更改时，视图自动更新
     */
    @StateObject private var monitor = StockPriceMonitor()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Stock Price Monitor")
                .font(.title)
            
            HStack {
                Text("Price:")
                Text("$\(monitor.currentPrice, specifier: "%.2f")")
                    .font(.largeTitle)
                    .foregroundColor(monitor.dailyChange >= 0 ? .green : .red)
            }
            
            HStack {
                Text("Change:")
                Text("\(monitor.dailyChange >= 0 ? "+" : "")\(monitor.dailyChange, specifier: "%.2f")")
                    .foregroundColor(monitor.dailyChange >= 0 ? .green : .red)
            }
            
            Text("Volume: \(monitor.volume)")
                .font(.caption)
        }
        .onAppear {
            monitor.startMonitoring()
        }
        .onDisappear {
            monitor.stopMonitoring()
        }
    }
}

/**
 * Custom observer implementation without Combine
 * 不使用 Combine 的自定义观察者实现
 */
class EventManager {
    typealias EventHandler = (String) -> Void
    
    private var observers: [UUID: EventHandler] = [:]
    
    /**
     * Subscribe to events
     * 订阅事件
     * Returns subscription ID for later unsubscribe
     * 返回订阅 ID 以便稍后取消订阅
     */
    @discardableResult
    func subscribe(_ handler: @escaping EventHandler) -> UUID {
        let id = UUID()
        observers[id] = handler
        return id
    }
    
    /**
     * Unsubscribe from events
     * 取消订阅事件
     */
    func unsubscribe(_ id: UUID) {
        observers.removeValue(forKey: id)
    }
    
    /**
     * Notify all observers
     * 通知所有观察者
     */
    func notify(_ event: String) {
        observers.values.forEach { handler in
            handler(event)
        }
    }
}

/**
 * USAGE WITH MULTIPLE OBSERVERS / 使用多个观察者
 */
class NotificationCenter {
    static let shared = NotificationCenter()
    private let eventManager = EventManager()
    
    func observeUserLogin(_ handler: @escaping (String) -> Void) -> UUID {
        return eventManager.subscribe(handler)
    }
    
    func userDidLogin(username: String) {
        eventManager.notify("User logged in: \(username)")
    }
}

// Different parts of app observing same event / 应用的不同部分观察同一事件
class AnalyticsService {
    private var subscriptionId: UUID?
    
    func startObserving() {
        subscriptionId = NotificationCenter.shared.observeUserLogin { event in
            print("Analytics: \(event)")
            // Track user login
        }
    }
}

class PushNotificationService {
    private var subscriptionId: UUID?
    
    func startObserving() {
        subscriptionId = NotificationCenter.shared.observeUserLogin { event in
            print("Push Notifications: \(event)")
            // Register for push notifications
        }
    }
}

class UserPreferencesService {
    private var subscriptionId: UUID?
    
    func startObserving() {
        subscriptionId = NotificationCenter.shared.observeUserLogin { event in
            print("Preferences: \(event)")
            // Load user preferences
        }
    }
}
```

### 7. Strategy Pattern / 策略模式

```swift
/**
 * STRATEGY PATTERN - 策略模式
 * 
 * INTENT / 意图:
 * Define a family of algorithms, encapsulate each one, and make them interchangeable
 * 定义一系列算法，封装每个算法，并使它们可互换
 * 
 * WHEN TO USE / 使用场景:
 * - Multiple ways to perform a task
 * - 执行任务的多种方式
 * - Runtime algorithm selection
 * - 运行时算法选择
 * - Eliminating conditional statements
 * - 消除条件语句
 */

// Strategy protocol / 策略协议
protocol SortingStrategy {
    func sort<T: Comparable>(_ array: [T]) -> [T]
}

// Concrete strategies / 具体策略
struct BubbleSort: SortingStrategy {
    /**
     * Simple but inefficient for large datasets
     * 简单但对大数据集效率低
     * O(n²) time complexity
     */
    func sort<T: Comparable>(_ array: [T]) -> [T] {
        var result = array
        for i in 0..<result.count {
            for j in 0..<result.count - i - 1 {
                if result[j] > result[j + 1] {
                    result.swapAt(j, j + 1)
                }
            }
        }
        return result
    }
}

struct QuickSort: SortingStrategy {
    /**
     * Efficient for large datasets
     * 对大数据集高效
     * O(n log n) average time complexity
     */
    func sort<T: Comparable>(_ array: [T]) -> [T] {
        guard array.count > 1 else { return array }
        
        let pivot = array[array.count / 2]
        let less = array.filter { $0 < pivot }
        let equal = array.filter { $0 == pivot }
        let greater = array.filter { $0 > pivot }
        
        return sort(less) + equal + sort(greater)
    }
}

struct MergeSort: SortingStrategy {
    /**
     * Stable sort with consistent performance
     * 具有一致性能的稳定排序
     * O(n log n) time complexity always
     */
    func sort<T: Comparable>(_ array: [T]) -> [T] {
        guard array.count > 1 else { return array }
        
        let middleIndex = array.count / 2
        let leftArray = sort(Array(array[0..<middleIndex]))
        let rightArray = sort(Array(array[middleIndex..<array.count]))
        
        return merge(leftArray, rightArray)
    }
    
    private func merge<T: Comparable>(_ left: [T], _ right: [T]) -> [T] {
        var leftIndex = 0
        var rightIndex = 0
        var result: [T] = []
        
        while leftIndex < left.count && rightIndex < right.count {
            if left[leftIndex] < right[rightIndex] {
                result.append(left[leftIndex])
                leftIndex += 1
            } else {
                result.append(right[rightIndex])
                rightIndex += 1
            }
        }
        
        result.append(contentsOf: left[leftIndex...])
        result.append(contentsOf: right[rightIndex...])
        
        return result
    }
}

/**
 * Context that uses strategy
 * 使用策略的上下文
 */
class DataProcessor {
    private var sortingStrategy: SortingStrategy
    
    init(strategy: SortingStrategy = QuickSort()) {
        self.sortingStrategy = strategy
    }
    
    /**
     * Change strategy at runtime
     * 在运行时更改策略
     */
    func setSortingStrategy(_ strategy: SortingStrategy) {
        self.sortingStrategy = strategy
    }
    
    func processData<T: Comparable>(_ data: [T]) -> [T] {
        // Use current strategy to sort
        // 使用当前策略排序
        return sortingStrategy.sort(data)
    }
}

/**
 * SWIFTUI EXAMPLE WITH STRATEGY PATTERN
 * 使用策略模式的 SwiftUI 示例
 */
struct SortingView: View {
    @State private var numbers = [5, 2, 8, 1, 9, 3, 7, 4, 6]
    @State private var selectedStrategy = "Quick Sort"
    
    private let strategies: [String: SortingStrategy] = [
        "Bubble Sort": BubbleSort(),
        "Quick Sort": QuickSort(),
        "Merge Sort": MergeSort()
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            /**
             * Strategy selection
             * 策略选择
             */
            Picker("Sorting Algorithm", selection: $selectedStrategy) {
                ForEach(Array(strategies.keys), id: \.self) { key in
                    Text(key).tag(key)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            /**
             * Display current data
             * 显示当前数据
             */
            HStack {
                ForEach(numbers, id: \.self) { number in
                    Text("\(number)")
                        .frame(width: 30, height: 30)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(5)
                }
            }
            
            /**
             * Apply selected strategy
             * 应用选定的策略
             */
            Button("Sort") {
                if let strategy = strategies[selectedStrategy] {
                    withAnimation {
                        numbers = strategy.sort(numbers)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Shuffle") {
                withAnimation {
                    numbers.shuffle()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

/**
 * Payment strategy example
 * 支付策略示例
 */
protocol PaymentStrategy {
    func pay(amount: Decimal) async throws -> Bool
}

struct CreditCardPayment: PaymentStrategy {
    let cardNumber: String
    let cvv: String
    
    func pay(amount: Decimal) async throws -> Bool {
        print("Processing credit card payment of \(amount)")
        // Credit card payment logic
        return true
    }
}

struct PayPalPayment: PaymentStrategy {
    let email: String
    
    func pay(amount: Decimal) async throws -> Bool {
        print("Processing PayPal payment of \(amount)")
        // PayPal payment logic
        return true
    }
}

struct ApplePayPayment: PaymentStrategy {
    func pay(amount: Decimal) async throws -> Bool {
        print("Processing Apple Pay payment of \(amount)")
        // Apple Pay payment logic
        return true
    }
}

class CheckoutViewModel: ObservableObject {
    @Published var selectedPaymentMethod = "Credit Card"
    private var paymentStrategy: PaymentStrategy?
    
    /**
     * Select payment strategy based on user choice
     * 根据用户选择选择支付策略
     */
    func selectPaymentMethod(_ method: String) {
        switch method {
        case "Credit Card":
            paymentStrategy = CreditCardPayment(
                cardNumber: "1234-5678-9012-3456",
                cvv: "123"
            )
        case "PayPal":
            paymentStrategy = PayPalPayment(email: "user@example.com")
        case "Apple Pay":
            paymentStrategy = ApplePayPayment()
        default:
            break
        }
    }
    
    func checkout(amount: Decimal) async {
        guard let strategy = paymentStrategy else { return }
        
        do {
            let success = try await strategy.pay(amount: amount)
            if success {
                print("Payment successful!")
            }
        } catch {
            print("Payment failed: \(error)")
        }
    }
}
```

---

## Pattern Selection Guide / 模式选择指南

### Decision Matrix / 决策矩阵

| Problem / 问题 | Pattern / 模式 | Use Case / 用例 |
|--------------|---------------|----------------|
| Need only one instance / 需要唯一实例 | Singleton | App configuration, Network manager |
| Create objects without specifying class / 创建对象而不指定类 | Factory | UI component creation |
| Complex object construction / 复杂对象构建 | Builder | Form data, Configuration |
| Incompatible interfaces / 不兼容的接口 | Adapter | Third-party integration |
| Add features dynamically / 动态添加功能 | Decorator | ViewModifiers, Middleware |
| One-to-many notifications / 一对多通知 | Observer | Event systems, Data binding |
| Interchangeable algorithms / 可互换算法 | Strategy | Sorting, Payment methods |

### Anti-Patterns to Avoid / 要避免的反模式

1. **Pattern Overuse / 过度使用模式**
   - Don't use patterns just because you can
   - 不要仅仅因为你能就使用模式

2. **Wrong Pattern Selection / 错误的模式选择**
   - Understand the problem before choosing a pattern
   - 在选择模式之前理解问题

3. **Premature Optimization / 过早优化**
   - Start simple, refactor to patterns when needed
   - 从简单开始，需要时重构为模式

4. **Ignoring Swift Features / 忽略 Swift 特性**
   - Use Swift's built-in features when appropriate
   - 适当时使用 Swift 的内置功能

### Remember / 记住

- Patterns are tools, not goals / 模式是工具，不是目标
- Understand the problem first / 首先理解问题
- Keep it simple when possible / 尽可能保持简单
- Combine patterns when needed / 需要时组合模式
- Refactor to patterns, don't start with them / 重构为模式，不要从它们开始