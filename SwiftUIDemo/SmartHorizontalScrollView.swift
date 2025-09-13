import SwiftUI

struct SmartHorizontalScrollView<Content: View>: View {
    @Binding var parentVerticalScrollOffset: CGFloat
    @Binding var isParentScrolling: Bool
    @Binding var debugInfo: String
    
    let content: Content
    
    @State private var scrollOffset: CGPoint = .zero
    @State private var lastDragValue: DragGesture.Value?
    @State private var isDragging: Bool = false
    @State private var dragVelocity: CGSize = .zero
    @State private var shouldScrollParent: Bool = false
    
    private let velocityThreshold: CGFloat = 0.5
    private let angleThreshold: Double = 45
    
    init(
        parentVerticalScrollOffset: Binding<CGFloat>,
        isParentScrolling: Binding<Bool>,
        debugInfo: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self._parentVerticalScrollOffset = parentVerticalScrollOffset
        self._isParentScrolling = isParentScrolling
        self._debugInfo = debugInfo
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    content
                        .background(
                            GeometryReader { innerGeometry in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: innerGeometry.frame(in: .named("scroll")).origin
                                    )
                            }
                        )
                        .id("content")
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            handleDragChanged(value, geometry: geometry)
                        }
                        .onEnded { value in
                            handleDragEnded(value)
                        }
                )
                .disabled(isParentScrolling)
                .overlay(
                    Group {
                        if shouldScrollParent {
                            Color.blue.opacity(0.1)
                                .allowsHitTesting(false)
                                .animation(.easeInOut(duration: 0.2), value: shouldScrollParent)
                        }
                    }
                )
            }
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value, geometry: GeometryProxy) {
        if let last = lastDragValue {
            let deltaX = value.translation.width - last.translation.width
            let deltaY = value.translation.height - last.translation.height
            
            dragVelocity = CGSize(
                width: deltaX,
                height: deltaY
            )
            
            let angle = abs(atan2(value.translation.height, value.translation.width) * 180 / .pi)
            let isVerticalGesture = angle > angleThreshold
            
            if isVerticalGesture {
                shouldScrollParent = true
                isParentScrolling = true
                parentVerticalScrollOffset += deltaY
                debugInfo = "滑动方向: 垂直 (角度: \(Int(angle))°)"
            } else {
                shouldScrollParent = false
                isParentScrolling = false
                debugInfo = "滑动方向: 水平 (角度: \(Int(angle))°)"
            }
        }
        
        lastDragValue = value
        isDragging = true
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        lastDragValue = nil
        isDragging = false
        shouldScrollParent = false
        isParentScrolling = false
        dragVelocity = .zero
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !isDragging {
                debugInfo = "滑动方向: 无"
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}