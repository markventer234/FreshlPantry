//
//  AchievementSystem.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//
import Foundation
import RealmSwift
import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
}

enum AchievementTrigger {
    case appOpened
    case productAdded(fromAI: Bool)
    case productUsed
    case shoppingListCompleted
}

final class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievementToDisplay: Achievement?
    
    private var unlockedIDsCache: Set<String> = []
    
    let allAchievements: [Achievement] = [
        Achievement(id: "firstStep", title: "First \nStep", description: "Add your first product", iconName: "ach_first_step"),
        Achievement(id: "pantryFiller", title: "Pantry Filler", description: "Add 10 products", iconName: "ach_pantry_filler"),
        Achievement(id: "homeStocker", title: "Home Stocker", description: "Add 50 products", iconName: "ach_home_stocker"),
        Achievement(id: "wasteWarrior", title: "Waste Warrior", description: "Use up 1 product", iconName: "ach_waste_warrior"),
        Achievement(id: "efficiencyExpert", title: "Efficiency Expert", description: "Use up 10 products", iconName: "ach_efficiency_expert"),
        Achievement(id: "shoppingPro", title: "Shop \nPro", description: "Complete first shopping list", iconName: "ach_shopping_pro"),
        Achievement(id: "listMaster", title: "List Master", description: "Complete 10 shopping lists", iconName: "ach_list_master"),
        Achievement(id: "aiExplorer", title: "AI Explorer", description: "Add a product using AI", iconName: "ach_ai_explorer"),
        Achievement(id: "techSavvy", title: "Tech Savvy", description: "Add 10 products by AI", iconName: "ach_tech_savvy"),
        Achievement(id: "freshStart", title: "Fresher", description: "Add 20 fresh products", iconName: "ach_fresh_start"),
        Achievement(id: "consistentUser", title: "Consistent User", description: "Open the app 7 days in a row", iconName: "ach_consistent_user"),
        Achievement(id: "trueFan", title: "True Fan", description: "Open the app 30 days in a row", iconName: "ach_true_fan")
    ]
    
    private init() {
        self.unlockedIDsCache = StorageManager.shared.fetchUnlockedAchievements()
    }
    
    func trigger(event: AchievementTrigger) {
        let stats = StorageManager.shared.fetchOverallStats()
        
        switch event {
        case .appOpened:
            checkAndUnlock(allAchievements[9], condition: stats.loginStreak >= 1)
            checkAndUnlock(allAchievements[10], condition: stats.loginStreak >= 7)
            checkAndUnlock(allAchievements[11], condition: stats.loginStreak >= 30)
            
        case .productAdded(let fromAI):
            checkAndUnlock(allAchievements[0], condition: stats.productsAdded >= 1)
            checkAndUnlock(allAchievements[1], condition: stats.productsAdded >= 10)
            checkAndUnlock(allAchievements[2], condition: stats.productsAdded >= 50)
            if fromAI {
                checkAndUnlock(allAchievements[7], condition: stats.productsAddedWithAI >= 1)
                checkAndUnlock(allAchievements[8], condition: stats.productsAddedWithAI >= 10)
            }
            
        case .productUsed:
            checkAndUnlock(allAchievements[3], condition: stats.productsUsed >= 1)
            checkAndUnlock(allAchievements[4], condition: stats.productsUsed >= 10)
            
        case .shoppingListCompleted:
            checkAndUnlock(allAchievements[5], condition: stats.shoppingListsCompleted >= 1)
            checkAndUnlock(allAchievements[6], condition: stats.shoppingListsCompleted >= 10)
        }
    }
    
    private func checkAndUnlock(_ achievement: Achievement, condition: Bool) {
        if condition && !unlockedIDsCache.contains(achievement.id) {
            StorageManager.shared.unlockAchievement(id: achievement.id)
            unlockedIDsCache.insert(achievement.id)
            showUnlockAlert(for: achievement)
        }
    }
    
    private func showUnlockAlert(for achievement: Achievement) {
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                self.achievementToDisplay = achievement
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.spring()) {
                    if self.achievementToDisplay?.id == achievement.id {
                        self.achievementToDisplay = nil
                    }
                }
            }
        }
    }
}
