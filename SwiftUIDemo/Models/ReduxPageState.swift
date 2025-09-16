//
//  ReduxPageState.swift
//  ReduxSwiftUIDemo
//
//  Enhanced page state management for network requests
//  增强的网络请求页面状态管理
//

import Foundation

// MARK: - Page State
// 页面状态枚举 / Page State Enum
public enum ReduxPageState<Content: Equatable>: Equatable {
    /// 空闲状态，还未发起请求 / Initial state, no request made yet
    case idle
    /// 加载中，包含不同的加载类型 / Loading with different types
    case loading(LoadingType)
    /// 加载成功，包含内容和加载更多状态 / Successfully loaded with content and load more state
    case loaded(Content, LoadMoreState)
    /// 加载失败，包含失败类型和错误信息 / Failed with error type and error info
    case failed(FailureType, ErrorInfo)
    
    // MARK: - Loading Type
    // 加载类型 / Loading Type
    public enum LoadingType: Equatable {
        /// 首次加载 / First time loading
        case initial
        /// 下拉刷新 / Pull to refresh
        case refresh
        /// 加载更多 / Loading more items
        case loadMore
    }
    
    // MARK: - Load More State
    // 加载更多状态 / Load More State
    public enum LoadMoreState: Equatable {
        /// 空闲，可以加载更多 / Can load more
        case idle
        /// 正在加载更多 / Currently loading more
        case loading
        /// 没有更多数据 / No more items to load
        case noMore
        /// 加载更多失败 / Load more failed
        case failed(ErrorInfo)
        /// 数据为空 / Empty data
        case empty
    }
    
    // MARK: - Failure Type
    // 失败类型 / Failure Type
    public enum FailureType: Equatable {
        /// 初始加载失败 / Initial load failed
        case initial
        /// 刷新失败 / Refresh failed
        case refresh
        /// 加载更多失败 / Load more failed
        case loadMore
    }
    
    // MARK: - Error Info
    // 错误信息 / Error Information
    public struct ErrorInfo: Equatable {
        /// 错误代码 / Error code
        public let code: String
        /// 错误消息 / Error message
        public let message: String
        
        public init(code: String, message: String) {
            self.code = code
            self.message = message
        }
        
        // Legacy initializer for backward compatibility / 向后兼容的初始化器
        public init(type: ErrorType, description: String? = nil, code: Int? = nil) {
            self.code = String(code ?? 0)
            self.message = description ?? type.defaultDescription
        }
    }
    
    // MARK: - Error Type
    // 错误类型枚举 / Error Type Enum
    public enum ErrorType: Equatable {
        /// 网络连接错误 / Network connection error
        case networkConnection
        /// 请求超时 / Request timeout
        case timeout
        /// 服务器错误 / Server error
        case serverError
        /// 数据解析错误 / Data parsing error
        case parsingError
        /// 未知错误 / Unknown error
        case unknown
        
        /// 默认错误描述 / Default error description
        var defaultDescription: String {
            switch self {
            case .networkConnection:
                return "网络连接失败，请检查网络设置 / Network connection failed, please check your network settings"
            case .timeout:
                return "请求超时，请稍后重试 / Request timed out, please try again later"
            case .serverError:
                return "服务器错误，请稍后重试 / Server error, please try again later"
            case .parsingError:
                return "数据解析失败 / Failed to parse data"
            case .unknown:
                return "未知错误 / Unknown error occurred"
            }
        }
    }
    
    // MARK: - Computed Properties
    // 计算属性 / Computed Properties
    
    /// 是否正在加载 / Is loading
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        if case let .loaded(_, loadMoreState) = self,
           case .loading = loadMoreState {
            return true
        }
        return false
    }
    
    /// 是否正在刷新 / Is refreshing
    public var isRefreshing: Bool {
        if case .loading(.refresh) = self {
            return true
        }
        return false
    }
    
    /// 是否正在加载更多 / Is loading more
    public var isLoadingMore: Bool {
        if case .loading(.loadMore) = self {
            return true
        }
        if case let .loaded(_, loadMoreState) = self,
           case .loading = loadMoreState {
            return true
        }
        return false
    }
    
    /// 是否可以加载更多 / Can load more
    public var canLoadMore: Bool {
        if case let .loaded(_, loadMoreState) = self {
            switch loadMoreState {
            case .idle, .failed:
                return true
            case .loading, .noMore, .empty:
                return false
            }
        }
        return false
    }
    
    /// 获取错误信息 / Get error information
    public var errorInfo: ErrorInfo? {
        switch self {
        case let .failed(_, errorInfo):
            return errorInfo
        case let .loaded(_, .failed(errorInfo)):
            return errorInfo
        default:
            return nil
        }
    }
    
    /// 获取错误消息 / Get error message
    public var errorMessage: String? {
        errorInfo?.message
    }
}