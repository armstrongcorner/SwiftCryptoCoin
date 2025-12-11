//
//  InfoView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 05/12/2025.
//

import SwiftUI

struct InfoView: View {
    private let defaultUrl = URL(string: "https://www.google.com")!
    private let youtubeUrl = URL(string: "https://www.youtube.com")!
    private let coffeeUrl = URL(string: "https://www.buymeacoffee.com")!
    private let coinGeckoUrl = URL(string: "https://www.coingecko.com")!
    private let personalUrl = URL(string: "https://github.com/armstrongcorner")!

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                List {
                    appIntroSection
                        .listRowBackground(Color.theme.infoRowBackground)
                    coinGeckoSection
                        .listRowBackground(Color.theme.infoRowBackground)
                    developerSection
                        .listRowBackground(Color.theme.infoRowBackground)
                    applicationSection
                        .listRowBackground(Color.theme.infoRowBackground)
                }
            }
            .font(.headline)
            .navigationTitle("Information")
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton()
                }
            }
        }
    }
}

// MARK: - UI extension
extension InfoView {
    private var appIntroSection: some View {
        Section(header: Text("Swift Crypto Coin")) {
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("""
                Swift Crypto Coin is a demo cryptocurrency project. All coin data is real and up-to-date which is fetched from CoinGecko API.
                Free to use the app to learn Swift/SwiftUI related knowledge
                """)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(Color.theme.accent)
            }
            .padding(.vertical)
            
            Link("Subscribe on YouTube 🥳", destination: youtubeUrl)
            Link("Buy me a coffee ☕️", destination: coffeeUrl)
        }
    }
    
    private var coinGeckoSection: some View {
        Section(header: Text("CoinGecko")) {
            VStack(alignment: .leading) {
                Image("coingecko")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("""
                The cryptocurrency data that is used in this app comes from CoinGecko API (Free or Premium version). Prices may be slightly delayed.
                """)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(Color.theme.accent)
            }
            .padding(.vertical)
            
            Link("Visit CoinGecko 🦎", destination: coinGeckoUrl)
        }
    }
    
    private var developerSection: some View {
        Section(header: Text("Developer")) {
            VStack(alignment: .leading) {
                Image("github")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("""
                This app was developed by Armstrong Liu. It uses SwiftUI and is written 100% in Swift. The project benefits from
                • MVVM architecture
                • Multi-threading
                • Combine (publisher/subscriber)
                • CoreData
                """)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(Color.theme.accent)
            }
            .padding(.vertical)
            
            Link("Visit Website 🤙", destination: personalUrl)
        }
    }
    
    private var applicationSection: some View {
        Section(header: Text("Developer")) {
            Link("Terms of Service", destination: defaultUrl)
            Link("Privacy Policy", destination: defaultUrl)
            Link("Company Website", destination: defaultUrl)
            Link("Learn More", destination: defaultUrl)
        }
    }
}

// MARK: - Previews
#Preview {
    InfoView()
}
