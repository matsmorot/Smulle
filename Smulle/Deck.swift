//
//  Deck.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-04-04.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation
import GameplayKit

class Deck {
    
    var deck: [Card]

    init(numDecks: Int) {
        deck = []
        
        let suits = [Card.Suit.s, Card.Suit.h, Card.Suit.d, Card.Suit.c]
        
        for _ in 1...numDecks {
            for i in 1...13 {
                for suit in suits {
                    deck.append(Card(rank: Card.Rank(rawValue: i)!, suit: suit))
                }
            }
        }
    }
    
    func shuffleDeck() {
        
        deck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: deck) as! [Card]
    }
    
    func getTopCardFromDeck() -> Card {
        let card = deck.last
        deck.remove(at: deck.index(of: card!)!)
        return card!
    }
}
