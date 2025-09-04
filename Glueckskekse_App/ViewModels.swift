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
        do {
            let decoded = try JSONDecoder().decode([Product].self, from: data)
            self.products = decoded
        } catch {
            print("Fehler beim Laden der Produkte: \(error)")
        }
    }
    
    func saveProducts() {
        do {
            let encoded = try JSONEncoder().encode(products)
            UserDefaults.standard.set(encoded, forKey: productsKey)
        } catch {
            print("Fehler beim Speichern der Produkte: \(error)")
        }
    }
    
    // Hilfsfunktion zum Bildpfad
    static func imageURL(for filename: String) -> URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
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
