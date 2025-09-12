//
//  SwiftUIDemoApp.swift
//  SwiftUIDemo
//
//  Created by LLLRNSTB on 2025/9/11.
//

import SwiftUI
import ComposableArchitecture

@main
struct SwiftUIDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}
