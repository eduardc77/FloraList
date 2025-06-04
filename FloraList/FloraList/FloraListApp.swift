//
//  FloraListApp.swift
//  FloraList
//
//  Created by User on 6/2/25.
//

import SwiftUI

@main
struct FloraListApp: App {
    @State private var coordinator = OrdersCoordinator()
    @State private var deepLinkManager = DeepLinkManager()
    @State private var errorMessage: String?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coordinator)
                .task {
                    deepLinkManager.setup(with: coordinator)
                }
                .onOpenURL { url in
                    Task {
                        do {
                            try await deepLinkManager.handle(url)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .alert("Deep Link Error",
                       isPresented: .init(
                        get: { errorMessage != nil },
                        set: { if !$0 { errorMessage = nil } }
                       )) {
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
        }
    }
}
