import SwiftUI
import UIKit

/**
 * UIKIT BRIDGED SCROLL VIEW - UIKit 桥接滚动视图
 * 
 * PURPOSE / 目的:
 * - Ultimate solution for nested scrolling in iOS 15+
 * - iOS 15+ 中嵌套滚动的终极解决方案
 * 
 * WHY THIS APPROACH / 为什么使用这种方法:
 * - UIScrollView provides fine-grained control over gesture recognition
 * - UIScrollView 提供对手势识别的精细控制
 * - Can properly handle simultaneous gestures
 * - 可以正确处理同时手势
 * - Works reliably on iOS 15.0+
 * - 在 iOS 15.0+ 上可靠工作
 */

// MARK: - UIKit Horizontal ScrollView / UIKit 横向滚动视图
struct UIKitHorizontalScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var isScrolling: Bool
    
    init(isScrolling: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isScrolling = isScrolling
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = context.coordinator
        
        // Allow both horizontal and vertical pan gestures
        // 允许水平和垂直平移手势
        scrollView.panGestureRecognizer.delegate = context.coordinator
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        
        // Host SwiftUI content / 托管 SwiftUI 内容
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        
        scrollView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        context.coordinator.hostingController = hostingController
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var parent: UIKitHorizontalScrollView
        var hostingController: UIHostingController<Content>?
        
        init(_ parent: UIKitHorizontalScrollView) {
            self.parent = parent
        }
        
        // Allow simultaneous recognition with parent scroll view
        // 允许与父滚动视图同时识别
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                              shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Check if it's a vertical scroll gesture
            // 检查是否是垂直滚动手势
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: panGesture.view)
                let translation = panGesture.translation(in: panGesture.view)
                
                // If strongly vertical, allow parent to handle
                // 如果明显是垂直的，允许父视图处理
                if abs(velocity.y) > abs(velocity.x) * 2 && abs(translation.y) > 20 {
                    return true
                }
                
                // If at scroll bounds and trying to scroll beyond, allow parent
                // 如果在滚动边界并尝试超出滚动，允许父视图
                if let scrollView = gestureRecognizer.view as? UIScrollView {
                    let isAtLeftEdge = scrollView.contentOffset.x <= 0
                    let isAtRightEdge = scrollView.contentOffset.x >= (scrollView.contentSize.width - scrollView.bounds.width)
                    
                    if (isAtLeftEdge && translation.x > 0) || (isAtRightEdge && translation.x < 0) {
                        return true
                    }
                }
            }
            
            return false
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.isScrolling = scrollView.isDragging || scrollView.isDecelerating
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                parent.isScrolling = false
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            parent.isScrolling = false
        }
    }
}

// MARK: - Demo View with UIKit Bridge / 使用 UIKit 桥接的演示视图
struct UIKitBridgedScrollDemoView: View {
    @State private var isHorizontalScrolling = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                ForEach(0..<10) { sectionIndex in
                    VStack(alignment: .leading, spacing: 12) {
                        // Section header / 部分头部
                        HStack {
                            Text("Section \(sectionIndex + 1)")
                                .font(.headline)
                            
                            if sectionIndex % 3 == 0 {
                                Text("(UIKit 横向滚动)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        if sectionIndex % 3 == 0 {
                            // UIKit bridged horizontal scroll / UIKit 桥接的横向滚动
                            UIKitHorizontalScrollView(isScrolling: $isHorizontalScrolling) {
                                HStack(spacing: 15) {
                                    ForEach(0..<15) { itemIndex in
                                        UIKitCardView(
                                            index: itemIndex,
                                            color: .blue
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                            }
                            .frame(height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.05))
                            )
                            .padding(.horizontal)
                            
                        } else if sectionIndex % 3 == 1 {
                            // Native SwiftUI horizontal scroll for comparison
                            // 用于对比的原生 SwiftUI 横向滚动
                            VStack(alignment: .leading, spacing: 5) {
                                Text("原生 SwiftUI 横向滚动")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: true) {
                                    HStack(spacing: 15) {
                                        ForEach(0..<10) { itemIndex in
                                            UIKitCardView(
                                                index: itemIndex,
                                                color: .purple
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(height: 200)
                            }
                            
                        } else {
                            // Regular vertical content / 常规垂直内容
                            VStack(spacing: 10) {
                                ForEach(0..<3) { itemIndex in
                                    HStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                        
                                        VStack(alignment: .leading) {
                                            Text("项目 \(itemIndex + 1)")
                                                .font(.headline)
                                            Text("这是一个垂直内容项")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("UIKit 桥接方案")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            // Debug indicator / 调试指示器
            Group {
                if isHorizontalScrolling {
                    Text("横向滚动中...")
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            },
            alignment: .topTrailing
        )
    }
}

// MARK: - Reusable Card View / 可复用卡片视图
private struct UIKitCardView: View {
    let index: Int
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 150, height: 180)
            .overlay(
                VStack {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("卡片 \(index + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("可滑动")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            )
            .shadow(color: color.opacity(0.3), radius: 5)
    }
}

// MARK: - Preview / 预览
#Preview {
    NavigationView {
        UIKitBridgedScrollDemoView()
    }
}