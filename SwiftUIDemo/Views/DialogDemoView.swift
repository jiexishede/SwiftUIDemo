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
            
            // Scrollable list with many items / 可滚动的列表，包含多个项目
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 12) {
                    // Item 1: Minimal content (very short) / 最小内容（非常短）
                    listItem(
                        title: "快速操作 / Quick Action",
                        subtitle: "最小高度弹窗 / Minimal height sheet",
                        icon: "bolt.fill",
                        color: .yellow,
                        strategy: .disabled,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.minimal))
                    }
                    
                    // Item 2: Small table / 小表格
                    listItem(
                        title: "小型列表 / Small List",
                        subtitle: "3个项目 / 3 items - Disabled strategy",
                        icon: "list.bullet.rectangle",
                        color: .cyan,
                        strategy: .disabled,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.smallTable))
                    }
                    
                    // Item 3: Medium table / 中等表格
                    listItem(
                        title: "表格数据 / Table Data",
                        subtitle: "8个项目 / 8 items - Task strategy",
                        icon: "tablecells",
                        color: .blue,
                        strategy: .taskBased,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.tableView))
                    }
                    
                    // Item 4: Large list / 大列表
                    listItem(
                        title: "大型列表 / Large List",
                        subtitle: "15个项目 / 15 items - Cooldown strategy",
                        icon: "list.bullet.indent",
                        color: .indigo,
                        strategy: .cooldown,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.largeList))
                    }
                    
                    // Item 5: Form View / 表单视图
                    listItem(
                        title: "表单输入 / Form Input",
                        subtitle: "中等高度 / Medium height - Combine strategy",
                        icon: "doc.text",
                        color: .green,
                        strategy: .combine,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.formView))
                    }
                    
                    // Item 6: Chart View / 图表视图
                    listItem(
                        title: "数据图表 / Data Chart",
                        subtitle: "固定百分比高度 / Fixed percentage",
                        icon: "chart.bar",
                        color: .orange,
                        strategy: .disabled,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.chartView))
                    }
                    
                    // Item 7: Media Gallery / 媒体画廊
                    listItem(
                        title: "媒体画廊 / Media Gallery",
                        subtitle: "固定高度 / Fixed height",
                        icon: "photo.stack",
                        color: .purple,
                        strategy: .taskBased,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.mediaGallery))
                    }
                    
                    // Item 8: Settings panel / 设置面板
                    listItem(
                        title: "设置面板 / Settings",
                        subtitle: "多个选项 / Multiple options",
                        icon: "gearshape.fill",
                        color: .gray,
                        strategy: .cooldown,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.settings))
                    }
                    
                    // Item 9: User profile / 用户资料
                    listItem(
                        title: "用户资料 / User Profile",
                        subtitle: "详细信息 / Detailed info",
                        icon: "person.circle.fill",
                        color: .pink,
                        strategy: .combine,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.userProfile))
                    }
                    
                    // Item 10: Long content / 长内容
                    listItem(
                        title: "长文本内容 / Long Text",
                        subtitle: "可滚动内容 / Scrollable content",
                        icon: "doc.richtext",
                        color: .brown,
                        strategy: .disabled,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.longContent))
                    }
                    
                    // Item 11: Expandable Content / 可展开内容
                    listItem(
                        title: "可展开内容 / Expandable",
                        subtitle: "点击展开更多 / Tap to expand",
                        icon: "arrow.up.arrow.down.circle",
                        color: .teal,
                        strategy: .taskBased,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.expandableContent))
                    }
                    
                    // Item 12: Dynamic Form / 动态表单
                    listItem(
                        title: "动态表单 / Dynamic Form",
                        subtitle: "增减字段 / Add/remove fields",
                        icon: "doc.badge.plus",
                        color: .mint,
                        strategy: .cooldown,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.dynamicForm))
                    }
                    
                    // Item 13: Async Loading / 异步加载
                    listItem(
                        title: "异步加载 / Async Loading",
                        subtitle: "加载后更新高度 / Height updates after load",
                        icon: "arrow.triangle.2.circlepath",
                        color: .cyan,
                        strategy: .combine,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.asyncLoading))
                    }
                    
                    // Item 14: Nested Scrolls / 嵌套滚动
                    listItem(
                        title: "嵌套滚动 / Nested Scrolls",
                        subtitle: "多层滚动视图 / Multiple scroll layers",
                        icon: "square.stack.3d.up",
                        color: .indigo,
                        strategy: .disabled,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.nestedScrolls))
                    }
                    
                    // Item 15: Mixed Content / 混合内容
                    listItem(
                        title: "混合内容 / Mixed Content",
                        subtitle: "图文表单组合 / Images, text & forms",
                        icon: "square.grid.2x2",
                        color: .orange,
                        strategy: .taskBased,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.mixedContent))
                    }
                    
                    // Item 16: Dynamic Cards / 动态卡片
                    listItem(
                        title: "动态卡片 / Dynamic Cards",
                        subtitle: "智能高度计算 / Smart height calculation",
                        icon: "rectangle.stack.badge.plus",
                        color: .purple,
                        strategy: .disabled,
                        viewStore: viewStore
                    ) {
                        viewStore.send(.showBottomSheet(.dynamicCards))
                    }
                }
            }
            .frame(maxHeight: 400) // Limit the scroll view height / 限制滚动视图高度
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
            // Minimal sheet / 最小弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .minimal },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                MinimalSheetContent()
            }
            // Small table sheet / 小表格弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .smallTable },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                SmallTableSheetContent()
            }
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
            // Large list sheet / 大列表弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .largeList },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                LargeListSheetContent()
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
            // Settings sheet / 设置弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .settings },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                SettingsSheetContent()
            }
            // User profile sheet / 用户资料弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .userProfile },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                UserProfileSheetContent()
            }
            // Long content sheet / 长内容弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .longContent },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .percentage(0.9)
            ) {
                LongContentSheetContent()
            }
            // Expandable content sheet / 可展开内容弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .expandableContent },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                ExpandableContentSheet()
            }
            // Dynamic form sheet / 动态表单弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .dynamicForm },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                DynamicFormSheet()
            }
            // Async loading sheet / 异步加载弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .asyncLoading },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                AsyncLoadingSheet()
            }
            // Nested scrolls sheet / 嵌套滚动弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .nestedScrolls },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                NestedScrollsSheet()
            }
            // Mixed content sheet / 混合内容弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .mixedContent },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                MixedContentSheet()
            }
            // Dynamic cards sheet / 动态卡片弹窗
            .adaptiveBottomSheet(
                isPresented: viewStore.binding(
                    get: { $0.activeSheet == .dynamicCards },
                    send: { _ in .dismissBottomSheet }
                ),
                height: .automatic
            ) {
                DynamicCardsSheet()
            }
    }
}

// MARK: - Sheet Content Views / 弹窗内容视图

/**
 * Minimal Sheet Content / 最小弹窗内容
 * Demonstrates the smallest possible sheet / 演示最小的弹窗
 */
struct MinimalSheetContent: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text("快速操作 / Quick Action")
                .font(.headline)
            
            Button("完成 / Done") {
                // Action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

/**
 * Small Table Sheet Content / 小表格弹窗内容
 * Just 3 items / 只有3个项目
 */
struct SmallTableSheetContent: View {
    let items = ["Apple", "Banana", "Orange"]
    
    var body: some View {
        VStack(spacing: 12) {
            headerText(
                title: "小型列表 / Small List",
                subtitle: "只有3个项目 / Only 3 items"
            )
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(item)
                            .font(.body)
                        Spacer()
                        Text("$\(index + 1)")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    if index < items.count - 1 {
                        Divider()
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            footerText(
                primary: "最小高度演示 / Minimal height demo",
                secondary: "自动适应内容 / Auto-fit content"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Large List Sheet Content / 大列表弹窗内容
 * Many items to show height adaptation up to 85% screen / 许多项目展示高度适应至屏幕85%
 */
struct LargeListSheetContent: View {
    let items = [
        "Apple", "Banana", "Orange", "Grape", "Watermelon",
        "Strawberry", "Pineapple", "Mango", "Kiwi", "Peach",
        "Pear", "Cherry", "Blueberry", "Raspberry", "Lemon",
        "Coconut", "Papaya", "Guava", "Pomegranate", "Fig",
        "Date", "Apricot", "Plum", "Blackberry", "Cranberry",
        "Grapefruit", "Lime", "Tangerine", "Cantaloupe", "Honeydew",
        "Dragon Fruit", "Lychee", "Passion Fruit", "Star Fruit", "Jackfruit",
        "Durian", "Rambutan", "Mangosteen", "Persimmon", "Kumquat"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            headerText(
                title: "大型列表 / Large List",
                subtitle: "40个项目，展示85%屏幕高度 / 40 items, shows up to 85% screen"
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(item)
                                .font(.body)
                            
                            Spacer()
                            
                            Text("#\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        if index < items.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            // No fixed height - let adaptive bottom sheet handle it
            // 无固定高度 - 让自适应底部弹窗处理
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            footerText(
                primary: "内容可滚动 / Content scrollable",
                secondary: "高度自动限制 / Height auto-limited"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Settings Sheet Content / 设置弹窗内容
 * Multiple toggle options / 多个开关选项
 */
struct SettingsSheetContent: View {
    @State private var notifications = true
    @State private var darkMode = false
    @State private var autoSave = true
    @State private var syncData = false
    
    var body: some View {
        VStack(spacing: 16) {
            headerText(
                title: "设置 / Settings",
                subtitle: "应用偏好设置 / App preferences"
            )
            
            VStack(spacing: 0) {
                Toggle("通知 / Notifications", isOn: $notifications)
                    .padding()
                Divider()
                Toggle("深色模式 / Dark Mode", isOn: $darkMode)
                    .padding()
                Divider()
                Toggle("自动保存 / Auto Save", isOn: $autoSave)
                    .padding()
                Divider()
                Toggle("数据同步 / Sync Data", isOn: $syncData)
                    .padding()
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button("保存设置 / Save Settings") {
                // Save action
            }
            .buttonStyle(.borderedProminent)
            
            footerText(
                primary: "设置立即生效 / Settings apply immediately",
                secondary: "可随时更改 / Can be changed anytime"
            )
        }
        .padding(.vertical)
    }
}

/**
 * User Profile Sheet Content / 用户资料弹窗内容
 * Detailed user information / 详细的用户信息
 */
struct UserProfileSheetContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // Avatar / 头像
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
            
            Text("John Doe")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("john.doe@example.com")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Stats / 统计
            HStack(spacing: 40) {
                VStack {
                    Text("128")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("关注 / Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("1.2K")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("粉丝 / Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("89")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("帖子 / Posts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Actions / 操作
            HStack(spacing: 16) {
                Button("编辑 / Edit") {
                    // Edit action
                }
                .buttonStyle(.bordered)
                
                Button("分享 / Share") {
                    // Share action
                }
                .buttonStyle(.borderedProminent)
            }
            
            footerText(
                primary: "加入时间：2024年1月 / Joined: Jan 2024",
                secondary: "最后活跃：今天 / Last active: Today"
            )
        }
        .padding()
    }
}

/**
 * Long Content Sheet Content / 长内容弹窗内容
 * Scrollable text content / 可滚动的文本内容
 */
struct LongContentSheetContent: View {
    let longText = """
    这是一段很长的文本内容，用于演示底部弹窗如何处理超长内容。
    This is a long text content to demonstrate how bottom sheet handles very long content.
    
    当内容超过屏幕高度时，弹窗会自动限制高度并提供滚动功能。
    When content exceeds screen height, the sheet automatically limits height and provides scrolling.
    
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    
    这种设计确保了用户体验的一致性，无论内容多长都能正常显示。
    This design ensures consistent user experience regardless of content length.
    
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    
    底部弹窗会根据内容自动调整高度，但不会超过屏幕的90%。
    The bottom sheet automatically adjusts height based on content, but won't exceed 90% of screen.
    
    更多内容...
    More content...
    
    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
    """
    
    var body: some View {
        VStack(spacing: 16) {
            headerText(
                title: "长文本内容 / Long Text Content",
                subtitle: "可滚动查看全部 / Scroll to view all"
            )
            
            ScrollView {
                Text(longText)
                    .font(.body)
                    .padding()
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            footerText(
                primary: "共 \(longText.count) 字符 / \(longText.count) characters",
                secondary: "上下滑动查看更多 / Swipe to see more"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Table View Sheet Content / 表格视图弹窗内容
 * Demonstrates automatic height calculation / 演示自动高度计算
 */
struct TableViewSheetContent: View {
    let items = ["Apple", "Banana", "Orange", "Grape", "Watermelon", "Strawberry", "Pineapple", "Mango"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Top text / 顶部文字
            headerText(
                title: "表格数据展示 / Table Data Display",
                subtitle: "这是一个自动计算高度的表格视图 / Auto-height table view"
            )
            
            // Table content / 表格内容
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
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
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading)
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
        .padding(.top, 20)
        .padding(.bottom, 10)
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

/**
 * Expandable Content Sheet / 可展开内容弹窗
 * Demonstrates dynamic height changes / 演示动态高度变化
 */
struct ExpandableContentSheet: View {
    @State private var isExpanded = false
    @State private var expandedSections: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 16) {
            headerText(
                title: "可展开内容 / Expandable Content",
                subtitle: "点击项目展开详情 / Tap items to expand"
            )
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                if expandedSections.contains(index) {
                                    expandedSections.remove(index)
                                } else {
                                    expandedSections.insert(index)
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: expandedSections.contains(index) ? "chevron.down.circle.fill" : "chevron.right.circle")
                                    .foregroundColor(.accentColor)
                                Text("部分 \(index + 1) / Section \(index + 1)")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if expandedSections.contains(index) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("这是展开的内容 / This is expanded content")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("更多详细信息... / More details...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("额外的说明文字 / Additional description")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 28)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            footerText(
                primary: "高度自动调整 / Height auto-adjusts",
                secondary: "根据展开状态变化 / Based on expansion state"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Dynamic Form Sheet / 动态表单弹窗
 * Form with add/remove fields / 可增减字段的表单
 * 
 * KEYBOARD HANDLING / 键盘处理:
 * - Sheet automatically moves up when keyboard appears / 键盘出现时弹窗自动上移
 * - Content remains visible above keyboard / 内容保持在键盘上方可见
 * - Smooth animation synchronized with keyboard / 与键盘同步的平滑动画
 */
struct DynamicFormSheet: View {
    @State private var fields: [String] = ["字段 1 / Field 1", "字段 2 / Field 2"]
    @State private var textValues: [String: String] = [:]
    @FocusState private var focusedField: String?
    
    var body: some View {
        VStack(spacing: 16) {
            headerText(
                title: "动态表单 / Dynamic Form",
                subtitle: "添加或删除字段 / Add or remove fields"
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(fields.enumerated()), id: \.offset) { index, field in
                        HStack {
                            TextField(field, text: binding(for: field))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: field)
                                .submitLabel(.next)
                                .onSubmit {
                                    // Move to next field / 移动到下一个字段
                                    if index < fields.count - 1 {
                                        focusedField = fields[index + 1]
                                    } else {
                                        focusedField = nil
                                    }
                                }
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(
                                                key: FocusedFieldFrameKey.self,
                                                value: focusedField == field ? geometry.frame(in: .global) : nil
                                            )
                                    }
                                )
                            
                            Button(action: {
                                withAnimation {
                                    fields.remove(at: index)
                                    textValues.removeValue(forKey: field)
                                    if focusedField == field {
                                        focusedField = nil
                                    }
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            let newField = "字段 \(fields.count + 1) / Field \(fields.count + 1)"
                            fields.append(newField)
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加字段 / Add Field")
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxHeight: 300)
            .padding(.horizontal)
            
            // Submit button with keyboard dismiss / 带键盘收起的提交按钮
            Button(action: {
                // Dismiss keyboard first / 先收起键盘
                focusedField = nil
                
                // Then submit / 然后提交
                print("表单提交 / Form submitted")
                print("字段数量 / Field count: \(fields.count)")
                for field in fields {
                    print("\(field): \(textValues[field] ?? "空 / Empty")")
                }
            }) {
                Text("提交表单 / Submit Form")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            // Tip about keyboard / 键盘提示
            Text("💡 点击输入框查看键盘避让效果 / Tap input to see keyboard avoidance")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            footerText(
                primary: "键盘出现时自动上移 / Auto-moves when keyboard appears",
                secondary: "保持内容可见 / Keeps content visible"
            )
        }
        .padding(.vertical)
    }
    
    private func binding(for field: String) -> Binding<String> {
        Binding(
            get: { textValues[field] ?? "" },
            set: { textValues[field] = $0 }
        )
    }
}

/**
 * Async Loading Sheet / 异步加载弹窗
 * Content that loads asynchronously / 异步加载的内容
 */
struct AsyncLoadingSheet: View {
    @State private var isLoading = true
    @State private var loadedItems: [String] = []
    
    var body: some View {
        VStack(spacing: 16) {
            headerText(
                title: "异步加载 / Async Loading",
                subtitle: "内容加载后更新高度 / Height updates after loading"
            )
            
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    
                    Text("加载中... / Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .onAppear {
                    // Simulate async loading / 模拟异步加载
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            loadedItems = [
                                "加载项 1 / Loaded Item 1",
                                "加载项 2 / Loaded Item 2",
                                "加载项 3 / Loaded Item 3",
                                "加载项 4 / Loaded Item 4",
                                "加载项 5 / Loaded Item 5",
                                "加载项 6 / Loaded Item 6"
                            ]
                            isLoading = false
                        }
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(loadedItems.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item)
                            Spacer()
                        }
                        .padding()
                        
                        if index < loadedItems.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Button(action: {
                    withAnimation {
                        isLoading = true
                        loadedItems = []
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            loadedItems = [
                                "新项目 1 / New Item 1",
                                "新项目 2 / New Item 2",
                                "新项目 3 / New Item 3",
                                "新项目 4 / New Item 4",
                                "新项目 5 / New Item 5",
                                "新项目 6 / New Item 6",
                                "新项目 7 / New Item 7",
                                "新项目 8 / New Item 8"
                            ]
                            isLoading = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("重新加载 / Reload")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }
            
            footerText(
                primary: "加载完成后高度变化 / Height changes after load",
                secondary: "展示异步内容处理 / Shows async content handling"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Nested Scrolls Sheet / 嵌套滚动弹窗
 * Multiple scroll views nested / 多个嵌套的滚动视图
 */
struct NestedScrollsSheet: View {
    var body: some View {
        VStack(spacing: 16) {
            headerText(
                title: "嵌套滚动 / Nested Scrolls",
                subtitle: "多层滚动视图 / Multiple scroll layers"
            )
            
            // Vertical tabs / 垂直标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<8, id: \.self) { index in
                        VStack {
                            Image(systemName: "folder.fill")
                                .font(.title2)
                            Text("Tab \(index + 1)")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 80)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            
            // Nested vertical scroll / 嵌套垂直滚动
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("部分 \(section + 1) / Section \(section + 1)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(0..<5, id: \.self) { item in
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.accentColor.opacity(0.2))
                                            .frame(width: 100, height: 60)
                                            .overlay(
                                                Text("\(section)-\(item)")
                                                    .font(.caption)
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
            
            footerText(
                primary: "复杂滚动布局 / Complex scroll layout",
                secondary: "水平和垂直滚动组合 / Horizontal and vertical scrolls"
            )
        }
        .padding(.vertical)
    }
}

/**
 * Mixed Content Sheet / 混合内容弹窗
 * Various content types combined / 各种内容类型组合
 */
struct MixedContentSheet: View {
    @State private var sliderValue: Double = 50
    @State private var toggleValue = false
    @State private var selectedSegment = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerText(
                    title: "混合内容 / Mixed Content",
                    subtitle: "图文表单组合 / Images, text & forms"
                )
                
                // Image section / 图片部分
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.8))
                            )
                    }
                }
                
                // Segmented control / 分段控制
                Picker("Options", selection: $selectedSegment) {
                    Text("选项 1").tag(0)
                    Text("选项 2").tag(1)
                    Text("选项 3").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Form controls / 表单控件
                VStack(spacing: 16) {
                    HStack {
                        Text("滑块 / Slider")
                        Spacer()
                        Text("\(Int(sliderValue))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $sliderValue, in: 0...100)
                        .accentColor(.blue)
                    
                    Toggle("开关选项 / Toggle Option", isOn: $toggleValue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Text section / 文本部分
                VStack(alignment: .leading, spacing: 8) {
                    Text("描述文本 / Description")
                        .font(.headline)
                    Text("这是一段混合内容的描述，展示了如何在底部弹窗中组合不同类型的内容元素。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("This is a mixed content description showing how to combine different types of content elements in a bottom sheet.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Action buttons / 操作按钮
                HStack(spacing: 12) {
                    Button(action: {
                        // Reset values / 重置值
                        sliderValue = 50
                        toggleValue = false
                        selectedSegment = 0
                        alertMessage = "已重置所有设置 / All settings reset"
                        showAlert = true
                    }) {
                        Text("重置 / Reset")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        // Save action / 保存操作
                        alertMessage = "设置已保存 / Settings saved\n滑块: \(Int(sliderValue))%\n开关: \(toggleValue ? "开" : "关")\n选项: \(selectedSegment + 1)"
                        showAlert = true
                    }) {
                        Text("保存 / Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                
                footerText(
                    primary: "复杂布局示例 / Complex layout example",
                    secondary: "自动适应内容高度 / Auto-adapts to content height"
                )
            }
            .padding(.vertical)
        }
        .alert("提示 / Notice", isPresented: $showAlert) {
            Button("确定 / OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

/**
 * Dynamic Cards Sheet / 动态卡片弹窗
 * Advanced dynamic content with smart height calculation / 高级动态内容和智能高度计算
 */
struct DynamicCardsSheet: View {
    // Card data model / 卡片数据模型
    struct CardItem: Identifiable, Equatable {
        let id = UUID()
        var title: String
        var description: String
        var isExpanded: Bool = false
        var priority: Priority
        var tags: [String]
        
        enum Priority: Equatable {
            case low, medium, high, urgent
            
            var color: Color {
                switch self {
                case .low: return .gray
                case .medium: return .blue
                case .high: return .orange
                case .urgent: return .red
                }
            }
            
            var icon: String {
                switch self {
                case .low: return "flag"
                case .medium: return "flag.fill"
                case .high: return "exclamationmark.triangle"
                case .urgent: return "exclamationmark.octagon.fill"
                }
            }
        }
    }
    
    // State variables / 状态变量
    @State private var cards: [CardItem] = [
        CardItem(
            title: "任务 1 / Task 1",
            description: "基础任务描述 / Basic task description",
            priority: .medium,
            tags: ["开发 / Dev", "UI"]
        ),
        CardItem(
            title: "紧急修复 / Urgent Fix",
            description: "需要立即处理的问题 / Issue needs immediate attention",
            priority: .urgent,
            tags: ["修复 / Fix", "Bug"]
        )
    ]
    
    @State private var showAddForm = false
    @State private var newCardTitle = ""
    @State private var newCardDescription = ""
    @State private var newCardPriority: CardItem.Priority = .medium
    @State private var filterPriority: CardItem.Priority? = nil
    @State private var sortAscending = true
    
    // Computed properties for dynamic content / 动态内容的计算属性
    private var filteredCards: [CardItem] {
        let filtered = filterPriority == nil ? cards : cards.filter { $0.priority == filterPriority }
        return sortAscending ? filtered : filtered.reversed()
    }
    
    private var contentHeight: CGFloat {
        // Dynamic height calculation based on content / 基于内容的动态高度计算
        let baseHeight: CGFloat = 200  // Header and controls / 头部和控件
        let cardHeight: CGFloat = cards.reduce(0) { total, card in
            total + (card.isExpanded ? 150 : 80)
        }
        let addFormHeight: CGFloat = showAddForm ? 200 : 0
        return min(baseHeight + cardHeight + addFormHeight, 600)  // Max 600 points / 最大600点
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header / 头部
                headerSection
                
                // Filter and Sort Controls / 过滤和排序控件
                controlsSection
                
                // Cards List / 卡片列表
                cardsSection
                
                // Add New Card Button/Form / 添加新卡片按钮/表单
                addCardSection
                
                // Statistics / 统计
                statisticsSection
                
                footerText(
                    primary: "键盘出现时弹窗自动上移 / Sheet moves up with keyboard",
                    secondary: "当前卡片数: \(cards.count) / Current cards: \(cards.count)"
                )
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Header Section / 头部部分
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("动态卡片管理 / Dynamic Card Manager")
                    .font(.headline)
            }
            
            Text("添加、删除、筛选和排序卡片 / Add, remove, filter and sort cards")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Controls Section / 控件部分
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Priority Filter / 优先级过滤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "全部 / All",
                        isSelected: filterPriority == nil,
                        action: { filterPriority = nil }
                    )
                    
                    ForEach([CardItem.Priority.urgent, .high, .medium, .low], id: \.self) { priority in
                        FilterChip(
                            title: priorityName(priority),
                            isSelected: filterPriority == priority,
                            color: priority.color,
                            action: { filterPriority = priority }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Sort Toggle / 排序切换
            HStack {
                Text("排序 / Sort:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: { sortAscending.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(sortAscending ? "升序 / Ascending" : "降序 / Descending")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Cards Section / 卡片部分
    private var cardsSection: some View {
        VStack(spacing: 8) {
            ForEach(filteredCards) { card in
                DynamicCardView(
                    card: binding(for: card),
                    onDelete: { removeCard(card) }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.3), value: cards)
    }
    
    // MARK: - Add Card Section / 添加卡片部分
    private var addCardSection: some View {
        VStack(spacing: 12) {
            if !showAddForm {
                Button(action: { withAnimation { showAddForm = true } }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加新卡片 / Add New Card")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            } else {
                // Add form / 添加表单
                VStack(spacing: 12) {
                    TextField("标题 / Title", text: $newCardTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("描述 / Description", text: $newCardDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Priority Picker / 优先级选择器
                    Picker("优先级 / Priority", selection: $newCardPriority) {
                        Text("低 / Low").tag(CardItem.Priority.low)
                        Text("中 / Medium").tag(CardItem.Priority.medium)
                        Text("高 / High").tag(CardItem.Priority.high)
                        Text("紧急 / Urgent").tag(CardItem.Priority.urgent)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack(spacing: 12) {
                        Button("取消 / Cancel") {
                            withAnimation {
                                showAddForm = false
                                resetForm()
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Button("添加 / Add") {
                            addNewCard()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newCardTitle.isEmpty)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
    }
    
    // MARK: - Statistics Section / 统计部分
    private var statisticsSection: some View {
        HStack(spacing: 20) {
            StatBox(
                title: "总计 / Total",
                value: "\(cards.count)",
                color: .blue
            )
            
            StatBox(
                title: "紧急 / Urgent",
                value: "\(cards.filter { $0.priority == .urgent }.count)",
                color: .red
            )
            
            StatBox(
                title: "展开 / Expanded",
                value: "\(cards.filter { $0.isExpanded }.count)",
                color: .green
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods / 辅助方法
    
    private func binding(for card: CardItem) -> Binding<CardItem> {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else {
            return .constant(card)
        }
        return $cards[index]
    }
    
    private func removeCard(_ card: CardItem) {
        withAnimation(.spring()) {
            cards.removeAll { $0.id == card.id }
        }
    }
    
    private func addNewCard() {
        let newCard = CardItem(
            title: newCardTitle,
            description: newCardDescription,
            priority: newCardPriority,
            tags: []
        )
        
        withAnimation(.spring()) {
            cards.append(newCard)
            showAddForm = false
            resetForm()
        }
    }
    
    private func resetForm() {
        newCardTitle = ""
        newCardDescription = ""
        newCardPriority = .medium
    }
    
    private func priorityName(_ priority: CardItem.Priority) -> String {
        switch priority {
        case .low: return "低 / Low"
        case .medium: return "中 / Medium"
        case .high: return "高 / High"
        case .urgent: return "紧急 / Urgent"
        }
    }
}

// MARK: - Supporting Views / 支持视图

/// Filter Chip Component / 过滤芯片组件
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .accentColor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Dynamic Card View Component / 动态卡片视图组件
struct DynamicCardView: View {
    @Binding var card: DynamicCardsSheet.CardItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header / 头部
            HStack {
                Image(systemName: card.priority.icon)
                    .foregroundColor(card.priority.color)
                    .font(.caption)
                
                Text(card.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: { withAnimation { card.isExpanded.toggle() } }) {
                    Image(systemName: card.isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                        .foregroundColor(.secondary)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            
            // Content / 内容
            if card.isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Tags / 标签
                    if !card.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(card.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Action buttons / 操作按钮
                    HStack(spacing: 8) {
                        Button("编辑 / Edit") {
                            print("编辑卡片: \(card.title)")
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        
                        Button("完成 / Done") {
                            print("完成卡片: \(card.title)")
                        }
                        .font(.caption)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

/// Statistics Box Component / 统计框组件
struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
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