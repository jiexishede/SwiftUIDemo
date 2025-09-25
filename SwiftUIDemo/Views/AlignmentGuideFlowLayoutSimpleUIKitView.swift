/**
 * AlignmentGuideFlowLayoutSimpleUIKitView.swift
 * 使用 UIKit 实现的极简流式布局视图
 * 
 * Minimal Flow Layout View Implemented with UIKit
 * 
 * 设计思路：
 * 这个文件展示了如何使用 UIKit 的 UICollectionView 实现流式布局，然后通过 UIViewRepresentable
 * 包装成 SwiftUI 可以使用的组件。相比纯 SwiftUI 实现，UIKit 方案在布局计算上更加稳定可靠。
 * 
 * Design Philosophy:
 * This file demonstrates how to implement flow layout using UIKit's UICollectionView, then wrap it
 * into a SwiftUI-usable component through UIViewRepresentable. Compared to pure SwiftUI implementation,
 * the UIKit approach is more stable and reliable in layout calculations.
 * 
 * 核心技术：
 * - UICollectionViewFlowLayout：UIKit 的流式布局引擎
 * - UIViewRepresentable：SwiftUI 与 UIKit 的桥接协议
 * - Coordinator Pattern：处理 UIKit 代理回调
 * - Dynamic Type：支持动态字体大小
 * 
 * Core Technologies:
 * - UICollectionViewFlowLayout: UIKit's flow layout engine
 * - UIViewRepresentable: Bridge protocol between SwiftUI and UIKit
 * - Coordinator Pattern: Handle UIKit delegate callbacks
 * - Dynamic Type: Support dynamic font sizing
 * 
 * 为什么使用 UIKit：
 * 1. 更稳定的布局算法
 * 2. 更好的性能，特别是大量数据时
 * 3. 更成熟的 API，经过多年优化
 * 4. 避免 SwiftUI alignmentGuide 的限制
 * 
 * Why Use UIKit:
 * 1. More stable layout algorithm
 * 2. Better performance, especially with large datasets
 * 3. More mature API, optimized over years
 * 4. Avoid SwiftUI alignmentGuide limitations
 */

import SwiftUI
import UIKit

// MARK: - 🎯 SwiftUI 包装视图 / SwiftUI Wrapper View

/**
 * 极简流式布局 UIKit 实现版本
 * Minimal flow layout UIKit implementation version
 * 
 * 功能完全对标 AlignmentGuideFlowLayoutSimpleView，但使用 UIKit 实现核心布局逻辑
 * Functionality fully matches AlignmentGuideFlowLayoutSimpleView, but uses UIKit for core layout logic
 */
struct AlignmentGuideFlowLayoutSimpleUIKitView: View {
    
    // MARK: - 📝 状态属性 / State Properties
    
    /// 文字数组 - 演示用的文字内容 / Text array - Demo text content
    @State private var texts: [String] = [
        "SwiftUI", "iOS", "TCA", "自适应", "流式布局",
        "极简", "演示", "UIKit", "这是一个比较长的文字标签用于测试截断效果", "标签"
    ]
    
    /// 🔧 容器内边距配置 / Container padding configuration
    @State private var containerPadding: CGFloat = 16
    
    /// 📏 item 最大宽度限制 / Item max width constraint
    @State private var enableMaxWidth: Bool = false
    @State private var maxWidthValue: CGFloat = 100
    
    /// 📐 间距配置 / Spacing configuration
    @State private var itemSpacing: CGFloat = 8      // item 之间的水平间距 / Horizontal spacing between items
    @State private var lineSpacing: CGFloat = 8      // 行之间的垂直间距 / Vertical spacing between lines
    
    // MARK: - 🎨 视图主体 / View Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 🎛️ 控制栏 / Control bar
                controlBar
                
                // 🔧 基础配置面板 / Basic configuration panel
                configPanel
                    .padding(.horizontal)
                
                // 📦 UIKit 流式布局展示区域 / UIKit flow layout display area
                ScrollView {
                    UIKitFlowLayout(
                        texts: texts,
                        containerPadding: containerPadding,
                        itemMaxWidth: enableMaxWidth ? maxWidthValue : nil,
                        itemSpacing: itemSpacing,
                        lineSpacing: lineSpacing
                    )
                    .frame(minHeight: 200)
                }
                .background(Color(.systemGroupedBackground))
                
                Spacer()
            }
            .navigationTitle("UIKit 流式布局")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 🎛️ 控制栏 / Control Bar
    
    private var controlBar: some View {
        HStack {
            // ➕ 添加按钮 - 添加随机长度的文字 / Add button - Add random length text
            Button("添加") {
                addRandomText()
            }
            .foregroundColor(.green)
            
            Spacer()
            
            // 🗑️ 清除按钮 - 清空所有文字 / Clear button - Clear all text
            Button("清除") {
                texts.removeAll()
            }
            .foregroundColor(.red)
        }
        .padding(.horizontal)
    }
    
    // MARK: - ⚙️ 配置面板 / Configuration Panel
    
    private var configPanel: some View {
        VStack(spacing: 12) {
            // 📏 容器内边距调整 / Container padding adjustment
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("容器内边距")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(containerPadding))pt")
                        .font(.caption.monospaced())
                        .foregroundColor(.blue)
                }
                
                Slider(value: $containerPadding, in: 0...40, step: 1)
                    .accentColor(.blue)
            }
            
            Divider()
            
            // 🔄 间距调整 / Spacing adjustment
            VStack(alignment: .leading, spacing: 8) {
                // 水平间距 / Horizontal spacing
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("水平间距")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(itemSpacing))pt")
                            .font(.caption.monospaced())
                            .foregroundColor(.green)
                    }
                    
                    Slider(value: $itemSpacing, in: 0...20, step: 1)
                        .accentColor(.green)
                }
                
                // 垂直间距 / Vertical spacing
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("垂直间距")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(lineSpacing))pt")
                            .font(.caption.monospaced())
                            .foregroundColor(.purple)
                    }
                    
                    Slider(value: $lineSpacing, in: 0...20, step: 1)
                        .accentColor(.purple)
                }
            }
            
            Divider()
            
            // 📐 最大宽度限制 / Max width constraint
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Toggle("限制最大宽度", isOn: $enableMaxWidth)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if enableMaxWidth {
                        Text("\(Int(maxWidthValue))pt")
                            .font(.caption.monospaced())
                            .foregroundColor(.orange)
                    }
                }
                
                if enableMaxWidth {
                    Slider(value: $maxWidthValue, in: 50...200, step: 10)
                        .accentColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - 🔧 辅助方法 / Helper Methods
    
    /// 添加随机文字 / Add random text
    private func addRandomText() {
        // 📏 生成随机长度 / Generate random length
        let randomType = Int.random(in: 0...2)
        let randomText: String
        
        switch randomType {
        case 0:  // 短文字 / Short text
            let length = Int.random(in: 1...3)
            let characters = "SwiftUI开发iOS"
            randomText = String((0..<length).compactMap { _ in
                characters.randomElement()
            })
            
        case 1:  // 中等文字 / Medium text
            let words = ["SwiftUI", "iOS开发", "TCA架构", "流式布局", "响应式", "组件化", "UIKit"]
            randomText = words.randomElement() ?? "默认"
            
        default:  // 长文字 / Long text
            let longTexts = [
                "这是一个很长的文字标签用于测试截断",
                "UIKit CollectionView Flow Layout",
                "测试超长文字的显示效果和省略号",
                "The Composable Architecture Pattern"
            ]
            randomText = longTexts.randomElement() ?? "长文字"
        }
        
        texts.append(randomText)
    }
}

// MARK: - 🏗️ UIKit 流式布局组件 / UIKit Flow Layout Component

/**
 * UIKit 实现的流式布局
 * Flow layout implemented with UIKit
 * 
 * 使用 UICollectionView 和 UICollectionViewFlowLayout 实现稳定的流式布局
 * Uses UICollectionView and UICollectionViewFlowLayout for stable flow layout
 */
struct UIKitFlowLayout: UIViewRepresentable {
    
    // MARK: - 📥 输入参数 / Input Parameters
    
    let texts: [String]
    let containerPadding: CGFloat
    let itemMaxWidth: CGFloat?
    let itemSpacing: CGFloat
    let lineSpacing: CGFloat
    
    // MARK: - UIViewRepresentable 实现 / UIViewRepresentable Implementation
    
    func makeUIView(context: Context) -> UICollectionView {
        // 🎯 创建流式布局 / Create flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = lineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: containerPadding,
            left: containerPadding,
            bottom: containerPadding,
            right: containerPadding
        )
        
        // 📦 创建 CollectionView / Create CollectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        collectionView.isScrollEnabled = false  // 禁用滚动，让外部 ScrollView 处理
        
        // 📝 注册 Cell / Register Cell
        collectionView.register(
            TextCollectionViewCell.self,
            forCellWithReuseIdentifier: "TextCell"
        )
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        // 🔄 更新布局参数 / Update layout parameters
        if let layout = uiView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = itemSpacing
            layout.minimumLineSpacing = lineSpacing
            layout.sectionInset = UIEdgeInsets(
                top: containerPadding,
                left: containerPadding,
                bottom: containerPadding,
                right: containerPadding
            )
        }
        
        // 🔄 更新数据 / Update data
        context.coordinator.texts = texts
        context.coordinator.itemMaxWidth = itemMaxWidth
        uiView.reloadData()
        
        // 📏 更新高度约束 / Update height constraint
        DispatchQueue.main.async {
            let height = uiView.collectionViewLayout.collectionViewContentSize.height
            context.coordinator.updateHeight(height)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            texts: texts,
            itemMaxWidth: itemMaxWidth,
            onHeightChange: { _ in }
        )
    }
    
    // MARK: - 🎯 协调器 / Coordinator
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var texts: [String]
        var itemMaxWidth: CGFloat?
        let onHeightChange: (CGFloat) -> Void
        
        init(texts: [String], itemMaxWidth: CGFloat?, onHeightChange: @escaping (CGFloat) -> Void) {
            self.texts = texts
            self.itemMaxWidth = itemMaxWidth
            self.onHeightChange = onHeightChange
        }
        
        func updateHeight(_ height: CGFloat) {
            onHeightChange(height)
        }
        
        // MARK: - UICollectionViewDataSource
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return texts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TextCell",
                for: indexPath
            ) as! TextCollectionViewCell
            
            cell.configure(
                text: texts[indexPath.item],
                maxWidth: itemMaxWidth
            )
            
            return cell
        }
        
        // MARK: - UICollectionViewDelegateFlowLayout
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // 📐 计算文字大小 / Calculate text size
            let text = texts[indexPath.item]
            let font = UIFont.preferredFont(forTextStyle: .caption1)
            let padding: CGFloat = 16  // 水平内边距
            let verticalPadding: CGFloat = 10  // 垂直内边距
            
            // 📏 计算文字尺寸 / Calculate text dimensions
            let maxWidth = itemMaxWidth.map { $0 - padding } ?? .greatestFiniteMagnitude
            let textSize = (text as NSString).boundingRect(
                with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            ).size
            
            // 🔧 加上内边距 / Add padding
            let width = min(textSize.width + padding, itemMaxWidth ?? .greatestFiniteMagnitude)
            let height = textSize.height + verticalPadding
            
            return CGSize(width: ceil(width), height: ceil(height))
        }
    }
}

// MARK: - 📱 UICollectionViewCell 定义 / UICollectionViewCell Definition

/**
 * 文字标签 Cell
 * Text label cell
 */
class TextCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI 组件 / UI Components
    
    private let label = UILabel()
    
    // MARK: - 初始化 / Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置 / UI Setup
    
    private func setupUI() {
        // 🎨 设置背景 / Setup background
        contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        
        // 📝 设置标签 / Setup label
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(label)
        
        // 📐 设置约束 / Setup constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    // MARK: - 配置方法 / Configuration Method
    
    func configure(text: String, maxWidth: CGFloat?) {
        label.text = text
        
        // 🔧 处理宽度限制 / Handle width constraint
        if let maxWidth = maxWidth {
            label.preferredMaxLayoutWidth = maxWidth - 16  // 减去内边距
        }
    }
}

// MARK: - 预览 / Preview

struct AlignmentGuideFlowLayoutSimpleUIKitView_Previews: PreviewProvider {
    static var previews: some View {
        AlignmentGuideFlowLayoutSimpleUIKitView()
    }
}