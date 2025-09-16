//
//  NetworkServiceDependency.swift
//  SwiftUIDemo
//
//  TCA Dependency for centralized network service
//  集中式网络服务的 TCA 依赖
//

import ComposableArchitecture
import Foundation

/**
 * NETWORK SERVICE DEPENDENCY - 网络服务依赖
 *
 * PURPOSE / 目的:
 * - Integrate NetworkService with TCA
 * - 将 NetworkService 与 TCA 集成
 * - Provide dependency injection for network layer
 * - 为网络层提供依赖注入
 * - Enable easy mocking for tests
 * - 启用测试的简单模拟
 *
 * USAGE IN REDUCER / 在 Reducer 中使用:
 * ```
 * @Dependency(\.networkService) var networkService
 *
 * // In action handler / 在动作处理器中
 * case .fetchData:
 *     return .run { send in
 *         do {
 *             let data = try await networkService.request(endpoint: .getData)
 *             await send(.dataReceived(data))
 *         } catch {
 *             await send(.errorOccurred(error))
 *         }
 *     }
 * ```
 */

// MARK: - Network Service Client / 网络服务客户端

struct NetworkServiceClient {
    /**
     * Request with automatic error handling
     * 带自动错误处理的请求
     */
    var request: @Sendable (APIEndpoint) async throws -> Data

    /**
     * Request with decoding to Data
     * 请求并返回 Data
     */
    var requestData: @Sendable (APIEndpoint) async throws -> Data

    /**
     * Request with decoding to String
     * 请求并返回 String
     */
    var requestString: @Sendable (APIEndpoint) async throws -> String

    /**
     * Upload with progress
     * 带进度的上传
     */
    var upload: @Sendable (APIEndpoint, Data, @escaping (Double) -> Void) async throws -> Data

    /**
     * Download with progress
     * 带进度的下载
     */
    var download: @Sendable (APIEndpoint, @escaping (Double) -> Void) async throws -> URL
}

// MARK: - Helper Extensions / 辅助扩展

extension NetworkServiceClient {
    /**
     * Generic request with Decodable type
     * 带 Decodable 类型的泛型请求
     *
     * USAGE / 使用:
     * ```
     * let user: User = try await networkService.requestDecoded(endpoint: .userProfile(id: "123"))
     * ```
     */
    func requestDecoded<T: Decodable>(endpoint: APIEndpoint, as type: T.Type = T.self) async throws -> T {
        let data = try await request(endpoint)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

// MARK: - API Endpoint / API 端点

/**
 * API endpoint configuration
 * API 端点配置
 */
public enum APIEndpoint {
    case custom(URLRequest)
    case get(String, parameters: [String: Any]? = nil)
    case post(String, body: Data? = nil)
    case put(String, body: Data? = nil)
    case delete(String)
    case patch(String, body: Data? = nil)

    // Common endpoints / 常用端点
    case login(username: String, password: String)
    case refreshToken(token: String)
    case userProfile(id: String)
    case listItems(page: Int, limit: Int)
    case uploadFile(Data)

    /**
     * Build URLRequest from endpoint
     * 从端点构建 URLRequest
     */
    func urlRequest(baseURL: String = "https://api.example.com") throws -> URLRequest {
        switch self {
        case .custom(let request):
            return request

        case .get(let path, let parameters):
            return try buildRequest(method: "GET", path: path, baseURL: baseURL, parameters: parameters)

        case .post(let path, let body):
            return try buildRequest(method: "POST", path: path, baseURL: baseURL, body: body)

        case .put(let path, let body):
            return try buildRequest(method: "PUT", path: path, baseURL: baseURL, body: body)

        case .delete(let path):
            return try buildRequest(method: "DELETE", path: path, baseURL: baseURL)

        case .patch(let path, let body):
            return try buildRequest(method: "PATCH", path: path, baseURL: baseURL, body: body)

        case .login(let username, let password):
            let body = try JSONEncoder().encode(["username": username, "password": password])
            return try buildRequest(method: "POST", path: "/auth/login", baseURL: baseURL, body: body)

        case .refreshToken(let token):
            let body = try JSONEncoder().encode(["refreshToken": token])
            return try buildRequest(method: "POST", path: "/auth/refresh", baseURL: baseURL, body: body)

        case .userProfile(let id):
            return try buildRequest(method: "GET", path: "/users/\(id)", baseURL: baseURL)

        case .listItems(let page, let limit):
            return try buildRequest(method: "GET", path: "/items", baseURL: baseURL, parameters: ["page": page, "limit": limit])

        case .uploadFile(let data):
            var request = try buildRequest(method: "POST", path: "/upload", baseURL: baseURL, body: data)
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            return request
        }
    }

    /**
     * Build request helper
     * 构建请求辅助方法
     */
    private func buildRequest(
        method: String,
        path: String,
        baseURL: String,
        parameters: [String: Any]? = nil,
        body: Data? = nil
    ) throws -> URLRequest {
        // Build URL with parameters / 构建带参数的 URL
        var urlComponents = URLComponents(string: baseURL + path)

        if let parameters = parameters {
            urlComponents?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }

        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        // Create request / 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        // Set headers / 设置头部
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
}

// MARK: - Network Service Dependency / 网络服务依赖

extension NetworkServiceClient: DependencyKey {
    /**
     * Live implementation using NetworkService
     * 使用 NetworkService 的实时实现
     */
    static let liveValue: NetworkServiceClient = {
        let service = NetworkService.default

        return NetworkServiceClient(
            request: { endpoint in
                let request = try endpoint.urlRequest()
                return try await service.request(request)
            },
            requestData: { endpoint in
                let request = try endpoint.urlRequest()
                return try await service.request(request)
            },
            requestString: { endpoint in
                let request = try endpoint.urlRequest()
                let data = try await service.request(request)
                guard let string = String(data: data, encoding: .utf8) else {
                    throw NetworkError.dataCorrupted
                }
                return string
            },
            upload: { endpoint, data, progress in
                // Simplified upload implementation / 简化的上传实现
                progress(0.0)
                let request = try endpoint.urlRequest()
                let result = try await service.request(request)
                progress(1.0)
                return result
            },
            download: { endpoint, progress in
                // Simplified download implementation / 简化的下载实现
                progress(0.0)
                let request = try endpoint.urlRequest()
                let data = try await service.request(request)

                // Save to temp file / 保存到临时文件
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try data.write(to: tempURL)

                progress(1.0)
                return tempURL
            }
        )
    }()

    /**
     * Test implementation for unit tests
     * 单元测试的测试实现
     */
    static let testValue = NetworkServiceClient(
        request: { _ in
            Data("test".utf8)
        },
        requestData: { _ in
            Data("test".utf8)
        },
        requestString: { _ in
            "test"
        },
        upload: { _, _, progress in
            progress(1.0)
            return Data("uploaded".utf8)
        },
        download: { _, progress in
            progress(1.0)
            return URL(fileURLWithPath: "/tmp/test")
        }
    )

    /**
     * Preview implementation for SwiftUI previews
     * SwiftUI 预览的预览实现
     */
    static let previewValue = NetworkServiceClient(
        request: { endpoint in
            // Return mock data based on endpoint / 基于端点返回模拟数据
            switch endpoint {
            case .listItems:
                // Create proper JSON data for list items / 为列表项创建正确的 JSON 数据
                let items = [
                    ["id": "1", "title": "Item 1"],
                    ["id": "2", "title": "Item 2"]
                ]
                return try JSONEncoder().encode(items)
            default:
                return Data("preview".utf8)
            }
        },
        requestData: { endpoint in
            // Return mock data based on endpoint / 基于端点返回模拟数据
            switch endpoint {
            case .listItems:
                // Create proper JSON data for list items / 为列表项创建正确的 JSON 数据
                let items = [
                    ["id": "1", "title": "Item 1"],
                    ["id": "2", "title": "Item 2"]
                ]
                return try JSONEncoder().encode(items)
            default:
                return Data("preview".utf8)
            }
        },
        requestString: { endpoint in
            switch endpoint {
            case .userProfile:
                return "{\"id\": \"123\", \"name\": \"Preview User\"}"
            default:
                return "preview"
            }
        },
        upload: { _, _, progress in
            progress(1.0)
            return Data("preview-uploaded".utf8)
        },
        download: { _, progress in
            progress(1.0)
            return URL(fileURLWithPath: "/tmp/preview")
        }
    )
}

// MARK: - Dependency Values Extension / 依赖值扩展

extension DependencyValues {
    var networkService: NetworkServiceClient {
        get { self[NetworkServiceClient.self] }
        set { self[NetworkServiceClient.self] = newValue }
    }
}

// MARK: - Helper Extensions / 辅助扩展

extension NetworkServiceClient {
    /**
     * Request with typed decoding
     * 带类型解码的请求
     */
    func request<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async throws -> T {
        let data = try await request(endpoint)
        return try JSONDecoder().decode(type, from: data)
    }

    /**
     * Request with optional response
     * 带可选响应的请求
     */
    func requestOptional<T: Decodable>(_ endpoint: APIEndpoint, as type: T.Type) async -> T? {
        do {
            return try await request(endpoint, as: type)
        } catch {
            #if DEBUG
            print("❌ Request failed: \(error)")
            #endif
            return nil
        }
    }
}

// MARK: - Usage Example in Reducer / 在 Reducer 中的使用示例

/**
 * Example of using NetworkServiceClient in TCA Reducer
 * 在 TCA Reducer 中使用 NetworkServiceClient 的示例
 *
 * ```swift
 * @Reducer
 * struct MyFeature {
 *     struct State: Equatable {
 *         var items: [Item] = []
 *         var isLoading = false
 *         var error: String?
 *     }
 *
 *     enum Action {
 *         case fetchItems
 *         case itemsReceived([Item])
 *         case errorOccurred(Error)
 *     }
 *
 *     @Dependency(\.networkService) var networkService
 *
 *     var body: some ReducerOf<Self> {
 *         Reduce { state, action in
 *             switch action {
 *             case .fetchItems:
 *                 state.isLoading = true
 *                 state.error = nil
 *
 *                 return .run { send in
 *                     do {
 *                         // Network connectivity is automatically checked
 *                         // 自动检查网络连接
 *                         // Errors are automatically handled and mapped
 *                         // 错误会自动处理和映射
 *                         let items = try await networkService.request(
 *                             .listItems(page: 1, limit: 20),
 *                             as: [Item].self
 *                         )
 *                         await send(.itemsReceived(items))
 *                     } catch {
 *                         // All network errors are already properly typed
 *                         // 所有网络错误都已正确类型化
 *                         await send(.errorOccurred(error))
 *                     }
 *                 }
 *
 *             case let .itemsReceived(items):
 *                 state.items = items
 *                 state.isLoading = false
 *                 return .none
 *
 *             case let .errorOccurred(error):
 *                 state.error = error.localizedDescription
 *                 state.isLoading = false
 *                 return .none
 *             }
 *         }
 *     }
 * }
 * ```
 */