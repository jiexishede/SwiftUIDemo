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
    @State private var isLoggedIn = false
    @State private var showLoginAnimation = true
    
    var body: some View {
        Group {
            if isLoggedIn {
                // Show home page directly / 直接显示首页
                ECommerceHomeView(
                    store: Store(initialState: ECommerceHomeFeature.State()) {
                        ECommerceHomeFeature()
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                // Show login page / 显示登录页
                ECommerceLoginWrapperView(
                    onLoginSuccess: {
                        print("🎯 Login success callback triggered / 登录成功回调触发")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLoggedIn = true
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.default, value: isLoggedIn)
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
    
    var body: some View {
        ECommerceLoginView(
            store: Store(
                initialState: ECommerceLoginFeature.State()
            ) {
                ECommerceLoginFeature()
            },
            onLoginSuccess: onLoginSuccess
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