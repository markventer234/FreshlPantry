//
//  RealmModels.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import Foundation
import RealmSwift

enum ProductStatus: String, PersistableEnum {
    case fresh = "Fresh"
    case aboutToSpoil = "About to Spoil"
    case spoiled = "Spoiled"
}

class ProductObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var photoData: Data?
    @Persisted var expirationDate: Date = Date()
    @Persisted var notes: String?
    @Persisted var statusRaw: ProductStatus = .fresh
}

class ShoppingListItemObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var quantity: String = "1"
    @Persisted var isCompleted: Bool = false
}

class AchievementStateObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var isUnlocked: Bool = false
    @Persisted var dateUnlocked: Date = Date()
}

class OverallStatsObject: Object {
    @Persisted(primaryKey: true) var id: String = "singleton"
    @Persisted var productsAdded: Int = 0
    @Persisted var productsAddedWithAI: Int = 0
    @Persisted var productsUsed: Int = 0
    @Persisted var shoppingListsCompleted: Int = 0
    @Persisted var lastLoginDate: Date = Date()
    @Persisted var loginStreak: Int = 0
}
