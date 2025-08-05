//
//  AddProductView.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import SwiftUI


struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView { presentationMode.wrappedValue.dismiss() }
                
                Picker("Add Mode", selection: $viewModel.addMode.animation()) {
                    Text("Auto (AI Scan)").tag(AddMode.auto)
                    Text("Manual").tag(AddMode.manual)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ImageSelectionView(selectedImage: $viewModel.selectedImage) {
                                               viewModel.isShowingActionSheet = true
                                           }
                        
                        if viewModel.addMode == .auto && viewModel.selectedImage == nil {
                            Text("Just add a photo of the product, click the button and let the magic happen.")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                        }
                        
                        
                        if viewModel.addMode == .auto && viewModel.selectedImage != nil {
                            scanButton()
                        }
                        
                        if viewModel.addMode == .manual || !viewModel.productName.isEmpty {
                            manualInputFields()
                        }
                    }
                    .padding(.horizontal)
                }
                
                if viewModel.addMode == .manual || !viewModel.productName.isEmpty {
                    saveButton()
                }
            }
            
            if viewModel.isSaved {
                CustomSuccessAlert(onDismiss: {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .actionSheet(isPresented: $viewModel.isShowingActionSheet) {
                   ActionSheet(
                       title: Text("Select Image"),
                       buttons: [
                           .default(Text("Camera")) {
                               viewModel.imageSource = .camera
                               viewModel.isShowingImagePicker = true
                           },
                           .default(Text("Photo Library")) {
                               viewModel.imageSource = .gallery
                               viewModel.isShowingImagePicker = true
                           },
                           .cancel()
                       ]
                   )
               }
               .sheet(isPresented: $viewModel.isShowingImagePicker) {
                   ImagePicker(
                       selectedImage: $viewModel.selectedImage,
                       sourceType: viewModel.imageSource == .camera ? .camera : .photoLibrary
                   )
               }
        .alert(isPresented: $viewModel.isShowingErrorAlert) {
            Alert(
                title: Text("Analysis Failed"),
                message: Text(viewModel.alertError?.localizedDescription ?? "An unknown error occurred."),
                primaryButton: .default(Text("Try Again"), action: {
                    viewModel.analyzeImage()
                }),
                secondaryButton: .default(Text("Enter Manually"), action: {
                    viewModel.addMode = .manual
                })
            )
        }
    }
    
    @ViewBuilder
    private func scanButton() -> some View {
        Button(action: viewModel.analyzeImage) {
            HStack {
                if viewModel.isScanning {
                    ProgressView()
                        .applyTint(.themeBackground)
                    Text("Scanning...")
                } else {
                    Image(systemName: "sparkles")
                    Text("Scan Product")
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.isScanning)
    }
    
    @ViewBuilder
    private func manualInputFields() -> some View {
        VStack(spacing: 16) {
            TitledTextField(title: "Product Name", text: $viewModel.productName)
            TitledDatePicker(title: "Expiration Date", selection: $viewModel.expirationDate)
            TitledTextEditor(title: "Notes", text: $viewModel.notes)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    @ViewBuilder
    private func saveButton() -> some View {
        Button("Save", action: viewModel.saveProduct)
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isSaveButtonEnabled)
            .opacity(viewModel.isSaveButtonEnabled ? 1 : 0.5)
            .padding()
    }
}


private struct TitledTextEditor: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline).foregroundColor(.themePrimaryText)
            TextEditor(text: $text)
                .hideScrollContentBackground()
                .padding(8)
                .frame(minHeight: 100)
                .background(Color.themeCardBackground)
                .cornerRadius(12)
                .foregroundColor(.themePrimaryText)
        }
    }
}

// Остальной код AddProductView (HeaderView, ImageSelectionView, и т.д.) остается без изменений
// ...


private struct HeaderView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text("Add Product")
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

private struct ImageSelectionView: View {
    @Binding var selectedImage: UIImage?
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.themeCardBackground
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                        Text("Add Photo")
                            .font(.headline)
                    }
                    .foregroundColor(.themeSecondaryText)
                }
            }
            .frame(height: 200)
            .cornerRadius(20)
        }
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
                .background(Color.themeCardBackground)
                .cornerRadius(12)
                .foregroundColor(.themePrimaryText)
        }
    }
}

private struct TitledDatePicker: View {
    let title: String
    @Binding var selection: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline).foregroundColor(.themePrimaryText)
            DatePicker("", selection: $selection, displayedComponents: .date)
                .labelsHidden()
                .frame(width: size().width - 40, alignment: .leading)
                .padding(8)
                .background(Color.themeCardBackground)
                .cornerRadius(12)
                .colorScheme(.dark)
                .accentColor(.themeAccentYellow)
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

private struct CustomSuccessAlert: View {
    let onDismiss: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.themeAccentGreen)
                
                Text("Product Added!")
                    .font(.title2).bold()
                
                Text("Your product has been successfully saved to your list.")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .background(Color.themeCardBackground)
            .cornerRadius(20)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    onDismiss()
                }
            }
        }
    }
}

#Preview {
    AddProductView()
}
