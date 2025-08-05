//
//  MainViewModel.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import Foundation
import Combine
import RealmSwift

@MainActor
final class MainViewModel: ObservableObject {
    
    @Published var productCount: Int = 0
    @Published var aboutToSpoilCount: Int = 0
    @Published var spoiledCount: Int = 0

    private var token: NotificationToken?
    
    init() {
        setupObserver()
    }
    
    deinit {
        token?.invalidate()
    }
    
    private func setupObserver() {
        guard let realm = try? Realm() else { return }
        
        let results = realm.objects(ProductObject.self)
        
        token = results.observe { [weak self] _ in
            self?.fetchData()
        }
    }
    
    private func fetchData() {
        self.productCount = StorageManager.shared.fetchProducts(filter: .all).count
        self.aboutToSpoilCount = StorageManager.shared.fetchProducts(filter: .aboutToSpoil).count
        self.spoiledCount = StorageManager.shared.fetchProducts(filter: .spoiled).count
    }
}
