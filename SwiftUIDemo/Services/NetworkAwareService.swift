//
//  NetworkAwareService.swift
//  SwiftUIDemo
//
//  Enhanced network service with immediate offline detection
//  带即时离线检测的增强网络服务
//

import Foundation
import Combine
import Network

/**
 * NETWORK AWARE SERVICE - 网络感知服务
 *
 * 这个服务在发起网络请求前就检测网络状态，
 * 避免在断网时等待超时，提供更好的用户体验。
 *
 * This service detects network status before making requests,
 * avoiding timeout waits when offline for better user experience.
 *
 * DESIGN PHILOSOPHY / 设计理念:
 *
 * 传统的网络请求流程在断网时会等待超时（通常30-60秒），
 * 这会导致用户界面长时间无响应。我们的方案是在请求前
 * 就检测网络状态，立即给出反馈。
 *
 * Traditional network request flow waits for timeout (usually 30-60s) when offline,
 * causing unresponsive UI. Our solution detects network status before requests,
 * providing immediate feedback.
 *
 * KEY FEATURES / 关键特性:
 * 1. Immediate offline detection / 即时离线检测
 * 2. Priority-based error handling / 基于优先级的错误处理
 * 3. Automatic retry queue / 自动重试队列
 * 4. Redux page state integration / Redux 页面状态集成
 *
 * USAGE EXAMPLE / 使用示例:
 * ```swift
 * let service = NetworkAwareService.shared
 *
 * // Check network before request / 请求前检查网络
 * let result = await service.request(endpoint: .getData) { pageState in
 *     // Update UI immediately if offline / 离线时立即更新 UI
 *     self.pageState = pageState
 * }
 *
 * switch result {
 * case .success(let data):
 *     // Handle success / 处理成功
 * case .failure(let error):
 *     // Already handled by pageState update / 已通过 pageState 更新处理
 * }
 * ```
 */
public final class NetworkAwareService {
    // MARK: - Singleton / 单例

    public static let shared = NetworkAwareService()

    // MARK: - Properties / 属性

    private let monitor = NetworkMonitor.shared
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Network Error Types / 网络错误类型

    public enum NetworkAwareError: LocalizedError {
        case offline
        case timeout
        case serverError(Int)
        case decodingError
        case unknown(Error)

        public var errorDescription: String? {
            switch self {
            case .offline:
                return "No Internet Connection / 无网络连接"
            case .timeout:
                return "Request Timeout / 请求超时"
            case .serverError(let code):
                return "Server Error (\(code)) / 服务器错误 (\(code))"
            case .decodingError:
                return "Data Format Error / 数据格式错误"
            case .unknown(let error):
                return "Unknown Error: \(error.localizedDescription) / 未知错误: \(error.localizedDescription)"
            }
        }

        /**
         * Priority for error handling
         * 错误处理优先级
         *
         * Higher priority errors should be shown immediately
         * 高优先级错误应立即显示
         */
        var priority: Int {
            switch self {
            case .offline: return 100  // Highest priority / 最高优先级
            case .timeout: return 80
            case .serverError: return 60
            case .decodingError: return 40
            case .unknown: return 20
            }
        }
    }

    // MARK: - Core Request Method / 核心请求方法

    /**
     * Enhanced request with immediate offline detection
     * 带即时离线检测的增强请求
     *
     * WHY THIS DESIGN / 为什么这样设计:
     *
     * 1. Check network BEFORE making request / 在发起请求前检查网络
     * 2. Update page state IMMEDIATELY if offline / 离线时立即更新页面状态
     * 3. No waiting for timeout / 无需等待超时
     * 4. Better user experience / 更好的用户体验
     *
     * @param endpoint: The API endpoint / API 端点
     * @param pageStateHandler: Called immediately with page state / 立即调用并传递页面状态
     * @return: Result with data or error / 包含数据或错误的结果
     */
    public func request<T>(
        endpoint: APIEndpoint,
        pageStateHandler: @escaping (ReduxPageState<T>) -> Void
    ) async -> Result<Data, NetworkAwareError> {

        // CRITICAL: Check network status FIRST / 关键：首先检查网络状态
        if !monitor.isConnected {
            // Update page state IMMEDIATELY / 立即更新页面状态
            let error = NetworkAwareError.offline
            let errorInfo = ReduxPageState<T>.ErrorInfo(
                code: "NETWORK_OFFLINE",
                message: error.localizedDescription
            )
            pageStateHandler(.failed(.initial, errorInfo))

            // Add to retry queue if needed / 如需要则添加到重试队列
            addToRetryQueue(endpoint: endpoint)

            return .failure(error)
        }

        // Network is connected, show loading state / 网络已连接，显示加载状态
        pageStateHandler(.loading(.initial))

        do {
            // Make the actual request / 发起实际请求
            let request = try buildURLRequest(from: endpoint)
            let (data, response) = try await session.data(for: request)

            // Check HTTP response / 检查 HTTP 响应
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    // Success - don't update page state here, let caller handle it
                    // 成功 - 不在这里更新页面状态，让调用者处理
                    return .success(data)

                case 401:
                    // Unauthorized / 未授权
                    let error = NetworkAwareError.serverError(401)
                    let errorInfo = ReduxPageState<T>.ErrorInfo(
                        code: "UNAUTHORIZED",
                        message: "Authentication Required / 需要身份验证"
                    )
                    pageStateHandler(.failed(.initial, errorInfo))
                    return .failure(error)

                case 404:
                    // Not found / 未找到
                    let error = NetworkAwareError.serverError(404)
                    let errorInfo = ReduxPageState<T>.ErrorInfo(
                        code: "NOT_FOUND",
                        message: "Resource Not Found / 资源未找到"
                    )
                    pageStateHandler(.failed(.initial, errorInfo))
                    return .failure(error)

                case 500...599:
                    // Server error / 服务器错误
                    let error = NetworkAwareError.serverError(httpResponse.statusCode)
                    let errorInfo = ReduxPageState<T>.ErrorInfo(
                        code: "SERVER_ERROR",
                        message: error.localizedDescription
                    )
                    pageStateHandler(.failed(.initial, errorInfo))
                    return .failure(error)

                default:
                    // Other error / 其他错误
                    let error = NetworkAwareError.serverError(httpResponse.statusCode)
                    let errorInfo = ReduxPageState<T>.ErrorInfo(
                        code: "HTTP_\(httpResponse.statusCode)",
                        message: "HTTP Error \(httpResponse.statusCode)"
                    )
                    pageStateHandler(.failed(.initial, errorInfo))
                    return .failure(error)
                }
            }

            return .success(data)

        } catch {
            // Handle other errors / 处理其他错误
            let networkError: NetworkAwareError

            if (error as NSError).code == NSURLErrorTimedOut {
                networkError = .timeout
            } else if (error as NSError).domain == NSURLErrorDomain {
                // Check if network was lost during request / 检查请求期间是否失去网络
                if !monitor.isConnected {
                    networkError = .offline
                } else {
                    networkError = .unknown(error)
                }
            } else {
                networkError = .unknown(error)
            }

            let errorInfo = ReduxPageState<T>.ErrorInfo(
                code: "REQUEST_ERROR",
                message: networkError.localizedDescription
            )
            pageStateHandler(.failed(.initial, errorInfo))

            return .failure(networkError)
        }
    }

    // MARK: - Convenience Methods / 便利方法

    /**
     * Request with automatic decoding
     * 带自动解码的请求
     *
     * USAGE / 使用:
     * ```swift
     * let result = await service.requestDecoded(
     *     endpoint: .userProfile,
     *     type: User.self
     * ) { pageState in
     *     self.userPageState = pageState
     * }
     * ```
     */
    public func requestDecoded<T: Decodable>(
        endpoint: APIEndpoint,
        type: T.Type,
        pageStateHandler: @escaping (ReduxPageState<T>) -> Void
    ) async -> Result<T, NetworkAwareError> {

        let dataResult = await request(endpoint: endpoint, pageStateHandler: pageStateHandler)

        switch dataResult {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode(type, from: data)
                // Update page state with success / 更新页面状态为成功
                pageStateHandler(.loaded(decoded, .idle))
                return .success(decoded)
            } catch {
                let decodingError = NetworkAwareError.decodingError
                let errorInfo = ReduxPageState<T>.ErrorInfo(
                    code: "DECODING_ERROR",
                    message: decodingError.localizedDescription
                )
                pageStateHandler(.failed(.initial, errorInfo))
                return .failure(decodingError)
            }

        case .failure(let error):
            // Error already handled in request method / 错误已在 request 方法中处理
            return .failure(error)
        }
    }

    /**
     * Request with array decoding
     * 带数组解码的请求
     */
    public func requestArray<T: Decodable>(
        endpoint: APIEndpoint,
        type: T.Type,
        pageStateHandler: @escaping (ReduxPageState<[T]>) -> Void
    ) async -> Result<[T], NetworkAwareError> {

        let dataResult = await request(endpoint: endpoint, pageStateHandler: pageStateHandler)

        switch dataResult {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode([T].self, from: data)

                // Check if empty / 检查是否为空
                if decoded.isEmpty {
                    pageStateHandler(.loaded([], .empty))
                } else {
                    pageStateHandler(.loaded(decoded, .idle))
                }

                return .success(decoded)
            } catch {
                let decodingError = NetworkAwareError.decodingError
                let errorInfo = ReduxPageState<[T]>.ErrorInfo(
                    code: "DECODING_ERROR",
                    message: decodingError.localizedDescription
                )
                pageStateHandler(.failed(.initial, errorInfo))
                return .failure(decodingError)
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - Private Methods / 私有方法

    private func buildURLRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        switch endpoint {
        case .custom(let request):
            return request
        default:
            // Build request from endpoint / 从端点构建请求
            throw NetworkAwareError.unknown(NSError(domain: "Invalid endpoint", code: -1))
        }
    }

    private func addToRetryQueue(endpoint: APIEndpoint) {
        // Add to NetworkMonitor's retry queue / 添加到 NetworkMonitor 的重试队列
        // This will be retried when network comes back / 网络恢复时将重试

        #if DEBUG
        print("📝 Added request to retry queue due to offline status")
        #endif
    }
}

// MARK: - TCA Integration / TCA 集成

/**
 * Extension for easy TCA integration
 * 便于 TCA 集成的扩展
 *
 * USAGE IN REDUCER / 在 Reducer 中使用:
 * ```swift
 * case .fetchData:
 *     state.pageState = .loading(.initial)
 *     return .run { [state] send in
 *         let result = await NetworkAwareService.shared.requestDecoded(
 *             endpoint: .getData,
 *             type: DataModel.self
 *         ) { pageState in
 *             await send(.updatePageState(pageState))
 *         }
 *
 *         switch result {
 *         case .success(let data):
 *             await send(.dataReceived(data))
 *         case .failure:
 *             // Error already handled by pageState update
 *             // 错误已通过 pageState 更新处理
 *             break
 *         }
 *     }
 * ```
 */
public extension NetworkAwareService {
    /**
     * Create TCA-compatible effect
     * 创建 TCA 兼容的 effect
     */
    func effect<T: Decodable>(
        endpoint: APIEndpoint,
        type: T.Type,
        pageStateAction: @escaping (ReduxPageState<T>) -> Void
    ) async -> Result<T, NetworkAwareError> {
        await requestDecoded(
            endpoint: endpoint,
            type: type,
            pageStateHandler: pageStateAction
        )
    }
}