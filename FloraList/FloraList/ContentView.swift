//
//  ContentView.swift
//  FloraList
//
//  Created by User on 6/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        OrdersListView()
    }
}

#Preview {
    ContentView()
        .environment(OrdersCoordinator())
}
