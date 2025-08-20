import SwiftUI

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
