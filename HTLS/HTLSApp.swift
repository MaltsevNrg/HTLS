//
//  HTLSApp.swift
//  HTLS
//
//  Created by Антон Мальцев on 01.12.2025.
//

import SwiftUI

@main
struct HTLSApp: App {
    
    @StateObject private var storageManager = StorageManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(storageManager)
            }
        }
    }
}
