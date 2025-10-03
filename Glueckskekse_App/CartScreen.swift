import SwiftUI

struct CartScreen: View {
    @Binding var path: NavigationPath
    @ObservedObject var orderSession: OrderSessionViewModel
    let allProducts: [Product]
    
    var cartItems: [(product: Product, count: Int)] {
        return allProducts.compactMap { product in
            if let count = orderSession.productCounts[product.id], count > 0 {
                return (product, count)
            }
            return nil
        }.sorted { $0.product.name < $1.product.name }
    }
    
    var totalSum: Double {
        return cartItems.reduce(0) { sum, item in
            sum + (Double(item.count) * item.product.price)
        }
    }
    
    var body: some View {
        ZStack {
            // Hintergrundfarbe
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if cartItems.isEmpty {
                    // Leerer Warenkorb
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Warenkorb ist leer")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                } else {
                    // Warenkorb-Liste
                    List {
                        ForEach(cartItems, id: \.product.id) { item in
                            cartItemRow(product: item.product, count: item.count)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Gesamtsumme
                Text("Gesamtsumme: \(String(format: "%.2f", totalSum)) €")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.vertical)
                
                // Weiter Button
                NavigationLink(destination: PaymentScreen(totalSum: totalSum, path: $path, orderSession: orderSession)) {
                    Text("➞")
                        .padding()
                        .font(.largeTitle)
                        .bold()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .disabled(cartItems.isEmpty)
                .opacity(cartItems.isEmpty ? 0.5 : 1.0)
            }
        }
    }
    
    @ViewBuilder
    private func cartItemRow(product: Product, count: Int) -> some View {
        HStack(spacing: 15) {
            // Produktbild (gleiche Größe wie in ProductListScreen)
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let docURL = documentsURL.appendingPathComponent(product.imageFilename)
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
            } else {
                Image(product.imageFilename)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.trailing, 15)
            }
            
            // Produktinfo
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(count)x")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", product.price))
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Gesamtpreis für dieses Produkt
            Text(String(format: "%.2f €", Double(count) * product.price))
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
        }
        .padding(.vertical, 8)
    }
}
