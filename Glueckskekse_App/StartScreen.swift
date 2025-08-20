import SwiftUI

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
