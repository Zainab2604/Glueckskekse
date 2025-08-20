import SwiftUI

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
