//
//  SettingsView.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView { presentationMode.wrappedValue.dismiss() }
                
                List {
                    Section(header: Text("General").foregroundColor(.themeSecondaryText)) {
                        SettingsNavigationRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            action: viewModel.openAppSettings
                        )
                    }
                    .listRowBackground(Color.themeCardBackground)
                    
                    Section(header: Text("Feedback").foregroundColor(.themeSecondaryText)) {
                        SettingsNavigationRow(icon: "envelope.fill", title: "Contact Us", action: viewModel.contactUs)
                        SettingsNavigationRow(icon: "star.fill", title: "Rate the App", action: viewModel.rateApp)
                        SettingsNavigationRow(icon: "square.and.arrow.up.fill", title: "Share The App", action: viewModel.shareApp)
                    }
                    .listRowBackground(Color.themeCardBackground)
                    
                    Section(header: Text("Data").foregroundColor(.themeSecondaryText)) {
                        SettingsNavigationRow(icon: "trash.fill", title: "Delete All Data", isDestructive: true) {
                            viewModel.isShowingResetAlert = true
                        }
                    }
                    .listRowBackground(Color.themeCardBackground)
                }
                .hideScrollContentBackground()
                .listStyle(InsetGroupedListStyle())
                
                Text("Version \(viewModel.appVersion)")
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
                    .padding()
            }
        }
        .alert(isPresented: $viewModel.isShowingResetAlert) {
            Alert(
                title: Text("Delete All Data"),
                message: Text("Are you sure you want to permanently delete all products, lists, and achievements? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete"), action: viewModel.deleteAllData),
                secondaryButton: .cancel()
            )
        }
    }
}


private struct HeaderView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text("Settings")
                .font(.largeTitle).bold().foregroundColor(.themePrimaryText)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title).foregroundColor(.themeSecondaryText)
            }
        }
        .padding()
    }
}

private struct SettingsNavigationRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .foregroundColor(.themeSecondaryText)
            }
        }
        .foregroundColor(isDestructive ? .red : .themePrimaryText)
    }
}


#Preview {
    SettingsView()
}
