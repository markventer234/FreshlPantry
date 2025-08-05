//
//  ShoppingListViewModel.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import Foundation
import RealmSwift
import Combine

@MainActor
final class ShoppingListViewModel: ObservableObject {
    
    @Published var items: [ShoppingListItemObject] = []
    
    @Published var isAddItemViewPresented: Bool = false
    @Published var isClearListAlertPresented: Bool = false
    
    private var token: NotificationToken?
    
    init() {
        setupObserver()
    }
    
    deinit {
        token?.invalidate()
    }
    
    func toggleItemCompletion(_ item: ShoppingListItemObject) {
        StorageManager.shared.updateShoppingItemCompletion(
            withId: item._id,
            isCompleted: !item.isCompleted
        )
    }
    
    func clearList() {
        items = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            StorageManager.shared.clearShoppingList()
        }
        
        StorageManager.shared.incrementShoppingListsCompleted()
            AchievementManager.shared.trigger(event: .shoppingListCompleted)
    }
    
    private func fetchItems() {
        items = StorageManager.shared.fetchShoppingItems()
    }
    
    private func setupObserver() {
        guard let realm = try? Realm() else { return }
        let results = realm.objects(ShoppingListItemObject.self)
        
        token = results.observe { [weak self] _ in
            self?.fetchItems()
        }
    }
}
