import SwiftUI
import Photos

struct EditCategoryView: View {
    let originalCategory: Category
    var onSave: (Category) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var categoryName: String
    @State private var categoryImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var hasImageChanged = false
    @State private var showPhotoPermissionAlert = false
    
    init(category: Category, onSave: @escaping (Category) -> Void) {
        self.originalCategory = category
        self.onSave = onSave
        self._categoryName = State(initialValue: category.name)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Kategorie bearbeiten")
                    .font(.headline)
                
                // Aktuelles Bild anzeigen
                VStack {
                    Text("Aktuelles Bild:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Bildanzeige: erst Dokumentenverzeichnis prüfen, sonst Asset
                    if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let docURL = documentsURL.appendingPathComponent(originalCategory.imageFilename)
                        if FileManager.default.fileExists(atPath: docURL.path), let uiImage = UIImage(contentsOfFile: docURL.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        } else {
                            Image(originalCategory.imageFilename)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                    }
                    
                    TextField("Kategoriename", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Bild ändern Button
                    Button(action: {
                        checkPhotoPermissionAndShowPicker()
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Bild ändern")
                        }
                        .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $categoryImage)
                    }
                    
                    // Vorschau des neuen Bildes
                    if let newImage = categoryImage {
                        VStack {
                            Text("Neues Bild:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Image(uiImage: newImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                        .onAppear {
                            hasImageChanged = true
                        }
                    }
                    
                    Button("Speichern") {
                        var updatedImageFilename = originalCategory.imageFilename
                        
                        // Wenn ein neues Bild ausgewählt wurde, speichere es
                        if hasImageChanged, let newImage = categoryImage {
                            let filename = UUID().uuidString + ".jpg"
                            if let data = newImage.jpegData(compressionQuality: 0.8),
                               let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                let url = documentsURL.appendingPathComponent(filename)
                                do {
                                    try data.write(to: url)
                                    updatedImageFilename = filename
                                } catch {
                                    print("Fehler beim Speichern des neuen Bildes: \(error)")
                                }
                            }
                        }
                        
                        let updatedCategory = Category(
                            id: originalCategory.id,
                            name: categoryName,
                            imageFilename: updatedImageFilename
                        )
                        onSave(updatedCategory)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(categoryName.isEmpty)
                    
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
            }
            .navigationTitle("Kategorie bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Foto-Zugriff", isPresented: $showPhotoPermissionAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Einstellungen öffnen") {
                openAppSettings()
            }
        } message: {
            Text("Um Kategoriebilder hinzuzufügen, benötigt die App Zugriff auf Ihre Fotos. Bitte gewähren Sie den Zugriff in den Einstellungen.")
        }
    }
    
    private func checkPhotoPermissionAndShowPicker() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            showImagePicker = true
        case .denied, .restricted:
            showPhotoPermissionAlert = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showImagePicker = true
                    } else {
                        showPhotoPermissionAlert = true
                    }
                }
            }
        @unknown default:
            showPhotoPermissionAlert = true
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}
