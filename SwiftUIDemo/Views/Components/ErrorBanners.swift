//
//  ErrorBanners.swift
//  SwiftUIDemo
//
//  Reusable error banner components
//  可复用的错误横幅组件
//

/**
 * ERROR BANNERS - 错误横幅组件
 * ═══════════════════════════════════════════════════════════════
 *
 * 组件设计 / Component Design:
 * 
 * 1. 三种错误横幅 / Three Error Banners
 *    • 粉色错误提示：严重错误，显示在页面顶部
 *    • 橙色悬浮提示：全局警告，固定在底部
 *    • 蓝色错误横幅：批量重试，显示在顶部
 *
 * 2. MVP 功能 / MVP Features
 *    • 基础错误展示
 *    • 重试功能
 *    • 关闭功能
 *
 * 3. 预留扩展 / Extensions Reserved
 *    • Extension 1: 动画效果
 *    • Extension 2: 自定义图标
 *    • Extension 3: 错误详情展开
 *
 * ViewModifier 应用 / ViewModifier Usage:
 * • 统一样式管理
 * • 可复用的动画效果
 * • 响应式布局适配
 */

import SwiftUI

// MARK: - Pink Error Banner / 粉色错误横幅

/**
 * 粉色错误提示组件
 * Pink error alert component
 * 
 * 用于显示严重错误，如核心API失败
 * Used for critical errors like core API failures
 */
struct PinkErrorBanner: View {
    let message: String
    let onRetry: (() -> Void)?
    @Binding var isVisible: Bool
    
    // MVP: Basic display / MVP：基础显示
    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
                HStack {
                    // Error icon / 错误图标
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                    
                    // Error message / 错误消息
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Close button / 关闭按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    // Pink gradient background / 粉色渐变背景
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 182/255, blue: 193/255),
                            Color(red: 255/255, green: 105/255, blue: 180/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                // Retry button if provided / 重试按钮（如果提供）
                if let onRetry = onRetry {
                    Button(action: onRetry) {
                        Text("点击重试 / Tap to Retry")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            
            // Extension 1: Add bounce animation / 扩展1：添加弹跳动画
            // .modifier(BounceAnimationModifier())
            
            // Extension 2: Custom error icon based on type / 扩展2：基于类型的自定义图标
            // .modifier(CustomErrorIconModifier(errorType: .critical))
        }
    }
}

// MARK: - Orange Floating Alert / 橙色悬浮提示

/**
 * 橙色悬浮提示组件
 * Orange floating alert component
 * 
 * 用于全局警告，固定在屏幕底部
 * Used for global warnings, fixed at screen bottom
 */
struct OrangeFloatingAlert: View {
    let message: String
    let onDismiss: (() -> Void)?
    
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                // Warning icon / 警告图标
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("系统提示 / System Alert")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .padding(16)
            .background(
                // Orange gradient / 橙色渐变
                LinearGradient(
                    colors: [
                        Color(red: 255/255, green: 152/255, blue: 0/255),
                        Color(red: 255/255, green: 87/255, blue: 34/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .offset(y: offset)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offset = 0
                opacity = 1
            }
        }
        
        // Extension 3: Auto-dismiss after timeout / 扩展3：超时自动消失
        // .modifier(AutoDismissModifier(duration: 5))
    }
}

// MARK: - Blue Error Banner / 蓝色错误横幅

/**
 * 蓝色错误横幅组件
 * Blue error banner component
 * 
 * 用于批量重试操作
 * Used for batch retry operations
 */
struct BlueErrorBanner: View {
    let errorCount: Int
    let failedAPIs: [String]
    let onRetryAll: () -> Void
    let onRetrySelected: ([String]) -> Void
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main banner / 主横幅
            HStack {
                // Error count badge / 错误计数徽章
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text("\(errorCount)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Error message / 错误消息
                VStack(alignment: .leading, spacing: 2) {
                    Text("检测到 \(errorCount) 个服务异常")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(errorCount) service errors detected")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Retry all button / 全部重试按钮
                Button(action: onRetryAll) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                        Text("全部重试 / Retry All")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(15)
                }
                
                // Expand/Collapse button / 展开/收起按钮
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(16)
            .background(
                // Blue gradient / 蓝色渐变
                LinearGradient(
                    colors: [
                        Color(red: 33/255, green: 150/255, blue: 243/255),
                        Color(red: 13/255, green: 71/255, blue: 161/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Expanded details / 展开的详情
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(failedAPIs, id: \.self) { api in
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            
                            Text(api)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                onRetrySelected([api])
                            }) {
                                Text("重试 / Retry")
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                }
                .background(Color.gray.opacity(0.05))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - ViewModifier Extensions / ViewModifier 扩展

/**
 * 错误横幅样式修饰符
 * Error banner style modifier
 */
struct ErrorBannerStyle: ViewModifier {
    let backgroundColor: Color
    let textColor: Color
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension View {
    /**
     * 应用错误横幅样式
     * Apply error banner style
     */
    func errorBannerStyle(
        backgroundColor: Color = .red,
        textColor: Color = .white,
        cornerRadius: CGFloat = 8
    ) -> some View {
        modifier(ErrorBannerStyle(
            backgroundColor: backgroundColor,
            textColor: textColor,
            cornerRadius: cornerRadius
        ))
    }
}

// MARK: - Preview / 预览

#if DEBUG
struct ErrorBanners_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Pink error banner / 粉色错误横幅
            PinkErrorBanner(
                message: "用户信息加载失败，请检查网络连接",
                onRetry: { print("Retry pink") },
                isVisible: .constant(true)
            )
            .padding()
            
            // Blue error banner / 蓝色错误横幅
            BlueErrorBanner(
                errorCount: 3,
                failedAPIs: ["用户资料", "用户设置", "用户权限"],
                onRetryAll: { print("Retry all") },
                onRetrySelected: { apis in print("Retry: \(apis)") },
                isExpanded: .constant(true)
            )
            .padding()
            
            Spacer()
            
            // Orange floating alert / 橙色悬浮提示
            OrangeFloatingAlert(
                message: "网络连接不稳定，部分功能可能受影响",
                onDismiss: { print("Dismiss orange") }
            )
        }
        .background(Color.gray.opacity(0.1))
    }
}
#endif