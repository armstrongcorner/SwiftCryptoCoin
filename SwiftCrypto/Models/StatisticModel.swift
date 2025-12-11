//
//  StatisticModel.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 24/11/2025.
//

import Foundation

struct StatisticModel: Identifiable {
    var id: String = UUID().uuidString
    let title: String
    let value: String
    let percentageChange: Double?
    
    init(title: String, value: String, percentageChange: Double? = nil) {
        self.title = title
        self.value = value
        self.percentageChange = percentageChange
    }
}
