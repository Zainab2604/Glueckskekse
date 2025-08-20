import SwiftUI

// Enum für die Navigationsziele
enum AppScreen: Hashable {
    case start
    case productList
    case payment(totalSum: Double)
    case change(totalSum: Double, paidAmount: Double)
}

// MARK: - Product Model
struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Double
    var imageFilename: String // Dateiname des gespeicherten Bildes
    
    init(id: UUID = UUID(), name: String, price: Double, imageFilename: String) {
        self.id = id
        self.name = name
        self.price = price
        self.imageFilename = imageFilename
    }
}
