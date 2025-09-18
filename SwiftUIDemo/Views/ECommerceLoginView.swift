//
//  ECommerceLoginView.swift
//  SwiftUIDemo
//
//  E-commerce login view with advanced UI
//  电商登录视图，包含高级UI设计
//

/**
 * 🎨 E-COMMERCE LOGIN VIEW - 电商登录视图
 * ═══════════════════════════════════════════════════════════════
 *
 * UI设计原则 / UI Design Principles:
 * 
 * 1. MATERIAL DESIGN 3.0
 *    • 圆角卡片设计
 *    • 柔和的阴影效果
 *    • 流畅的动画过渡
 *
 * 2. 用户体验优化 / UX Optimization
 *    • 实时表单验证
 *    • 清晰的错误提示
 *    • 友好的加载状态
 *
 * 3. 响应式设计 / Responsive Design
 *    • 适配不同屏幕尺寸
 *    • 键盘避让处理
 *    • 横竖屏适配
 *
 * ViewModifier使用 / ViewModifier Usage:
 * • 最大化组件复用
 * • 统一的样式管理
 * • 清晰的代码结构
 */

import SwiftUI
import ComposableArchitecture

struct ECommerceLoginView: View {
    // Store for TCA / TCA存储
    let store: StoreOf<ECommerceLoginFeature>
    
    // Login success callback / 登录成功回调
    var onLoginSuccess: (() -> Void)? = nil
    
    // Animation states / 动画状态
    @State private var logoScale: CGFloat = 0.5
    @State private var formOffset: CGFloat = 50
    @State private var formOpacity: Double = 0
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                // Background gradient / 背景渐变
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo section / Logo区域
                        logoSection
                        
                        // Login form card / 登录表单卡片
                        loginFormCard(viewStore: viewStore)
                        
                        // Social login section / 社交登录区域
                        socialLoginSection(viewStore: viewStore)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarHidden(true)
            .onAppear {
                animateEntrance()
            }
            // iOS 15 compatible onChange / iOS 15 兼容的 onChange
            .onReceive(viewStore.publisher.shouldNavigateToHome) { shouldNavigate in
                print("📱 shouldNavigateToHome changed to: \(shouldNavigate)")
                // Call the success callback when login succeeds
                // 登录成功时调用回调
                if shouldNavigate {
                    print("✅ Calling onLoginSuccess callback")
                    onLoginSuccess?()
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "667eea"),
                Color(hex: "764ba2")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .scaleEffect(logoScale)
                .shadow(radius: 10)
            
            Text("购物商城 / E-Commerce")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("登录您的账户 / Sign in to your account")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.top, 50)
    }
    
    // MARK: - Login Form Card
    
    private func loginFormCard(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        VStack(spacing: 20) {
            // Username field / 用户名输入框
            usernameField(viewStore: viewStore)
            
            // Password field / 密码输入框
            passwordField(viewStore: viewStore)
            
            // Remember me & Forgot password / 记住我和忘记密码
            optionsRow(viewStore: viewStore)
            
            // Error message / 错误消息
            if let error = viewStore.generalError {
                errorMessage(error)
            }
            
            // Login button / 登录按钮
            loginButton(viewStore: viewStore)
            
            // Register link / 注册链接
            registerLink(viewStore: viewStore)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .offset(y: formOffset)
        .opacity(formOpacity)
    }
    
    // MARK: - Form Fields
    
    private func usernameField(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("用户名 / Username", systemImage: "person.fill")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("请输入用户名 / Enter username", text: viewStore.binding(get: \.username, send: { .usernameChanged($0) }))
                .textFieldStyle(CustomTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: viewStore.username) { _ in
                    viewStore.send(.validateUsername)
                }
            
            if let error = viewStore.usernameError {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
    }
    
    private func passwordField(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("密码 / Password", systemImage: "lock.fill")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                if viewStore.isPasswordVisible {
                    TextField("请输入密码 / Enter password", text: viewStore.binding(get: \.password, send: { .passwordChanged($0) }))
                        .textFieldStyle(CustomTextFieldStyle())
                } else {
                    SecureField("请输入密码 / Enter password", text: viewStore.binding(get: \.password, send: { .passwordChanged($0) }))
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                Button(action: { viewStore.send(.togglePasswordVisibility) }) {
                    Image(systemName: viewStore.isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .onChange(of: viewStore.password) { _ in
                viewStore.send(.validatePassword)
            }
            
            if let error = viewStore.passwordError {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Options Row
    
    private func optionsRow(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        HStack {
            // Remember me / 记住我
            Button(action: { viewStore.send(.toggleRememberMe) }) {
                HStack(spacing: 6) {
                    Image(systemName: viewStore.rememberMe ? "checkmark.square.fill" : "square")
                        .font(.system(size: 16))
                    Text("记住我 / Remember")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Forgot password / 忘记密码
            Button(action: { viewStore.send(.forgotPasswordTapped) }) {
                Text("忘记密码? / Forgot?")
                    .font(.caption)
                    .foregroundColor(Color(hex: "667eea"))
            }
        }
    }
    
    // MARK: - Login Button
    
    private func loginButton(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        Button(action: { viewStore.send(.loginButtonTapped) }) {
            HStack {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("登录 / Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewStore.isLoading || !viewStore.isFormValid)
        .opacity(viewStore.isFormValid ? 1 : 0.6)
    }
    
    // MARK: - Register Link
    
    private func registerLink(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        HStack {
            Text("没有账户? / No account?")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { viewStore.send(.registerTapped) }) {
                Text("立即注册 / Register")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "667eea"))
            }
        }
    }
    
    // MARK: - Social Login
    
    private func socialLoginSection(viewStore: ViewStore<ECommerceLoginFeature.State, ECommerceLoginFeature.Action>) -> some View {
        VStack(spacing: 16) {
            Text("或使用以下方式登录 / Or sign in with")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 20) {
                // WeChat login / 微信登录
                SocialLoginButton(
                    icon: "message.fill",
                    title: "微信",
                    color: .green
                ) {
                    viewStore.send(.wechatLoginTapped)
                }
                
                // Apple login / Apple登录
                SocialLoginButton(
                    icon: "apple.logo",
                    title: "Apple",
                    color: .black
                ) {
                    viewStore.send(.appleLoginTapped)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func errorMessage(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.red)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Animations
    
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            logoScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            formOffset = 0
            formOpacity = 1
        }
    }
}

// MARK: - Custom Components

/**
 * 自定义文本框样式
 * Custom text field style
 */
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

/**
 * 社交登录按钮
 * Social login button
 */
struct SocialLoginButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}