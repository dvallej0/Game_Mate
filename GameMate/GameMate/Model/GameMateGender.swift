//
//  GameMateGender.swift
//  GameMate
//
//  Created by Daniel on 1/9/24.
//

import Foundation

enum GameMateGender: String, CaseIterable, Identifiable, Codable {
    case man = "man"
    case woman = "woman"
    case unspecified = "unspecified"
    
    var id: Self{self}
    
    static func fromString(str: String) -> GameMateGender {
        switch str.lowercased(){
        case "man": return .man
        case "woman": return .woman
        default: return .unspecified
        }
    }
}
