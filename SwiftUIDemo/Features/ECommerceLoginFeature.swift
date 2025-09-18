//
//  ECommerceLoginFeature.swift
//  SwiftUIDemo
//
//  E-commerce login feature with TCA architecture
//  电商登录功能，使用TCA架构
//

/**
 * 🔐 E-COMMERCE LOGIN FEATURE - 电商登录功能
 * ═══════════════════════════════════════════════════════════════
 *
 * 架构设计 / Architecture Design:
 * 
 * 采用TCA (The Composable Architecture) 架构模式
 * Using TCA (The Composable Architecture) pattern
 *
 * ┌─────────────────────────────────────────────┐
 * │              LoginView (UI)                 │
 * ├─────────────────────────────────────────────┤
 * │         LoginFeature (Reducer)              │
 * ├─────────────────────────────────────────────┤
 * │      AuthenticationService (Service)        │
 * ├─────────────────────────────────────────────┤
 * │           Combine Framework                 │
 * └─────────────────────────────────────────────┘
 *
 * 设计模式 / Design Patterns:
 * 
 * 1. STATE PATTERN (状态模式)
 *    • 管理登录状态的转换
 *    • idle → loading → success/failed
 *
 * 2. COMMAND PATTERN (命令模式)
 *    • Action枚举封装所有用户操作
 *    • 解耦UI事件和业务逻辑
 *
 * 3. DEPENDENCY INJECTION (依赖注入)
 *    • 注入认证服务
 *    • 便于测试和扩展
 *
 * SOLID原则 / SOLID Principles:
 * • SRP: 登录逻辑单一职责
 * • OCP: 通过协议扩展新的认证方式
 * • DIP: 依赖于AuthenticationProtocol抽象
 */

import ComposableArchitecture
import Foundation
import Combine

// MARK: - Feature Definition

@Reducer
struct ECommerceLoginFeature {

    // MARK: - State

    /**
     * 登录状态定义
     * Login state definition
     *
     * 包含所有登录相关的状态数据
     * Contains all login-related state data
     */
    @ObservableState
    struct State: Equatable {
        // Form fields / 表单字段
        // Pre-filled with default credentials / 预填充默认凭据
        var username: String = "demo"  // Pre-filled / 预填充
        var password: String = "123456"  // Pre-filled / 预填充

        // UI States / UI状态
        var isLoading: Bool = false
        var isPasswordVisible: Bool = false
        var rememberMe: Bool = false

        // Validation / 验证
        var usernameError: String?
        var passwordError: String?
        var generalError: String?

        // Navigation / 导航
        var isLoginSuccessful: Bool = false
        var shouldNavigateToHome: Bool = false

        // Computed properties / 计算属性
        var isFormValid: Bool {
            !username.isEmpty && !password.isEmpty &&
            usernameError == nil && passwordError == nil
        }

        var hasAnyError: Bool {
            usernameError != nil || passwordError != nil || generalError != nil
        }
    }

    // MARK: - Action

    /**
     * 用户动作定义
     * User action definition
     *
     * 遵循命令模式，封装所有可能的用户操作
     * Following Command Pattern, encapsulating all possible user operations
     */
    enum Action: Equatable {
        // User inputs / 用户输入
        case usernameChanged(String)
        case passwordChanged(String)
        case togglePasswordVisibility
        case toggleRememberMe

        // Form actions / 表单操作
        case validateUsername
        case validatePassword
        case clearErrors

        // Authentication / 认证
        case loginButtonTapped
        case loginResponse(Result<AuthResponse, AuthError>)

        // Navigation / 导航
        case navigateToHome
        case forgotPasswordTapped
        case registerTapped

        // Social login / 社交登录
        case wechatLoginTapped
        case appleLoginTapped
    }

    // MARK: - Dependencies

    /**
     * 依赖注入
     * Dependency Injection
     *
     * 注入外部服务，遵循DIP原则
     * Inject external services, following DIP principle
     */
    @Dependency(\.authenticationService) var authService

    // MARK: - Reducer

    /**
     * 核心业务逻辑
     * Core business logic
     *
     * 处理所有Action，更新State，返回Effect
     * Handle all Actions, update State, return Effects
     */
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            // MARK: Username handling
            case let .usernameChanged(username):
                state.username = username
                state.usernameError = nil
                state.generalError = nil
                return .none

            // MARK: Password handling
            case let .passwordChanged(password):
                state.password = password
                state.passwordError = nil
                state.generalError = nil
                return .none

            // MARK: Toggle visibility
            case .togglePasswordVisibility:
                state.isPasswordVisible.toggle()
                return .none

            // MARK: Toggle remember me
            case .toggleRememberMe:
                state.rememberMe.toggle()
                return .none

            // MARK: Validate username
            case .validateUsername:
                if state.username.isEmpty {
                    state.usernameError = "用户名不能为空 / Username cannot be empty"
                } else if state.username.count < 3 {
                    state.usernameError = "用户名至少3个字符 / Username must be at least 3 characters"
                } else if !isValidUsername(state.username) {
                    state.usernameError = "用户名格式不正确 / Invalid username format"
                } else {
                    state.usernameError = nil
                }
                return .none

            // MARK: Validate password
            case .validatePassword:
                if state.password.isEmpty {
                    state.passwordError = "密码不能为空 / Password cannot be empty"
                } else if state.password.count < 6 {
                    state.passwordError = "密码至少6个字符 / Password must be at least 6 characters"
                } else {
                    state.passwordError = nil
                }
                return .none

            // MARK: Clear errors
            case .clearErrors:
                state.usernameError = nil
                state.passwordError = nil
                state.generalError = nil
                return .none

            // MARK: Login action
            case .loginButtonTapped:
                print("🔵 Login button tapped")
                print("📝 Username: \(state.username)")
                print("📝 Password: \(state.password)")

                // Validate before login / 登录前验证
                guard state.isFormValid else {
                    state.generalError = "请填写正确的信息 / Please fill in correct information"
                    return .none
                }

                state.isLoading = true
                state.generalError = nil

                print("🚀 Starting login request...")

                // Perform login / 执行登录
                return .run { [username = state.username, password = state.password] send in
                    do {
                        print("🔄 Calling authService.login with username: \(username)")
                        let response = try await authService.login(username, password)
                        print("✅ Login successful, sending success response")
                        await send(.loginResponse(.success(response)))
                    } catch let error as AuthError {
                        print("❌ Login failed with error: \(error)")
                        await send(.loginResponse(.failure(error)))
                    } catch {
                        print("❌ Login failed with unknown error")
                        await send(.loginResponse(.failure(.unknown)))
                    }
                }

            // MARK: Login response
            case .loginResponse(.success(_)):
                print("🎉 Login response received successfully")
                print("📊 Current shouldNavigateToHome: \(state.shouldNavigateToHome)")

                state.isLoading = false
                state.isLoginSuccessful = true

                // Store token if remember me is checked / 如果选择记住我则存储token
                if state.rememberMe {
                    // Store token logic here
                }

                print("⏱️ Waiting 500ms before navigation...")

                // Navigate to home after short delay / 短暂延迟后导航到首页
                return .run { send in
                    // Use Task.sleep which is iOS 15 compatible
                    // 使用兼容 iOS 15 的 Task.sleep
                    try await Task.sleep(nanoseconds: 500_000_000) // 500ms
                    print("🔄 Sending navigateToHome action")
                    await send(.navigateToHome)
                }

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.isLoginSuccessful = false

                switch error {
                case .invalidCredentials:
                    state.generalError = "用户名或密码错误 / Invalid username or password"
                case .networkError:
                    state.generalError = "网络连接失败 / Network connection failed"
                case .serverError:
                    state.generalError = "服务器错误，请稍后重试 / Server error, please try again"
                case .unknown:
                    state.generalError = "未知错误 / Unknown error"
                }
                return .none

            // MARK: Navigation
            case .navigateToHome:
                print("🏠 NavigateToHome action received")
                print("📊 Setting shouldNavigateToHome from \(state.shouldNavigateToHome) to true")
                state.shouldNavigateToHome = true
                print("✅ shouldNavigateToHome is now: \(state.shouldNavigateToHome)")
                return .none

            case .forgotPasswordTapped:
                // Handle forgot password / 处理忘记密码
                return .none

            case .registerTapped:
                // Handle registration / 处理注册
                return .none

            // MARK: Social login
            case .wechatLoginTapped:
                state.isLoading = true
                // Implement WeChat login / 实现微信登录
                return .none

            case .appleLoginTapped:
                state.isLoading = true
                // Implement Apple login / 实现Apple登录
                return .none
            }
        }
    }

    // MARK: - Helper Methods

    /**
     * 验证用户名格式
     * Validate username format
     *
     * 支持字母、数字、下划线，3-20个字符
     * Support letters, numbers, underscore, 3-20 characters
     */
    private func isValidUsername(_ username: String) -> Bool {
        let regex = "^[a-zA-Z0-9_]{3,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: username)
    }
}

// MARK: - Authentication Models

/**
 * 认证响应模型
 * Authentication response model
 */
struct AuthResponse: Equatable {
    let token: String
    let refreshToken: String
    let userId: String
    let expiresIn: TimeInterval
}

/**
 * 认证错误类型
 * Authentication error types
 */
enum AuthError: Error, Equatable {
    case invalidCredentials
    case networkError
    case serverError
    case unknown
}

// MARK: - Authentication Service

/**
 * 认证服务协议
 * Authentication service protocol
 *
 * 定义认证相关的抽象接口
 * Define authentication-related abstract interface
 */
protocol AuthenticationServiceProtocol {
    func login(_ username: String, _ password: String) async throws -> AuthResponse
    func logout() async throws
    func refreshToken(_ refreshToken: String) async throws -> AuthResponse
}

/**
 * 模拟认证服务
 * Mock authentication service
 *
 * 用于开发和测试
 * For development and testing
 */
struct MockAuthenticationService: AuthenticationServiceProtocol {
    func login(_ username: String, _ password: String) async throws -> AuthResponse {
        // Simulate network delay / 模拟网络延迟
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // Simulate validation / 模拟验证
        if username == "demo" && password == "123456" {
            return AuthResponse(
                token: "mock_token_\(UUID().uuidString)",
                refreshToken: "mock_refresh_\(UUID().uuidString)",
                userId: "user_123",
                expiresIn: 3600
            )
        } else if username == "error" {
            throw AuthError.serverError
        } else if username == "network" {
            throw AuthError.networkError
        } else {
            throw AuthError.invalidCredentials
        }
    }

    func logout() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    func refreshToken(_ refreshToken: String) async throws -> AuthResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return AuthResponse(
            token: "new_token_\(UUID().uuidString)",
            refreshToken: "new_refresh_\(UUID().uuidString)",
            userId: "user_123",
            expiresIn: 3600
        )
    }
}

// MARK: - Dependency Values

/**
 * 依赖注入扩展
 * Dependency injection extension
 */
extension DependencyValues {
    var authenticationService: any AuthenticationServiceProtocol {
        get { self[AuthenticationServiceKey.self] }
        set { self[AuthenticationServiceKey.self] = newValue }
    }
}

private struct AuthenticationServiceKey: DependencyKey {
    static let liveValue: any AuthenticationServiceProtocol = MockAuthenticationService()
}
