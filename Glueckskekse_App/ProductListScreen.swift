import SwiftUI

struct ProductListScreen: View {
    @AppStorage("isParent") var isParent: Bool = false

    //@State private var editingProduct: Product? = nil
    @State private var showDeleteAlert = false
    @State private var productToDelete: Product? = nil
    @State private var showDeactivateAlert = false
    @State private var productToDeactivate: Product? = nil
    @State private var showDeactivatedProducts = false // Für einklappbare Liste
    @State private var editingProduct: Product? = nil

    @Binding var path: NavigationPath
    @ObservedObject var orderSession: OrderSessionViewModel
    @State private var products: [Product] = []
    @State private var cafeProducts: [Product] = [
//        Product(name: "Ein Stück Kuchen", price: 2.5, imageFilename: "Ein Stück Kuchen"),
//        Product(name: "Eisbecher 'Glückskekse'🍨 🍀🍪", price: 4.5, imageFilename: "Eisbecher 'Glückskekse'"),
//        Product(name: "Eisbecher 'Schokoglück'🍨 🍫🍀", price: 4.5, imageFilename: "Eisbecher 'Glückskekse'"),
//        Product(name: "Eisbecher 'Glückliche Kirsche'🍨 🍒", price: 4.5, imageFilename: "Eisbecher 'Glückliche Kirsche'"),
//        Product(name: "Eisbecher 'Gemischtes Glück'🍨 🍀", price: 4.0, imageFilename: "Eisbecher 'Glückskekse'"),
//        Product(name: "Becher Kaffee", price: 2.0, imageFilename: "Becher Kaffee"),
//        Product(name: "Heiße Schokolade", price: 2.5, imageFilename: "Heiße Schokolade"),
//        Product(name: "Tee", price: 2.0, imageFilename: "Tee"),
//        Product(name: "Sprudel", price: 1.5, imageFilename: "Sprudel"),
//        Product(name: "Bio-Limo (Flasche)", price: 2.5, imageFilename: "Bio-Limo (Flasche)"),
//        Product(name: "Zitrone-Ingwer-Limo (hausgemacht)", price: 2.0, imageFilename: "logo"),
//        Product(name: "Karotte küsst Ingwersaft (mit Apfelsaft)", price: 3.5, imageFilename: "logo")
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
        return allProducts.filter { $0.isActive }.reduce(0) { sum, product in
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
                        ForEach(Array((products + customProducts).filter { $0.isActive }.enumerated()), id: \.element.id) { index, product in
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
                        ForEach((cafeProducts + customCafeProducts).filter { $0.isActive }) { product in
                            productRow(for: product)
                        }
                    }
                    
                    // Deaktivierte Produkte (nur im Elternmodus sichtbar)
                    if isParent {
                        Section(header: 
                            HStack {
                                Text("Deaktivierte Produkte")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        showDeactivatedProducts.toggle()
                                    }
                                }) {
                                    Image(systemName: showDeactivatedProducts ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.blue)
                                }
                            }
                        ) {
                            if showDeactivatedProducts {
                                let deactivatedProducts = (products + customProducts + cafeProducts + customCafeProducts).filter { !$0.isActive }
                                if deactivatedProducts.isEmpty {
                                    Text("Keine deaktivierten Produkte")
                                        .foregroundColor(.secondary)
                                        .italic()
                                } else {
                                    ForEach(deactivatedProducts) { product in
                                        deactivatedProductRow(for: product)
                                    }
                                }
                            }
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
        .alert("Produkt deaktivieren", isPresented: $showDeactivateAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Deaktivieren", role: .destructive) {
                if let product = productToDeactivate {
                    deactivateProduct(product)
                    productToDeactivate = nil
                }
            }
        } message: {
            if let product = productToDeactivate {
                Text("Möchten Sie das Produkt \"\(product.name)\" wirklich deaktivieren?")
            }
        }
        .fullScreenCover(item: $editingProduct) { product in
            NavigationView {
                EditProductView(product: product) { updatedProduct in
                    updateProduct(updatedProduct)
                }
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

    private func toggleProductStatus(_ product: Product) {
        var updatedProduct = product
        updatedProduct.isActive.toggle()
        updateProduct(updatedProduct)
    }
    
    private func deactivateProduct(_ product: Product) {
        var updatedProduct = product
        updatedProduct.isActive = false
        updateProduct(updatedProduct)
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
                    Button(action: {
                        editingProduct = product
                    }) {
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Deaktivieren Button
                    Button(action: {
                        if product.isActive {
                            productToDeactivate = product
                            showDeactivateAlert = true
                        } else {
                            toggleProductStatus(product)
                        }
                    }) {
                        Image(systemName: product.isActive ? "eye.slash.circle" : "eye.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(product.isActive ? .orange : .green)
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

    private func deactivatedProductRow(for product: Product) -> some View {
        HStack {
            // Bildanzeige: erst Dokumentenverzeichnis prüfen, sonst Asset
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(product.imageFilename)
            if FileManager.default.fileExists(atPath: docURL.path), let uiImage = UIImage(contentsOfFile: docURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.trailing, 15)
                    .opacity(0.5)
            } else {
                Image(product.imageFilename)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.trailing, 15)
                    .opacity(0.5)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f €", product.price))
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            
            // Aktivieren Button
            Button(action: {
                toggleProductStatus(product)
            }) {
                Image(systemName: "eye.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .opacity(0.7)
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
