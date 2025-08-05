//
//  StorageManager.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import Foundation
import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    
    private var realm: Realm?
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
    }
    
    func addProduct(name: String, expirationDate: Date, photoData: Data?, notes: String?) {
        guard let realm = realm else { return }
        
        let product = ProductObject()
        product.name = name
        product.expirationDate = expirationDate
        product.photoData = photoData
        product.notes = notes
        
        do {
            try realm.write {
                realm.add(product)
            }
            NotificationManager.shared.scheduleNotifications(for: product)
            
        } catch {
            print("Error saving product: \(error)")
        }
    }
    
    func fetchProducts(filter: ProductFilter) -> [ProductObject] {
        guard let realm = realm else { return [] }
        
        let allProducts = realm.objects(ProductObject.self)
        let now = Date()
        let calendar = Calendar.current
        
        let results: Results<ProductObject>
        
        switch filter {
        case .all:
            results = allProducts
        case .aboutToSpoil:
            guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) else { return [] }
            results = allProducts.filter("expirationDate >= %@ AND expirationDate <= %@", now, weekFromNow)
        case .spoiled:
            results = allProducts.filter("expirationDate < %@", now)
        }
        
        return Array(results.sorted(byKeyPath: "expirationDate", ascending: true))
    }
    
    func deleteProduct(withId id: ObjectId) {
        guard let realm = realm, let product = realm.object(ofType: ProductObject.self, forPrimaryKey: id) else { return }
        let productIDString = product._id.stringValue
        NotificationManager.shared.cancelNotifications(for: productIDString)
        do {
            try realm.write {
                realm.delete(product)
            }
        } catch {
            print("Error deleting product: \(error)")
        }
    }
    
    func addShoppingItem(name: String, quantity: String) {
        guard let realm = realm else { return }
        
        let item = ShoppingListItemObject()
        item.name = name
        item.quantity = quantity
        
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving shopping item: \(error)")
        }
    }
    
    func fetchShoppingItems() -> [ShoppingListItemObject] {
        guard let realm = realm else { return [] }
        let items = realm.objects(ShoppingListItemObject.self)
        return Array(items)
    }
    
    func updateShoppingItemCompletion(withId id: ObjectId, isCompleted: Bool) {
        guard let realm = realm, let item = realm.object(ofType: ShoppingListItemObject.self, forPrimaryKey: id) else { return }
        
        do {
            try realm.write {
                item.isCompleted = isCompleted
            }
        } catch {
            print("Error updating shopping item: \(error)")
        }
    }
    
    func clearShoppingList() {
        guard let realm = realm else { return }
        
        let itemsToDelete = realm.objects(ShoppingListItemObject.self)
        
        do {
            try realm.write {
                realm.delete(itemsToDelete)
            }
        } catch {
            print("Error clearing shopping list: \(error)")
        }
    }
    
    func isAchievementUnlocked(id: String) -> Bool {
        guard let realm = realm else { return false }
        return realm.object(ofType: AchievementStateObject.self, forPrimaryKey: id) != nil
    }
    
    func unlockAchievement(id: String) {
        guard let realm = realm, !isAchievementUnlocked(id: id) else { return }
        
        let achievementState = AchievementStateObject()
        achievementState.id = id
        
        do {
            try realm.write {
                realm.add(achievementState)
            }
        } catch {
            print("Error unlocking achievement: \(error)")
        }
    }
    
    func fetchUnlockedAchievements() -> Set<String> {
        guard let realm = realm else { return [] }
        let unlockedObjects = realm.objects(AchievementStateObject.self)
        return Set(unlockedObjects.map { $0.id })
    }
    
    func deleteAllData() {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error deleting all data: \(error)")
        }
    }
    
    func deleteShoppingItem(withId id: ObjectId) {
        guard let realm = realm, let item = realm.object(ofType: ShoppingListItemObject.self, forPrimaryKey: id) else { return }
        
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Error deleting shopping item: \(error)")
        }
    }
    
    private func getStatsObject() -> OverallStatsObject {
        guard let realm = realm else { fatalError("Realm is not available") }
        if let stats = realm.object(ofType: OverallStatsObject.self, forPrimaryKey: "singleton") {
            return stats
        } else {
            let stats = OverallStatsObject()
            try! realm.write {
                realm.add(stats)
            }
            return stats
        }
    }
    
    func fetchOverallStats() -> OverallStatsObject {
        return getStatsObject()
    }
    
    func incrementProductsAdded(fromAI: Bool) {
        guard let realm = realm else { return }
        let stats = getStatsObject()
        try! realm.write {
            stats.productsAdded += 1
            if fromAI {
                stats.productsAddedWithAI += 1
            }
        }
    }
    
    func incrementProductsUsed() {
        guard let realm = realm else { return }
        let stats = getStatsObject()
        try! realm.write {
            stats.productsUsed += 1
        }
    }
    
    func incrementShoppingListsCompleted() {
        guard let realm = realm else { return }
        let stats = getStatsObject()
        try! realm.write {
            stats.shoppingListsCompleted += 1
        }
    }
    
    func updateUserLogin() {
        guard let realm = realm else { return }
        let stats = getStatsObject()
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastLogin = Calendar.current.startOfDay(for: stats.lastLoginDate)
        
        guard today != lastLogin else { return }
        
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        try! realm.write {
            if lastLogin == dayBefore {
                stats.loginStreak += 1
            } else {
                stats.loginStreak = 1
            }
            stats.lastLoginDate = Date()
        }
    }
}
