import SwiftUI

// MARK: - ProductListViewModel
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    private let productsKey = "products_key"
    
    init() {
        loadProducts()
    }
    
    func addProduct(_ product: Product) {
        products.append(product)
        saveProducts()
    }
    
    func loadProducts() {
        guard let data = UserDefaults.standard.data(forKey: productsKey) else { return }
        if let decoded = try? JSONDecoder().decode([Product].self, from: data) {
            self.products = decoded
        }
    }
    
    func saveProducts() {
        if let encoded = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(encoded, forKey: productsKey)
        }
    }
    
    // Hilfsfunktion zum Bildpfad
    static func imageURL(for filename: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(filename)
    }
}

// MARK: - OrderSessionViewModel für Kundensession
class OrderSessionViewModel: ObservableObject {
    @Published var productCounts: [UUID: Int] = [:]
    
    func resetCounts() {
        productCounts = [:]
    }
}
