//
//  LaunchView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 05/12/2025.
//

import SwiftUI
import Combine

struct LaunchView: View {
    @State private var loadingText: [String] = "Loading data...".map { String($0) }
    @State private var showLoadingText: Bool = false
    @State private var counter: Int = 0
    @State private var loopCounter: Int = 0
    @Binding var showLaunchView: Bool
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private let maxLoopCount: Int = 2
    
    var body: some View {
        ZStack {
            Color.launchTheme.launchBackground
                .ignoresSafeArea()
            
            Image("logo-transparent")
            
            ZStack {
                if showLoadingText {
                    HStack(spacing: 0) {
                        ForEach(loadingText.indices, id: \.self) { index in
                            Text(loadingText[index])
                                .font(.headline)
                                .foregroundStyle(Color.launchTheme.launchAccent)
                                .fontWeight(.heavy)
                                .offset(y: counter == index ? -5 : 0)
                        }
                    }
                    .transition(AnyTransition.scale.animation(.easeIn))
                }
            }
            .offset(y: 70)
        }
        .onAppear {
            showLoadingText.toggle()
        }
        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                if counter == loadingText.count {
                    print("\(loopCounter)")
                    counter = 0
                    loopCounter += 1
                    if loopCounter >= maxLoopCount {
                        showLaunchView = false
                    }
                } else {
                    counter += 1
                }
            }
        }
    }
}

#Preview {
    LaunchView(showLaunchView: .constant(true))
}
