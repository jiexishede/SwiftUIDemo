import SwiftUI

struct SmartVerticalScrollView<Content: View>: View {
    @Binding var verticalScrollOffset: CGFloat
    @Binding var isVerticalScrolling: Bool
    @Binding var debugInfo: String
    
    let content: Content
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var contentHeight: CGFloat = 0
    @State private var viewHeight: CGFloat = 0
    
    init(
        verticalScrollOffset: Binding<CGFloat>,
        isVerticalScrolling: Binding<Bool>,
        debugInfo: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self._verticalScrollOffset = verticalScrollOffset
        self._isVerticalScrolling = isVerticalScrolling
        self._debugInfo = debugInfo
        self.content = content()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    content
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(
                                        key: ScrollContentPreferenceKey.self,
                                        value: ScrollContentData(
                                            offset: geometry.frame(in: .named("vertical_scroll")).origin,
                                            size: geometry.size
                                        )
                                    )
                            }
                        )
                }
                .id("scrollContent")
            }
            .coordinateSpace(name: "vertical_scroll")
            .onPreferenceChange(ScrollContentPreferenceKey.self) { data in
                scrollPosition = data.offset
                contentHeight = data.size.height
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewHeight = geometry.size.height
                        }
                }
            )
            .onChange(of: verticalScrollOffset) { newValue in
                if isVerticalScrolling {
                    withAnimation(.interactiveSpring()) {
                        proxy.scrollTo("scrollContent", anchor: .top)
                    }
                }
            }
        }
    }
}

struct SmartVerticalOnlyScrollView<Content: View>: View {
    @Binding var debugInfo: String
    
    let content: Content
    
    @State private var isDragging: Bool = false
    @State private var lastDragValue: DragGesture.Value?
    @State private var isHorizontalGesture: Bool = false
    
    private let angleThreshold: Double = 45
    
    init(
        debugInfo: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self._debugInfo = debugInfo
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            content
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
        .scrollDisabled(isHorizontalGesture)
        .overlay(
            Group {
                if isHorizontalGesture {
                    Color.red.opacity(0.1)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 0.2), value: isHorizontalGesture)
                }
            }
        )
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let angle = abs(atan2(value.translation.height, value.translation.width) * 180 / .pi)
        isHorizontalGesture = angle < angleThreshold
        
        if isHorizontalGesture {
            debugInfo = "滑动方向: 水平被阻止 (角度: \(Int(angle))°)"
        } else {
            debugInfo = "滑动方向: 垂直 (角度: \(Int(angle))°)"
        }
        
        lastDragValue = value
        isDragging = true
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        lastDragValue = nil
        isDragging = false
        isHorizontalGesture = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !isDragging {
                debugInfo = "滑动方向: 无"
            }
        }
    }
}

struct ScrollContentData: Equatable {
    let offset: CGPoint
    let size: CGSize
}

struct ScrollContentPreferenceKey: PreferenceKey {
    static var defaultValue: ScrollContentData = ScrollContentData(offset: .zero, size: .zero)
    
    static func reduce(value: inout ScrollContentData, nextValue: () -> ScrollContentData) {
        value = nextValue()
    }
}