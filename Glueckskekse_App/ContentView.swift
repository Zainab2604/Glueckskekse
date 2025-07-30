//
//  ContentView.swift
//  Glueckskekse_App
//
//  Created by Zainab Mohamed Basheer on 21.12.24.
//

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

struct ContentView: View {
    @State private var path = NavigationPath()
    @StateObject private var productListVM = ProductListViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            StartScreen(path: $path)
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen {
                    case .start:
                        StartScreen(path: $path)
                    case .productList:
                        ProductListScreen(path: $path)
                    case .payment(let totalSum):
                        PaymentScreen(totalSum: totalSum, path: $path)
                    case .change(let totalSum, let paidAmount):
                        ChangeScreen(totalSum: totalSum, paidAmount: paidAmount, path: $path)
                    }
                }
        }
    }
}

struct StartScreen: View {
    @Binding var path: NavigationPath
    var body: some View {
        ZStack {
            Color.mint.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Spacer()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                Button(action: {
                    path.append(AppScreen.productList)
                }) {
                    Text("Start")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
        }
    }
}

struct ProductListScreen: View {
    @Binding var path: NavigationPath
    @State private var productCounts: [UUID: Int] = [:]
    @State private var products: [Product] = [
        Product(name: "Pfirsichmarmelade", price: 4.0, imageFilename: "Pfirsichmarmelade"),
        Product(name: "Aprikosenmarmelade", price: 4.0, imageFilename: "Aprikosenmarmelade"),
        Product(name: "Traubengelee", price: 3.5, imageFilename: "Traubengelee"),
        Product(name: "Bio-Orangenmarmelade", price: 3.5, imageFilename: "Bio-Orangenmarmelade"),
        Product(name: "Bio Chili-Olivenöl", price: 8.0, imageFilename: "Bio Chili-Olivenöl"),
        Product(name: "Bio-Bärlauch Rapsöl", price: 5.0, imageFilename: "Bio-Bärlauch Rapsöl"),
        Product(name: "Bio Zitronen Rapsöl", price: 5.0, imageFilename: "Bio Zitronen Rapsöl"),
        Product(name: "Himbeerbalsamico", price: 7.0, imageFilename: "Himbeerbalsamico"),
        Product(name: "Ingwer-Zitronensirup", price: 5.0, imageFilename: "Ingwer-Zitronen-Sirup"),
        Product(name: "Zitronenpfeffer in der Mühle", price: 5.5, imageFilename: "Zitronenpfeffer in der Mühle"),
        Product(name: "Chilisalz in der Mühle", price: 4.5, imageFilename: "Chilisalz in der Mühle"),
        Product(name: "Butterbrotsalz in der Mühle", price: 4.5, imageFilename: "Butterbrotsalz in der Mühle"),
        Product(name: "Zitronen-Rosmarinsalz im Streuer", price: 3.5, imageFilename: "Zitronen-Rosmarinsalz im Streuer"),
        Product(name: "Mediterranes Kräutersalz im Streuer", price: 3.5, imageFilename: "Mediterranes Kräutersalz im Streuer"),
        Product(name: "Sesamsalz Gomasio", price: 3.5, imageFilename: "Sesamsalz Gomasio")
    ]
    @State private var cafeProducts: [Product] = [
        Product(name: "Ein Stück Kuchen", price: 2.5, imageFilename: "Ein Stück Kuchen"),
        Product(name: "Eisbecher 'Glückskekse'🍨 🍀🍪", price: 4.5, imageFilename: "Eisbecher 'Glückskekse'"),
        Product(name: "Eisbecher 'Schokoglück'🍨 🍫🍀", price: 4.5, imageFilename: "Eisbecher 'Glückskekse'"),
        Product(name: "Eisbecher 'Glückliche Kirsche'🍨 🍒", price: 4.5, imageFilename: "Eisbecher 'Glückliche Kirsche'"),
        Product(name: "Eisbecher 'Gemischtes Glück'🍨 🍀", price: 4.0, imageFilename: "Eisbecher 'Glückskekse'"),
        Product(name: "Becher Kaffee", price: 2.0, imageFilename: "Becher Kaffee"),
        Product(name: "Heiße Schokolade", price: 2.5, imageFilename: "Heiße Schokolade"),
        Product(name: "Tee", price: 2.0, imageFilename: "Tee"),
        Product(name: "Sprudel", price: 1.5, imageFilename: "Sprudel"),
        Product(name: "Bio-Limo (Flasche)", price: 2.5, imageFilename: "Bio-Limo (Flasche)"),
        Product(name: "Zitrone-Ingwer-Limo (hausgemacht)", price: 2.0, imageFilename: "logo"),
        Product(name: "Karotte küsst Ingwersaft (mit Apfelsaft)", price: 3.5, imageFilename: "logo")
    ]
    @State private var isAddingProduct = false
    @State private var showAddProductSheet = false
    @State private var newProductName = ""
    @State private var newProductPrice = ""
    @State private var newProductCategory = 0 // 0 = Sortiment, 1 = Café
    @State private var newProductImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var customProducts: [Product] = []
    @State private var customCafeProducts: [Product] = []

    var totalSum: Double {
        let allProducts = products + customProducts + cafeProducts + customCafeProducts
        return allProducts.reduce(0) { sum, product in
            sum + (Double(productCounts[product.id] ?? 0) * product.price)
        }
    }

    // Hilfsfunktion, um productCounts an die Produktanzahl anzupassen
    private func updateProductCounts() {
        let allProducts = products + customProducts + cafeProducts + customCafeProducts
        for product in allProducts {
            if productCounts[product.id] == nil {
                productCounts[product.id] = 0
            }
        }
        // Entferne Zähler für gelöschte Produkte
        let allIDs = Set(allProducts.map { $0.id })
        productCounts = productCounts.filter { allIDs.contains($0.key) }
    }

    var body: some View {
        
        ZStack {
            // Hintergrundfarbe
            Color.mint
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                List {
                    Section(header: Text("Das Glückskekse-Sortiment").font(.headline)) {
                        ForEach(products + customProducts) { product in
                            productRow(for: product)
                        }
                    }
                    
                    Section(header: Text("Glückscafé 🍀☕️").font(.headline)) {
                        ForEach(cafeProducts + customCafeProducts) { product in
                            productRow(for: product)
                        }
                    }
                }
                
                Text("Gesamtsumme: \(String(format: "%.2f", totalSum)) €")
                    .font(.title)
                    .padding()
                
                NavigationLink(destination: PaymentScreen(totalSum: totalSum, path: $path)) {
                    Text("Weiter")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Essen und Trinken")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddProductSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                // Custom-Produkte laden
                if let data = UserDefaults.standard.data(forKey: "customProducts") {
                    if let decoded = try? JSONDecoder().decode([Product].self, from: data) {
                        customProducts = decoded
                    }
                }
                if let data = UserDefaults.standard.data(forKey: "customCafeProducts") {
                    if let decoded = try? JSONDecoder().decode([Product].self, from: data) {
                        customCafeProducts = decoded
                    }
                }
                updateProductCounts()
            }
            .sheet(isPresented: $showAddProductSheet) {
                VStack(spacing: 20) {
                    Text("Neues Produkt hinzufügen")
                        .font(.headline)
                    TextField("Produktname", text: $newProductName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    TextField("Preis in Euro", text: $newProductPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Picker("Kategorie", selection: $newProductCategory) {
                        Text("Glückskekse-Sortiment").tag(0)
                        Text("Glückscafé").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let image = newProductImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } else {
                            Text("Bild auswählen")
                                .foregroundColor(.blue)
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $newProductImage)
                    }
                    Button("Speichern") {
                        guard let price = Double(newProductPrice), let image = newProductImage else { return }
                        // Bild speichern
                        let filename = UUID().uuidString + ".jpg"
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
                            try? data.write(to: url)
                        }
                        // Produktmodell anlegen
                        let newProduct = Product(name: newProductName, price: price, imageFilename: filename)
                        if newProductCategory == 0 {
                            customProducts.append(newProduct)
                            if let encoded = try? JSONEncoder().encode(customProducts) {
                                UserDefaults.standard.set(encoded, forKey: "customProducts")
                            }
                        } else {
                            customCafeProducts.append(newProduct)
                            if let encoded = try? JSONEncoder().encode(customCafeProducts) {
                                UserDefaults.standard.set(encoded, forKey: "customCafeProducts")
                            }
                        }
                        updateProductCounts()
                        // Formular zurücksetzen
                        newProductName = ""
                        newProductPrice = ""
                        newProductImage = nil
                        newProductCategory = 0
                        showAddProductSheet = false
                    }
                    .disabled(newProductName.isEmpty || newProductPrice.isEmpty || newProductImage == nil)
                    Button("Abbrechen") {
                        showAddProductSheet = false
                    }
                }
                .padding()
            }
        }
    }

    private func productRow(for product: Product) -> some View {
        HStack {
            // Bildanzeige: erst Dokumentenverzeichnis prüfen, sonst Asset
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(product.imageFilename)
            if FileManager.default.fileExists(atPath: docURL.path), let uiImage = UIImage(contentsOfFile: docURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.trailing, 15)
            } else {
                Image(product.imageFilename)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.trailing, 15)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(String(format: "%.2f €", product.price))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            HStack(spacing: 10) {
                Button(action: {
                    decrementCount(for: product.id)
                }) {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                let count = productCounts[product.id] ?? 0
                Text("\(count)")
                    .frame(width: 40, alignment: .center)
                    .font(.headline)
                Button(action: {
                    incrementCount(for: product.id)
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 8)
    }

    private func incrementCount(for id: UUID) {
        productCounts[id, default: 0] += 1
    }

    private func decrementCount(for id: UUID) {
        if let current = productCounts[id], current > 0 {
            productCounts[id] = current - 1
        }
    }
}

struct PaymentScreen: View {
    let totalSum: Double
    @Binding var path: NavigationPath
    
    @State private var selectedAmounts: [Double] = []
    @State private var showAlert = false // Neu: Warnung bei zu wenig Geld
    @State private var navigateToNextScreen = false // Neu: Steuerung für Navigation
    
    let euroAmounts: [Double] = [
        0.10, 0.20, 0.50, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0
    ]
    
    let euroImages: [Double: String] = [
        0.10: "coin_10c",
        0.20: "coin_20c",
        0.50: "coin_50c",
        1.0: "coin_1e",
        2.0: "coin_2e",
        5.0: "note_5",
        10.0: "note_10",
        20.0: "note_20",
        50.0: "note_50"
    ]
    
    var totalSelectedSum: Double {
        selectedAmounts.reduce(0, +)
    }

    var body: some View {
        ZStack {
            Color.mint.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Wie viel hat der Kunde gezahlt?")
                    .font(.title2)
                    .padding()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(euroAmounts, id: \.self) { amount in
                            Button(action: {
                                selectedAmounts.append(amount)
                            }) {
                                if let imageName = euroImages[amount] {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 90, height: 80)
                                        .padding()
                                } else {
                                    Text(String(format: "%.2f €", amount))
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .center) {
                        Text("=")
                            .font(.headline)
                        
                        Text("\(String(format: "%.2f", totalSelectedSum)) €")
                            .font(.title)
                    }
                }
                .padding()
                
                VStack(alignment: .center) {
                    Text("Ausgewählt:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedAmounts.indices, id: \.self) { index in
                                Button(action: {
                                    selectedAmounts.remove(at: index)
                                }) {
                                    if let imageName = euroImages[selectedAmounts[index]] {
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 70)
                                            .padding(4)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                // EINZIGER "Weiter"-Button
                Button(action: {
                    if totalSelectedSum < totalSum {
                        showAlert = true  // Warnung anzeigen
                    } else {
                        navigateToNextScreen = true // Navigation aktivieren
                    }
                }) {
                    Text("Weiter")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Warnung"),
                        message: Text("Der gezahlte Betrag ist niedriger als der Gesamtbetrag!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .background(
                    NavigationLink("", destination: ChangeScreen(totalSum: totalSum, paidAmount: totalSelectedSum, path: $path), isActive: $navigateToNextScreen)
                        .opacity(0) // Unsichtbarer NavigationLink
                )
                
                Spacer()
            }
            .navigationTitle("Bezahlen")
        }
    }
}


struct ChangeScreen: View {
    let totalSum: Double
    let paidAmount: Double
    @Binding var path: NavigationPath
    
    let euroAmounts: [Double] = [
        50.0, 20.0, 10.0, 5.0, 2.0, 1.0, 0.50, 0.20, 0.10
    ]
    
    let euroImages: [Double: String] = [
        50.0: "note_50",
        20.0: "note_20",
        10.0: "note_10",
        5.0: "note_5",
        2.0: "coin_2e",
        1.0: "coin_1e",
        0.50: "coin_50c",
        0.20: "coin_20c",
        0.10: "coin_10c"
    ]
    
    var change: Double {
        max(0, paidAmount - totalSum)
    }
    
    var changeDetails: [(imageName: String, amount: Double, count: Int)] {
        var remainingChange = Int(round(change * 100)) // Umwandlung in Cent
        var details: [(String, Double, Int)] = []
        
        for amount in euroAmounts {
            let amountInCents = Int(round(amount * 100)) // Betrag auch in Cent umwandeln
            let count = remainingChange / amountInCents
            if count > 0, let imageName = euroImages[amount] {
                details.append((imageName, amount, count))
                remainingChange -= count * amountInCents // Korrektes Abziehen in Cent
            }
        }
        
        return details
    }

    
    var body: some View {
        ZStack {
            // Hintergrundfarbe
            Color.mint
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Du musst \(String(format: "%.2f", change)) € zurückgeben")
                    .font(.title)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(changeDetails, id: \.amount) { detail in
                            HStack {
                                // ScrollView für Bilder, zentriert
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        ForEach(0..<detail.count, id: \.self) { _ in
                                            Image(detail.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 140, height: 140)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center) // Bilder zentrieren
                                }
                                
                                // Text
                                Text("\(detail.count) × \(String(format: "%.2f", detail.amount)) €")
                                    .font(.headline)
                                    .frame(width:100, height: 100)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)  // Gesamte HStack zentrieren
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    
                    Button(action: {
                        path = NavigationPath() // Nächster Kunde: zurück zum Start
                    }) {
                        Text("Nächster Kunde")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        path = NavigationPath() // Beenden: zurück zum Start
                    }) {
                        Text("Beenden")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
            }
            .navigationTitle("Wechselgeld")
        }
    }

}

// MARK: - ImagePicker für SwiftUI
import PhotosUI
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
