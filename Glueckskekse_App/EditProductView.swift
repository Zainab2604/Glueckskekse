import SwiftUI

struct EditProductView: View {
    let originalProduct: Product
    var onSave: (Product) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var productName: String
    @State private var productPrice: String

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

            TextField("Produktname", text: $productName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Preis in Euro", text: $productPrice)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Speichern") {
                // Neues Produkt mit aktualisierten Werten erstellen
                if let newPrice = Double(productPrice.replacingOccurrences(of: ",", with: ".")) {
                    let updatedProduct = Product(
                        id: originalProduct.id,
                        name: productName,
                        price: newPrice,
                        imageFilename: originalProduct.imageFilename
                    )
                    onSave(updatedProduct)
                }
                presentationMode.wrappedValue.dismiss()
            }

            Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .navigationTitle("Produkt bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
    }
}
