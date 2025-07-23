//
//  ContentView.swift
//  Glueckskekse_App
//
//  Created by Zainab Mohamed Basheer on 21.12.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            StartScreen()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StartScreen: View {
    var body: some View {
        
        ZStack {
            // Hintergrundfarbe
            Color.mint
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                // Eigenes Logo
                Image("logo") // Name des Bildes in den Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                
                // Button
                NavigationLink(destination: ProductListScreen()) {
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

// Produktmodell
struct Product {
    let name: String
    let price: Double
    let image: String
}

struct ProductListScreen: View {
    
    @State private var productCounts: [Int] = Array(repeating: 0, count: 27)
    @State private var products: [Product] = [
        Product(name: "Pfirsichmarmelade", price: 4.0, image: "Pfirsichmarmelade"),
        Product(name: "Aprikosenmarmelade", price: 4.0, image: "Aprikosenmarmelade"),
        Product(name: "Traubengelee", price: 3.5, image: "Traubengelee"),
        Product(name: "Bio-Orangenmarmelade", price: 3.5, image: "Bio-Orangenmarmelade"),
        Product(name: "Bio Chili-Olivenöl", price: 8.0, image: "Bio Chili-Olivenöl"),
        Product(name: "Bio-Bärlauch Rapsöl", price: 5.0, image: "Bio-Bärlauch Rapsöl"),
        Product(name: "Bio Zitronen Rapsöl", price: 5.0, image: "Bio Zitronen Rapsöl"),
        Product(name: "Himbeerbalsamico", price: 7.0, image: "Himbeerbalsamico"),
        Product(name: "Ingwer-Zitronensirup", price: 5.0, image: "logo"),
        Product(name: "Zitronenpfeffer in der Mühle", price: 5.5, image: "Zitronenpfeffer in der Mühle"),
        Product(name: "Chilisalz in der Mühle", price: 4.5, image: "Chilisalz in der Mühle"),
        Product(name: "Butterbrotsalz in der Mühle", price: 4.5, image: "Butterbrotsalz in der Mühle"),
        Product(name: "Zitronen-Rosmarinsalz im Streuer", price: 3.5, image: "Zitronen-Rosmarinsalz im Streuer"),
        Product(name: "Mediterranes Kräutersalz im Streuer", price: 3.5, image: "Mediterranes Kräutersalz im Streuer"),
        Product(name: "Sesamsalz Gomasio", price: 3.5, image: "Sesamsalz Gomasio")
    ]
    @State private var cafeProducts: [Product] = [
        Product(name: "Ein Stück Kuchen", price: 2.5, image: "Ein Stück Kuchen"),
        Product(name: "Eisbecher 'Glückskekse'🍨 🍀🍪", price: 4.5, image: "Eisbecher 'Glückskekse'"),
        Product(name: "Eisbecher 'Schokoglück'🍨 🍫🍀", price: 4.5, image: "Eisbecher 'Glückskekse'"),
        Product(name: "Eisbecher 'Glückliche Kirsche'🍨 🍒", price: 4.5, image: "Eisbecher 'Glückliche Kirsche'"),
        Product(name: "Eisbecher 'Gemischtes Glück'🍨 🍀", price: 4.0, image: "Eisbecher 'Glückskekse'"),
        Product(name: "Becher Kaffee", price: 2.0, image: "Becher Kaffee"),
        Product(name: "Heiße Schokolade", price: 2.5, image: "Heiße Schokolade"),
        Product(name: "Tee", price: 2.0, image: "Tee"),
        Product(name: "Sprudel", price: 1.5, image: "Sprudel"),
        Product(name: "Bio-Limo (Flasche)", price: 2.5, image: "Bio-Limo (Flasche)"),
        Product(name: "Zitrone-Ingwer-Limo (hausgemacht)", price: 2.0, image: "logo"),
        Product(name: "Karotte küsst Ingwersaft (mit Apfelsaft)", price: 3.5, image: "logo")
        
        
    ]
    @State private var isAddingProduct = false

    var totalSum: Double {
        let productTotals = zip(products, productCounts.prefix(products.count))
            .map { $0.0.price * Double($0.1) }
        let productTotal = productTotals.reduce(0, +)

        let cafeTotals = zip(cafeProducts, productCounts.suffix(cafeProducts.count))
            .map { $0.0.price * Double($0.1) }
        let cafeTotal = cafeTotals.reduce(0, +)

        return productTotal + cafeTotal
    }

    var body: some View {
        
        ZStack {
            // Hintergrundfarbe
            Color.mint
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                List {
                    Section(header: Text("Das Glückskekse-Sortiment").font(.headline)) {
                        ForEach(Array(products.enumerated()), id: \.0) { (index, product) in
                            productRow(for: product, countIndex: index)
                        }
                    }
                    
                    Section(header: Text("Glückscafé 🍀☕️").font(.headline)) {
                        ForEach(Array(cafeProducts.enumerated()), id: \.0) { (index, product) in
                            productRow(for: product, countIndex: index + products.count)
                        }
                    }
                }
                
                Text("Gesamtsumme: \(String(format: "%.2f", totalSum)) €")
                    .font(.title)
                    .padding()
                
                NavigationLink(destination: PaymentScreen(totalSum: totalSum)) {
                    Text("Weiter")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Essen und Trinken")
        }
    }

    private func productRow(for product: Product, countIndex: Int) -> some View {
        HStack {
            Image(product.image)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.title3)
                Text(String(format: "%.2f €", product.price))
                    .font(.subheadline)
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: {
                    decrementCount(for: countIndex)
                }) {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())

                Text("\(productCounts[countIndex])")
                    .frame(width: 40, alignment: .center)

                Button(action: {
                    incrementCount(for: countIndex)
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
    }

    private func incrementCount(for index: Int) {
        guard index >= 0 && index < productCounts.count else { return }
        productCounts[index] += 1
    }

    private func decrementCount(for index: Int) {
        guard index >= 0 && index < productCounts.count else { return }
        if productCounts[index] > 0 {
            productCounts[index] -= 1
        }
    }
}

struct PaymentScreen: View {
    let totalSum: Double
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
                    NavigationLink("", destination: ChangeScreen(totalSum: totalSum, paidAmount: totalSelectedSum), isActive: $navigateToNextScreen)
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
                    
                    NavigationLink(destination: ProductListScreen()) {
                        Text("Nächster Kunde")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: StartScreen()) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
