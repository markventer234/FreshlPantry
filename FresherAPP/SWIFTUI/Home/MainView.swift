//
//  MainView.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI

enum ProductFilter {
    case all, aboutToSpoil, spoiled
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @ObservedObject private var achievementManager = AchievementManager.shared
    
    @State private var isOnboardingShown: Bool = false
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init() {
        StorageManager.shared.updateUserLogin()
        AchievementManager.shared.trigger(event: .appOpened)
        
//        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HeaderView()
                        
                        HStack {
                            Spacer()
                            
                            Text("Check it before you chuck it!")
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .italic()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 20)
                        
                        
                        DashboardStatsView(
                            productCount: viewModel.productCount,
                            aboutToSpoilCount: viewModel.aboutToSpoilCount,
                            spoiledCount: viewModel.spoiledCount
                        )
                        
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            NavigationCard(
                                title: "All Products",
                                iconName: "square.grid.2x2.fill",
                                destination: AllProductsView(filter: .all).navigationBarBackButtonHidden()
                            )
                            NavigationCard(
                                title: "Shopping List",
                                iconName: "list.bullet.rectangle.portrait.fill",
                                destination: ShoppingListView().navigationBarBackButtonHidden()
                            )
                            NavigationCard(
                                title: "Achievements",
                                iconName: "star.fill",
                                destination: AchievementsView().navigationBarBackButtonHidden()
                            )
                            NavigationCard(
                                title: "Add Product",
                                iconName: "plus.app.fill",
                                destination: AddProductView().navigationBarBackButtonHidden()
                            )
                        }
                    }
                    .padding()
                }
                
                VStack {
                    if let achievement = achievementManager.achievementToDisplay {
                        AchievementUnlockedAlert(achievement: achievement)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "onboardingShown") {
                isOnboardingShown.toggle()
                UserDefaults.standard.set(true, forKey: "onboardingShown")
            }
        }
        .fullScreenCover(isPresented: $isOnboardingShown) {
            OnboardingView()
        }
    }
}


private struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Home")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryText)
            
            Spacer()
            
            NavigationLink(destination: SettingsView().navigationBarBackButtonHidden()) {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(.themeSecondaryText)
            }
        }
    }
}

private struct DashboardStatsView: View {
    let productCount: Int
    let aboutToSpoilCount: Int
    let spoiledCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: AllProductsView(filter: .all).navigationBarBackButtonHidden()) {
                StatCard(count: productCount, label: "Products")
            }
            NavigationLink(destination: AllProductsView(filter: .aboutToSpoil).navigationBarBackButtonHidden()) {
                StatCard(count: aboutToSpoilCount, label: "About to Spoil")
            }
            NavigationLink(destination: AllProductsView(filter: .spoiled).navigationBarBackButtonHidden()) {
                StatCard(count: spoiledCount, label: "Spoiled")
            }
        }
    }
}

private struct StatCard: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryText)
                .offset(y: 10)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.themeSecondaryText)
                .frame(height: 40)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color.themeCardBackground)
        .cornerRadius(20)
    }
}

private struct NavigationCard<Destination: View>: View {
    let title: String
    let iconName: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(.themeAccentYellow)
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .background(Color.themeCardBackground)
            .cornerRadius(20)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

