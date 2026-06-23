//
//  ContentView.swift
//  iDungeon
//
//  Created by yonmo on 4/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            } else {
                HomeRootView()
                    .transition(.opacity)
            }
        }
        .task {
            guard isShowingSplash else { return }
            try? await Task.sleep(for: .seconds(1.8))

            withAnimation(.easeInOut(duration: 0.45)) {
                isShowingSplash = false
            }
        }
    }
}
