import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // App-Version aus Bundle
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .center, spacing: 10) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .accessibilityLabel("Glückskekse Logo")
                        
                        Text("Glückskekse App")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Versionsnummer
                        VStack(spacing: 5) {
                            Text("Version \(appVersion)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Text("Entwickelt von: Zainab Mohamed Basheer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    
                    // Privacy Policy Content
                    Group {
                        sectionHeader("Datenschutzerklärung")
                        
                        Text("Der Schutz Ihrer persönlichen Daten ist uns wichtig. Diese Datenschutzerklärung informiert Sie über die Art, den Umfang und Zweck der Verarbeitung personenbezogener Daten bei der Nutzung unserer Glückskekse App.")
                            .font(.body)
                        
                        sectionHeader("Welche Daten werden verarbeitet?")
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• Fotos (Foto-Bibliothek)")
                                .font(.body)
                            Text("  - Produktbilder für das Glückskekse-Sortiment hinzufügen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 20)
                            
                            Text("• Lokale App-Daten")
                                .font(.body)
                            Text("  - Produktinformationen (Name, Preis, Bild)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 20)
                            Text("  - Bestellungen und Warenkorb-Inhalte")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 20)
                            Text("  - App-Einstellungen und Präferenzen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 20)
                        }
                        
                        sectionHeader("Wichtige Hinweise")
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                Text("Alle Daten werden ausschließlich lokal auf Ihrem Gerät gespeichert")
                                    .font(.body)
                            }
                            
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                Text("Keine Übertragung an externe Server oder Dritte")
                                    .font(.body)
                            }
                            
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                Text("App greift nur auf ausgewählte Fotos zu")
                                    .font(.body)
                            }
                        }
                        
                        sectionHeader("Ihre Rechte")
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• Alle Daten sind in der App sichtbar und bearbeitbar")
                            Text("• Produkte können gelöscht oder deaktiviert werden")
                            Text("• Bei App-Entfernung werden alle Daten gelöscht")
                        }
                        .font(.body)
                        
                        sectionHeader("Kontakt")
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Entwicklerin: Zainab Mohamed Basheer")
                            Text("App: Glückskekse (iOS App Store)")
                            
                            // Link zur Online-Version
                            Link("Vollständige Datenschutzerklärung online lesen", destination: URL(string: "https://gluckskekse-privacy.netlify.app")!)
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .font(.body)
                        
                        // Footer
                        VStack(spacing: 5) {
                            Text("© 2025 Zainab Mohamed Basheer. Alle Rechte vorbehalten.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Diese Datenschutzerklärung wurde zuletzt am 31. August 2025 aktualisiert.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("App-Informationen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.top, 10)
    }
}

#Preview {
    PrivacyPolicyView()
}
