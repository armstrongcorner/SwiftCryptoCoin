//
//  CoinImageViewModel.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 23/11/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CoinImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var errMsg: String? = nil
    
    private let coin: CoinModel
    private let imageService: ImageServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, imageService: ImageServiceProtocol = ImageService()) {
        self.coin = coin
        self.imageService = imageService
        
        addSubscriber()
    }
    
    private func addSubscriber() {
        isLoading = true
        errMsg = nil
        
        imageService.getCoinImage(urlString: coin.image, imageName: coin.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errMsg = error.localizedDescription
                    self.image = nil
                }
            } receiveValue: { [weak self] returnedImg in
                self?.image = returnedImg
            }
            .store(in: &cancellables)
    }
}
