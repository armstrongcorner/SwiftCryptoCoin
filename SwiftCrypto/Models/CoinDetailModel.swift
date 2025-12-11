//
//  CoinDetailModel.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 01/12/2025.
//

import Foundation

// JSON data
/*
 curl --request GET \
   --url https://api.coingecko.com/api/v3/coins/{coinId} \
   --header 'x-cg-demo-api-key: xxxxxxxx'
 
 JSON response:
 {
   "id": "bitcoin",
   "symbol": "btc",
   "name": "Bitcoin",
   "web_slug": "bitcoin",
   "asset_platform_id": null,
   "platforms": {
     "": ""
   },
   "detail_platforms": {
     "": {
       "decimal_place": null,
       "contract_address": ""
     }
   },
   "block_time_in_minutes": 10,
   "hashing_algorithm": "SHA-256",
   "categories": [
     "Smart Contract Platform",
     "Layer 1 (L1)",
     "FTX Holdings",
     "Proof of Work (PoW)",
     "Bitcoin Ecosystem",
     "GMCI 30 Index",
     "GMCI Index",
     "Coinbase 50 Index"
   ],
   "preview_listing": false,
   "public_notice": null,
   "additional_notices": [],
   "description": {
     "en": "Bitcoin is the world's first decentralized cryptocurrency, created in 2009 by the pseudonymous Satoshi Nakamoto. It enables peer-to-peer electronic cash transactions without intermediaries like banks or governments, operating on a blockchain secured by Proof of Work mining and the SHA-256 cryptographic algorithm. \r\n\r\nWith a fixed supply cap of 21 million coins and programmatic halvings every four years that reduce miner rewards, Bitcoin is designed as a deflationary digital asset often called \"digital gold.\" Its value stems from solving the double-spending problem without trusted intermediaries, creating the first truly scarce digital asset with censorship resistance and permissionless access that no government, corporation, or individual can control.\r\n\r\nBitcoin operates as a decentralized peer-to-peer network where transactions are recorded on a public ledger called the blockchain, distributed across thousands of computers globally. Transactions are grouped into blocks added approximately every 10 minutes through mining, where specialized computers compete to solve complex mathematical puzzles. \r\n\r\nBitcoin has achieved mainstream adoption through multiple vectors. The January 2024 SEC approval of 11 spot Bitcoin ETFs opened Bitcoin investment to traditional finance participants, and corporations like Strategy (formerly MicroStrategy) are using Bitcoin as a treasury reserve asset to protect against currency debasement, offering MSTR holders amplified exposure to Bitcoin. \r\n\r\nThe Bitcoin ecosystem continues to evolve with innovations like Ordinals, which emerged in January 2023 to enable NFT-like functionality directly on Bitcoin, and BRC-20 tokens, an experimental standard for creating fungible tokens using Ordinal inscriptions. BTCFi (Bitcoin Finance) represents emerging financial applications extending beyond Bitcoin's traditional role, with protocols like Babylon allowing Bitcoin holders to stake BTC to secure Proof of Stake chains. "
   },
   "links": {
     "homepage": [
       "http://www.bitcoin.org"
     ],
     "whitepaper": "https://bitcoin.org/bitcoin.pdf",
     "blockchain_site": [
       "https://mempool.space/",
       "https://platform.arkhamintelligence.com/explorer/token/bitcoin",
       "https://blockchair.com/bitcoin/",
       "https://btc.com/",
       "https://btc.tokenview.io/",
       "https://www.oklink.com/btc",
       "https://3xpl.com/bitcoin"
     ],
     "official_forum_url": [
       "https://bitcointalk.org/"
     ],
     "chat_url": [],
     "announcement_url": [],
     "snapshot_url": null,
     "twitter_screen_name": "bitcoin",
     "facebook_username": "bitcoins",
     "bitcointalk_thread_identifier": null,
     "telegram_channel_identifier": "",
     "subreddit_url": "https://www.reddit.com/r/Bitcoin/",
     "repos_url": {
       "github": [
         "https://github.com/bitcoin/bitcoin",
         "https://github.com/bitcoin/bips"
       ],
       "bitbucket": []
     }
   },
   "image": {
     "thumb": "https://coin-images.coingecko.com/coins/images/1/thumb/bitcoin.png?1696501400",
     "small": "https://coin-images.coingecko.com/coins/images/1/small/bitcoin.png?1696501400",
     "large": "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400"
   },
   "country_origin": "",
   "genesis_date": "2009-01-03",
   "sentiment_votes_up_percentage": 63.38,
   "sentiment_votes_down_percentage": 36.62,
   "watchlist_portfolio_users": 2271263,
   "market_cap_rank": 1,
   "status_updates": [],
   "last_updated": "2025-12-01T08:11:40.901Z"
 }
 
 */

struct CoinDetailModel: Codable {
    let id, symbol, name, webSlug: String?
    let blockTimeInMinutes: Int?
    let hashingAlgorithm: String?
    let categories: [String]?
    let previewListing: Bool?
    let description: Description?
    let links: Links?
    let countryOrigin, genesisDate: String?
    let sentimentVotesUpPercentage, sentimentVotesDownPercentage: Double?
    let watchlistPortfolioUsers, marketCapRank: Int?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case webSlug = "web_slug"
        case blockTimeInMinutes = "block_time_in_minutes"
        case hashingAlgorithm = "hashing_algorithm"
        case categories
        case previewListing = "preview_listing"
        case description, links
        case countryOrigin = "country_origin"
        case genesisDate = "genesis_date"
        case sentimentVotesUpPercentage = "sentiment_votes_up_percentage"
        case sentimentVotesDownPercentage = "sentiment_votes_down_percentage"
        case watchlistPortfolioUsers = "watchlist_portfolio_users"
        case marketCapRank = "market_cap_rank"
        case lastUpdated = "last_updated"
    }
}

// MARK: - Description
struct Description: Codable {
    let en: String?
}

// MARK: - Links
struct Links: Codable {
    let homepage: [String]?
    let whitepaper: String?
    let blockchainSite, officialForumURL: [String]?
    let twitterScreenName, facebookUsername: String?
    let telegramChannelIdentifier: String?
    let subredditURL: String?

    enum CodingKeys: String, CodingKey {
        case homepage, whitepaper
        case blockchainSite = "blockchain_site"
        case officialForumURL = "official_forum_url"
        case twitterScreenName = "twitter_screen_name"
        case facebookUsername = "facebook_username"
        case telegramChannelIdentifier = "telegram_channel_identifier"
        case subredditURL = "subreddit_url"
    }
}
