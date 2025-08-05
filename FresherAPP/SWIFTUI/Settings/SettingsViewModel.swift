//
//  SettingsViewModel.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//
import Foundation
import SwiftUI
import StoreKit

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var isShowingResetAlert = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func contactUs() {
        let email = "support@yourappdomain.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func shareApp() {
        guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") else { return }
        let text = "Check out this app for managing food expiration dates!"
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        let allScenes = UIApplication.shared.connectedScenes
        if let scene = allScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func deleteAllData() {
        StorageManager.shared.deleteAllData()
    }
}
