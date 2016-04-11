//
//  Deck.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-03-17.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation
import UIKit

class Card {
    
    var rank: Rank
    var suit: Suit
    var cardImage = UIImage(named: "Back")
    
    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
        cardImage = UIImage(named: "\(self.rank.simpleDescription())_\(self.suit)")
    }
    
    enum Suit {
        case H //Hearts
        case S //Spades
        case D //Diamonds
        case C //Clubs
    }
    
    enum Rank: Int {
        case Ace = 1
        case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
        case Jack, Queen, King
        
        func simpleDescription() -> String {
            switch self {
            case .Ace:
                return "A"
            case .Jack:
                return "J"
            case .Queen:
                return "Q"
            case .King:
                return "K"
            default:
                return String(self.rawValue)
            }
        }
    }
}
