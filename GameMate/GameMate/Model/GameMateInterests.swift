//
//  GameMateInterests.swift
//  GameMate
//
//  Created by Daniel on 1/9/24.
//

import Foundation


enum GameMateInterests: String, CaseIterable {
    case Fortnite, Rocket_League, Rainbow_6_Siege, Call_Of_Duty, FIFA, MineCraft, Need_For_Speed, Fall_Guys
    
    var displayName: String{
        switch self{
        default:
            return self.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

