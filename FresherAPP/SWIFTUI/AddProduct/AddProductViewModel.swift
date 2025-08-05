//
//  AddProductViewModel.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI
import Combine

enum AddMode: Int, CaseIterable, Identifiable {
    case auto, manual
    var id: Int { self.rawValue }
}

enum ImageSourceType {
    case camera, gallery
}

@MainActor
final class AddProductViewModel: ObservableObject {
    
    @Published var addMode: AddMode = .auto
    
    @Published var selectedImage: UIImage?
    @Published var productName: String = ""
    @Published var expirationDate: Date = Date()
    @Published var notes: String = ""
    
    @Published var isShowingImagePicker = false
    @Published var isShowingActionSheet = false
    @Published var imageSource: ImageSourceType = .gallery
    
    @Published var isScanning: Bool = false
    @Published var isSaved: Bool = false
    
    @Published var alertError: GeminiService.GeminiError?
    @Published var isShowingErrorAlert: Bool = false
    
    
    var isSaveButtonEnabled: Bool {
        selectedImage != nil && !productName.isEmpty
    }
    
    private let geminiService = GeminiService()
    
    func analyzeImage() {
        guard let image = selectedImage else { return }
        
        isScanning = true
        
        Task {
            let result = await geminiService.analyzeImage(image)
            
            isScanning = false
            
            switch result {
            case .success(let productInfo):
                handleSuccess(productInfo)
            case .failure(let error):
                handleError(error)
            }
        }
    }
    
    func saveProduct() {
        guard isSaveButtonEnabled else { return }
        
        StorageManager.shared.addProduct(
            name: productName,
            expirationDate: expirationDate,
            photoData: selectedImage?.jpegData(compressionQuality: 0.8),
            notes: notes.isEmpty ? nil : notes
        )
        
        let wasAddedByAI = (addMode == .auto)
            StorageManager.shared.incrementProductsAdded(fromAI: wasAddedByAI)
            AchievementManager.shared.trigger(event: .productAdded(fromAI: wasAddedByAI))
        
        isSaved = true
    }
    
    private func handleSuccess(_ info: ProductInfo) {
        self.productName = info.name
        if let date = info.expirationDate {
            self.expirationDate = date
        }
        self.notes = info.notes ?? ""
    }
    
    private func handleError(_ error: GeminiService.GeminiError) {
        self.alertError = error
        self.isShowingErrorAlert = true
    }
    
    func resetFields() {
        selectedImage = nil
        productName = ""
        expirationDate = Date()
        notes = ""
    }
}
