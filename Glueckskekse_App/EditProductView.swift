import SwiftUI

struct EditProductView: View {
    let originalProduct: Product
    var onSave: (Product) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var productName: String
    @State private var productPrice: String
    @State private var productImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var hasImageChanged = false

    init(product: Product, onSave: @escaping (Product) -> Void) {
        self.originalProduct = product
        self.onSave = onSave
        // Werte direkt beim Initialisieren setzen
        self._productName = State(initialValue: product.name)
        self._productPrice = State(initialValue: String(format: "%.2f", product.price))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Produkt bearbeiten")
                .font(.headline)

            // Aktuelles Bild anzeigen
            VStack {
                Text("Aktuelles Bild:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Bildanzeige: erst Dokumentenverzeichnis prüfen, sonst Asset
                let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(originalProduct.imageFilename)
                if FileManager.default.fileExists(atPath: docURL.path), let uiImage = UIImage(contentsOfFile: docURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(8)
                } else {
                    Image(originalProduct.imageFilename)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(8)
                }
            }

            TextField("Produktname", text: $productName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Preis in Euro", text: $productPrice)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Bild ändern Button
            Button(action: {
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo")
                    Text("Bild ändern")
                }
                .foregroundColor(.blue)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $productImage)
            }

            // Vorschau des neuen Bildes
            if let newImage = productImage {
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
                // Neues Produkt mit aktualisierten Werten erstellen
                if let newPrice = Double(productPrice.replacingOccurrences(of: ",", with: ".")) {
                    var updatedImageFilename = originalProduct.imageFilename
                    
                    // Wenn ein neues Bild ausgewählt wurde, speichere es
                    if hasImageChanged, let newImage = productImage {
                        let filename = UUID().uuidString + ".jpg"
                        if let data = newImage.jpegData(compressionQuality: 0.8) {
                            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
                            try? data.write(to: url)
                            updatedImageFilename = filename
                        }
                    }
                    
                    let updatedProduct = Product(
                        id: originalProduct.id,
                        name: productName,
                        price: newPrice,
                        imageFilename: updatedImageFilename
                    )
                    onSave(updatedProduct)
                }
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(productName.isEmpty || productPrice.isEmpty)

            Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .navigationTitle("Produkt bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
    }
}
