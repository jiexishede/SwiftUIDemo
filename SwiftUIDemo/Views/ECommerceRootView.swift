//
//  ECommerceRootView.swift
//  SwiftUIDemo
//
//  Root view for e-commerce feature with login management
//  电商功能根视图，管理登录状态
//

/**
 * 🛍️ E-COMMERCE ROOT VIEW - 电商根视图
 * ═══════════════════════════════════════════════════════════════
 *
 * ⚠️ CURRENT IMPLEMENTATION / 当前实现:
 * - Login is SKIPPED by default (isLoggedIn = true) / 默认跳过登录 (isLoggedIn = true)
 * - Login page code is PRESERVED but not used / 登录页面代码保留但不使用
 * - Username/Password are PRE-FILLED: demo/123456 / 用户名密码预填充: demo/123456
 * - To enable login: change isLoggedIn to false / 要启用登录: 将 isLoggedIn 改为 false
 *
 * 导航架构 / Navigation Architecture:
 * 
 * 1. LOGIN FLOW (登录流程)
 *    • 初次进入显示登录页
 *    • 登录成功后进入首页
 *    • 替换导航栈，避免返回到登录页
 *
 * 2. NAVIGATION STACK (导航栈)
 *    • 项目首页 → 电商根视图 → 电商首页
 *    • 返回时直接回到项目首页
 *    • 不会返回到登录页
 *
 * 3. STATE MANAGEMENT (状态管理)
 *    • 使用 @State 管理登录状态
 *    • 登录成功后切换视图
 *    • 保持简单的状态流
 */

import SwiftUI
import ComposableArchitecture

/**
 * 电商根视图 - 管理登录流程和导航
 * E-Commerce Root View - Manages login flow and navigation
 * 
 * 架构职责 / Architectural Responsibilities:
 * 1. 登录状态管理: 控制显示登录页还是首页
 * 2. Store生命周期: 延迟创建homeStore，优化内存使用
 * 3. 导航流程: 确保登录后不能返回登录页
 * 
 * 设计模式 / Design Pattern:
 * - 状态机模式: 通过isLoggedIn控制视图状态
 * - 延迟初始化: homeStore只在需要时创建
 * - 回调模式: 通过闭包处理登录成功事件
 */
struct ECommerceRootView: View {
    // MARK: - State Properties / 状态属性
    
    /**
     * 登录状态标志
     * Login status flag
     * 
     * false: 显示登录页面
     * true: 显示商城首页
     * 
     * 重要: 默认为false以确保用户必须登录
     * Important: Default to false to ensure user must login
     */
    @State private var isLoggedIn = false
    
    /**
     * 动画控制标志
     * Animation control flag
     * 
     * 用于控制页面切换动画
     */
    @State private var showLoginAnimation = false
    
    /**
     * 首页Store - 延迟创建
     * Home page Store - Lazy creation
     * 
     * 优化策略 / Optimization Strategy:
     * - 只在登录成功后创建
     * - 避免不必要的内存占用
     * - 确保数据加载时机正确
     */
    @State private var homeStore: StoreOf<ECommerceHomeFeature>?
    
    // MARK: - Initialization / 初始化
    
    /**
     * 视图初始化器
     * View Initializer
     * 
     * 关键操作 / Key Operations:
     * 1. 设置isLoggedIn = false 强制显示登录页
     * 2. homeStore初始化为nil，延迟创建
     * 3. 打印调试信息帮助追踪流程
     * 
     * 为什么使用_property语法 / Why use _property syntax:
     * - 直接访问@State的底层存储
     * - 在init中设置初始值
     * - 避免属性包装器的限制
     */
    init() {
        print("🔨 ECommerceRootView init - setting isLoggedIn = false (enable login)")
        
        // 强制设置初始状态，确保显示登录页
        // Force initial state to ensure login page is shown
        _isLoggedIn = State(initialValue: false)
        _showLoginAnimation = State(initialValue: false)
        _homeStore = State(initialValue: nil)  // 延迟创建，优化性能
    }
    
    var body: some View {
        Group {
            // Conditional display based on login state / 根据登录状态条件显示
            if isLoggedIn {
                /**
                 * 已登录状态 - 显示商城首页
                 * Logged in state - Show e-commerce home
                 * 
                 * 双重检查 / Double check:
                 * 1. isLoggedIn = true
                 * 2. homeStore != nil
                 * 
                 * 这确保了Store已正确创建
                 */
                if let store = homeStore {
                    ECommerceHomeView(store: store)
                        .transition(.opacity)
                        .onAppear {
                            print("✨ ECommerceHomeView appeared - Login successful!")
                            
                            /**
                             * 关键时机 - 视图出现时立即加载数据
                             * Critical timing - Load data immediately when view appears
                             * 
                             * 发送.onAppear action会触发:
                             * 1. 5个核心用户API并行请求
                             * 2. 各组件数据加载
                             * 3. 错误状态初始化
                             */
                            store.send(.onAppear)
                        }
                } else {
                    // Loading state while creating store / 创建Store时的加载状态
                    ProgressView("Loading...")
                        .onAppear {
                            print("📦 Creating homeStore after login success")
                        }
                }
            } else {
                /**
                 * 未登录状态 - 显示登录页面
                 * Not logged in - Show login page
                 * 
                 * 使用包装器视图处理登录成功回调
                 * Use wrapper view to handle login success callback
                 */
                ECommerceLoginWrapperView(
                    onLoginSuccess: {
                        print("🎯 Login success callback triggered in ECommerceRootView / 登录成功回调触发")
                        print("📊 Current isLoggedIn: \(isLoggedIn)")
                        
                        /**
                         * 步骤1: 创建HomeStore
                         * Step 1: Create HomeStore
                         * 
                         * 延迟创建的优势 / Benefits of lazy creation:
                         * - 节省内存: 未登录时不占用资源
                         * - 状态清晰: 登录成功才初始化
                         * - 数据新鲜: 确保获取最新数据
                         */
                        if homeStore == nil {
                            print("🏪 Creating ECommerceHomeFeature store after login")
                            homeStore = Store(initialState: ECommerceHomeFeature.State()) {
                                ECommerceHomeFeature()
                            }
                        }
                        
                        /**
                         * 步骤2: 更新UI状态
                         * Step 2: Update UI State
                         * 
                         * 使用主队列的原因 / Why use main queue:
                         * - 确保UI更新在主线程
                         * - 避免潜在的线程问题
                         * - SwiftUI要求UI更新必须在主线程
                         */
                        DispatchQueue.main.async {
                            print("🔄 Setting isLoggedIn to true on main queue")
                            
                            // 带动画的状态切换，提供平滑过渡
                            // Animated state transition for smooth UX
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.isLoggedIn = true
                                print("✅ isLoggedIn is now: \(self.isLoggedIn)")
                            }
                            
                            /**
                             * 步骤3: 触发数据加载
                             * Step 3: Trigger data loading
                             * 
                             * 延迟0.1秒的原因 / Why delay 0.1s:
                             * - 确保视图切换动画开始
                             * - 避免同时处理过多任务
                             * - 提供更好的用户体验
                             */
                            if let store = self.homeStore {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    print("🚀 Triggering initial data load after login")
                                    store.send(.onAppear)
                                }
                            }
                        }
                    }
                )
                .transition(.opacity)
                .onAppear {
                    print("🔐 ECommerceLoginWrapperView appeared / 登录包装视图出现")
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
        .onAppear {
            print("🚀 ECommerceRootView appeared")
            let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
            print("📱 iOS Version: \(systemVersion.majorVersion).\(systemVersion.minorVersion)")
            print("📊 isLoggedIn: \(isLoggedIn)")
            print("🔍 View currently showing: \(isLoggedIn ? "Home" : "Login")")
        }
        .onChange(of: isLoggedIn) { newValue in
            print("🔔 isLoggedIn changed to: \(newValue)")
            print("🏠 Will show: \(newValue ? "ECommerceHomeView" : "ECommerceLoginWrapperView")")
        }
    }
}

/**
 * 登录页面包装视图
 * Login page wrapper view
 * 
 * 处理登录成功回调
 * Handle login success callback
 */
struct ECommerceLoginWrapperView: View {
    let onLoginSuccess: () -> Void
    
    init(onLoginSuccess: @escaping () -> Void) {
        self.onLoginSuccess = onLoginSuccess
        print("🔧 ECommerceLoginWrapperView initialized with callback / 登录包装器初始化带回调")
    }
    
    var body: some View {
        ECommerceLoginView(
            store: Store(
                initialState: ECommerceLoginFeature.State()
            ) {
                ECommerceLoginFeature()
            },
            onLoginSuccess: {
                print("🎉 ECommerceLoginWrapperView - Login success, calling parent callback / 登录成功，调用父回调")
                onLoginSuccess()
            }
        )
        .navigationBarHidden(true)  // Hide nav bar on login page / 登录页隐藏导航栏
    }
}

// MARK: - Preview / 预览

#Preview {
    NavigationView {
        ECommerceRootView()
    }
}