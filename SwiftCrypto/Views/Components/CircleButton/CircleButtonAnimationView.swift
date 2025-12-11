//
//  CircleButtonAnimationView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 22/11/2025.
//

import SwiftUI

struct CircleButtonAnimationView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 5)
            .scale(isAnimating ? 1.0 : 0.0)
            .opacity(isAnimating ? 0.0 : 1.0)
            .animation(isAnimating ? .easeOut(duration: 1.0) : .none, value: isAnimating)
    }
}

#Preview {
    CircleButtonAnimationView(isAnimating: .constant(false))
        .foregroundStyle(.red)
        .frame(width: 100, height: 100)
}
