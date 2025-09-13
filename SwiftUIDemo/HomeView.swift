import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                Section("SwiftUI 高级演示") {
                    NavigationLink(destination: SmartScrollDemoView()) {
                        HStack {
                            Image(systemName: "scroll")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text("智能滚动视图")
                                    .font(.headline)
                                Text("横向滚动与竖向滚动智能切换")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("SwiftUI 演示集")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    HomeView()
}