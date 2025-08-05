//
//  AllProductsView.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI
import RealmSwift

struct AllProductsView: View {
    @StateObject private var viewModel: AllProductsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    init(filter: ProductFilter) {
        _viewModel = StateObject(wrappedValue: AllProductsViewModel(initialFilter: filter))
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView { presentationMode.wrappedValue.dismiss() }
                
                CustomSegmentedControl(
                    selectedFilter: $viewModel.currentFilter,
                    onSelect: viewModel.filterProducts
                )
                
                if viewModel.products.isEmpty {
                    EmptyStateView() {
                        viewModel.isAddProductViewPresented = true
                    }

                } else {
                    productGrid()
                }
            }
            
            if viewModel.isDetailViewPresented, let productID = viewModel.selectedProductID {
                ProductDetailOverlayView(
                    viewModel: viewModel,
                    productID: productID
                )
                .frame(width: size().width - 60)
            }
        }
        .sheet(isPresented: $viewModel.isAddProductViewPresented) {
            AddProductView()
        }
    }
    
    @ViewBuilder
    private func productGrid() -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.products) { product in
                        ProductCell(product: product)
                            .onTapGesture {
                                viewModel.selectProduct(product)
                            }
                    }
                }
                .padding()
            }
            
            FloatingActionButton { viewModel.isAddProductViewPresented = true }
        }
    }
}


private struct ProductDetailOverlayView: View {
    @ObservedObject var viewModel: AllProductsViewModel
    @ObservedRealmObject var product: ProductObject
    
    @State private var isAnimating = false
    
    init(viewModel: AllProductsViewModel, productID: ObjectId) {
        self.viewModel = viewModel
        _product = ObservedRealmObject(wrappedValue: try! Realm().object(ofType: ProductObject.self, forPrimaryKey: productID)!)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { viewModel.isDetailViewPresented = false }
            
            VStack(spacing: 20) {
                if let data = product.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size().width - 40, height: 200)
                        .cornerRadius(20)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(product.name)
                        .font(.largeTitle).bold()
                    
                    Label("Expires on: \(product.expirationDate.formattedLong())", systemImage: "calendar.badge.exclamationmark")
                    
                    ScrollView {
                        Text(product.notes ?? "No additional notes.")
                            .font(.body)
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                
                Button(action: {
                    withAnimation {
                        viewModel.prepareToDeleteSelectedProduct()
                    }
                }) {
                    Label("Delete Product", systemImage: "trash.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(15)
                }
            }
            .padding()
            .background(Color.themeCardBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.isDetailViewPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title).foregroundColor(.themeSecondaryText)
                    }
                }
                Spacer()
            }
            .padding(50)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}


private struct ProductCell: View {
    @ObservedRealmObject var product: ProductObject
    
    var body: some View {
        VStack(alignment: .leading) {
            if let data = product.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 170, height: 100)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.themeBackground)
                    .frame(height: 100)
                    .overlay(Image(systemName: "photo").foregroundColor(.themeSecondaryText))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
                    .lineLimit(1)
                
                Label(product.expirationDate.formattedCompact(), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
            }
            .padding(8)
        }
        .background(Color.themeCardBackground)
        .cornerRadius(20)
    }
}



private struct HeaderView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text("All Products")
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

private struct CustomSegmentedControl: View {
    @Binding var selectedFilter: ProductFilter
    let onSelect: (ProductFilter) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            SegmentButton(title: "All", filter: .all, selectedFilter: $selectedFilter, action: onSelect)
            SegmentButton(title: "About To Spoil", filter: .aboutToSpoil, selectedFilter: $selectedFilter, action: onSelect)
            SegmentButton(title: "Spoiled", filter: .spoiled, selectedFilter: $selectedFilter, action: onSelect)
        }
        .padding(.horizontal)
    }
}

private struct SegmentButton: View {
    let title: String
    let filter: ProductFilter
    @Binding var selectedFilter: ProductFilter
    let action: (ProductFilter) -> Void
    
    var isSelected: Bool {
        filter == selectedFilter
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                action(filter)
            }
        }) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.themeCardBackground : Color.clear)
                .foregroundColor(isSelected ? .themeAccentYellow : .themeSecondaryText)
                .clipShape(Capsule())
        }
    }
}


private struct EmptyStateView: View {
    
    var completion: () -> ()
    
    var body: some View {
        Spacer()
        VStack(spacing: 12) {
            Image(systemName: "archivebox.fill")
                .font(.system(size: 50))
                .foregroundColor(.themeSecondaryText)
            Text("No Products Here")
                .font(.title3).bold()
                .foregroundColor(.themePrimaryText)
            Text("Add a product to get started!")
                .foregroundColor(.themeSecondaryText)
            
            Button {
                completion()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: 150, height: 60)
                        .foregroundColor(.themeAccentYellow)
                    Text("Add Product")
                        .foregroundColor(.black)
                }
            }
            .padding(.top)
        }
        Spacer()
        
    }
}

private struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title.bold())
                .foregroundColor(.themeBackground)
                .padding()
                .background(Color.themeAccentYellow)
                .clipShape(Circle())
                .shadow(radius: 10)
        }
        .padding()
    }
}

#Preview {
    AllProductsView(filter: ProductFilter.all)
}
