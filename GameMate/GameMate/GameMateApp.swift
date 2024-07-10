//
//  GameMateApp.swift
//  GameMate
//
//  Created by Daniel on 12/15/23.
//

import SwiftUI
import Firebase

@main
struct GameMateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
