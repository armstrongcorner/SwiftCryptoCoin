//
//  PortfolioDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 28/11/2025.
//

import Foundation
import CoreData
import Combine

class PortfolioDataService {
    private let dbManager: DatabaseManager
    @Published var portfolioEntities: [PortfolioEntity] = []
    
    init(inMemory: Bool = false) {
        dbManager = inMemory ? DatabaseManager.previewInstance : DatabaseManager.instance
        self.getPortfolio()
    }
    
    // MARK: - Public functions
    func updatePortfolio(coin: CoinModel, amount: Double) {
        if let foundEntity = portfolioEntities.first(where: { $0.coinID == coin.id }) {
            // Found in the saved portfolio entities
            if amount > 0 {
                // update
                update(entity: foundEntity, amount: amount)
            } else {
                // remove
                remove(entity: foundEntity)
            }
        } else {
            // New entity, then add
            add(coin: coin, amount: amount)
        }
    }
    
    // MARK: - Private functions
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: "PortfolioEntity")
        do {
            portfolioEntities = try dbManager.context.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities: \(error)")
        }
    }
    
    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: dbManager.context)
        entity.coinID = coin.id
        entity.amount = amount
        
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        
        applyChanges()
    }
    
    private func remove(entity: PortfolioEntity) {
        dbManager.context.delete(entity)
        
        applyChanges()
    }
    
    private func applyChanges() {
        dbManager.save()
        getPortfolio()
    }
}
