//
//  NetworkMiddleware.swift
//  SwiftUIDemo
//
//  Centralized network middleware for request/response handling
//  集中式网络中间件用于请求/响应处理
//

import Foundation
import ComposableArchitecture

/**
 * NETWORK MIDDLEWARE - 网络中间件
 *
 * PURPOSE / 目的:
 * - Centralized error handling for all network requests
 * - 所有网络请求的集中错误处理
 * - Automatic connectivity checking before requests
 * - 请求前自动连接性检查
 * - Request/response interceptors for common logic
 * - 请求/响应拦截器用于通用逻辑
 * - Automatic retry with exponential backoff
 * - 使用指数退避的自动重试
 *
 * DESIGN PATTERN / 设计模式:
 * - Chain of Responsibility: Middleware chain
 * - 责任链模式：中间件链
 * - Decorator Pattern: Enhance requests
 * - 装饰器模式：增强请求
 *
 * HOW IT WORKS / 工作原理:
 * 1. Check network connectivity first
 *    首先检查网络连接
 * 2. Apply request interceptors
 *    应用请求拦截器
 * 3. Execute request
 *    执行请求
 * 4. Apply response interceptors
 *    应用响应拦截器
 * 5. Handle errors uniformly
 *    统一处理错误
 */

// MARK: - Network Middleware Protocol / 网络中间件协议

protocol NetworkMiddleware {
    func process(_ request: URLRequest, next: @escaping (URLRequest) async throws -> (Data, URLResponse)) async throws -> (Data, URLResponse)
}

// MARK: - Connectivity Middleware / 连接性中间件

/**
 * Check network connectivity before making request
 * 在发起请求前检查网络连接
 */
struct ConnectivityMiddleware: NetworkMiddleware {
    let networkMonitor = NetworkMonitor.shared
    let waitForConnection: Bool
    let timeout: TimeInterval

    init(waitForConnection: Bool = false, timeout: TimeInterval = 30) {
        self.waitForConnection = waitForConnection
        self.timeout = timeout
    }

    func process(_ request: URLRequest, next: @escaping (URLRequest) async throws -> (Data, URLResponse)) async throws -> (Data, URLResponse) {
        // Check connectivity / 检查连接性
        if !networkMonitor.isConnected {
            if waitForConnection {
                // Wait for connection / 等待连接
                try await networkMonitor.waitForConnection(timeout: timeout)
            } else {
                // Throw no connection error immediately / 立即抛出无连接错误
                throw NetworkError.noConnection
            }
        }

        // Proceed with request / 继续请求
        return try await next(request)
    }
}

// MARK: - Retry Middleware / 重试中间件

/**
 * Automatic retry with exponential backoff
 * 使用指数退避的自动重试
 */
struct RetryMiddleware: NetworkMiddleware {
    let maxRetries: Int
    let initialDelay: TimeInterval
    let maxDelay: TimeInterval
    let retryableErrors: Set<Int> // HTTP status codes / HTTP 状态码

    init(
        maxRetries: Int = 3,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        retryableErrors: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.maxRetries = maxRetries
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
        self.retryableErrors = retryableErrors
    }

    func process(_ request: URLRequest, next: @escaping (URLRequest) async throws -> (Data, URLResponse)) async throws -> (Data, URLResponse) {
        var lastError: Error?
        var currentDelay = initialDelay

        for attempt in 0...maxRetries {
            do {
                let (data, response) = try await next(request)

                // Check if response indicates retryable error / 检查响应是否表示可重试错误
                if let httpResponse = response as? HTTPURLResponse,
                   retryableErrors.contains(httpResponse.statusCode),
                   attempt < maxRetries {

                    #if DEBUG
                    print("🔄 Retrying request (attempt \(attempt + 1)/\(maxRetries)) after \(currentDelay)s")
                    #endif

                    // Wait before retry / 重试前等待
                    try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))

                    // Exponential backoff / 指数退避
                    currentDelay = min(currentDelay * 2, maxDelay)

                    lastError = NetworkError.serverError(httpResponse.statusCode)
                    continue
                }

                return (data, response)

            } catch {
                lastError = error

                // Check if error is retryable / 检查错误是否可重试
                if attempt < maxRetries && isRetryableError(error) {
                    #if DEBUG
                    print("🔄 Retrying after error: \(error.localizedDescription)")
                    #endif

                    try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                    currentDelay = min(currentDelay * 2, maxDelay)
                    continue
                }

                throw error
            }
        }

        throw lastError ?? NetworkError.unknown
    }

    private func isRetryableError(_ error: Error) -> Bool {
        // Check for timeout or connection errors / 检查超时或连接错误
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .cannotConnectToHost, .networkConnectionLost:
                return true
            default:
                return false
            }
        }

        // Check for custom network errors / 检查自定义网络错误
        if let networkError = error as? NetworkError {
            switch networkError {
            case .timeout, .noConnection:
                return true
            case .serverError(let code):
                return retryableErrors.contains(code)
            default:
                return false
            }
        }

        return false
    }
}

// MARK: - Authentication Middleware / 认证中间件

/**
 * Add authentication headers to requests
 * 为请求添加认证头
 */
struct AuthenticationMiddleware: NetworkMiddleware {
    let tokenProvider: () async -> String?

    func process(_ request: URLRequest, next: @escaping (URLRequest) async throws -> (Data, URLResponse)) async throws -> (Data, URLResponse) {
        var modifiedRequest = request

        // Add auth token if available / 如果可用，添加认证令牌
        if let token = await tokenProvider() {
            modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await next(modifiedRequest)

        // Check for 401 unauthorized / 检查 401 未授权
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }

        return (data, response)
    }
}

// MARK: - Logging Middleware / 日志中间件

/**
 * Log all network requests and responses
 * 记录所有网络请求和响应
 */
struct LoggingMiddleware: NetworkMiddleware {
    let logLevel: LogLevel

    enum LogLevel {
        case none
        case basic      // URL and status only / 仅 URL 和状态
        case headers    // Include headers / 包含头部
        case full       // Include body / 包含正文
    }

    init(logLevel: LogLevel = .basic) {
        self.logLevel = logLevel
    }

    func process(_ request: URLRequest, next: @escaping (URLRequest) async throws -> (Data, URLResponse)) async throws -> (Data, URLResponse) {
        guard logLevel != .none else {
            return try await next(request)
        }

        // Log request / 记录请求
        logRequest(request)

        let startTime = Date()

        do {
            let (data, response) = try await next(request)

            // Log response / 记录响应
            logResponse(response, data: data, duration: Date().timeIntervalSince(startTime))

            return (data, response)
        } catch {
            // Log error / 记录错误
            logError(error, duration: Date().timeIntervalSince(startTime))
            throw error
        }
    }

    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("""

        📤 REQUEST / 请求:
        URL: \(request.url?.absoluteString ?? "nil")
        Method: \(request.httpMethod ?? "GET")
        """)

        if logLevel == .headers || logLevel == .full {
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        }

        if logLevel == .full, let body = request.httpBody {
            print("Body: \(String(data: body, encoding: .utf8) ?? "binary")")
        }
        #endif
    }

    private func logResponse(_ response: URLResponse, data: Data, duration: TimeInterval) {
        #if DEBUG
        let httpResponse = response as? HTTPURLResponse
        print("""

        📥 RESPONSE / 响应:
        Status: \(httpResponse?.statusCode ?? 0)
        Duration: \(String(format: "%.3f", duration))s
        Size: \(data.count) bytes
        """)

        if logLevel == .headers || logLevel == .full {
            print("Headers: \(httpResponse?.allHeaderFields ?? [:])")
        }

        if logLevel == .full {
            print("Body: \(String(data: data, encoding: .utf8) ?? "binary")")
        }
        #endif
    }

    private func logError(_ error: Error, duration: TimeInterval) {
        #if DEBUG
        print("""

        ❌ ERROR / 错误:
        Message: \(error.localizedDescription)
        Duration: \(String(format: "%.3f", duration))s
        """)
        #endif
    }
}

// MARK: - Error Mapping Middleware / 错误映射中间件

/**
 * Map HTTP status codes to NetworkError
 * 将 HTTP 状态码映射到 NetworkError
 */
struct ErrorMappingMiddleware: NetworkMiddleware {
    func process(_ request: URLRequest, next: @escaping (URLRequest) async throws -> (Data, URLResponse)) async throws -> (Data, URLResponse) {
        let (data, response) = try await next(request)

        // Map HTTP errors to NetworkError / 将 HTTP 错误映射到 NetworkError
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return (data, response)
            case 400:
                throw NetworkError.badRequest("Bad Request")
            case 401:
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            case 429:
                throw NetworkError.rateLimited
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.httpError(httpResponse.statusCode, String(data: data, encoding: .utf8))
            }
        }

        return (data, response)
    }
}

// MARK: - Network Service with Middleware / 带中间件的网络服务

/**
 * Network service that applies middleware chain
 * 应用中间件链的网络服务
 *
 * USAGE / 使用:
 * ```
 * let service = NetworkService()
 *     .use(ConnectivityMiddleware())
 *     .use(AuthenticationMiddleware { getToken() })
 *     .use(RetryMiddleware())
 *     .use(LoggingMiddleware(logLevel: .basic))
 *     .use(ErrorMappingMiddleware())
 *
 * let data = try await service.request(urlRequest)
 * ```
 */
class NetworkService {
    private var middlewares: [NetworkMiddleware] = []
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /**
     * Add middleware to the chain
     * 添加中间件到链
     */
    @discardableResult
    func use(_ middleware: NetworkMiddleware) -> NetworkService {
        middlewares.append(middleware)
        return self
    }

    /**
     * Execute request with middleware chain
     * 使用中间件链执行请求
     */
    func request(_ request: URLRequest) async throws -> Data {
        let (data, _) = try await executeWithMiddleware(request)
        return data
    }

    /**
     * Execute request and decode response
     * 执行请求并解码响应
     */
    func request<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let data = try await self.request(request)
        return try JSONDecoder().decode(type, from: data)
    }

    /**
     * Execute middleware chain
     * 执行中间件链
     */
    private func executeWithMiddleware(_ request: URLRequest) async throws -> (Data, URLResponse) {
        // Build middleware chain / 构建中间件链
        var chain: (URLRequest) async throws -> (Data, URLResponse) = { [weak self] request in
            guard let self = self else { throw NetworkError.unknown }
            return try await self.session.data(for: request)
        }

        // Apply middlewares in reverse order / 以相反顺序应用中间件
        for middleware in middlewares.reversed() {
            let next = chain
            chain = { request in
                try await middleware.process(request, next: next)
            }
        }

        // Execute chain / 执行链
        return try await chain(request)
    }
}

// MARK: - Default Network Service / 默认网络服务

extension NetworkService {
    /**
     * Create default configured service
     * 创建默认配置的服务
     *
     * Includes all standard middleware
     * 包含所有标准中间件
     */
    static var `default`: NetworkService {
        NetworkService()
            .use(ConnectivityMiddleware())
            .use(RetryMiddleware())
            .use(LoggingMiddleware(logLevel: .basic))
            .use(ErrorMappingMiddleware())
    }

    /**
     * Create service with authentication
     * 创建带认证的服务
     */
    static func authenticated(tokenProvider: @escaping () async -> String?) -> NetworkService {
        NetworkService()
            .use(ConnectivityMiddleware())
            .use(AuthenticationMiddleware(tokenProvider: tokenProvider))
            .use(RetryMiddleware())
            .use(LoggingMiddleware(logLevel: .basic))
            .use(ErrorMappingMiddleware())
    }
}