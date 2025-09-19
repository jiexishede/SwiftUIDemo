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

struct ECommerceRootView: View {
    // State to track if user is logged in / 追踪用户是否已登录
    // NOW: Default to false to enable login / 现在：默认为false以启用登录
    @State private var isLoggedIn = false  // Enable login / 启用登录
    @State private var showLoginAnimation = false
    
    // Store for home page (created lazily) / 首页的Store（延迟创建）
    @State private var homeStore: StoreOf<ECommerceHomeFeature>?
    
    // Initialize with login enabled / 初始化时启用登录
    init() {
        print("🔨 ECommerceRootView init - setting isLoggedIn = false (enable login)")
        // Force the initial state / 强制初始状态
        _isLoggedIn = State(initialValue: false)  // Enable login / 启用登录
        _showLoginAnimation = State(initialValue: false)
        _homeStore = State(initialValue: nil)
    }
    
    var body: some View {
        Group {
            // Conditional display based on login state / 根据登录状态条件显示
            if isLoggedIn {
                // Show home page after successful login / 登录成功后显示首页
                if let store = homeStore {
                    ECommerceHomeView(store: store)
                        .transition(.opacity)
                        .onAppear {
                            print("✨ ECommerceHomeView appeared - Login successful! / 商城首页出现 - 登录成功！")
                            // Trigger data loading when view appears / 视图出现时触发数据加载
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
                // Show login page when not logged in / 未登录时显示登录页
                ECommerceLoginWrapperView(
                    onLoginSuccess: {
                        print("🎯 Login success callback triggered in ECommerceRootView / 登录成功回调触发")
                        print("📊 Current isLoggedIn: \(isLoggedIn)")
                        
                        // Create homeStore when login succeeds / 登录成功时创建homeStore
                        if homeStore == nil {
                            print("🏪 Creating ECommerceHomeFeature store after login")
                            homeStore = Store(initialState: ECommerceHomeFeature.State()) {
                                ECommerceHomeFeature()
                            }
                        }
                        
                        // Use DispatchQueue.main to ensure UI update / 使用主队列确保 UI 更新
                        DispatchQueue.main.async {
                            print("🔄 Setting isLoggedIn to true on main queue / 在主队列上设置 isLoggedIn 为 true")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.isLoggedIn = true
                                print("✅ isLoggedIn is now: \(self.isLoggedIn)")
                            }
                            
                            // Trigger data loading immediately after login / 登录后立即触发数据加载
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