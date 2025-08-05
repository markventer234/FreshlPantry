//
//  ShoppingListView.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI
import RealmSwift

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView(
                    onDismiss: { presentationMode.wrappedValue.dismiss() },
                    onClear: { viewModel.isClearListAlertPresented = true }
                )
                
                if viewModel.items.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            ShoppingListItemCell(item: item) {
                                viewModel.toggleItemCompletion(item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .listRowBackground(Color.themeCardBackground)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Button("Add Item") {
                    viewModel.isAddItemViewPresented = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
            
            if viewModel.isAddItemViewPresented {
                AddItemOverlayView(isPresented: $viewModel.isAddItemViewPresented)
            }
        }
        .alert(isPresented: $viewModel.isClearListAlertPresented) {
            Alert(
                title: Text("Clear Shopping List"),
                message: Text("Are you sure you want to delete all items from your shopping list?"),
                primaryButton: .destructive(Text("Clear All"), action: viewModel.clearList),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { viewModel.items[$0] }
        itemsToDelete.forEach { item in
            StorageManager.shared.deleteShoppingItem(withId: item._id) // Предполагаем, что этот метод есть
        }
    }
}


private struct HeaderView: View {
    let onDismiss: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        HStack {
            Text("Shopping List")
                .font(.largeTitle).bold().foregroundColor(.themePrimaryText)
            
            Spacer()
            
            Button(action: onClear) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.themeSecondaryText)
            }
            .padding(.trailing, 20)
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title).foregroundColor(.themeSecondaryText)
            }
        }
        .padding()
    }
}

private struct ShoppingListItemCell: View {
    @ObservedRealmObject var item: ShoppingListItemObject
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .themeAccentGreen : .themeSecondaryText)
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(item.isCompleted ? .themeSecondaryText : .themePrimaryText)
                    .strikethrough(item.isCompleted, color: .themeSecondaryText)
                
                Text("Qty: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        Spacer()
        VStack(spacing: 12) {
            Image(systemName: "cart.fill")
                .font(.system(size: 50))
                .foregroundColor(.themeSecondaryText)
            Text("Shopping List is Empty")
                .font(.title3).bold()
                .foregroundColor(.themePrimaryText)
            Text("Tap 'Add Item' to start building your list.")
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        Spacer()
    }
}

private struct AddItemOverlayView: View {
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var quantity: String = "1"
    @State private var isAnimating = false
    
    var isSaveEnabled: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text("Add New Item").font(.title2).bold()
                
                TitledTextField(title: "Item Name", text: $name)
                TitledTextField(title: "Quantity", text: $quantity)
                
                HStack {
                    Button("Cancel") { isPresented = false }
                        .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Save") {
                        StorageManager.shared.addShoppingItem(name: name, quantity: quantity)
                        isPresented = false
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!isSaveEnabled)
                    .opacity(isSaveEnabled ? 1 : 0.5)
                }
            }
            .padding(30)
            .background(Color.themeCardBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(40)
            .foregroundColor(.themePrimaryText)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}


private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.themeAccentYellow)
            .foregroundColor(.themeBackground)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.themeSecondaryText.opacity(0.2))
            .foregroundColor(.themePrimaryText)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

private struct TitledTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline).foregroundColor(.themePrimaryText)
            TextField("", text: $text)
                .padding(12)
                .background(Color.themeBackground)
                .cornerRadius(12)
                .foregroundColor(.themePrimaryText)
        }
    }
}


#Preview {
    ShoppingListView()
}
