//
//  AllProductsViewModel.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//
import Foundation
import Combine
import RealmSwift

@MainActor
final class AllProductsViewModel: ObservableObject {
    
    @Published var products: [ProductObject] = []
    @Published var currentFilter: ProductFilter
    
    @Published var selectedProductID: ObjectId?
    @Published var isDetailViewPresented: Bool = false {
        didSet {
            if !isDetailViewPresented, let idToDelete = productIDPendingDeletion {
                deleteProduct(withId: idToDelete)
                self.productIDPendingDeletion = nil
            }
        }
    }
    
    @Published var isAddProductViewPresented: Bool = false
    
    private var token: NotificationToken?
    private var productIDPendingDeletion: ObjectId?
    
    init(initialFilter: ProductFilter) {
        self.currentFilter = initialFilter
        setupObserver()
    }
    
    deinit {
        token?.invalidate()
    }
    
    func filterProducts(by filter: ProductFilter) {
        self.currentFilter = filter
        fetchProducts()
    }
    
    func selectProduct(_ product: ProductObject) {
        selectedProductID = product._id
        isDetailViewPresented = true
    }
    
    func prepareToDeleteSelectedProduct() {
        self.productIDPendingDeletion = selectedProductID
        self.isDetailViewPresented = false
    }
    
    private func deleteProduct(withId id: ObjectId) {
        products = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            StorageManager.shared.deleteProduct(withId: id)
            print("DELETED")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fetchProducts()
            print("SHOWN")
        }
        
        
     
    }
    
    private func fetchProducts() {
        products = StorageManager.shared.fetchProducts(filter: currentFilter)
    }
    
    private func setupObserver() {
        guard let realm = try? Realm() else { return }
        let results = realm.objects(ProductObject.self)
        
        token = results.observe { [weak self] _ in
            self?.fetchProducts()
        }
    }
}
