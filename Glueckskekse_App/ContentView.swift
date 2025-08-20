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

// MARK: - OrderSessionViewModel für Kundensession
class OrderSessionViewModel: ObservableObject {
    @Published var productCounts: [UUID: Int] = [:]
    func resetCounts() {
        productCounts = [:]
    }
}

struct ContentView: View {
    @AppStorage("isParent") var isParent: Bool = false
    @State private var path = NavigationPath()
    @StateObject private var productListVM = ProductListViewModel()
    @StateObject private var orderSession = OrderSessionViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            StartScreen(path: $path)
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen {
                    case .start:
                        StartScreen(path: $path)
                    case .productList:
                        ProductListScreen(path: $path, orderSession: orderSession)
                    case .payment(let totalSum):
                        PaymentScreen(totalSum: totalSum, path: $path, orderSession: orderSession)
                    case .change(let totalSum, let paidAmount):
                        ChangeScreen(totalSum: totalSum, paidAmount: paidAmount, path: $path, orderSession: orderSession)
                    }
                }
        }
    }
}

struct StartScreen: View {
    @Binding var path: NavigationPath

    @AppStorage("isParent") var isParent: Bool = false
    @State private var parentCodeInput = ""
    let parentCode = "2839" //  Eltern-Code

    var body: some View {
        ZStack {
            Color.mint.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)


                // Eltern-Login-Bereich
                VStack(spacing: 10) {
                    Text("Elternbereich").bold().foregroundColor(.black)
                    SecureField("Eltern-Code", text: $parentCodeInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                    Button("Einloggen") {
                        if parentCodeInput == parentCode {
                            isParent = true
                            parentCodeInput = ""
                        }
                    }
                }

                if isParent {
                    Text("👨‍👩‍👧 Elternrechte aktiv").foregroundColor(.green)
                }
                    
                if isParent {
                    Button("Elternrechte verlassen") {
                        isParent = false
                        parentCodeInput = ""
                    }
                    .foregroundColor(.red)
                }


            Button(action: {
                path.append(AppScreen.productList)
            }) {
                Text("Start 🛍️")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .frame(width: 170, height: 100)
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }

          
            }

        }

        
    }
}

struct ProductListScreen: View {

    @AppStorage("isParent") var isParent: Bool = false


    @State private var editingProduct: Product? = nil
    @State private var showDeleteAlert = false
    @State private var productToDelete: Product? = nil


    @Binding var path: NavigationPath
    @ObservedObject var orderSession: OrderSessionViewModel
    @State private var products: [Product] = [
        
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
            sum + (Double(orderSession.productCounts[product.id] ?? 0) * product.price)
        }
    }

    // Hilfsfunktion, um productCounts an die Produktanzahl anzupassen
    private func updateProductCounts() {
        let allProducts = products + customProducts + cafeProducts + customCafeProducts
        for product in allProducts {
            if orderSession.productCounts[product.id] == nil {
                orderSession.productCounts[product.id] = 0
            }
        }
        // Entferne Zähler für gelöschte Produkte
        let allIDs = Set(allProducts.map { $0.id })
        orderSession.productCounts = orderSession.productCounts.filter { allIDs.contains($0.key) }
    }

    var body: some View {
        
        ZStack {
            // Hintergrundfarbe
            Color.mint
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                List {
                    Section(header: Text("Das Glückskekse-Sortiment").font(.headline)) {
                        ForEach(Array((products + customProducts).enumerated()), id: \.element.id) { index, product in
                            productRow(for: product)
                        }
                        .onMove { indices, newOffset in
                            if isParent {
                                moveProducts(in: &products, custom: &customProducts, indices: indices, newOffset: newOffset)
                            }
                        }
                        .moveDisabled(!isParent)

                    }
                    
                    Section(header: Text("Glückscafé 🍀☕️").font(.headline)) {
                        ForEach(cafeProducts + customCafeProducts) { product in
                            productRow(for: product)
                        }
                    }
                }
                .environment(\.editMode, .constant(.inactive))
                
                Text("Gesamtsumme: \(String(format: "%.2f", totalSum)) €")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                
                NavigationLink(destination: PaymentScreen(totalSum: totalSum, path: $path, orderSession: orderSession)) {
                    Text("Weiter")
                        .padding()
                        .font(.largeTitle)
                        .bold()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Essen und Trinken")
            .toolbar {
                if isParent {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddProductSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
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
        

        .alert("Produkt löschen", isPresented: $showDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                if let product = productToDelete {
                    deleteProduct(product)
                    productToDelete = nil
                }
            }
        } message: {
            if let product = productToDelete {
                Text("Möchten Sie das Produkt \"\(product.name)\" wirklich löschen?")
            }
        }

    }

    private func updateProduct(_ updated: Product) {
        if let index = products.firstIndex(where: { $0.id == updated.id }) {
            products[index] = updated
        } else if let index = customProducts.firstIndex(where: { $0.id == updated.id }) {
            customProducts[index] = updated
            if let encoded = try? JSONEncoder().encode(customProducts) {
                UserDefaults.standard.set(encoded, forKey: "customProducts")
            }
        } else if let index = cafeProducts.firstIndex(where: { $0.id == updated.id }) {
            cafeProducts[index] = updated
        } else if let index = customCafeProducts.firstIndex(where: { $0.id == updated.id }) {
            customCafeProducts[index] = updated
            if let encoded = try? JSONEncoder().encode(customCafeProducts) {
                UserDefaults.standard.set(encoded, forKey: "customCafeProducts")
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
                    .frame(width: 200, height: 200)
                    .padding(.trailing, 15)
            } else {
                Image(product.imageFilename)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.trailing, 15)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Text(String(format: "%.2f €", product.price))
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            HStack(spacing: 10) {

                if isParent {
                NavigationLink(destination: EditProductView(
                    product: product
                ) { updatedProduct in
                    updateProduct(updatedProduct)
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                }
                Button(action: {
                    incrementCount(for: product.id)
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                }
                .buttonStyle(BorderlessButtonStyle())
                let count = orderSession.productCounts[product.id] ?? 0
                Text("\(count)")
                    .frame(width: 60, alignment: .center)
                    .font(.headline)
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
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if isParent {
                Button(role: .destructive) {
                    productToDelete = product
                    showDeleteAlert = true
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            }
        }
    }

    private func incrementCount(for id: UUID) {
        orderSession.productCounts[id, default: 0] += 1
    }

    private func decrementCount(for id: UUID) {
        if let current = orderSession.productCounts[id], current > 0 {
            orderSession.productCounts[id] = current - 1
        }
    }

    private func moveProducts(in original: inout [Product], custom: inout [Product], indices: IndexSet, newOffset: Int) {
        // Zusammenfügen + verschieben
        var combined = original + custom
        combined.move(fromOffsets: indices, toOffset: newOffset)

        // Neu aufteilen
        original = Array(combined.prefix(original.count))
        custom = Array(combined.dropFirst(original.count))

        // Custom speichern
        if let encoded = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(encoded, forKey: "customProducts")
        }
    }
    
    private func deleteProduct(_ product: Product) {
        // Produkt aus der entsprechenden Liste entfernen
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products.remove(at: index)
        } else if let index = customProducts.firstIndex(where: { $0.id == product.id }) {
            customProducts.remove(at: index)
            if let encoded = try? JSONEncoder().encode(customProducts) {
                UserDefaults.standard.set(encoded, forKey: "customProducts")
            }
        } else if let index = cafeProducts.firstIndex(where: { $0.id == product.id }) {
            cafeProducts.remove(at: index)
        } else if let index = customCafeProducts.firstIndex(where: { $0.id == product.id }) {
            customCafeProducts.remove(at: index)
            if let encoded = try? JSONEncoder().encode(customCafeProducts) {
                UserDefaults.standard.set(encoded, forKey: "customCafeProducts")
            }
        }
        
        // Zähler für das gelöschte Produkt entfernen
        orderSession.productCounts.removeValue(forKey: product.id)
        
        // Bilddatei löschen, falls es eine benutzerdefinierte Datei ist
        let filename = product.imageFilename
        if !filename.isEmpty {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imageURL = documentsURL.appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: imageURL)
        }
    }


    
}

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





struct PaymentScreen: View {
    let totalSum: Double
    @Binding var path: NavigationPath
    @ObservedObject var orderSession: OrderSessionViewModel
    
    @State private var selectedAmounts: [Double] = []
    @State private var showAlert = false // Warnung bei zu wenig Geld
    @State private var navigateToNextScreen = false // Steuerung für Navigation
    
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

    var coinAmounts: [Double] {
        euroAmounts.filter { $0 < 5.0 }
    }

    var noteAmounts: [Double] {
        euroAmounts.filter { $0 >= 5.0 }
    }
    
    var totalSelectedSum: Double {
        selectedAmounts.reduce(0, +)
    }

    var body: some View {
        ZStack {
            Color.mint.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Wie viel hat der Kunde gezahlt?")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding()
                
                /*ScrollView(.horizontal) {
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
                }*/

                VStack(spacing: 20) {

                    // Münzen
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(coinAmounts, id: \.self) { amount in
                                paymentButton(for: amount)
                            }
                        }
                    }

                    //Scheine
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(noteAmounts, id: \.self) { amount in
                                paymentButton(for: amount)
                            }
                        }
                    }
                }
                
                
                HStack {
                    VStack(alignment: .center) {
                        Text("=")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                        
                        Text("\(String(format: "%.2f", totalSelectedSum)) €")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                
                VStack(alignment: .center) {
                    Text("Ausgewählt:")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        
                    
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
                                            .frame(width: 150, height: 70)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                // "Weiter"-Button
                Button(action: {
                    if totalSelectedSum < totalSum {
                        showAlert = true  // Warnung anzeigen
                    } else {
                        navigateToNextScreen = true // Navigation aktivieren
                    }
                }) {
                    Text("Weiter")
                        .padding()
                        .font(.largeTitle)
                        .bold()
                        .background(Color.green)
                        .foregroundColor(.black)
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
                    NavigationLink("", destination: ChangeScreen(totalSum: totalSum, paidAmount: totalSelectedSum, path: $path, orderSession: orderSession), isActive: $navigateToNextScreen)
                        .opacity(0) // Unsichtbarer NavigationLink
                )
                
                Spacer()
            }
            .navigationTitle("Bezahlen")
        }
    }

    @ViewBuilder
    private func paymentButton(for amount: Double) -> some View {
        Button(action: {
            selectedAmounts.append(amount)
        }) {
            if let imageName = euroImages[amount] {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 140)
                    
            } else {
                Text(String(format: "%.2f €", amount))
                    
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
        }
    }
}


struct ChangeScreen: View {
    let totalSum: Double
    let paidAmount: Double
    @Binding var path: NavigationPath
    @ObservedObject var orderSession: OrderSessionViewModel
    @State private var shouldNavigateToProductList = false
    
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
                    .font(.largeTitle)
                    .foregroundColor(.black)
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
                                    .font(.title)
                                    .frame(width:150, height: 150)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.black)
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
                        orderSession.resetCounts()
                        shouldNavigateToProductList = true
                    }) {
                        Text("Nächster Kunde")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.black)
                            .bold()
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        orderSession.resetCounts() // Zähler zurücksetzen
                        path = NavigationPath() // Beenden: zurück zum Start
                    }) {
                        Text("Beenden")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.black)
                            .bold()
                            .cornerRadius(10)
                    }
                }
                .padding()
                
            }
            .navigationTitle("Wechselgeld")
            
            // NavigationLink für Produktliste
            NavigationLink(
                destination: ProductListScreen(path: $path, orderSession: orderSession),
                isActive: $shouldNavigateToProductList
            ) {
                EmptyView()
            }
            .opacity(0)
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
