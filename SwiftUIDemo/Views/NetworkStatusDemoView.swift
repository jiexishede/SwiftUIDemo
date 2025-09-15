//
//  NetworkStatusDemoView.swift
//  SwiftUIDemo
//
//  Network status monitoring demo view
//  网络状态监控演示视图
//

import SwiftUI
import Network

/**
 * NETWORK STATUS DEMO VIEW - 网络状态演示视图
 * 
 * PURPOSE / 目的:
 * - Demonstrate network connectivity detection
 * - 演示网络连接检测
 * - Show real-time network status changes
 * - 显示实时网络状态变化
 * - Test network-aware features
 * - 测试网络感知功能
 * 
 * HOW TO TEST / 如何测试:
 * 1. On Simulator / 在模拟器上:
 *    - Device menu -> Network -> No Network
 *    - 设备菜单 -> 网络 -> 无网络
 * 
 * 2. On Real Device / 在真机上:
 *    - Turn on/off Airplane Mode
 *    - 开关飞行模式
 *    - Toggle WiFi/Cellular
 *    - 切换 WiFi/蜂窝数据
 */
struct NetworkStatusDemoView: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var testRequestResult: String = ""
    @State private var isTestingRequest = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Main Status Card / 主状态卡片
                mainStatusCard
                
                // Connection Details / 连接详情
                connectionDetailsCard
                
                // Network Properties / 网络属性
                networkPropertiesCard
                
                // Test Network Request / 测试网络请求
                testRequestCard
                
                // How to Test Guide / 测试指南
                testingGuideCard
            }
            .padding()
        }
        .navigationTitle("Network Status / 网络状态")
        .navigationBarTitleDisplayMode(.inline)
        // Apply network aware modifier / 应用网络感知修饰符
        .networkAware(showBanner: true)
    }
    
    // MARK: - Main Status Card / 主状态卡片
    
    private var mainStatusCard: some View {
        VStack(spacing: 16) {
            // Big status icon / 大状态图标
            Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(networkMonitor.isConnected ? .green : .red)
                .animation(.easeInOut, value: networkMonitor.isConnected)
            
            // Status text / 状态文本
            Text(networkMonitor.isConnected ? "Connected / 已连接" : "Disconnected / 已断开")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(networkMonitor.isConnected ? .green : .red)
            
            // Status description / 状态描述
            Text(networkMonitor.statusDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
    }
    
    // MARK: - Connection Details Card / 连接详情卡片
    
    private var connectionDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Connection Details / 连接详情", systemImage: "info.circle")
                .font(.headline)
            
            Divider()
            
            // Connection Type / 连接类型
            HStack {
                Label("Type / 类型", systemImage: networkMonitor.connectionType.icon)
                    .foregroundColor(.secondary)
                Spacer()
                Text(networkMonitor.connectionType.description)
                    .fontWeight(.medium)
            }
            
            // Connection Status / 连接状态
            HStack {
                Label("Status / 状态", systemImage: "circle.fill")
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(networkMonitor.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(networkMonitor.isConnected ? "Active / 活跃" : "Inactive / 非活跃")
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Network Properties Card / 网络属性卡片
    
    private var networkPropertiesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Network Properties / 网络属性", systemImage: "gear")
                .font(.headline)
            
            Divider()
            
            // Expensive Connection / 昂贵连接
            PropertyRow(
                title: "Expensive / 昂贵",
                icon: "dollarsign.circle",
                value: networkMonitor.isExpensive ? "Yes / 是" : "No / 否",
                isWarning: networkMonitor.isExpensive
            )
            
            // Constrained Connection / 受限连接
            PropertyRow(
                title: "Constrained / 受限",
                icon: "exclamationmark.triangle",
                value: networkMonitor.isConstrained ? "Yes / 是" : "No / 否",
                isWarning: networkMonitor.isConstrained
            )
            
            // Can Perform Expensive Operations / 可执行昂贵操作
            PropertyRow(
                title: "Allow Heavy Operations / 允许大型操作",
                icon: "arrow.up.arrow.down.circle",
                value: networkMonitor.canPerformExpensiveOperation ? "Yes / 是" : "No / 否",
                isWarning: !networkMonitor.canPerformExpensiveOperation
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Test Request Card / 测试请求卡片
    
    private var testRequestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Test Network Request / 测试网络请求", systemImage: "network")
                .font(.headline)
            
            Divider()
            
            Text("Click the button to test a network request with automatic connectivity checking.")
            Text("点击按钮测试带有自动连接检查的网络请求。")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: performTestRequest) {
                HStack {
                    if isTestingRequest {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Test Request / 测试请求")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isTestingRequest)
            
            if !testRequestResult.isEmpty {
                Text(testRequestResult)
                    .font(.caption)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Testing Guide Card / 测试指南卡片
    
    private var testingGuideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How to Test / 如何测试", systemImage: "questionmark.circle")
                .font(.headline)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("On iOS Simulator / 在 iOS 模拟器上:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("• Device → Network → Network Link Conditioner")
                Text("• 设备 → 网络 → 网络链接调节器")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("On Real Device / 在真机上:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("• Toggle Airplane Mode / 切换飞行模式")
                Text("• Turn WiFi/Cellular on/off / 开关 WiFi/蜂窝数据")
                Text("• Settings → Developer → Network Link Conditioner")
                Text("• 设置 → 开发者 → 网络链接调节器")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Helper Methods / 辅助方法
    
    private func performTestRequest() {
        isTestingRequest = true
        testRequestResult = "Testing... / 测试中..."
        
        // Simulate network request / 模拟网络请求
        Task {
            do {
                if !networkMonitor.isConnected {
                    throw NetworkError.noConnection
                }
                
                // Simulate API call / 模拟 API 调用
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                
                await MainActor.run {
                    testRequestResult = """
                    ✅ Success / 成功
                    Connection Type / 连接类型: \(networkMonitor.connectionType.description)
                    Timestamp / 时间戳: \(Date().formatted(date: .omitted, time: .standard))
                    """
                    isTestingRequest = false
                }
            } catch {
                await MainActor.run {
                    testRequestResult = """
                    ❌ Failed / 失败
                    Error / 错误: \(error.localizedDescription)
                    Tip / 提示: Check your network connection / 请检查网络连接
                    """
                    isTestingRequest = false
                }
            }
        }
    }
}

// MARK: - Property Row Component / 属性行组件

struct PropertyRow: View {
    let title: String
    let icon: String
    let value: String
    let isWarning: Bool
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
                .font(.callout)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(isWarning ? .orange : .primary)
                .font(.callout)
        }
    }
}

// MARK: - Preview / 预览

struct NetworkStatusDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NetworkStatusDemoView()
        }
    }
}