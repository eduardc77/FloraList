//
//  ContentView.swift
//  FloraList
//
//  Created by User on 6/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var coordinator = OrdersCoordinator()
    
    var body: some View {
        OrdersListView()
            .environment(\.ordersCoordinator, coordinator)
    }
}

#Preview {
    ContentView()
}
