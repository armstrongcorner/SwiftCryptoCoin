//
//  CloseButton.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 26/11/2025.
//

import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CloseButton()
}
