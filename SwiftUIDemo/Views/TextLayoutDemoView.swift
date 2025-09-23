/**
 * TextLayoutDemoView.swift
 * 文字布局框架演示主页面 - 整合所有布局组件的完整演示界面
 * 
 * Text Layout Framework Demo Main Page - Complete demonstration interface integrating all layout components
 * 
 * 设计思路和技术实现：
 * 本页面作为文字布局框架的主要演示界面，整合了横向流式布局、纵向流式布局、网格布局等多种布局模式。
 * 使用TCA架构管理复杂的UI状态，包括布局类型切换、配置参数调整、演示数据管理等。界面设计注重用户体验，
 * 提供直观的配置面板和实时预览效果，让用户能够轻松理解和使用各种布局功能。
 * 
 * Design Philosophy and Technical Implementation:
 * This page serves as the main demonstration interface for the text layout framework, integrating multiple
 * layout modes including horizontal flow layout, vertical flow layout, grid layout, etc. Uses TCA architecture
 * to manage complex UI state, including layout type switching, configuration parameter adjustment, demo data
 * management, etc. The interface design focuses on user experience, providing intuitive configuration panels
 * and real-time preview effects, allowing users to easily understand and use various layout functions.
 * 
 * 核心技术栈：
 * - SwiftUI: 主要UI框架，实现响应式界面
 * - TCA (The Composable Architecture): 状态管理和业务逻辑
 * - Combine: 数据绑定和响应式编程
 * - 自定义布局组件: FlowLayoutView, VerticalFlowLayoutView, GridLayoutView
 * 
 * Core Technology Stack:
 * - SwiftUI: Main UI framework for responsive interface implementation
 * - TCA (The Composable Architecture): State management and business logic
 * - Combine: Data binding and reactive programming
 * - Custom layout components: FlowLayoutView, VerticalFlowLayoutView, GridLayoutView
 * 
 * 解决的核心问题：
 * 1. 多种布局组件的统一管理和切换
 * 2. 复杂配置参数的用户友好界面
 * 3. 实时预览和配置调整的响应式体验
 * 4. 不同布局模式下的一致性用户体验
 * 5. 演示数据的灵活管理和切换
 * 
 * Core Problems Solved:
 * 1. Unified management and switching of multiple layout components
 * 2. User-friendly interface for complex configuration parameters
 * 3. Responsive experience for real-time preview and configuration adjustment
 * 4. Consistent user experience across different layout modes
 * 5. Flexible management and switching of demo data
 * 
 * 使用的设计模式：
 * 1. Facade Pattern - 为复杂的布局系统提供简化接口
 * 2. State Pattern - 管理不同布局模式的状态转换
 * 3. Observer Pattern - 监听配置变化并更新预览
 * 4. Command Pattern - 封装布局配置操作
 * 
 * Design Patterns Used:
 * 1. Facade Pattern - Providing simplified interface for complex layout system
 * 2. State Pattern - Managing state transitions of different layout modes
 * 3. Observer Pattern - Monitoring configuration changes and updating preview
 * 4. Command Pattern - Encapsulating layout configuration operations
 * 
 * SOLID原则应用：
 * - SRP: 页面专注于演示和用户交互
 * - OCP: 可扩展支持新的布局类型
 * - LSP: 布局组件可以互相替换
 * - ISP: 接口按功能模块分离
 * - DIP: 依赖抽象的布局组件接口
 * 
 * SOLID Principles Applied:
 * - SRP: Page focuses on demonstration and user interaction
 * - OCP: Extensible to support new layout types
 * - LSP: Layout components are interchangeable
 * - ISP: Interfaces separated by functional modules
 * - DIP: Depending on abstract layout component interfaces
 * 
 * 关键技术点和易错点：
 * 1. TCA状态管理要正确处理异步更新
 * 2. 布局切换时要保持配置的一致性
 * 3. 配置面板的响应式更新要避免性能问题
 * 4. 不同布局组件的参数映射要准确
 * 5. 用户交互的反馈要及时和明确
 * 
 * Key Technical Points and Pitfalls:
 * 1. TCA state management must correctly handle asynchronous updates
 * 2. Configuration consistency must be maintained when switching layouts
 * 3. Responsive updates of configuration panel must avoid performance issues
 * 4. Parameter mapping for different layout components must be accurate
 * 5. User interaction feedback must be timely and clear
 * 
 * 使用示例：
 * ```swift
 * // 集成到应用中 / Integration into application
 * NavigationView {
 *     TextLayoutDemoView(
 *         store: Store(
 *             initialState: TextLayoutFeature.State(),
 *             reducer: TextLayoutFeature()
 *         )
 *     )
 * }
 * 
 * // 自定义初始状态 / Custom initial state
 * TextLayoutDemoView(
 *     store: Store(
 *         initialState: TextLayoutFeature.State(
 *             texts: customTexts,
 *             layoutType: .horizontalFlow,
 *             layoutConfig: customConfig
 *         ),
 *         reducer: TextLayoutFeature()
 *     )
 * )
 * ```
 */

import SwiftUI
import ComposableArchitecture

// MARK: - Text Layout Demo View Implementation / 文字布局演示视图实现

/**
 * 文字布局演示主页面
 * Main text layout demonstration page
 * 
 * 提供完整的布局框架演示和配置界面
 * Provides complete layout framework demonstration and configuration interface
 */
struct TextLayoutDemoView: View {
    let store: StoreOf<TextLayoutFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 0) {
                    // 紧凑顶部控制栏 / Compact top control bar
                    compactTopControlBar(viewStore: viewStore)
                    
                    // 主要内容区域（扩大填充空间）/ Main content area (expanded to fill space)
                    GeometryReader { geometry in
                        mainContentArea(viewStore: viewStore)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    
                    // 底部固定配置面板 / Bottom fixed configuration panel
                    compactConfigurationPanel(viewStore: viewStore)
                }
                .navigationTitle("布局Demo")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(false)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("v1.0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // MARK: - Top Control Bar / 顶部控制栏
    
    /**
     * 紧凑顶部控制栏组件
     * Compact top control bar component
     * 
     * 使用最小高度，横向滚动节省空间
     * Uses minimal height with horizontal scrolling to save space
     */
    private func compactTopControlBar(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(spacing: 0) {
            // 单行紧凑控制 / Single row compact controls - 进一步缩短高度 / Further reduce height
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {  // 减少间距 / Reduce spacing
                    // 布局类型选择 / Layout type selection
                    compactLayoutTypeSelector(viewStore: viewStore)
                    
                    // 分隔线 / Separator - 缩短高度 / Reduce height
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 20)  // 缩短分隔线高度 / Reduce separator height
                    
                    // 演示数据切换 / Demo data switching
                    compactDemoDataControls(viewStore: viewStore)
                }
                .padding(.horizontal, 8)  // 减少水平边距 / Reduce horizontal padding
            }
            .frame(height: 28) // 缩短固定高度 / Reduce fixed height
            
            // 细分割线 / Thin divider
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    /**
     * 紧凑布局类型选择器
     * Compact layout type selector
     */
    private func compactLayoutTypeSelector(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        HStack(spacing: 6) {
            Text("布局")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            ForEach(LayoutType.allCases.prefix(4), id: \.self) { layoutType in
                Button(action: {
                    viewStore.send(.changeLayoutType(layoutType))
                }) {
                    Image(systemName: layoutType.systemImage)
                        .font(.system(size: 12))
                        .foregroundColor(viewStore.layoutType == layoutType ? .white : .primary)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(viewStore.layoutType == layoutType ? Color.blue : Color.gray.opacity(0.15))
                        )
                }
            }
        }
    }
    
    /**
     * 布局类型按钮
     * Layout type button
     */
    private func layoutTypeButton(layoutType: LayoutType, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: layoutType.systemImage)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(layoutType.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /**
     * 紧凑演示数据控制
     * Compact demo data controls
     */
    private func compactDemoDataControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        HStack(spacing: 6) {
            Text("数据")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            // 模式切换按钮 / Mode toggle button
            Button(viewStore.isDemoMode ? "演示" : "自定义") {
                viewStore.send(.toggleDemoMode)
            }
            .font(.system(size: 11))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
            )
            .foregroundColor(.blue)
            
            if viewStore.isDemoMode {
                // 紧凑预设数据选择 / Compact preset data selection
                ForEach(TextSampleType.allCases.prefix(3), id: \.self) { sampleType in
                    Button(sampleType.displayName.components(separatedBy: " / ").first?.prefix(2).description ?? "") {
                        viewStore.send(.loadSampleTexts(sampleType))
                    }
                    .font(.system(size: 11))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    // MARK: - Main Content Area / 主要内容区域
    
    /**
     * 主要内容区域（扩大版）
     * Main content area (expanded version)
     * 
     * 最大化显示区域，充分利用可用空间
     * Maximize display area, fully utilize available space
     */
    private func mainContentArea(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(spacing: 4) {
            // 最紧凑统计信息 / Ultra-compact statistics information
            ultraCompactStatisticsSection(viewStore: viewStore)
            
            // 扩大布局预览区域（占据剩余空间）/ Expanded layout preview area (takes remaining space)
            expandedLayoutPreviewArea(viewStore: viewStore)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(.systemGroupedBackground))
    }
    
    /**
     * 扩大布局预览区域
     * Expanded layout preview area
     */
    private func expandedLayoutPreviewArea(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("预览")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(viewStore.displayTexts.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // 扩大的布局显示区域 / Expanded layout display area
            Group {
                switch viewStore.layoutType {
                case .horizontalFlow:
                    ScrollView {
                        FlowLayoutView(
                            texts: viewStore.displayTexts,
                            config: viewStore.layoutConfig,
                            selectedIndex: viewStore.binding(
                                get: \.selectedTextIndex,
                                send: TextLayoutFeature.Action.selectText
                            ),
                            onTextTapped: { text, index in
                                viewStore.send(.textTapped(text, index))
                            }
                        )
                    }
                    
                case .verticalFlow:
                    VerticalFlowLayoutView(
                        texts: viewStore.displayTexts,
                        config: viewStore.layoutConfig,
                        selectedIndex: viewStore.binding(
                            get: \.selectedTextIndex,
                            send: TextLayoutFeature.Action.selectText
                        ),
                        onTextTapped: { text, index in
                            viewStore.send(.textTapped(text, index))
                        }
                    )
                    
                case .grid:
                    ScrollView {
                        GridLayoutView(
                            texts: viewStore.displayTexts,
                            config: viewStore.layoutConfig,
                            gridType: .adaptive(minItemWidth: 100),
                            selectedIndex: viewStore.binding(
                                get: \.selectedTextIndex,
                                send: TextLayoutFeature.Action.selectText
                            ),
                            onTextTapped: { text, index in
                                viewStore.send(.textTapped(text, index))
                            }
                        )
                    }
                    
                case .list:
                    ScrollView {
                        VStack(spacing: viewStore.layoutConfig.lineSpacing) {
                            ForEach(Array(viewStore.displayTexts.enumerated()), id: \.offset) { index, text in
                                HStack {
                                    Text(text)
                                        .font(viewStore.layoutConfig.itemStyle.font)
                                        .foregroundColor(viewStore.selectedTextIndex == index ? .white : viewStore.layoutConfig.itemStyle.foregroundColor)
                                        .padding(EdgeInsets(
                                            top: viewStore.layoutConfig.itemStyle.padding.top,
                                            leading: viewStore.layoutConfig.itemStyle.padding.leading,
                                            bottom: viewStore.layoutConfig.itemStyle.padding.bottom,
                                            trailing: viewStore.layoutConfig.itemStyle.padding.trailing
                                        ))
                                        .applyItemSizeConstraints(style: viewStore.layoutConfig.itemStyle)
                                        .background(
                                            RoundedRectangle(cornerRadius: viewStore.layoutConfig.itemStyle.cornerRadius)
                                                .fill(viewStore.selectedTextIndex == index ? Color.blue : viewStore.layoutConfig.itemStyle.backgroundColor)
                                        )
                                        .onTapGesture {
                                            viewStore.send(.textTapped(text, index))
                                        }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                case .waterfall:
                    Text("瀑布流布局 / Waterfall Layout")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 充分利用可用空间 / Fully utilize available space
            .padding(6)
            .background(Color(.systemBackground))
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
        }
    }
    
    /**
     * 超紧凑统计信息区域
     * Ultra-compact statistics information area
     */
    private func ultraCompactStatisticsSection(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        HStack(spacing: 8) {
            ultraCompactStatisticCard(title: "项", value: "\(viewStore.displayTexts.count)")
            ultraCompactStatisticCard(title: "布局", value: viewStore.layoutType.displayName.components(separatedBy: " / ").first?.prefix(2).description ?? "")
            ultraCompactStatisticCard(title: "选中", value: viewStore.selectedTextIndex != nil ? "\(viewStore.selectedTextIndex! + 1)" : "-")
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
    }
    
    /**
     * 超紧凑统计卡片
     * Ultra-compact statistics card
     */
    private func ultraCompactStatisticCard(title: String, value: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(4)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Configuration Panel / 配置面板
    
    /**
     * 配置面板
     * Configuration panel
     */
    private func configurationPanel(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("布局配置 / Layout Configuration")
                    .font(.headline)
                
                Spacer()
                
                Button("重置 / Reset") {
                    viewStore.send(.resetToDefault)
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            // 间距配置 / Spacing configuration
            spacingConfiguration(viewStore: viewStore)
            
            // 对齐配置 / Alignment configuration
            alignmentConfiguration(viewStore: viewStore)
            
            // 预设配置 / Preset configuration
            presetConfiguration(viewStore: viewStore)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
    }
    
    /**
     * 间距配置区域
     * Spacing configuration area
     */
    private func spacingConfiguration(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("间距设置 / Spacing Settings")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("元素间距 / Item Spacing")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int(viewStore.layoutConfig.itemSpacing))pt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: viewStore.binding(
                        get: { $0.layoutConfig.itemSpacing },
                        send: { .updateItemSpacing($0) }
                    ),
                    in: 0...24,
                    step: 1
                ) {
                    Text("Item Spacing")
                }
                .accentColor(.blue)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("行间距 / Line Spacing")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int(viewStore.layoutConfig.lineSpacing))pt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: viewStore.binding(
                        get: { $0.layoutConfig.lineSpacing },
                        send: { .updateLineSpacing($0) }
                    ),
                    in: 0...24,
                    step: 1
                ) {
                    Text("Line Spacing")
                }
                .accentColor(.blue)
            }
        }
    }
    
    /**
     * 对齐配置区域
     * Alignment configuration area
     */
    private func alignmentConfiguration(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("对齐方式 / Alignment")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(spacing: 8) {
                ForEach(LayoutAlignment.allCases, id: \.self) { alignment in
                    Button(alignment.displayName.components(separatedBy: " / ").first ?? "") {
                        viewStore.send(.updateAlignment(alignment))
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewStore.layoutConfig.alignment == alignment ? Color.blue : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(viewStore.layoutConfig.alignment == alignment ? .white : .primary)
                }
            }
        }
    }
    
    /**
     * 预设配置区域
     * Preset configuration area
     */
    private func presetConfiguration(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("预设配置 / Preset Configurations")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(viewStore.presetConfigs.enumerated()), id: \.offset) { index, preset in
                        Button(preset.name.components(separatedBy: " / ").first ?? "") {
                            viewStore.send(.selectPreset(index))
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewStore.currentPresetIndex == index ? Color.blue : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(viewStore.currentPresetIndex == index ? .white : .primary)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Helper Views / 辅助视图
    
    /**
     * 配置按钮
     * Configuration button
     */
    private func configButton(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
        Button {
            viewStore.send(.toggleConfigPanel)
        } label: {
            Image(systemName: viewStore.isShowingConfigPanel ? "gearshape.fill" : "gearshape")
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Supporting Extensions / 支持扩展

extension View {
    /**
     * 自定义圆角修饰符
     * Custom corner radius modifier
     */
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Compact Configuration Panel / 紧凑配置面板

/**
 * 底部紧凑配置面板
 * Bottom compact configuration panel
 * 
 * 设计为高度较小的可滚动区域，固定在页面底部
 * Designed as a small-height scrollable area, fixed at the bottom of the page
 */
private func compactConfigurationPanel(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(spacing: 0) {
        // 分隔线 / Separator line
        Divider()
        
        // 紧凑配置内容 / Compact configuration content
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                // 布局类型选择 / Layout type selection
                layoutTypeCompactSelector(viewStore: viewStore)
                
                // 垂直分隔 / Vertical separator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // 间距配置 / Spacing configuration
                spacingCompactControls(viewStore: viewStore)
                
                // 垂直分隔 / Vertical separator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // 容器内边距配置 / Container padding configuration
                paddingCompactControls(viewStore: viewStore)
                
                // 垂直分隔 / Vertical separator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // Item内边距配置 / Item padding configuration
                itemPaddingCompactControls(viewStore: viewStore)
                
                // 垂直分隔 / Vertical separator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // 对齐方式配置 / Alignment configuration
                alignmentCompactControls(viewStore: viewStore)
                
                // 垂直分隔 / Vertical separator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // Item尺寸控制 / Item size controls
                itemSizeCompactControls(viewStore: viewStore)
                
                // 垂直分隔 / Vertical separator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // 文字截断控制 / Text truncation controls
                textTruncationCompactControls(viewStore: viewStore)
            }
            .padding(.horizontal, 12)  // 减少水平边距 / Reduce horizontal padding
            .padding(.vertical, 6)    // 减少垂直边距 / Reduce vertical padding
        }
        .frame(height: 40) // 进一步最小化高度 / Further minimize height
        .background(Color(.systemBackground))
    }
}

/**
 * 紧凑布局类型选择器
 * Compact layout type selector
 */
private func layoutTypeCompactSelector(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("布局")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        HStack(spacing: 2) {
            ForEach(LayoutType.allCases.prefix(4), id: \.self) { layoutType in
                Button(action: {
                    viewStore.send(.changeLayoutType(layoutType))
                }) {
                    Image(systemName: layoutType.systemImage)
                        .font(.system(size: 10))
                        .foregroundColor(viewStore.layoutType == layoutType ? .white : .primary)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle()
                                .fill(viewStore.layoutType == layoutType ? Color.blue : Color.gray.opacity(0.2))
                        )
                }
            }
        }
    }
    .frame(width: 50)
}

/**
 * 紧凑间距控制
 * Compact spacing controls
 */
private func spacingCompactControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("间距")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        HStack(spacing: 4) {
            VStack(spacing: 0) {
                Text("元")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                Slider(
                    value: viewStore.binding(
                        get: { $0.layoutConfig.itemSpacing },
                        send: { .updateItemSpacing($0) }
                    ),
                    in: 0...24,
                    step: 1
                )
                .frame(width: 30, height: 20)
                Text("\(Int(viewStore.layoutConfig.itemSpacing))")
                    .font(.system(size: 8))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 0) {
                Text("行")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                Slider(
                    value: viewStore.binding(
                        get: { $0.layoutConfig.lineSpacing },
                        send: { .updateLineSpacing($0) }
                    ),
                    in: 0...24,
                    step: 1
                )
                .frame(width: 30, height: 20)
                Text("\(Int(viewStore.layoutConfig.lineSpacing))")
                    .font(.system(size: 8))
                    .foregroundColor(.primary)
            }
        }
    }
    .frame(width: 70)
}

/**
 * 紧凑容器内边距控制
 * Compact container padding controls
 */
private func paddingCompactControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("容器边距")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        VStack(spacing: 0) {
            Text("区")
                .font(.system(size: 8))
                .foregroundColor(.secondary)
            Slider(
                value: viewStore.binding(
                    get: { $0.layoutConfig.padding.top },
                    send: { .updateContainerPadding($0) }
                ),
                in: 0...40,
                step: 2
            )
            .frame(width: 40, height: 20)
            Text("\(Int(viewStore.layoutConfig.padding.top))")
                .font(.system(size: 8))
                .foregroundColor(.primary)
        }
    }
    .frame(width: 60)
}

/**
 * 紧凑Item内边距控制
 * Compact item padding controls
 */
private func itemPaddingCompactControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("Item边距")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        VStack(spacing: 0) {
            Text("项")
                .font(.system(size: 8))
                .foregroundColor(.secondary)
            Slider(
                value: viewStore.binding(
                    get: { $0.layoutConfig.itemStyle.padding.top },
                    send: { .updateItemPadding($0) }
                ),
                in: 0...20,
                step: 1
            )
            .frame(width: 40, height: 20)
            Text("\(Int(viewStore.layoutConfig.itemStyle.padding.top))")
                .font(.system(size: 8))
                .foregroundColor(.primary)
        }
    }
    .frame(width: 55)
}

/**
 * 紧凑对齐控制
 * Compact alignment controls
 */
private func alignmentCompactControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("对齐")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        HStack(spacing: 1) {
            ForEach(LayoutAlignment.allCases.prefix(3), id: \.self) { alignment in
                Button(action: {
                    viewStore.send(.updateAlignment(alignment))
                }) {
                    Image(systemName: alignment.iconName)
                        .font(.system(size: 8))
                        .foregroundColor(viewStore.layoutConfig.alignment == alignment ? .white : .primary)
                        .frame(width: 14, height: 14)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(viewStore.layoutConfig.alignment == alignment ? Color.blue : Color.gray.opacity(0.2))
                        )
                }
            }
        }
    }
    .frame(width: 50)
}

/**
 * 紧凑Item尺寸控制
 * Compact item size controls
 */
private func itemSizeCompactControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("尺寸")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        HStack(spacing: 3) {
            VStack(spacing: 0) {
                Text("宽")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                Slider(
                    value: viewStore.binding(
                        get: { $0.layoutConfig.itemStyle.maxWidth ?? 100 },
                        send: { .updateItemMaxWidth($0 > 0 ? $0 : nil) }
                    ),
                    in: 0...200,
                    step: 10
                )
                .frame(width: 28, height: 20)
                Text("\(Int(viewStore.layoutConfig.itemStyle.maxWidth ?? 0))")
                    .font(.system(size: 8))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 0) {
                Text("高")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                Slider(
                    value: viewStore.binding(
                        get: { $0.layoutConfig.itemStyle.maxHeight ?? 40 },
                        send: { .updateItemMaxHeight($0 > 0 ? $0 : nil) }
                    ),
                    in: 0...100,
                    step: 5
                )
                .frame(width: 28, height: 20)
                Text("\(Int(viewStore.layoutConfig.itemStyle.maxHeight ?? 0))")
                    .font(.system(size: 8))
                    .foregroundColor(.primary)
            }
        }
    }
    .frame(width: 65)
}

/**
 * 紧凑文字截断控制
 * Compact text truncation controls
 */
private func textTruncationCompactControls(viewStore: ViewStoreOf<TextLayoutFeature>) -> some View {
    VStack(alignment: .leading, spacing: 1) {
        Text("截断")
            .font(.system(size: 9))
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        
        VStack(spacing: 1) {
            HStack(spacing: 1) {
                Button("1") {
                    viewStore.send(.updateLineLimit(1))
                }
                .font(.system(size: 8))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(viewStore.layoutConfig.itemStyle.lineLimit == 1 ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(viewStore.layoutConfig.itemStyle.lineLimit == 1 ? .white : .primary)
                .frame(width: 14, height: 14)
                
                Button("2") {
                    viewStore.send(.updateLineLimit(2))
                }
                .font(.system(size: 8))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(viewStore.layoutConfig.itemStyle.lineLimit == 2 ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(viewStore.layoutConfig.itemStyle.lineLimit == 2 ? .white : .primary)
                .frame(width: 14, height: 14)
                
                Button("∞") {
                    viewStore.send(.updateLineLimit(nil))
                }
                .font(.system(size: 8))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(viewStore.layoutConfig.itemStyle.lineLimit == nil ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(viewStore.layoutConfig.itemStyle.lineLimit == nil ? .white : .primary)
                .frame(width: 14, height: 14)
            }
            
            HStack(spacing: 1) {
                Button("...") {
                    viewStore.send(.updateTruncationMode(.tail))
                }
                .font(.system(size: 7))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(viewStore.layoutConfig.itemStyle.truncationMode == .tail ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(viewStore.layoutConfig.itemStyle.truncationMode == .tail ? .white : .primary)
                .frame(width: 20, height: 12)
                
                Button("•••") {
                    viewStore.send(.updateTruncationMode(.middle))
                }
                .font(.system(size: 7))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(viewStore.layoutConfig.itemStyle.truncationMode == .middle ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(viewStore.layoutConfig.itemStyle.truncationMode == .middle ? .white : .primary)
                .frame(width: 20, height: 12)
            }
        }
    }
    .frame(width: 50)
}

// MARK: - Constrained Text View / 约束文字视图

/**
 * 支持尺寸约束和文字截断的文字组件
 * Text component with size constraints and text truncation support
 */
struct ConstrainedTextView: View {
    let text: String
    let style: ItemStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(style.font)
                .foregroundColor(isSelected ? .white : style.foregroundColor)
                .lineLimit(style.lineLimit)
                .truncationMode(style.truncationMode)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(
                    top: style.padding.top,
                    leading: style.padding.leading,
                    bottom: style.padding.bottom,
                    trailing: style.padding.trailing
                ))
                .applyItemSizeConstraints(style: style)
                .background(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .fill(isSelected ? Color.blue : style.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: style.cornerRadius)
                                .stroke(style.borderColor, lineWidth: style.borderWidth)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/**
 * 应用item尺寸约束的修饰符
 * View modifier for applying item size constraints
 */
extension View {
    func applyItemSizeConstraints(style: ItemStyle) -> some View {
        self.modifier(ItemSizeConstraintModifier(style: style))
    }
}

/**
 * Item尺寸约束修饰符
 * Item size constraint modifier
 */
struct ItemSizeConstraintModifier: ViewModifier {
    let style: ItemStyle
    
    func body(content: Content) -> some View {
        // 应用尺寸约束的优先级顺序 / Priority order for applying size constraints:
        // 1. 固定尺寸 > 2. 最大/最小尺寸 > 3. 默认自适应
        // 1. Fixed size > 2. Max/Min size > 3. Default adaptive
        
        Group {
            if let fixedWidth = style.fixedWidth, let fixedHeight = style.fixedHeight {
                // 固定宽度和高度 / Fixed width and height
                content
                    .frame(width: fixedWidth, height: fixedHeight)
                    .clipped()
                    
            } else if let fixedWidth = style.fixedWidth {
                // 仅固定宽度 / Fixed width only
                content
                    .frame(width: fixedWidth)
                    .if(style.maxHeight != nil) { view in
                        view.frame(maxHeight: style.maxHeight!)
                    }
                    .if(style.minHeight != nil) { view in
                        view.frame(minHeight: style.minHeight!)
                    }
                    .clipped()
                    
            } else if let fixedHeight = style.fixedHeight {
                // 仅固定高度 / Fixed height only
                content
                    .frame(height: fixedHeight)
                    .if(style.maxWidth != nil) { view in
                        view.frame(maxWidth: style.maxWidth!)
                    }
                    .if(style.minWidth != nil) { view in
                        view.frame(minWidth: style.minWidth!)
                    }
                    .clipped()
                    
            } else {
                // 使用最大/最小尺寸约束 / Use max/min size constraints
                content
                    .if(style.maxWidth != nil) { view in
                        view.frame(maxWidth: style.maxWidth!)
                    }
                    .if(style.maxHeight != nil) { view in
                        view.frame(maxHeight: style.maxHeight!)
                    }
                    .if(style.minWidth != nil) { view in
                        view.frame(minWidth: style.minWidth!)
                    }
                    .if(style.minHeight != nil) { view in
                        view.frame(minHeight: style.minHeight!)
                    }
                    .clipped()
            }
        }
    }
}

// Note: Conditional modifier extension is defined in ReusableUIComponents.swift
// 注意：条件修饰符扩展定义在 ReusableUIComponents.swift 中

// MARK: - Preview / 预览

struct TextLayoutDemoView_Previews: PreviewProvider {
    static var previews: some View {
        TextLayoutDemoView(
            store: Store(
                initialState: TextLayoutFeature.State()
            ) {
                TextLayoutFeature()
            }
        )
    }
}