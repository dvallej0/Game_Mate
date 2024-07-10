//
//  AppDelegate.swift
//  GameMate
//
//  Created by Daniel on 3/7/24.
//

import Foundation
import UIKit
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        return true
    }
}
