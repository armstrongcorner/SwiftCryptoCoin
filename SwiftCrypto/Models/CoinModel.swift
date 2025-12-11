//
//  CoinModel.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 22/11/2025.
//

import Foundation

// JSON data
/*
 curl --request GET \
   --url 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&price_change_percentage=24h&order=market_cap_desc&per_page=250&page=1&sparkline=true' \
   --header 'x-cg-demo-api-key: xxxxxxx'
 
 JSON response:
 {
     "id": "bitcoin",
     "symbol": "btc",
     "name": "Bitcoin",
     "image": "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
     "current_price": 85012,
     "market_cap": 1696884751211,
     "market_cap_rank": 1,
     "fully_diluted_valuation": 1696884751211,
     "total_volume": 134697482116,
     "high_24h": 86951,
     "low_24h": 81051,
     "price_change_24h": -1931.0178908704547,
     "price_change_percentage_24h": -2.22102,
     "market_cap_change_24h": -37644057939.75513,
     "market_cap_change_percentage_24h": -2.17028,
     "circulating_supply": 19950600.0,
     "total_supply": 19950600.0,
     "max_supply": 21000000.0,
     "ath": 126080,
     "ath_change_percentage": -32.61248,
     "ath_date": "2025-10-06T18:57:42.558Z",
     "atl": 67.81,
     "atl_change_percentage": 125196.21806,
     "atl_date": "2013-07-06T00:00:00.000Z",
     "roi": null,
     "last_updated": "2025-11-22T01:58:14.948Z",
     "sparkline_in_7d": {
       "price": [
         94456.39368235337,
         96031.12559501508,
         84164.15221203933
       ]
     },
     "price_change_percentage_24h_in_currency": -2.2210205224954462
   }
 */
struct CoinModel: Codable, Identifiable, Hashable {
    let id, symbol, name: String
    let image: String
    let currentPrice: Double
    let marketCap, marketCapRank, fullyDilutedValuation: Double?
    let totalVolume, high24H, low24H: Double?
    let priceChange24H, priceChangePercentage24H, marketCapChange24H, marketCapChangePercentage24H: Double?
    let circulatingSupply, totalSupply, maxSupply, ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl, atlChangePercentage: Double?
    let atlDate: String?
    let lastUpdated: String?
    let sparklineIn7D: SparklineIn7D?
    let priceChangePercentage24HInCurrency: Double?
    
    var currentHoldings: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d"
        case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
        case currentHoldings
    }
    
    func updateHoldings(amount: Double) -> CoinModel {
        var updatedCoin = self
        updatedCoin.currentHoldings = amount
        return updatedCoin
    }
    
    var currentHoldingValue: Double {
        return currentPrice * (currentHoldings ?? 0.0)
    }
    
    var rank: Int {
        return Int(marketCapRank ?? 0)
    }
}

// MARK: - SparklineIn7D
struct SparklineIn7D: Codable, Hashable {
    let price: [Double]?
}
