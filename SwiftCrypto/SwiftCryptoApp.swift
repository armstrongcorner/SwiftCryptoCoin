//
//  SwiftCryptoApp.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 20/11/2025.
//

import SwiftUI

@main
struct SwiftCryptoApp: App {
    @StateObject private var homeVM = HomeViewModel()
    @State private var showLaunchView: Bool = true
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
//        appearance.backgroundColor = UIColor(Color.theme.background)
        // apply the appearance to all scene
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                NavigationStack {
                    ZStack {
                        HomeView()
                            .toolbarVisibility(.hidden, for: .navigationBar)
                            .navigationDestination(for: CoinModel.self) { coin in
                                CoinDetailView(coin: coin)
                            }
                        
                        if showLaunchView {
                            LaunchView(showLaunchView: $showLaunchView)
                                .zIndex(1)
                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                        }
//                        if homeVM.isLoading {
//                            LaunchView(showLaunchView: $homeVM.isLoading)
//                        }
                    }
                }
                .environment(\.screenSize, proxy.size)
            }
            .environmentObject(homeVM)
        }
    }
}
