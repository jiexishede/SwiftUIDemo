//
//  DialogDemoView.swift
//  SwiftUIDemo
//
//  Dialog demonstration with debounced buttons and bottom sheets
//  防连点按钮和底部弹窗演示
//

/**
 * DialogDemoView - 弹窗演示视图
 * 
 * FEATURES / 功能:
 * 1. Multiple debounce strategies / 多种防连点策略
 * 2. Adaptive bottom sheets / 自适应底部弹窗
 * 3. Different content types / 不同的内容类型
 * 4. Various dialog styles / 各种弹窗样式
 * 
 * DESIGN PATTERNS / 设计模式:
 * 1. Strategy Pattern for debounce / 防连点的策略模式
 * 2. Factory Pattern for content creation / 内容创建的工厂模式
 * 3. Composite Pattern for complex UI / 复杂 UI 的组合模式
 * 
 * USAGE / 使用:
 * ```
 * DialogDemoView(
 *     store: Store(initialState: DialogDemoFeature.State()) {
 *         DialogDemoFeature()
 *     }
 * )
 * ```
 */

import SwiftUI
import ComposableArchitecture

// MARK: - Dialog Demo View / 弹窗演示视图

struct DialogDemoView: View {
    let store: StoreOf<DialogDemoFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 20) {
                    // Header / 头部
                    headerSection
                    
                    // List items with debounced buttons / 带防连点按钮的列表项
                    listSection(viewStore: viewStore)
                    
                    // Additional dialog demos / 额外的弹窗演示
                    additionalDialogsSection(viewStore: viewStore)
                }
                .padding()
            }
            .navigationTitle("弹窗演示 / Dialog Demo")
            .navigationBarTitleDisplayMode(.large)
            // Bottom sheets for different items / 不同项目的底部弹窗
            .bottomSheets(viewStore: viewStore)
        }
    }
    
    // MARK: - Header Section / 头部部分
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.bottomthird.inset.filled")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("防连点按钮与底部弹窗")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Debounced Buttons & Bottom Sheets")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("点击按钮查看不同的防连点策略和弹窗样式")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Tap buttons to see different debounce strategies and sheet styles")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - List Section / 列表部分
    
    private func listSection(viewStore: ViewStore<DialogDemoFeature.State, DialogDemoFeature.Action>) -> some View {
        VStack(spacing: 16) {
            sectionTitle("列表项演示 / List Items Demo")
            
            // Item 1: Table View with Disabled Strategy / 表格视图 - 禁用策略
            listItem(
                title: "表格数据 / Table Data",
                subtitle: "使用禁用策略防连点 / Disabled strategy",
                icon: "tablecells",
                color: .blue,
                strategy: .disabled,
                viewStore: viewStore
            ) {
                viewStore.send(.showBottomSheet(.tableView))
            }
            
            // Item 2: Form View with Task Strategy / 表单视图 - 任务策略
            listItem(
                title: "表单输入 / Form Input",
                subtitle: "使用任务策略防连点 / Task-based strategy",
                icon: "doc.text",
                color: .green,
                strategy: .taskBased,
                viewStore: viewStore
            ) {
                viewStore.send(.showBottomSheet(.formView))
            }
            
            // Item 3: Chart View with Cooldown Strategy / 图表视图 - 冷却策略
            listItem(
                title: "数据图表 / Data Chart",
                subtitle: "使用冷却计时器策略 / Cooldown timer strategy",
                icon: "chart.bar",
                color: .orange,
                strategy: .cooldown,
                viewStore: viewStore
            ) {
                viewStore.send(.showBottomSheet(.chartView))
            }
            
            // Item 4: Media Gallery with Combine Strategy / 媒体画廊 - Combine策略
            listItem(
                title: "媒体画廊 / Media Gallery",
                subtitle: "使用 Combine 策略防连点 / Combine strategy",
                icon: "photo.stack",
                color: .purple,
                strategy: .combine,
                viewStore: viewStore
            ) {
                viewStore.send(.showBottomSheet(.mediaGallery))
            }
        }
    }
    
    // MARK: - List Item Component / 列表项组件
    
    private func listItem(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        strategy: DebounceStrategy,
        viewStore: ViewStore<DialogDemoFeature.State, DialogDemoFeature.Action>,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 16) {
            // Icon / 图标
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(10)
            
            // Text content / 文本内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Debounced button / 防连点按钮
            Button(action: {}) {
                Text("打开 / Open")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(color)
                    .cornerRadius(20)
            }
            .debouncedButton(
                duration: 2.0,
                strategy: strategy,
                showLoading: strategy == .taskBased,
                action: action
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Additional Dialogs Section / 额外弹窗部分
    
    private func additionalDialogsSection(viewStore: ViewStore<DialogDemoFeature.State, DialogDemoFeature.Action>) -> some View {
        VStack(spacing: 16) {
            sectionTitle("其他弹窗类型 / Other Dialog Types")
            
            // Alert dialog / 警告弹窗
            dialogButton(
                title: "警告弹窗 / Alert",
                icon: "exclamationmark.triangle",
                color: .red
            ) {
                viewStore.send(.showDialog(.alert))
            }
            
            // Action sheet / 操作表
            dialogButton(
                title: "操作表 / Action Sheet",
                icon: "rectangle.grid.1x2",
                color: .indigo
            ) {
                viewStore.send(.showDialog(.actionSheet))
            }
            
            // Full screen modal / 全屏模态
            dialogButton(
                title: "全屏模态 / Full Screen",
                icon: "rectangle.fill",
                color: .teal
            ) {
                viewStore.send(.showDialog(.fullScreen))
            }
            
            // Custom popup / 自定义弹出
            dialogButton(
                title: "自定义弹出 / Custom Popup",
                icon: "sparkles",
                color: .pink
            ) {
                viewStore.send(.showDialog(.customPopup))
            }
        }
    }
    
    // MARK: - Dialog Button Component / 弹窗按钮组件
    
    private func dialogButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(color)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
    }
    
    // MARK: - Section Title / 部分标题
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }
}

// MARK: - Bottom Sheets Extension / 底部弹窗扩展

extension View {
    func bottomSheets(viewStore: ViewStore<DialogDemoFeature.State, DialogDemoFeature.Action>) -> some View {
        self
            // Table view sheet / 表格视图弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .tableView },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                TableViewSheetContent()
            }
            // Form view sheet / 表单视图弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .formView },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .adaptive(min: 400, max: 600)
            ) {
                FormViewSheetContent()
            }
            // Chart view sheet / 图表视图弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .chartView },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .percentage(0.7)
            ) {
                ChartViewSheetContent()
            }
            // Media gallery sheet / 媒体画廊弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .mediaGallery },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .fixed(500)
            ) {
                MediaGallerySheetContent()
            }
    }
}

// MARK: - Sheet Content Views / 弹窗内容视图

/**
 * Table View Sheet Content / 表格视图弹窗内容
 * Demonstrates automatic height calculation / 演示自动高度计算
 */
struct TableViewSheetContent: View {
    let items = ["Apple", "Banana", "Orange", "Grape", "Watermelon"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Top text / 顶部文字
            headerText(
                title: "表格数据展示 / Table Data Display",
                subtitle: "这是一个自动计算高度的表格视图 / Auto-height table view"
            )
            
            // Table content / 表格内容
            VStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        
                        Text(item)
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(Int.random(in: 1...100))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    
                    if item != items.last {
                        Divider()
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Bottom text / 底部文字
            footerText(
                primary: "数据更新时间：刚刚 / Updated: Just now",
                secondary: "下拉可关闭此弹窗 / Pull down to dismiss"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Form View Sheet Content / 表单视图弹窗内容
 * Demonstrates adaptive height with bounds / 演示带边界的自适应高度
 */
struct FormViewSheetContent: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var agreeToTerms = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Top text / 顶部文字
            headerText(
                title: "用户反馈表单 / User Feedback Form",
                subtitle: "请填写以下信息 / Please fill in the information"
            )
            
            // Form content / 表单内容
            VStack(spacing: 16) {
                // Name field / 姓名字段
                VStack(alignment: .leading, spacing: 4) {
                    Text("姓名 / Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("请输入姓名 / Enter name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Email field / 邮箱字段
                VStack(alignment: .leading, spacing: 4) {
                    Text("邮箱 / Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("请输入邮箱 / Enter email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                }
                
                // Message field / 留言字段
                VStack(alignment: .leading, spacing: 4) {
                    Text("留言 / Message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $message)
                        .frame(height: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Terms toggle / 条款开关
                Toggle(isOn: $agreeToTerms) {
                    Text("同意条款 / Agree to terms")
                        .font(.caption)
                }
                
                // Submit button / 提交按钮
                Button(action: {}) {
                    Text("提交 / Submit")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!agreeToTerms)
            }
            .padding(.horizontal)
            
            // Bottom text / 底部文字
            footerText(
                primary: "我们会在24小时内回复 / We'll reply within 24 hours",
                secondary: "您的信息将被安全保存 / Your information is secure"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Chart View Sheet Content / 图表视图弹窗内容
 * Demonstrates percentage-based height / 演示基于百分比的高度
 */
struct ChartViewSheetContent: View {
    let data = [45, 78, 23, 90, 56, 34, 67]
    let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Top text / 顶部文字
            headerText(
                title: "数据分析图表 / Data Analytics Chart",
                subtitle: "本周销售数据概览 / Weekly sales overview"
            )
            
            // Chart content / 图表内容
            VStack(spacing: 20) {
                // Bar chart / 条形图
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<data.count, id: \.self) { index in
                        VStack {
                            Text("\(data[index])")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor)
                                .frame(width: 40, height: CGFloat(data[index]) * 2)
                            
                            Text(labels[index])
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Statistics / 统计数据
                HStack(spacing: 20) {
                    statisticItem(title: "总计 / Total", value: "\(data.reduce(0, +))")
                    statisticItem(title: "平均 / Average", value: "\(data.reduce(0, +) / data.count)")
                    statisticItem(title: "最高 / Max", value: "\(data.max() ?? 0)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Bottom text / 底部文字
            footerText(
                primary: "数据每日更新 / Data updates daily",
                secondary: "点击图表可查看详情 / Tap chart for details"
            )
        }
        .padding(.vertical)
    }
    
    private func statisticItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

/**
 * Media Gallery Sheet Content / 媒体画廊弹窗内容
 * Demonstrates fixed height / 演示固定高度
 */
struct MediaGallerySheetContent: View {
    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]
    
    var body: some View {
        VStack(spacing: 16) {
            // Top text / 顶部文字
            headerText(
                title: "媒体画廊 / Media Gallery",
                subtitle: "浏览您的照片和视频 / Browse your photos and videos"
            )
            
            // Gallery content / 画廊内容
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colors[index].opacity(0.3))
                            .frame(height: 150)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(colors[index])
                                    Text("Image \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            )
                    }
                }
                .padding(.horizontal)
            }
            
            // Bottom text / 底部文字
            footerText(
                primary: "共 6 张照片 / 6 photos total",
                secondary: "点击查看大图 / Tap to view full size"
            )
        }
        .padding(.vertical)
    }
}

// MARK: - Helper Views / 辅助视图

private func headerText(title: String, subtitle: String) -> some View {
    VStack(spacing: 8) {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
        
        Text(subtitle)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    .padding(.horizontal)
}

private func footerText(primary: String, secondary: String) -> some View {
    VStack(spacing: 4) {
        Text(primary)
            .font(.caption)
            .foregroundColor(.primary)
        
        Text(secondary)
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    .padding(.horizontal)
    .padding(.bottom)
}

// MARK: - Preview / 预览

struct DialogDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DialogDemoView(
                store: Store(initialState: DialogDemoFeature.State()) {
                    DialogDemoFeature()
                }
            )
        }
    }
}