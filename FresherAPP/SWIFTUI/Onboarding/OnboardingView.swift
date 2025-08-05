//
//  OnboardingView.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPageIndex = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding_image_1",
            title: "Never Waste Food Again",
            description: "Easily track expiration dates for all your groceries. Get timely reminders and keep your pantry fresh."
        ),
        OnboardingPage(
            imageName: "onboarding_image_2",
            title: "Shop Smarter",
            description: "Build your shopping list on the go. Check off items as you shop and never forget the milk again."
        ),
        OnboardingPage(
            imageName: "onboarding_image_3",
            title: "Earn Achievements",
            description: "Become a pantry pro! Unlock achievements for managing your food, completing lists, and reducing waste."
        )
    ]

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPageIndex.animation()) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 20) {
                    PageIndicatorView(pageCount: pages.count, currentIndex: $currentPageIndex)
                    
                    OnboardingButton(isLastPage: currentPageIndex == pages.count - 1) {
                        if currentPageIndex < pages.count - 1 {
                            currentPageIndex += 1
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .padding(30)
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(16)
                .padding()
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle).bold()
                    .frame(height: 100)
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(.themeSecondaryText)
                    .frame(height: 100)
            }
            .multilineTextAlignment(.center)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 30)
            
            Spacer()
        }
        .padding(30)
        .foregroundColor(.themePrimaryText)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

private struct PageIndicatorView: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.themeAccentYellow : Color.themeCardBackground)
                    .frame(width: index == currentIndex ? 30 : 10, height: 10)
            }
        }
    }
}

private struct OnboardingButton: View {
    let isLastPage: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isLastPage ? "Get Started" : "Continue")
                .font(.headline.bold())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeAccentYellow)
                .foregroundColor(.themeBackground)
                .clipShape(Capsule())
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
