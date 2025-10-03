import SwiftUI
import Photos

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
    @State private var categories: [Category] = []
    @State private var allProducts: [Product] = []
    @State private var isAddingProduct = false
    @State private var showAddProductSheet = false
    @State private var newProductName = ""
    @State private var newProductPrice = ""
    @State private var newProductCategoryId: UUID? = nil
    @State private var newProductImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showPhotoPermissionAlert = false
    @State private var selectedCategoryId: UUID? = nil // nil = Kategorien-Übersicht
    @State private var editingCategory: Category? = nil
    @State private var showAddCategorySheet = false
    @State private var newCategoryName = ""
    @State private var newCategoryImage: UIImage? = nil
    @State private var showCategoryImagePicker = false

    var totalSum: Double {
        return allProducts.filter { $0.isActive }.reduce(0) { sum, product in
            sum + (Double(orderSession.productCounts[product.id] ?? 0) * product.price)
        }
    }

    // Hilfsfunktion, um productCounts an die Produktanzahl anzupassen
    private func updateProductCounts() {
        for product in allProducts {
            if orderSession.productCounts[product.id] == nil {
                orderSession.productCounts[product.id] = 0
            }
        }
        // Entferne Zähler für gelöschte Produkte
        let allIDs = Set(allProducts.map { $0.id })
        orderSession.productCounts = orderSession.productCounts.filter { allIDs.contains($0.key) }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "categories") {
            do {
                categories = try JSONDecoder().decode([Category].self, from: data)
            } catch {
                print("Fehler beim Laden der Kategorien: \(error)")
                // Fallback: Standard-Kategorien erstellen
                createDefaultCategories()
            }
        } else {
            // Erste Nutzung: Standard-Kategorien erstellen
            createDefaultCategories()
        }
    }
    
    private func createDefaultCategories() {
        categories = [
            Category(name: "Marmelade + Caramel", imageFilename: "logo"),
            Category(name: "Gewürze", imageFilename: "logo")
        ]
        saveCategories()
    }
    
    private func saveCategories() {
        do {
            let encoded = try JSONEncoder().encode(categories)
            UserDefaults.standard.set(encoded, forKey: "categories")
        } catch {
            print("Fehler beim Speichern der Kategorien: \(error)")
        }
    }
    
    private func loadProducts() {
        if let data = UserDefaults.standard.data(forKey: "allProducts") {
            do {
                allProducts = try JSONDecoder().decode([Product].self, from: data)
            } catch {
                print("Fehler beim Laden der Produkte: \(error)")
            }
        } else {
            // Migration: Alte Produkte in neue Struktur übernehmen
            migrateOldProducts()
        }
    }
    
    private func migrateOldProducts() {
        var migratedProducts: [Product] = []
        
        // Sicherstellen, dass Kategorien geladen sind
        if categories.isEmpty {
            loadCategories()
        }
        
        // Standard-Kategorie-IDs ermitteln
        let sortimentCategory = categories.first(where: { $0.name.contains("Marmelade + Caramel") })
        let cafeCategory = categories.first(where: { $0.name.contains("Gewürze") || $0.name.contains("Café") })
        
        // Migration: customProducts (Sortiment)
        if let data = UserDefaults.standard.data(forKey: "customProducts") {
            do {
                let oldProducts = try JSONDecoder().decode([Product].self, from: data)
                // categoryId hinzufügen - neues Product erstellen mit categoryId
                let updatedProducts = oldProducts.map { product in
                    Product(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        imageFilename: product.imageFilename,
                        isActive: product.isActive,
                        categoryId: sortimentCategory?.id
                    )
                }
                migratedProducts.append(contentsOf: updatedProducts)
                print("✅ Migriert: \(updatedProducts.count) Produkte aus customProducts")
            } catch {
                print("Fehler beim Migrieren von customProducts: \(error)")
            }
        }
        
        // Migration: customCafeProducts (Café)
        if let data = UserDefaults.standard.data(forKey: "customCafeProducts") {
            do {
                let oldProducts = try JSONDecoder().decode([Product].self, from: data)
                // categoryId hinzufügen - neues Product erstellen mit categoryId
                let updatedProducts = oldProducts.map { product in
                    Product(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        imageFilename: product.imageFilename,
                        isActive: product.isActive,
                        categoryId: cafeCategory?.id
                    )
                }
                migratedProducts.append(contentsOf: updatedProducts)
                print("✅ Migriert: \(updatedProducts.count) Produkte aus customCafeProducts")
            } catch {
                print("Fehler beim Migrieren von customCafeProducts: \(error)")
            }
        }
        
        // Migrierte Produkte speichern
        if !migratedProducts.isEmpty {
            allProducts = migratedProducts
            saveProducts()
            print("✅ Migration abgeschlossen: \(migratedProducts.count) Produkte gespeichert")
            
            // Alte Keys löschen (optional, für saubere Migration)
            UserDefaults.standard.removeObject(forKey: "customProducts")
            UserDefaults.standard.removeObject(forKey: "customCafeProducts")
        }
    }
    
    private func saveProducts() {
        do {
            let encoded = try JSONEncoder().encode(allProducts)
            UserDefaults.standard.set(encoded, forKey: "allProducts")
        } catch {
            print("Fehler beim Speichern der Produkte: \(error)")
        }
    }
    
    private func products(for categoryId: UUID) -> [Product] {
        return allProducts.filter { $0.categoryId == categoryId && $0.isActive }
    }

    var body: some View {
        ZStack {
            // Hintergrundfarbe
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if selectedCategoryId == nil {
                    // Kategorien-Übersicht
                    ScrollView {
                        VStack(spacing: 20) {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                ForEach(categories) { category in
                                    categoryCard(category: category) {
                                        selectedCategoryId = category.id
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // "Neue Kategorie" Button im Elternmodus
                            if isParent {
                                Button(action: {
                                    showAddCategorySheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Neue Kategorie")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                } else {
                    // Produktliste für die gewählte Kategorie
                    if let categoryId = selectedCategoryId {
                        List {
                            Section(header: Text(categories.first(where: { $0.id == categoryId })?.name ?? "").font(.headline)) {
                                ForEach(products(for: categoryId)) { product in
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
                                        let deactivatedProducts = allProducts.filter { $0.categoryId == categoryId && !$0.isActive }
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
                    }
                }

                Text("Gesamtsumme: \(String(format: "%.2f", totalSum)) €")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                NavigationLink(destination: CartScreen(path: $path, orderSession: orderSession, allProducts: allProducts)) {
                    Text("➞")
                        .padding()
                        .font(.largeTitle)
                        .bold()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
            .navigationTitle(selectedCategoryId == nil ? "Essen und Trinken" : (categories.first(where: { $0.id == selectedCategoryId })?.name ?? ""))
            .navigationBarBackButtonHidden(selectedCategoryId != nil)
            .toolbar {
                // Custom Back-Button wenn in Kategorie
                if selectedCategoryId != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                selectedCategoryId = nil
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Zurück")
                            }
                        }
                    }
                }
                
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
                loadCategories()
                loadProducts()
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
                    
                    // Kategorie-Picker mit allen verfügbaren Kategorien
                    Picker("Kategorie", selection: $newProductCategoryId) {
                        Text("Bitte wählen").tag(nil as UUID?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    
                    Button(action: {
                        checkPhotoPermissionAndShowPicker()
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
                        guard let price = Double(newProductPrice.replacingOccurrences(of: ",", with: ".")),
                              let image = newProductImage,
                              let categoryId = newProductCategoryId else { return }
                        // Bild speichern
                        let filename = UUID().uuidString + ".jpg"
                        if let data = image.jpegData(compressionQuality: 0.8),
                           let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let url = documentsURL.appendingPathComponent(filename)
                            do {
                                try data.write(to: url)
                            } catch {
                                print("Fehler beim Speichern des Bildes: \(error)")
                            }
                        }
                        // Produktmodell anlegen
                        let newProduct = Product(name: newProductName, price: price, imageFilename: filename, categoryId: categoryId)
                        allProducts.append(newProduct)
                        saveProducts()
                        updateProductCounts()
                        // Formular zurücksetzen
                        newProductName = ""
                        newProductPrice = ""
                        newProductImage = nil
                        newProductCategoryId = nil
                        showAddProductSheet = false
                    }
                    .disabled(newProductName.isEmpty || newProductPrice.isEmpty || newProductImage == nil || newProductCategoryId == nil)
                    Button("Abbrechen") {
                        showAddProductSheet = false
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showAddCategorySheet) {
                VStack(spacing: 20) {
                    Text("Neue Kategorie hinzufügen")
                        .font(.headline)
                    TextField("Kategoriename", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button(action: {
                        showCategoryImagePicker = true
                    }) {
                        if let image = newCategoryImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } else {
                            Text("Bild auswählen")
                                .foregroundColor(.blue)
                        }
                    }
                    .sheet(isPresented: $showCategoryImagePicker) {
                        ImagePicker(selectedImage: $newCategoryImage)
                    }
                    Button("Speichern") {
                        guard let image = newCategoryImage else { return }
                        // Bild speichern
                        let filename = UUID().uuidString + ".jpg"
                        if let data = image.jpegData(compressionQuality: 0.8),
                           let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let url = documentsURL.appendingPathComponent(filename)
                            do {
                                try data.write(to: url)
                            } catch {
                                print("Fehler beim Speichern des Bildes: \(error)")
                            }
                        }
                        // Kategorie anlegen
                        let newCategory = Category(name: newCategoryName, imageFilename: filename)
                        categories.append(newCategory)
                        saveCategories()
                        // Formular zurücksetzen
                        newCategoryName = ""
                        newCategoryImage = nil
                        showAddCategorySheet = false
                    }
                    .disabled(newCategoryName.isEmpty || newCategoryImage == nil)
                    Button("Abbrechen") {
                        showAddCategorySheet = false
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
                EditProductView(product: product, categories: categories) { updatedProduct in
                    updateProduct(updatedProduct)
                }
            }
        }
        .fullScreenCover(item: $editingCategory) { category in
            NavigationView {
                EditCategoryView(category: category) { updatedCategory in
                    updateCategory(updatedCategory)
                }
            }
        }
        .alert("Foto-Zugriff", isPresented: $showPhotoPermissionAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Einstellungen öffnen") {
                openAppSettings()
            }
        } message: {
            Text("Um Produktbilder hinzuzufügen, benötigt die App Zugriff auf Ihre Fotos. Bitte gewähren Sie den Zugriff in den Einstellungen.")
        }
    }

    private func updateProduct(_ updated: Product) {
        if let index = allProducts.firstIndex(where: { $0.id == updated.id }) {
            allProducts[index] = updated
            saveProducts()
        }
    }
    
    private func updateCategory(_ updated: Category) {
        if let index = categories.firstIndex(where: { $0.id == updated.id }) {
            categories[index] = updated
            saveCategories()
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
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let docURL = documentsURL.appendingPathComponent(product.imageFilename)
                if FileManager.default.fileExists(atPath: docURL.path), let uiImage = UIImage(contentsOfFile: docURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.trailing, 15)
                        .accessibilityLabel("Produktbild: \(product.name)")
                } else {
                    Image(product.imageFilename)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.trailing, 15)
                        .accessibilityLabel("Produktbild: \(product.name)")
                }
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
                    .accessibilityLabel("Produkt bearbeiten: \(product.name)")
                    .accessibilityHint("Tippen Sie, um das Produkt zu bearbeiten")
                    
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
                .accessibilityLabel("\(product.name) hinzufügen")
                .accessibilityHint("Tippen Sie, um ein \(product.name) zum Warenkorb hinzuzufügen")
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
                .accessibilityLabel("\(product.name) entfernen")
                .accessibilityHint("Tippen Sie, um ein \(product.name) aus dem Warenkorb zu entfernen")
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
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let docURL = documentsURL.appendingPathComponent(product.imageFilename)
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

    // Funktion wird nicht mehr benötigt, da wir keine separate Sortierung mehr haben
    
    private func deleteProduct(_ product: Product) {
        // Produkt aus der Liste entfernen
        if let index = allProducts.firstIndex(where: { $0.id == product.id }) {
            allProducts.remove(at: index)
            saveProducts()
        }
        
        // Zähler für das gelöschte Produkt entfernen
        orderSession.productCounts.removeValue(forKey: product.id)
        
        // Bilddatei löschen, falls es eine benutzerdefinierte Datei ist
        let filename = product.imageFilename
        if !filename.isEmpty, let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imageURL = documentsURL.appendingPathComponent(filename)
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch {
                print("Fehler beim Löschen der Bilddatei: \(error)")
            }
        }
    }
    
    private func checkPhotoPermissionAndShowPicker() {
        // Prüfe den aktuellen Berechtigungsstatus
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            // Berechtigung bereits erteilt - ImagePicker direkt öffnen
            showImagePicker = true
        case .denied, .restricted:
            // Berechtigung verweigert - Alert zeigen
            showPhotoPermissionAlert = true
        case .notDetermined:
            // Noch nicht gefragt - iOS fragt automatisch
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

    // Kategorie-Kachel
    @ViewBuilder
    private func categoryCard(category: Category, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Bildanzeige: erst Dokumentenverzeichnis prüfen, sonst Asset
                if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let docURL = documentsURL.appendingPathComponent(category.imageFilename)
                    if FileManager.default.fileExists(atPath: docURL.path), let uiImage = UIImage(contentsOfFile: docURL.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .accessibilityHidden(true)
                    } else {
                        Image(category.imageFilename)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .accessibilityHidden(true)
                    }
                } else {
                    Image(category.imageFilename)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .accessibilityHidden(true)
                }
                Text(category.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 2)
            .contextMenu {
                if isParent {
                    Button(action: {
                        editingCategory = category
                    }) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
