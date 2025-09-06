import SwiftUI

struct StartScreen: View {
    @Binding var path: NavigationPath

    @AppStorage("isParent") var isParent: Bool = false
    @State private var parentCodeInput = ""
    // Eltern-Code wird sicher aus UserDefaults geladen
    var parentCode: String {
        UserDefaults.standard.string(forKey: "parentCode") ?? "2839"
    }
    
    @State private var showPrivacyPolicy = false
    @State private var showPhotoPermissionAlert = false

    var body: some View {
        ZStack {
            Color.mint.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .accessibilityLabel("Glückskekse Logo")

                // Eltern-Login-Bereich
                VStack(spacing: 10) {
                    Text("Elternbereich").bold().foregroundColor(.black)
                    SecureField("Eltern-Code", text: $parentCodeInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                        .accessibilityLabel("Eltern-Code Eingabe")
                        .accessibilityHint("Geben Sie den vierstelligen Eltern-Code ein")
                    Button("Einloggen") {
                        if parentCodeInput == parentCode {
                            isParent = true
                            parentCodeInput = ""
                        }
                    }
                }

                if isParent {
                    Text("👨‍👩‍👧 Elternrechte aktiv").foregroundColor(.black)
                }
                
                // Einwilligung für Foto-Zugriff
                VStack(spacing: 10) {
                    Text("📸 Foto-Zugriff")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Diese App benötigt Zugriff auf Ihre Fotos, um Produktbilder hinzuzufügen. Alle Bilder werden nur lokal auf Ihrem Gerät gespeichert.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        showPhotoPermissionAlert = true
                    }) {
                        Text("Einwilligung erteilen")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Einwilligung für Foto-Zugriff erteilen")
                    .accessibilityHint("Tippen Sie, um der App Zugriff auf Ihre Fotos zu gewähren")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                    
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
            
            // Info-Button in der rechten unteren Ecke
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showPrivacyPolicy = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .accessibilityLabel("App-Informationen und Datenschutz")
                    .accessibilityHint("Tippen Sie für Informationen über die App und die Datenschutzerklärung")
                }
                .padding(.bottom, 20)
                .padding(.trailing, 20)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
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
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}
