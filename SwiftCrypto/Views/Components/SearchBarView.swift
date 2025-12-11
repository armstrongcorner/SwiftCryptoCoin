//
//  SearchBarView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 24/11/2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(searchText.isEmpty ? Color.theme.secondaryText : Color.theme.accent)
            
            TextField("Search by name or symbol...", text: $searchText)
                .foregroundStyle(Color.theme.accent)
                .autocorrectionDisabled()
                .overlay(alignment: .trailing) {
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 15)
                        .foregroundStyle(Color.theme.accent)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            searchText = ""
                            UIApplication.shared.endEditing()
                        }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.theme.accent.opacity(0.15),
                    radius: 10, x: 0, y: 0
                )
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    SearchBarView(searchText: .constant(""))
}
