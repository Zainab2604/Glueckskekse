//
//  ContentView.swift
//  Glueckskekse_App
//
//  Created by Zainab Mohamed Basheer on 21.12.24.
//

import SwiftUI

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
