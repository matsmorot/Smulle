//
//  Deck.swift
//  Smulle
//
//  Created by Mattias Almén on 2016-04-04.
//  Copyright © 2016 pixlig.se. All rights reserved.
//

import Foundation

class Deck {
    
    var deck: [Card]

    init(numDecks: Int) {
        deck = []
        
        let suits = [Card.Suit.S, Card.Suit.H, Card.Suit.D, Card.Suit.C]
        
        for _ in 1...numDecks {
            for i in 1...13 {
                for suit in suits {
                    deck.append(Card(rank: Card.Rank(rawValue: i)!, suit: suit))
                }
            }
        }
    }
    
    func shuffleDeck() {
        deck = deck.shuffle()
    }
    
    func getTopCardFromDeck() -> Card {
        let card = deck.last
        deck.removeAtIndex(deck.indexOf(card!)!)
        return card!
    }
}