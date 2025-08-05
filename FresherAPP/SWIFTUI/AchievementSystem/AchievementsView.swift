//
//  AchievementsViewModel.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import Foundation
import SwiftUI

class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var unlockedIDs: Set<String> = []
    
    init() {
        self.achievements = AchievementManager.shared.allAchievements
    }
    
    func loadUnlockedStatus() {
        self.unlockedIDs = StorageManager.shared.fetchUnlockedAchievements()

    }
}

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.achievements) { achievement in
                        let isUnlocked = viewModel.unlockedIDs.contains(achievement.id)
                        AchievementCell(achievement: achievement, isUnlocked: isUnlocked)
                    }
                }
                .padding()
            }
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .onAppear(perform: viewModel.loadUnlockedStatus)
    }
}

private struct HeaderView: View {
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Text("Achievements")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryText)
            
            Spacer()
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.themeSecondaryText)
            }
        }
        .padding()
    }
}

private struct AchievementCell: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(achievement.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(12)
                .background(Color.themeBackground.opacity(0.5))
                .clipShape(Circle())
            
            Text(achievement.title)
                .font(.headline)
                .foregroundColor(.themePrimaryText)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .frame(width: 100, height: 180)
        .background(Color.themeCardBackground)
        .cornerRadius(20)
        .opacity(isUnlocked ? 1.0 : 0.4)
    }
}

struct AchievementUnlockedAlert: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(achievement.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text("ACHIEVEMENT UNLOCKED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.themeAccentYellow)
                
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
    }
}
